import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/io_client.dart';
import 'package:linkify/linkify.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/adaptive.dart';
import '../core/scroll_control.dart';
import '../core/string_utils.dart';
import '../database/database.dart';
import '../database/models.dart';
import '../group/group_controller.dart';
import '../group/group_options.dart';
import '../home/filter_controller.dart';
import '../home/home_controller.dart';
import '../nntp/nntp_service.dart';
import '../settings/settings.dart';
import 'post_export.dart';
import 'thread_controller.dart';

final selectedPostProvider = StateProvider<String>((ref) {
  ref.watch(selectedGroupProvider);
  ref.watch(selectedThreadProvider);
  return '';
});

final postsLoader = Provider<PostsLoader>(PostsLoader.new);

final postsProvider = StateProvider<List<PostData>>((ref) => []);

final postChangeProvider =
    ChangeNotifierProvider.autoDispose.family<ChangeNotifier, String>(
  (ref, id) => ChangeNotifier(),
);

final postImagesProvider =
    NotifierProvider<PostImagesNotifier, List<PostImage>>(
        PostImagesNotifier.new);

final postListScrollProvider = Provider<ScrollControl>((_) => ScrollControl());

class PostData {
  PostData(this.post, this.state, this.options);
  Post post;
  PostState state;
  PostBody? body;
  PostData? parent;
  List<PostData> children = [];
  GroupOptions options;
  var index = -1;
  String userAgent = '';
  bool html = false;
}

enum PostLoadState { waiting, loading, toOutside, loaded, error }

class PostState {
  var load = PostLoadState.waiting;
  var isNew = false;
  var isRead = false;
  var showQuote = false;
  var inside = false;
  var reply = <PostData>[];
  var selectable = false;
  var error = false;
  var visible = false;
}

class PostBody {
  String text = '';
  String? html;
  var links = <PostLinkPreview>[];
  var images = <PostImage>[];
  var files = <PostFile>[];
}

class PostLinkPreview {
  ImageProvider? image;
  var enabled = false;
  var ready = false;
  var url = '';
  var title = '';
  var description = '';
}

class PostImage {
  late ImageProvider image;
  Uint8List? data;
  var filename = '';
  String? url;
  var id = 0;
  var post = 0;
  var index = 0;
}

class PostFile {
  Uint8List? data;
  var filename = '';
}

class PostImagesNotifier extends Notifier<List<PostImage>> {
  @override
  List<PostImage> build() {
    return [];
  }

  void addImage(PostImage image, int post, int index) {
    var imageList = [...state];
    imageList.add(image
      ..id = imageList.length
      ..post = post
      ..index = index);
    imageList.sort((a, b) {
      var cmp = a.post.compareTo(b.post);
      return cmp != 0 ? cmp : a.index.compareTo(b.index);
    });
    state = imageList;
  }

  void addList(List<PostImage> images, int post) {
    var imageList = [...state];
    for (var (index, image) in images.indexed) {
      imageList.add(image
        ..id = imageList.length
        ..post = post
        ..index = index);
    }
    imageList.sort((a, b) {
      var cmp = a.post.compareTo(b.post);
      return cmp != 0 ? cmp : a.index.compareTo(b.index);
    });
    state = imageList;
  }
}

class PostsLoader {
  final Ref ref;

  final _posts = <PostData>[];
  final _loadedLinkPreview = <String, PostLinkPreview>{};

  StreamSubscription? _subscription;
  ValueNotifier<bool>? _cancel;

  final progress = ValueNotifier(0);
  final unread = ValueNotifier(0);
  final screenshot = ScreenshotController();

  PostsLoader(this.ref) {
    var scrollControl = ref.read(postListScrollProvider);
    ref.listen(selectedThreadProvider, (_, threadId) {
      scrollControl.jumpTop();
      _subscription?.cancel();
      _subscription = AppDatabase.get.postChangeStream(threadId).listen(
        (_) async {
          scrollControl.saveLast((i) => getId(i));
          await getPosts(threadId);

          _cancel?.value = true;
          _cancel = ValueNotifier(false);
          _loadPostBody(_cancel!);
        },
      );
    }, fireImmediately: true);
  }

