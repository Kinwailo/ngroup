import 'dart:async';
import 'dart:convert';

import 'package:enough_mail/enough_mail.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:universal_io/io.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:image/image.dart' as img;

import '../core/string_utils.dart';
import '../database/database.dart';
import '../group/group_controller.dart';
import '../group/group_options.dart';
import '../nntp/nntp_service.dart';
import '../settings/settings.dart';
import '../widgets/progress_dialog.dart';
import 'post_controller.dart';

final writeController = Provider<WriteController>(WriteController.new);

class ImageData {
  ImageData(this.filename, this.fileData) {
    decoder = img.findDecoderForNamedImage(filename);
    info = decoder?.startDecode(fileData);
    imageData = fileData;
  }
  String filename;
  Uint8List fileData = Uint8List(0);

  img.Decoder? decoder;
  img.DecodeInfo? info;
  img.Image? image;

  int scale = WriteController.scaleList.length - 1;
  bool original = true;
  bool hqResize = false;
  Uint8List imageData = Uint8List(0);
}

class WriteController {
  final Ref ref;

  static const scaleList = [0.16, 0.25, 0.33, 0.50, 0.66, 0.75, 0.90, 1.00];

  var name = TextEditingController();
  var email = TextEditingController();
  var subject = TextEditingController();
  var body = TextEditingController();
  var signature = TextEditingController();
  var quote = TextEditingController();

  var nameFocusNode = FocusNode();
  var emailFocusNode = FocusNode();
  var subjectFocusNode = FocusNode();
  var bodyFocusNode = FocusNode();
  var signatureFocusNode = FocusNode();
  var quoteFocusNode = FocusNode();

  var data = ValueNotifier<PostData?>(null);
  var identity = ValueNotifier(-1);
  var enableSignature = ValueNotifier(true);
  var enableQuote = ValueNotifier(true);
  var references = <String>[];
  var sendable = ValueNotifier(false);

  var htmlData = ValueNotifier('');
  var textData = ValueNotifier('');

  var images = ValueNotifier(<ImageData>[]);
  var selectedFile = ValueNotifier<ImageData?>(null);
  var resizing = ValueNotifier(false);

  var rawQuote = '';

  WriteController(this.ref) {
    identity.addListener(_updateIdentity);
    subject.addListener(_updateSendable);
    name.addListener(_updateSendable);
    email.addListener(_updateSendable);
    body.addListener(_updateSendable);
    images.addListener(_updateSendable);
    htmlData.addListener(_updateSendable);

    ref.listen(selectedGroupProvider, (_, groupId) {
      _setGroupIdentity(groupId);
    });

    data.addListener(() {
      var groupId = data.value?.post.groupId;
      groupId = groupId ?? ref.read(selectedGroupProvider);
      _setGroupIdentity(groupId!);
    });

    _setGroupIdentity(ref.read(selectedGroupProvider));
  }

  void _updateSendable() {
    sendable.value = name.text.isNotEmpty &&
        email.text.isNotEmpty &&
        subject.text.isNotEmpty &&
        (body.text.isNotEmpty ||
            images.value.isNotEmpty ||
            htmlData.value.isNotEmpty) &&
        !resizing.value;
  }

  void _setGroupIdentity(int groupId) async {
    var group = await AppDatabase.get.getGroup(groupId);
    var options = group == null ? null : GroupOptions(group);
    identity.value = options?.identity.val ?? -1;
  }

  void _updateIdentity() {
    if (identity.value == -1) {
      name.text = '';
      email.text = '';
      signature.text = '';
    } else {
      var id = Settings.identities.val[identity.value];
      name.text = id['name'];
      email.text = id['email'];
      signature.text = id['signature'];
    }
  }

  String _getQuote() {
    var text = const LineSplitter().convert(data.value?.body?.text ?? '');
    return text.map((e) => '> $e').join('\n');
  }

  Set<FocusNode> getAllFocusNode() {
    return <FocusNode>{
      nameFocusNode,
      emailFocusNode,
      subjectFocusNode,
      bodyFocusNode,
      signatureFocusNode,
      quoteFocusNode
    };
  }

  Widget contextMenuBuilder(BuildContext context, EditableTextState state) {
    var cause = SelectionChangedCause.toolbar;
    return AdaptiveTextSelectionToolbar.editable(
      anchors: state.contextMenuAnchors,
      clipboardStatus: state.clipboardStatus.value,
      onCopy: state.copyEnabled ? () => state.copySelection(cause) : null,
      onCut: state.cutEnabled ? () => state.cutSelection(cause) : null,
      onPaste: () async {
        if (!await handlePaste(cause)) state.pasteText(cause);
        state.hideToolbar();
      },
      onSelectAll: state.selectAllEnabled ? () => state.selectAll(cause) : null,
      onLookUp: null,
      onSearchWeb: null,
      onShare: null,
      onLiveTextInput: null,
    );
  }

  Future<bool> handlePaste(SelectionChangedCause cause) async {
    var reader = await SystemClipboard.instance?.read();
    if (reader == null) return false;
    var text = await reader.readValue(Formats.plainText);
    if (text != null) {
      var html = await reader.readValue(Formats.htmlText);
      if (html == null) return false;
      textData.value = text;
      htmlData.value = html;
      return true;
    }
    var uri = await reader.readValue(Formats.fileUri);
    var filepath = uri?.toFilePath();
    if (filepath != null && filepath.isImageFile) {
      var file = File(filepath);
      var data = await file.readAsBytes();
      addFile(basename(file.path), data);
    } else {
      reader.getFile(Formats.png, (file) async {
        var data = await file.readAll();
        addFile(file.fileName ?? 'image.png', data);
      });
    }
    return false;
  }

