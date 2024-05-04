import 'dart:async';
import 'dart:convert';

import 'package:enough_mail/enough_mail.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:universal_io/io.dart';
import 'package:image/image.dart' as img;

import '../database/database.dart';
import '../group/group_controller.dart';
import '../group/group_options.dart';
import '../nntp/nntp_service.dart';
import '../settings/settings.dart';
import '../widgets/progress_dialog.dart';
import 'post_controller.dart';

final writeController = Provider<WriteController>(WriteController.new);

class ImageData {
  ImageData(this.info, this.bytes);
  img.DecodeInfo? info;
  int scale = WriteController.scaleList.length - 1;
  bool original = true;
  bool hqResize = false;
  Uint8List? bytes;
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

  var data = ValueNotifier<PostData?>(null);
  var identity = ValueNotifier(-1);
  var enableSignature = ValueNotifier(true);
  var enableQuote = ValueNotifier(true);
  var references = <String>[];
  var sendable = ValueNotifier(false);

  var files = ValueNotifier(<PlatformFile>[]);
  var selectedFile = ValueNotifier<PlatformFile?>(null);
  var imageData = <PlatformFile, ImageData>{};
  var resizing = ValueNotifier(false);

  var rawQuote = '';

  WriteController(this.ref) {
    identity.addListener(_updateIdentity);
    subject.addListener(_updateSendable);
    name.addListener(_updateSendable);
    email.addListener(_updateSendable);

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
    files.value = [];
    selectedFile.value = null;

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

  void addFile() async {
    var result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image, withData: true);
    if (result != null) {
      files.value = [...files.value, ...result.files];
      imageData.addAll({
        for (var file in result.files)
          file: ImageData(
              img.findDecoderForNamedImage(file.name)?.startDecode(file.bytes!),
              file.bytes)
      });
      selectedFile.value = files.value.first;
    }
  }

  void removeFile(PlatformFile? file) {
    if (file == null) return;
    imageData.remove(file);
    files.value = files.value.where((e) => e != file).toList();
    if (selectedFile.value == file) {
      selectedFile.value = files.value.firstOrNull;
    }
  }

  Future<void> setImageScale(
      PlatformFile file, int scale, bool original, bool hqResize) async {
    imageData[file]!.scale = scale;
    imageData[file]!.original = original;
    imageData[file]!.hqResize = hqResize;

    img.Command? cmd;

    if (original) {
      imageData[file]!.bytes = file.bytes;
    } else {
      var width = img
          .findDecoderForNamedImage(file.name)
          ?.startDecode(file.bytes!)
          ?.width;
      if (width == null) return;
      width = (width * scaleList[scale]).toInt();

      cmd = img.Command()
        ..decodeNamedImage(file.name, file.bytes!)
        ..copyResize(
            width: width,
            interpolation:
                hqResize ? img.Interpolation.cubic : img.Interpolation.linear)
        ..encodeJpg(quality: 85);
    }
    files.value = [...files.value];

    if (cmd != null) {
      resizing.value = true;
      _updateSendable();
      imageData[file]!.bytes = await cmd.getBytesThread();
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
    if (enableSignature.value && signature.text != '') {
      content += '\n\n--\n${signature.text}';
    }
    if (enableQuote.value && quote.text != '') {
      content +=
          '\n\n${data.value?.post.from ?? 'Someone'} wrote: \n${quote.text}';
    }
    if (files.value.isNotEmpty) content += '\n';

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
        ..subject = subject.text
        ..text = content;
      for (var e in files.value) {
        var bytes = imageData[e]?.bytes;
        if (bytes == null) continue;
        builder.addBinary(bytes, MediaType.guessFromFileName(e.name),
            filename: MailCodec.base64.encodeHeader(e.name));
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
