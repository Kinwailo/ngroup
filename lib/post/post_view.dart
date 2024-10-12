import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linkify/linkify.dart';
import 'package:ngroup/conv/conv.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';

import '../core/adaptive.dart';
import '../core/block_painter.dart';
import '../core/html_simplifier.dart';
import '../core/string_utils.dart';
import '../core/datetime_utils.dart';
import '../core/theme.dart';
import '../home/filter_controller.dart';
import '../home/home_controller.dart';
import '../widgets/remote_image.dart';
import 'capture_view.dart';
import 'gallery_view.dart';
import '../settings/settings.dart';
import 'post_controller.dart';
import 'thread_controller.dart';

class PostView extends HookConsumerWidget {
  const PostView({super.key});

  static var path = 'posts';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;

    var posts = ref.watch(postsProvider);
    var loader = ref.read(postsLoader);

    final scrollControl = ref.read(postListScrollProvider);
    ref.listen(postsProvider,
        (_, __) => scrollControl.jumpLastId((id) => loader.getIndex(id)));
    useEffect(() {
      ref.read(rightNavigator).onPathChanged = (old, now) {
        if (old == PostView.path) {
          scrollControl.saveLast((i) => loader.getId(i));
        }
      };
      return null;
      // return () => scrollControl.saveLast((i) => loader.getId(i));
    });