  Future<void> getPosts(String threadId) async {
    _posts.clear();
    ref.invalidate(postImagesProvider);

    var postList = await AppDatabase.get.postList(threadId);
    if (postList.isNotEmpty) {
      var group = await AppDatabase.get.getGroup(postList.first.groupId);
      if (group == null) throw Exception('Cannot load group data.');

      var map = <String, PostData>{};
      var options = GroupOptions(group);

      for (var p in postList) {
        map[p.messageId] = _createData(p, options);
      }
      for (var d in map.values) {
        for (var r in d.post.references.reversed) {
          if (map.containsKey(r)) {
            map[r]!.children
              ..add(d)
              ..sort((a, b) => a.post.number.compareTo(b.post.number));
            d.parent = map[r]!;
            break;
          }
        }
      }

      if (Settings.sortMode.val == SortMode.order) {
        _posts.addAll(map.values
            .sorted((a, b) => a.post.number.compareTo(b.post.number))
            .mapIndexed((i, p) => p..index = i));
      }

      if (Settings.sortMode.val == SortMode.hierarchy) {
        var root =
            map.values.firstWhereOrNull((d) => d.post.references.isEmpty);
        if (root != null) {
          _traverseTree(root, (d) => _posts.add(d..index = _posts.length));
        } else {
          _posts.addAll(postList
              .mapIndexed((i, p) => _createData(p, options)..index = i));
        }
      }

      ref.read(titleProvider.notifier).state =
          _posts.firstOrNull?.post.subject.noLinebreak ?? '';
    }
    progress.value = 0;
    unread.value = _posts.whereNot((p) => p.post.isRead).length;
    ref.read(postsProvider.notifier).state = [..._posts];
  }

  PostData? getPostData(String postId) {
    return _posts.firstWhereOrNull((p) => p.post.messageId == postId);
  }

  String getId(int index) {
    return index >= _posts.length ? '' : _posts[index].post.messageId;
  }

  int getIndex(String id) {
    return getPostData(id)?.index ?? 0;
  }

  Iterable<PostData> getAllOrSelected() {
    var filters = ref.read(filterProvider);
    var selected = ref.read(selectedPostProvider);
    return _posts
        .where((e) => selected == '' || e.post.messageId == selected)
        .where((e) => selected != '' || filters.filterPost(e));
  }

  PostData? getPrevious(PostData data) {
    if (data.index >= _posts.length) return null;
    var filters = ref.read(filterProvider);
    var i = data.index - 1;
    while (i >= 0) {
      data = _posts[i];
      if (filters.filterPost(data) && !data.state.inside) return data;
      i--;
    }
    return null;
  }

  PostData? getQuoteData(PostData data) {
    var previous = getPrevious(data);
    return switch (Settings.showQuote.val) {
      ShowQuote.always => data.parent,
      ShowQuote.never => null,
      _ => previous == data.parent ? null : data.parent,
    };
  }

  void select(PostData? data) {
    var selected = ref.read(selectedPostProvider);
    var postId = data?.post.messageId ?? '';
    ref.read(selectedPostProvider.notifier).state =
        selected == postId ? '' : postId;
    invalidatePost(data);
    var old = getPostData(selected);
    if (old != null) invalidatePost(old);
  }

  void invalidatePost(PostData? data) {
    if (data == null) return;
    var filters = ref.read(filterProvider);
    var blocked = Settings.blockSenders.val.contains(data.parent?.post.from);
    if (data.state.inside && !blocked && filters.filterPost(data.parent!)) {
      data = data.parent!;
    }
    ref.invalidate(postChangeProvider(data.post.messageId));
  }

  void toggleSelectable(PostData data) {
    data.state.selectable = !data.state.selectable;
    invalidatePost(data);
  }

  void export() {
    var selected = ref.read(selectedPostProvider) != '';
    var posts = getAllOrSelected().map((e) => e
      ..state.showQuote =
          selected ? e.parent != null : getQuoteData(e) != null);
    PostExport.save(posts);
  }

  void share() {
    var output = StringBuffer();
    for (var p in getAllOrSelected()) {
      var text = p.body?.text ?? '';
      if (p.body?.images.isNotEmpty ?? false) {
        if (text.isNotEmpty) text += ' ';
        var images = p.body?.images.map((e) => e.filename).join(', ') ?? '';
        text += '[image: $images]';
      }
      if (p.body?.files.isNotEmpty ?? false) {
        if (text.isNotEmpty) text += ' ';
        var files = p.body?.files.map((e) => e.filename).join(', ') ?? '';
        text += '[file: $files]';
      }
      output.writeln('${p.post.from.sender}: $text');
    }
    Share.share(output.toString(), subject: _posts[0].post.subject);
  }