  void clearHtmlData() {
    htmlData.value = '';
    if (textData.value.isNotEmpty) {
      body.text += body.text.isNotEmpty ? '\n\n' : '';
      body.text += textData.value;
      textData.value = '';
    }
  }

  void create(PostData? data) {
    this.data.value = data;

    var re = RegExp(r'^(Re: ?)*');
    var text = data?.post.subject ?? '';
    if (text.isNotEmpty) text = 'Re: ${text.replaceAll(re, '')}';
    subject.text = text;

    rawQuote = _getQuote();
    var chop = Settings.chopQuote.val;
    quote.text =
        rawQuote.length < chop ? rawQuote : '${rawQuote.substring(0, chop)}...';

    references =
        data == null ? [] : [...data.post.references, data.post.messageId];
    images.value = [];
    selectedFile.value = null;
    htmlData.value = '';
    textData.value = '';

    enableSignature.value = true;
    enableQuote.value = true;
  }

  void quoteAll() {
    quote.text = rawQuote;
  }

  bool needChop() {
    return rawQuote.length > Settings.chopQuote.val;
  }

  int charChopped() {
    return rawQuote.length - Settings.chopQuote.val;
  }

  void pickFiles() async {
    var result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image, withData: true);
    if (result != null) {
      images.value = [
        ...images.value,
        ...result.files.map((e) => ImageData(e.name, e.bytes ?? Uint8List(0))),
      ];
      selectedFile.value ??= images.value.first;
    }
  }

  void addFile(String filename, Uint8List data) {
    images.value = [...images.value, ImageData(filename, data)];
    selectedFile.value ??= images.value.first;
  }

  void removeFile(ImageData? image) {
    if (image == null) return;
    images.value = images.value.where((e) => e != image).toList();
    if (selectedFile.value == image) {
      selectedFile.value = images.value.firstOrNull;
    }
  }

  Future<void> setImageScale(
      ImageData image, int scale, bool original, bool hqResize) async {
    image.scale = scale;
    image.original = original;
    image.hqResize = hqResize;

    img.Command? cmd;

    if (original) {
      image.imageData = image.fileData;
    } else {
      if (image.decoder == null || image.info == null) return;

      image.image ??= image.decoder!.decodeFrame(0);
      cmd = img.Command()
        ..image(image.image!)
        ..copyResize(
            width: (image.info!.width * scaleList[scale]).toInt(),
            interpolation:
                hqResize ? img.Interpolation.cubic : img.Interpolation.linear)
        ..encodeJpg(quality: 85);
    }
    images.value = [...images.value];

    if (cmd != null) {
      resizing.value = true;
      _updateSendable();
      image.imageData = await cmd.getBytesThread() ?? Uint8List(0);
      resizing.value = false;
      _updateSendable();
    }
  }

  Future<void> send(BuildContext context,
      {void Function()? onCompleted}) async {
    var pd = ProgressDialog(context);
    pd.onClosed = onCompleted;
    pd.message.value = 'Sending...';
    pd.show();

    var groupId = ref.read(selectedGroupProvider);
    groupId = data.value?.post.groupId ?? groupId;
    var group = await AppDatabase.get.getGroup(groupId);
    if (group == null) throw Exception('Cannot load group data.');

    var content = body.text;
    var html = htmlData.value;

    if (content.isNotEmpty) {
      html = '<p>${content.replaceAll('\n', '</br>')}</p>$html';
    }
    if (textData.value.isNotEmpty) {
      content += content.isNotEmpty ? '\n\n' : '';
      content += textData.value;
    }
    if (enableSignature.value && signature.text != '') {
      content += '\n\n--\n${signature.text}';
    }
    if (enableQuote.value && quote.text != '') {
      content +=
          '\n\n${data.value?.post.from ?? 'Someone'} wrote: \n${quote.text}';
    }
    if (images.value.isNotEmpty) content += '\n';
    content = latin1.decode(utf8.encode(content));
    html = latin1.decode(utf8.encode(html));

    try {
      var pf = 'Web';
      if (!kIsWeb) {
        if (Platform.isWindows) pf = 'Windows';
        if (Platform.isMacOS) pf = 'MacOS';
        if (Platform.isLinux) pf = 'Linux';
        if (Platform.isAndroid) pf = 'Android';
        if (Platform.isIOS) pf = 'IOS';
      }
      var builder = MessageBuilder(
          subjectEncoding: HeaderEncoding.B,
          transferEncoding: TransferEncoding.eightBit)
        ..from = [MailAddress(name.text, email.text)]
        ..addHeader('Newsgroups', group.name)
        ..addHeader('References', references.join(' '))
        ..addHeader('User-Agent', 'NGroup @$pf')
        ..subject = subject.text;

      if (htmlData.value.isEmpty) {
        builder.text = content;
      } else {
        builder
          ..addTextPlain(content, transferEncoding: TransferEncoding.eightBit)
          ..addTextHtml(html, transferEncoding: TransferEncoding.eightBit)
          ..setContentType(MediaSubtype.multipartAlternative.mediaType);
      }

      for (var e in images.value) {
        if (e.imageData.isEmpty) continue;
        builder.addBinary(e.imageData, MediaType.guessFromFileName(e.filename),
            filename: MailCodec.base64.encodeHeader(e.filename));
      }
      var message = builder.buildMimeMessage();
      var data = message.renderMessage();

      var nntp = await NNTPService.fromGroup(group.id!);
      await nntp!.post(data);

      pd.message.value = 'Post was sent successfully.';
      pd.completed.value = true;
      body.text = '';
    } catch (e) {
      pd.message.value = e.toString();
      pd.error.value = true;
    }
  }
}