    useAutomaticKeepAlive();

    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: () => ref.read(postsLoader).select(null),
        child: Stack(
          children: [
            const PostProgress(),
            Padding(
              padding: const EdgeInsets.all(4),
              child: CustomMaterialIndicator(
                displacement: 20,
                backgroundColor: Colors.transparent,
                onRefresh: () async {
                  Future.delayed(
                      Durations.short4, () => ref.read(threadsLoader).next());
                  return Future.value();
                },
                indicatorBuilder: (context, controller) {
                  return Opacity(
                    opacity: (controller.value / 0.5).clamp(0.0, 1.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: colorScheme.outline.withOpacity(0.4))),
                          child: SizedBox.square(
                              dimension: 40,
                              child: RotatedBox(
                                  quarterTurns:
                                      Settings.nextThreadDirection.val ==
                                              NextDirection.newer
                                          ? 0
                                          : 2,
                                  child: const Icon(Icons.double_arrow))),
                        ),
                        OverflowBox(
                          maxWidth: constraints.maxWidth * 0.8,
                          maxHeight: 128,
                          child: const Align(
                            alignment: Alignment.bottomCenter,
                            child: PostNext(true),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: ScrollablePositionedList.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  initialScrollIndex: loader.getIndex(scrollControl.lastId),
                  initialAlignment: scrollControl.lastOffset,
                  itemScrollController: scrollControl.itemScrollController,
                  itemPositionsListener: scrollControl.itemPositionsListener,
                  itemCount: posts.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= posts.length) {
                      return const SizedBox(height: 80);
                    }
                    var post = posts[index];
                    return PostTile(key: ValueKey(post.post.messageId), post);
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: Adaptive.useTwoPaneUI
                    ? EdgeInsets.only(
                        right: Adaptive.isDesktop ? 100 : 130, bottom: 48)
                    : const EdgeInsets.only(right: 74, bottom: 52),
                child: Visibility(
                    visible: Settings.nextTitle.val,
                    child: const PostNext(false)),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class PostProgress extends HookConsumerWidget {
  const PostProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var posts = ref.watch(postsProvider);
    var loader = ref.read(postsLoader);
    useListenable(loader.progress);
    return AnimatedOpacity(
      opacity: posts.isEmpty ||
              loader.progress.value == 0 ||
              loader.progress.value == posts.length
          ? 0
          : 1,
      duration: Durations.long1,
      child: TweenAnimationBuilder<double>(
          key: ValueKey(posts.firstOrNull?.post.threadId),
          duration: Durations.short4,
          tween: Tween<double>(
            begin: 0,
            end: posts.isEmpty ? 0 : loader.progress.value / posts.length,
          ),
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              borderRadius: BorderRadius.circular(4),
            );
          }),
    );
  }
}

class PostNext extends HookConsumerWidget {
  const PostNext(this.showNoMore, {super.key});

  final bool showNoMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var theme = Theme.of(context);

    ref.watch(selectedThreadProvider);
    var loader = ref.read(postsLoader);
    var next = ref.read(threadsLoader).getNext();
    var text = next == null ? 'No more' : next.thread.subject.convUseSetting;

    useListenable(loader.unread);
    useListenable(Settings.nextThreadDirection);

    return AnimatedSwitcher(
      duration: Durations.short4,
      child: !showNoMore && (next == null || loader.unread.value > 0)
          ? const SizedBox.shrink()
          : Card(
              key: ValueKey(text),
              elevation: 2,
              color: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ),
    );
  }
}

class PostTile extends HookConsumerWidget {
  const PostTile(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var postId = data.post.messageId;
    ref.watch(postChangeProvider(postId));
    var selected = ref.read(selectedPostProvider) == postId;
    var state = data.state;
    var blocked = Settings.blockSenders.val.contains(data.parent?.post.from);
    var blocked2 = Settings.blockSenders.val.contains(data.post.from);

    var filters = ref.read(filterProvider);
    var hide = (state.inside &&
            !blocked &&
            !blocked2 &&
            filters.filterPost(data.parent!) &&
            !(selected && CaptureView.of(context))) ||
        state.load == PostLoadState.waiting ||
        !filters.filterPost(data);

    useListenable(Listenable.merge(
        [filters, ...filters.filters.where((e) => e.useInPost)]));
    useListenable(Settings.blockSenders);

    return AnimatedCrossFade(
      duration: Durations.short4,
      sizeCurve: Curves.easeOutCirc,
      crossFadeState:
          hide ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: const SizedBox.shrink(),
      secondChild: Settings.blockSenders.val.contains(data.post.from)
          ? PostBlockedTile(
              key: ValueKey('${data.post.messageId} Blocked'), data)
          : PostNormalTile(
              key: ValueKey('${data.post.messageId} Normal'), data),
    );
  }
}

List<Widget> _tileHeader(
    BuildContext context, ColorScheme colorScheme, PostData data) {
  return [
    Text.rich(
      TextSpan(
        children: [
          WidgetSpan(child: PostState(data)),
          _senderTextSpan(context, data),
          const WidgetSpan(child: SizedBox(width: 4)),
          TextSpan(
            text: data.post.dateTime.toLocal().string,
            style: TextStyle(color: colorScheme.onTertiaryContainer),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textScaler: TextScaler.linear(Settings.contentScale.val / 100),
    ),
    const Spacer(),
    Text.rich(
      TextSpan(text: '#${data.index + 1}'),
      textScaler: TextScaler.linear(Settings.contentScale.val / 100),
    ),
  ];
}

class PostBlockedTile extends HookConsumerWidget {
  const PostBlockedTile(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: CustomPaint(
          painter: BlockPainter(colorScheme.surfaceTint, Colors.yellow),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
            child: Opacity(
              opacity: 0.8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _tileHeader(context, colorScheme, data),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PostNormalTile extends HookConsumerWidget {
  const PostNormalTile(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var selected = ref.read(selectedPostProvider) == data.post.messageId;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: () => ref.read(postsLoader).select(data),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
                style: selected && !CaptureView.of(context)
                    ? BorderStyle.solid
                    : BorderStyle.none,
                color: colorScheme.outline,
                width: 2,
                strokeAlign: BorderSide.strokeAlignCenter),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: colorScheme.tertiaryContainer,
                elevation: 1,
                margin: const EdgeInsets.all(0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _tileHeader(context, colorScheme, data),
                  ),
                ),
              ),
              Card(
                elevation: 1,
                margin: const EdgeInsets.all(0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: PostBody(data),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostState extends ConsumerWidget {
  const PostState(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context).extension<NGroupTheme>()!;
    var state = data.state;
    var blocked = Settings.blockSenders.val.contains(data.post.from);

    Widget widget = const SizedBox.shrink();
    if (CaptureView.of(context) && !blocked) return widget;

    if (blocked) {
      widget = Padding(
        padding: const EdgeInsets.only(right: 4, top: 2, bottom: 1),
        child: Icon(Icons.block,
            size: 16,
            color: state.isNew
                ? theme.isNew!
                : state.isRead
                    ? theme.isRead!
                    : theme.sender!),
      );
    } else if (state.isRead) {
      widget = Padding(
        padding: const EdgeInsets.only(right: 4, top: 2, bottom: 1),
        child: Icon(Icons.check,
            size: 16, color: state.isNew ? theme.isNew! : theme.isRead!),
      );
    } else if (state.isNew) {
      widget = Padding(
        padding: const EdgeInsets.only(right: 4, top: 2, bottom: 3),
        child: Icon(Icons.circle, size: 12, color: theme.isNew!),
      );
    }
    return widget;
  }
}

TextSpan _senderTextSpan(BuildContext context, PostData data,
    {double opacity = 1.0}) {
  var theme = Theme.of(context).extension<NGroupTheme>()!;
  return TextSpan(
    text: '${data.post.from.sender.convUseSetting} ',
    style: TextStyle(color: theme.sender?.withOpacity(opacity)),
    recognizer: LongPressGestureRecognizer()
      ..onLongPress = () {
        if (Settings.blockSenders.val.contains(data.post.from)) {
          Settings.blockSenders.val.remove(data.post.from);
        } else {
          Settings.blockSenders.val.add(data.post.from);
        }
        Settings.blockSenders.update();
      },
  );
}

class NetworkImageFactory extends WidgetFactory with UrlLauncherFactory {
  NetworkImageFactory(this.post, this.loader);

  final int post;
  final urls = <String>{};
  final PostsLoader loader;

  @override
  Widget? buildImage(BuildTree tree, ImageMetadata data) {
    var src = data.sources.firstOrNull;
    if (src == null) {
      return null;
    }
    var url = src.url;
    if (!url.startsWith(RegExp('https?://'))) {
      return super.buildImageWidget(tree, src);
    }
    if (!kIsWeb) {
      Future(() => loader.addLinkPreview(url, post, urls.length));
      urls.add(url);
    }
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: Settings.linkedImageMaxWidth.val.toDouble()),
      child: RemoteImage(
        url,
        post,
        width: src.width,
        height: src.height,
      ),
    );
  }
}

class PostBody extends HookConsumerWidget {
  const PostBody(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;

    var body = data.body;
    var state = data.state;
    var filters = ref.read(filterProvider);
    var blocked = Settings.blockSenders.val.contains(data.parent?.post.from);
    var loader = ref.read(postsLoader);
    var quote = loader.getQuoteData(data);
    if ((blocked && Settings.showQuote.val != ShowQuote.never) ||
        (CaptureView.of(context) && ref.read(selectedPostProvider) != '')) {
      quote = data.parent;
    }

    final htmlState = useState(data.htmlState);
    var showHtml = htmlState.value == PostHtmlState.html ||
        htmlState.value == PostHtmlState.simplify;
    var textStyle =
        const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold);
    onTap(PostHtmlState v) => TapGestureRecognizer()
      ..onTap = () {
        data.htmlState = htmlState.value = v;
        loader.rebuildLinkPreview(data);
      };

    var quoteBody = [
      if (quote != null) PostQuote(quote),
      if (body?.html != null &&
          Settings.htmlMode.val == PostHtmlState.showOptions)
        Text.rich(
          TextSpan(
            text: 'Switch to [ ',
            style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: 'text',
                style: htmlState.value == PostHtmlState.text ? null : textStyle,
                recognizer: htmlState.value == PostHtmlState.text
                    ? null
                    : onTap(PostHtmlState.text),
              ),
              const TextSpan(text: ' | '),
              TextSpan(
                text: 'html',
                style: htmlState.value == PostHtmlState.html ? null : textStyle,
                recognizer: htmlState.value == PostHtmlState.html
                    ? null
                    : onTap(PostHtmlState.html),
              ),
              const TextSpan(text: ' | '),
              TextSpan(
                text: 'simplify',
                style: htmlState.value == PostHtmlState.simplify
                    ? null
                    : textStyle,
                recognizer: htmlState.value == PostHtmlState.simplify
                    ? null
                    : onTap(PostHtmlState.simplify),
              ),
              const TextSpan(text: ' | '),
              TextSpan(
                text: 'textify',
                style:
                    htmlState.value == PostHtmlState.textify ? null : textStyle,
                recognizer: htmlState.value == PostHtmlState.textify
                    ? null
                    : onTap(PostHtmlState.textify),
              ),
              const TextSpan(text: ' ] version\n')
            ],
          ),
          textScaler: TextScaler.linear(Settings.contentScale.val / 100),
        ),
      if (body?.html != null && showHtml)
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(Settings.contentScale.val / 100)),
          child: VisibilityDetector(
            key: Key('${data.post.messageId} html'),
            onVisibilityChanged: (info) {
              if (context.mounted) ref.read(postsLoader).setVisible(data, info);
            },
            child: HtmlWidget(
              htmlState.value == PostHtmlState.html
                  ? body?.html ?? ''
                  : HtmlSimplifier.simplifyHtml(body?.html ?? ''),
              buildAsync: false,
              enableCaching: true,
              factoryBuilder: () => NetworkImageFactory(data.index, loader),
            ),
          ),
        )
      else if (body != null && _getBodyText(data).isNotEmpty)
        PostBodyText(data, false),
    ];

    var list = [
      if (body == null)
        const Center(
            child: SizedBox.square(
                dimension: 50, child: CircularProgressIndicator()))
      else ...[
        if (quoteBody.isNotEmpty)
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: quoteBody),
        if (Settings.showLinkPreview.val &&
            !Settings.embedLinkPreview.val &&
            body.links.any((e) => e.enabled))
          PostLinkPreviews(data),
        if (ref.watch(postImagesProvider.select((list) =>
            list.any((image) => image.post == data.index && !image.embed))))
          PostImages(data),
        if (body.files.isNotEmpty) PostFiles(data),
        if (state.reply
            .where((e) => e.state.inside)
            .where((e) => !Settings.blockSenders.val.contains(e.post.from))
            .any((e) =>
                e.state.load == PostLoadState.loading ||
                (e.body != null && filters.filterPost(e))))
          PostShortReply(data),
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list
          .expand((e) sync* {
            yield const Divider();
            yield e;
          })
          .skip(1)
          .toList(),
    );
  }
}

class PostQuote extends StatelessWidget {
  const PostQuote(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var theme = Theme.of(context).extension<NGroupTheme>()!;
    var blocked = Settings.blockSenders.val.contains(data.post.from);
    var quote = data.body?.text.noLinebreak.convUseSetting ?? '';
    if (quote.isEmpty) quote = 'No content.';
    if (blocked) quote = 'Blocked';
    return Card(
      color: blocked ? null : theme.quote,
      shadowColor: Color.lerp(theme.quote, Colors.black, 0.8),
      elevation: 1,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(Settings.contentScale.val / 100)),
        child: CustomPaint(
          painter: blocked
              ? BlockPainter(colorScheme.surfaceTint, Colors.yellow)
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: blocked ? 0.8 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text.rich(TextSpan(children: [
                    _senderTextSpan(context, data, opacity: 0.8),
                  ])),
                ),
              ),
              Flexible(
                child: Card(
                  margin: const EdgeInsets.all(1),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Opacity(
                    opacity: blocked ? 0.8 : 1.0,
                    child: Text(' $quote ',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostShortReply extends ConsumerWidget {
  const PostShortReply(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var state = data.state;
    var filters = ref.read(filterProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...state.reply
            .where((e) => e.state.inside && e.body != null)
            .where((e) => !Settings.blockSenders.val.contains(e.post.from))
            .map(
          (e) {
            var selected = ref.read(selectedPostProvider) == e.post.messageId;
            return AnimatedCrossFade(
              duration: Durations.short4,
              sizeCurve: Curves.easeOutCirc,
              crossFadeState: !filters.filterPost(e)
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: const SizedBox.shrink(),
              secondChild: GestureDetector(
                onTap: () => ref.read(postsLoader).select(e),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(
                        style: selected && !CaptureView.of(context)
                            ? BorderStyle.solid
                            : BorderStyle.none,
                        color: colorScheme.outline,
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignInside),
                  ),
                  child: PostBodyText(e, true),
                ),
              ),
            );
          },
        ),
        if (state.reply.any(
            (e) => e.state.inside && e.state.load == PostLoadState.loading))
          const Center(
            child: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ],
    );
  }
}

String _getBodyText(PostData data) {
  return data.body?.html != null && data.htmlState == PostHtmlState.textify
      ? HtmlSimplifier.textifyHtml(data.body?.html ?? '')
      : data.body?.text.convUseSetting ?? '';
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  const CustomScrollBehavior();
  @override
  Widget buildScrollbar(context, child, details) => child;
}

class CustomWidgetSpan extends WidgetSpan {
  const CustomWidgetSpan({
    required this.size,
    required super.child,
    super.alignment,
    super.baseline,
    super.style,
  });
  final Size size;
}

class PostBodyText extends HookConsumerWidget {
  const PostBodyText(this.data, this.short, {super.key});

  final PostData data;
  final bool short;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var filters = ref.read(filterProvider);
    var loader = ref.read(postsLoader);

    final more = useState(false);
    final clearSelection = useState(0);

    var text = _getBodyText(data);
    if (short) text = text.noLinebreak;
    text += ' ';
    var hide = Settings.hideText.val;
    var blocked = Settings.blockSenders.val.contains(data.parent?.post.from);
    var linkifies =
        linkify(text, options: const LinkifyOptions(humanize: false));

    var sizeMap = useMemoized(() => <String, Size>{});
    var sizeStream = useStreamController<MapEntry<String, Size>>();
    var sizeData = useStream(sizeStream.stream).data;
    if (sizeData != null) sizeMap.addEntries([sizeData]);

    List<InlineSpan> linkifyTextSpan(String text) {
      var urls = <String>{};
      var spans = linkifies.expand((e) {
        if (e is! LinkableElement) return [TextSpan(text: e.text)];
        if (e is EmailElement) return [TextSpan(text: e.text)];

        var link = loader.getLinkPreview(e.url);
        var embed = link.isImage
            ? Settings.showLinkedImage.val && Settings.embedLinkedImage.val
            : Settings.showLinkPreview.val && Settings.embedLinkPreview.val;
        if (kIsWeb ||
            !embed ||
            (!link.isImage && link.ready && !link.enabled)) {
          return [
            const CustomWidgetSpan(
              size: Size(20, 16),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Icon(Icons.link, size: 16),
              ),
            ),
            TextSpan(
              text: e.url.decodeUrl,
              style: const TextStyle(
                color: Colors.blueAccent,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrlString(e.url),
            ),
          ];
        } else if (!urls.add(link.url)) {
          return [];
        } else if (!link.ready) {
          return [
            const CustomWidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.ideographic,
              size: Size(16, 12),
              child: Padding(
                padding: EdgeInsets.only(right: 4),
                child: SizedBox.square(
                    dimension: 12,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
            TextSpan(
              text: link.url.decodeUrl,
              style: const TextStyle(
                color: Colors.blueAccent,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrlString(e.url),
            ),
          ];
        } else if (link.isImage) {
          var maxWidth = Settings.linkedImageMaxWidth.val.toDouble();
          return [
            CustomWidgetSpan(
              size: sizeMap.containsKey(link.url)
                  ? sizeMap[link.url]!
                  : Size.zero,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: GalleryCardItem.url(
                  link.url,
                  data.index,
                  'remote-image',
                  border: true,
                  onSize: (w, h) => sizeStream.add(MapEntry(link.url,
                      Size(min(w.toDouble(), maxWidth), h.toDouble()))),
                ),
              ),
            )
          ];
        } else if (link.enabled) {
          var description =
              link.description == link.url ? '' : link.description;
          description += link.image == null ? '' : '\n\n\n';
          return [
            CustomWidgetSpan(
              size: const Size.fromHeight(80),
              child: Card(
                color: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Table(
                  columnWidths: link.image == null
                      ? null
                      : const {0: FixedColumnWidth(80)},
                  children: [
                    TableRow(
                      children: [
                        if (link.image != null)
                          TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.fill,
                              child: GalleryCardItem.url(
                                  e.url, data.index, 'link-image')),
                        InkWell(
                          onTap: () => launchUrlString(link.url),
                          child: SizedBox(
                            // height: link.image == null ? null : 80,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Ink(
                                  decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer
                                          .withOpacity(0.8)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    child: Text(
                                      link.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                          color:
                                              colorScheme.onTertiaryContainer,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                if (description.isNotEmpty ||
                                    link.image != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Text(
                                      description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall,
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  child: Text(
                                    link.url.decodeUrl,
                                    maxLines: 1,
                                    style: textTheme.labelSmall?.copyWith(
                                        color: Colors.blueAccent,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ];
        }
        return [];
      });
      return spans.cast<InlineSpan>().toList();
    }

    var span = TextSpan(children: [
      if (short && !blocked && filters.filterPost(data.parent!)) ...[
        WidgetSpan(child: PostState(data)),
        _senderTextSpan(context, data),
      ],
      if (data.state.error) ...[
        WidgetSpan(
            child: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(Icons.error, size: 18, color: colorScheme.error),
        )),
        TextSpan(text: text, style: TextStyle(color: colorScheme.error)),
      ],
      if (!data.state.error) ...linkifyTextSpan(text),
      if (data.state.error) ...[
        const TextSpan(text: ' '),
        TextSpan(
            text: 'Skip',
            style: const TextStyle(
                color: Colors.blueAccent, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () => ref.read(postsLoader).retry()),
        const TextSpan(text: ' '),
      ],
    ]);

    return VisibilityDetector(
      key: Key('${data.post.messageId} body'),
      onVisibilityChanged: (info) {
        if (context.mounted) ref.read(postsLoader).setVisible(data, info);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          var length = 1;
          if (!short && !data.state.error) {
            var tp = TextPainter(
                text: span, textDirection: Directionality.of(context));
            var dims = <PlaceholderDimensions>[];
            span.visitChildren((s) {
              if (s is CustomWidgetSpan) {
                var width = s.size.width == double.infinity
                    ? constraints.maxWidth
                    : s.size.width;
                var size = Size(width, s.size.height);
                dims.add(PlaceholderDimensions(
                  size: size,
                  alignment: s.alignment,
                  baseline: s.baseline,
                ));
              }
              return true;
            });
            tp.setPlaceholderDimensions(dims);
            tp.layout(maxWidth: constraints.maxWidth);
            length = tp.computeLineMetrics().length;
          }
          return GestureDetector(
            onLongPress: !Adaptive.isDesktop
                ? null
                : () => ref.read(postsLoader).toggleSelectable(data),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!Adaptive.isDesktop)
                  SelectionArea(
                    key: ValueKey('${clearSelection.value}'),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(postsLoader).select(data);
                        clearSelection.value++;
                      },
                      child: Text.rich(
                        span,
                        maxLines:
                            more.value || CaptureView.of(context) ? null : hide,
                        textScaler:
                            TextScaler.linear(Settings.contentScale.val / 100),
                      ),
                    ),
                  )
                else if (data.state.selectable)
                  ScrollConfiguration(
                    behavior: const CustomScrollBehavior().copyWith(
                        scrollbars: false,
                        physics: const NeverScrollableScrollPhysics()),
                    child: SelectableText.rich(
                      span,
                      maxLines: short ||
                              length <= hide ||
                              more.value ||
                              CaptureView.of(context)
                          ? null
                          : hide,
                      onTap: () => ref.read(postsLoader).select(data),
                      contextMenuBuilder: (_, state) =>
                          AdaptiveTextSelectionToolbar.buttonItems(
                              anchors: state.contextMenuAnchors,
                              buttonItems: state.contextMenuButtonItems),
                      textScaler:
                          TextScaler.linear(Settings.contentScale.val / 100),
                    ),
                  )
                else
                  Text.rich(
                    span,
                    maxLines:
                        more.value || CaptureView.of(context) ? null : hide,
                    textScaler:
                        TextScaler.linear(Settings.contentScale.val / 100),
                  ),
                if (!more.value && length > hide && !CaptureView.of(context))
                  Text.rich(
                    TextSpan(
                      text: '\n${length - hide} lines is hidden. ',
                      style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text: 'Show more',
                            style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => more.value = true),
                        const TextSpan(text: ' ')
                      ],
                    ),
                    textScaler:
                        TextScaler.linear(Settings.contentScale.val / 100),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}

class PostFiles extends ConsumerWidget {
  const PostFiles(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    return VisibilityDetector(
      key: Key('${data.post.messageId} file'),
      onVisibilityChanged: (info) {
        if (context.mounted) ref.read(postsLoader).setVisible(data, info);
      },
      child: Center(
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ...data.body!.files.map((e) => ActionChip(
                  label: Text(e.filename),
                  avatar: const Icon(Icons.attach_file),
                  elevation: 1,
                  pressElevation: 2,
                  side:
                      BorderSide(color: colorScheme.outline.withOpacity(0.12)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onPressed: () => Adaptive.saveBinary(
                      e.data!, 'Save attachment', e.filename, null),
                ))
          ],
        ),
      ),
    );
  }
}

class PostImages extends ConsumerWidget {
  const PostImages(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var images = ref.watch(postImagesProvider.select((list) =>
        list.where((image) => image.post == data.index && !image.embed)));
    return VisibilityDetector(
      key: Key('${data.post.messageId} image'),
      onVisibilityChanged: (info) {
        if (context.mounted) ref.read(postsLoader).setVisible(data, info);
      },
      child: Center(
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ...images.map(
              (e) => SizedBox(
                height: Settings.smallPreview.val ? 100 : null,
                child: GalleryCardItem.id(e.id, 'post-image', border: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostLinkPreviews extends ConsumerWidget {
  const PostLinkPreviews(this.data, {super.key});

  final PostData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var loader = ref.read(postsLoader);
    var links = data.body!.links
        .where((e) => e.enabled)
        .map((e) => loader.getLinkPreview(e.url))
        .toList();
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: links.length * 300),
        child: MasonryGridView.extent(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          maxCrossAxisExtent: 300,
          physics: const ClampingScrollPhysics(),
          itemCount: links.length,
          itemBuilder: (_, index) {
            var e = links[index];
            return Card(
              color: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8)),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return SizedBox(
                    width: 300,
                    height: e.image != null ? 200 : null,
                    child: InkWell(
                      onTap: () => launchUrlString(e.url),
                      child: !e.ready
                          ? const SizedBox(
                              height: 200,
                              child: Center(
                                child: SizedBox.square(
                                    dimension: 50,
                                    child: CircularProgressIndicator()),
                              ),
                            )
                          : Stack(
                              fit: StackFit.loose,
                              children: [
                                if (e.image != null)
                                  Center(
                                    child: Ink.image(
                                      image: e.image!,
                                      fit: BoxFit.contain,
                                      onImageError: (_, __) =>
                                          setState(() => e.image = null),
                                    ),
                                  ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Ink(
                                      decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer
                                              .withOpacity(0.8)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          e.title.convUseSetting,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    if (e.image != null) const Spacer(),
                                    Ink(
                                      decoration: BoxDecoration(
                                          color: colorScheme.tertiaryContainer
                                              .withOpacity(0.8)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          e.description.convUseSetting,
                                          maxLines: e.image == null ? 10 : 2,
                                          overflow: e.image == null
                                              ? null
                                              : TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