  Future<void> capture(double pixelRatio) async {
    var filename = '${_posts[0].post.subject}.png';
    var data = await screenshot.capture(pixelRatio: pixelRatio);
    if (data != null) {
      Adaptive.saveBinary(data, 'Capture to image', filename, 'image/png');
    }
  }

  void setVisible(PostData data, VisibilityInfo info) {
    data.state.visible = info.visibleFraction >= 0.9 || info.size.height > 100;
    if (data.state.visible) markRead(data);
  }

  Future<void> markRead(PostData data) async {
    if (data.state.error) return;
    if (data.post.isRead) return;
    if (data.body == null) return;

    data.post.isRead = true;
    unread.value--;
    await AppDatabase.get
        .markThreadRead(data.post.threadId, data.post.messageId);
    await AppDatabase.get.updatePost(data.post);
    await ref.read(threadsLoader).markThreadRead(data.post.threadId);
  }

  void nextUnread() {
    var data = _posts.firstWhereOrNull((p) =>
        !p.post.isRead ||
        p.children.any((p) => p.state.inside && !p.post.isRead));
    if (data != null) ref.read(postListScrollProvider).scrollTo(data.index);
  }

  void retry() {
    _cancel?.value = true;
    _cancel = ValueNotifier(false);
    _downloadPostBody(_cancel!);
  }

  void _loadPostBody(ValueNotifier<bool> cancel) async {
    var posts = [..._posts];
    for (var p in posts) {
      _decompressContent(p);
      if (p.body != null) {
        p.state.load = PostLoadState.loaded;
        progress.value++;
        ref.read(postImagesProvider.notifier).addList(p.body!.images, p.index);
        ref.invalidate(postChangeProvider(p.post.messageId));
        if (!p.state.inside) _getLinkPreview(p, cancel);
      }
    }

    if (Settings.shortReply.val) {
      for (var p in posts) {
        for (var child in p.children) {
          if (child.children.isEmpty) {
            p.state.reply.add(child);
            child.state.inside = true;
            _checkInside(child);
          }
        }
      }
    }

    _downloadPostBody(cancel);
  }

  void _downloadPostBody(ValueNotifier<bool> cancel) async {
    var posts = [..._posts];
    for (var data in posts) {
      await _loadBody(data, cancel);
      if (!data.state.inside) _getLinkPreview(data, cancel);
      if (cancel.value) return;

      for (var child in data.state.reply) {
        await _loadBody(child, cancel);
        if (cancel.value) return;
      }
    }
  }

  void _traverseTree(PostData data, Function(PostData) action) {
    action(data);
    for (var d in data.children) {
      _traverseTree(d, action);
    }
  }

  PostData _createData(Post post, GroupOptions options) {
    var d = PostData(
      post,
      PostState()
        ..isNew = post.isNew
        ..isRead = post.isRead,
      options,
    );
    return d;
  }

  void _checkInside(PostData data) {
    if (data.body == null) return;
    if (data.parent == null) return;
    if (data.children.isNotEmpty) return;
    if (!Settings.shortReply.val) return;
    data.state.inside = data.body!.images.isEmpty &&
        data.body!.files.isEmpty &&
        (data.body!.text.length <= Settings.shortReplySize.val);
  }

  Future<void> _loadBody(PostData data, ValueNotifier<bool> cancel) async {
    if (cancel.value) return;
    if (data.state.error) return;

    if (data.state.load == PostLoadState.toOutside) {
      data.state.load = PostLoadState.loaded;
      ref.invalidate(postChangeProvider(data.post.messageId));
      return;
    }
    if (data.state.load != PostLoadState.waiting) return;
    data.state.load = PostLoadState.loading;
    ref.invalidate(postChangeProvider(data.post.messageId));
    var inside = data.state.inside;

    await _loadBodyData(data);
    if (data.state.visible) markRead(data);

    if (data.state.load != PostLoadState.error) {
      ref
          .read(postImagesProvider.notifier)
          .addList(data.body!.images, data.index);
      progress.value++;

      _checkInside(data);
      if (inside && !data.state.inside) {
        data.state.load = PostLoadState.toOutside;
      } else {
        data.state.load = PostLoadState.loaded;
      }
    }
    ref.invalidate(postChangeProvider(data.post.messageId));
    if (inside) {
      ref.invalidate(postChangeProvider(data.parent!.post.messageId));
    }
  }

  Future<void> _loadBodyData(PostData data) async {
    try {
      var nntp = await NNTPService.fromGroup(data.post.groupId);
      var body = await nntp?.downloadBody(data.post);
      data.body = _getContent(data, body ?? '');
    } catch (e) {
      data.state.error = true;
      data.body = PostBody()..text = e.toString();
      data.state.load = PostLoadState.error;
      _cancel?.value = true;
    }
  }

  void _decompressContent(PostData data) {
    if (data.post.source == null) return;
    var u = Uint8List.fromList(data.post.source!);
    String text;
    if (kIsWeb) {
      text = latin1.decode(u);
    } else {
      text = latin1.decode(gzip.decode(u));
    }
    data.body = _getContent(data, text);
  }

  Future<void> _getLinkPreview(
      PostData data, ValueNotifier<bool> cancel) async {
    if (cancel.value) return;

    for (var link in data.body?.links ?? <PostLinkPreview>[]) {
      if (!link.enabled || link.ready) continue;

      var client = HttpClient();
      client.userAgent = 'TelegramBot (like TwitterBot)';
      var http = IOClient(client);
      try {
        var uri = Uri.parse(link.url);
        var resp = await http.get(uri);
        var doc = MetadataFetch.responseToDocument(resp);
        var meta = MetadataParser.parse(doc);

        if ((meta.title ?? '').isEmpty &&
            (meta.description ?? '').isEmpty &&
            (meta.image ?? '').isEmpty) {
          link.enabled = false;
        } else {
          link
            ..title = meta.title ?? ''
            ..description = meta.description ?? '';
          if ((meta.image ?? '').isNotEmpty) {
            resp = await http.get(Uri.parse(meta.image!));
            link.image = MemoryImage(resp.bodyBytes);
          }
          if (link.description.isEmpty || link.description == link.title) {
            link.description = meta.url ?? link.url;
          }
          link.ready = true;
        }
        ref.invalidate(postChangeProvider(data.post.messageId));
      } catch (e) {
        link.enabled = false;
        ref.invalidate(postChangeProvider(data.post.messageId));
      } finally {
        http.close();
        client.close();
      }
      _loadedLinkPreview[link.url] = link;
    }
  }

  PostBody _getContent(PostData data, String text) {
    var mime = MimeMessage.parseFromText(text);
    var charset = data.options.charset.val;

    if (mime.allPartsFlat.length == 1 &&
        (mime.mimeData?.contentType?.charset ?? '') == '') {
      mime.setHeader('Content-Type', 'text/plain; charset="$charset"');
    }
    text = mime.decodeTextPlainPart() ??
        mime.decodeTextHtmlPart()?.stripHtmlTag ??
        '';
    text = text.replaceAll('\r\n', '\n');

    var html = mime.decodeTextHtmlPart();
    html = html?.replaceAll(
        RegExp(r'(?<!<br>\s*)<br>\s+<br>(?!\s*<br>)', caseSensitive: false),
        '<p><br></p>');

    data.userAgent = mime.decodeHeaderValue('User-Agent') ??
        mime.decodeHeaderValue('X-Newsreader') ??
        '';

    var images = <PostImage>[];
    var files = <PostFile>[];
    bool isImage(MimePart p) {
      if (p.mediaType.isImage) return true;
      if (p.mediaType.sub != MediaSubtype.applicationOctetStream) return false;
      var filename = p.decodeFileName();
      if (filename == null) return false;
      return filename.contains('.') &&
          ['webp', 'png', 'jpg', 'jpeg', 'jfif', 'gif', 'bmp']
              .contains(filename.split('.').last.toLowerCase());
    }

    try {
      images = mime.allPartsFlat
          // .where((e) => e.getHeaderContentDisposition() != null)
          .where(isImage)
          .map((e) => PostImage()
            ..data = e.decodeContentBinary()
            ..filename = e.decodeFileName() ?? 'image.jpg')
          .where((e) => e.data != null)
          .map((e) => e..image = MemoryImage(e.data!))
          .toList();
      files = mime.allPartsFlat
          // .where((e) => e.getHeaderContentDisposition() != null)
          .where((e) => !e.mediaType.isMultipart)
          .where((e) => e.mediaType.sub != MediaSubtype.textPlain)
          .where((e) => e.mediaType.sub != MediaSubtype.textHtml)
          .whereNot(isImage)
          .where((e) => e.decodeFileName() != null)
          .map((e) => PostFile()
            ..data = e.decodeContentBinary()
            ..filename = e.decodeFileName()!)
          .where((e) => e.data != null)
          .toList();

      do {
        var (data, filename) = _getUuencodeData(text);
        if (data == null) break;
        text = text.stripUuencode;
        if (filename.contains('.') &&
            ['webp', 'png', 'jpg', 'jpeg', 'jfif', 'gif', 'bmp']
                .contains(filename.split('.').last.toLowerCase())) {
          images.add(PostImage()
            ..data = data
            ..filename = filename
            ..image = MemoryImage(data));
        } else {
          files.add(PostFile()
            ..data = data
            ..filename = filename);
        }
      } while (true);
    } catch (e) {
      text += '\n\nDecode attachment failed. ${e.toString()}';
    } finally {
      while (text.containsUuencode) {
        text = text.stripUuencode;
      }
    }

    if (Settings.stripText.val) {
      text = text.replaceAll('\u200b', '');
      text = text.stripSameContent(data.parent?.body?.text ?? '');
      text = text.stripSignature;
      text = text.stripQuote;
      text = text.stripMultiEmptyLine;
      text = text.stripUnicodeEmojiModifier;
      text = text.stripCustomPattern;
      text = text.trim();
    }
    if (text == '' && images.isEmpty) text = data.post.subject;

    var links = linkify(text, options: const LinkifyOptions(humanize: false))
        .whereType<UrlElement>()
        .map((e) => e.url)
        .where((e) => const ['http', 'https'].contains(Uri.parse(e).scheme))
        .toSet()
        .map((e) => _loadedLinkPreview[e] ??= PostLinkPreview()
          ..enabled = kIsWeb ? false : Settings.linkPreview.val
          ..url = e)
        .toList();

    return PostBody()
      ..text = text
      ..html = html
      ..links = links
      ..images = images
      ..files = files;
  }

  (Uint8List?, String) _getUuencodeData(String text) {
    var re = RegExp(r'\nbegin\s[0-7]{3}\s(.+)\n');
    var match = re.firstMatch(text);
    if (match == null) return (null, '');
    var start = match.start;
    var filename = 'image.jpg';
    if (match.groupCount > 0) filename = match.group(1)!;
    if (start == -1) return (null, '');
    // var end = text.indexOf(RegExp(r'\n(`|\s)?\nend(\n)?'), start);
    // if (end == -1) return (null, '');
    var stop = text.indexOf(RegExp(r'\nend\s?(\n|$)'), start);
    if (stop == -1) stop = text.length;

    const b64 =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    var data = StringBuffer();
    var end = text.indexOf("\n", start + 10);

    while (end >= 0) {
      start = end + 1;
      if (start >= stop) break;
      var next = text.indexOf("\n", start);
      end = (text.codeUnitAt(start++) - 32) & 0x3f;
      if (end == 0) break;
      while (end > 0) {
        data.write(b64[_getUuencodeCodeAt(text, start++, next)]);
        data.write(b64[_getUuencodeCodeAt(text, start++, next)]);
        if (end == 1) {
          data.write('==');
        } else {
          data.write(b64[_getUuencodeCodeAt(text, start++, next)]);
          if (end == 2) {
            data.write('=');
          } else {
            data.write(b64[_getUuencodeCodeAt(text, start++, next)]);
          }
        }
        end -= 3;
      }
      end = next;
    }
    return (base64Decode(data.toString()), filename);
  }

  int _getUuencodeCodeAt(String text, int index, int end) {
    if (index >= end) return 0;
    return (text.codeUnitAt(index) - 32) & 0x3f;
  }
}
