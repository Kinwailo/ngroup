import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sanitize_filename/sanitize_filename.dart';
import 'package:share_plus/share_plus.dart';
import 'package:window_manager/window_manager.dart';

import '../settings/settings.dart';
import '../widgets/window_frame.dart';

class Adaptive {
  static String _dataPath = kIsWeb ? '' : dirname(Platform.resolvedExecutable);
  static String get dataPath => _dataPath;

  static const bool forceMobile = false;

  static bool get isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  static bool get useTwoPaneUI =>
      (!forceMobile && isDesktop) || Settings.twoPane.val;

  static double? get appBarHeight => isDesktop ? 32 : null;

  static initDataPath() async {
    if (kIsWeb) return;
    if (!isDesktop) {
      _dataPath = (await getApplicationSupportDirectory()).path;
    }
  }

  static initWindow() async {
    if (!kIsWeb && isDesktop) {
      await windowManager.ensureInitialized();

      WindowOptions windowOptions = WindowOptions(
        title: 'NGroup',
        size: null,
        minimumSize: const Size(800, 600),
        center: Settings.center.val,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        windowButtonVisibility: true,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        if (Settings.customFrame.val) await windowManager.setAsFrameless();
        if (Settings.center.val) {
          var pos = await windowManager.getPosition();
          Settings.left.val = pos.dx;
          Settings.top.val = pos.dy;
          Settings.center.val = false;
        } else {
          var pos = Offset(Settings.left.val, Settings.top.val);
          await windowManager.setPosition(pos);
          var size = Size(Settings.width.val, Settings.height.val);
          await windowManager.setSize(size);
        }
        await windowManager.show();
        await windowManager.focus();
      });

      Future.delayed(Durations.long4, () {
        if (Settings.maximize.val) windowManager.maximize();
      });
    }
  }

  static Widget desktopFrame(Widget child) {
    if (kIsWeb || !isDesktop) return child;
    return WindowShadow(WindowFrame(child));
  }

  static Future<void> saveText(
      String output, String desc, String filename, String? mimeType) async {
    filename = sanitizeFilename(filename);
    if (isDesktop) {
      String? path = await FilePicker.platform
          .saveFile(dialogTitle: desc, fileName: filename);
      if (path != null) await File(path).writeAsString(output, flush: true);
    } else {
      var temp = await getTemporaryDirectory();
      var file = File('${temp.path}/$filename');
      await file.writeAsString(output, flush: true);
      await Share.shareXFiles([XFile(file.path, mimeType: mimeType)]);
      await file.delete();
    }
  }

  static Future<void> saveBinary(
      Uint8List output, String desc, String filename, String? mimeType) async {
    filename = sanitizeFilename(filename);
    if (isDesktop) {
      String? path = await FilePicker.platform
          .saveFile(dialogTitle: desc, fileName: filename);
      if (path != null) await File(path).writeAsBytes(output, flush: true);
    } else {
      var temp = await getTemporaryDirectory();
      var file = File('${temp.path}/$filename');
      await file.writeAsBytes(output, flush: true);
      await Share.shareXFiles([XFile(file.path, mimeType: mimeType)]);
      await file.delete();
    }
  }
}

class AdaptivePageView extends HookWidget {
  const AdaptivePageView({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    useListenable(Settings.contentScale);
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: Adaptive.useTwoPaneUI
                  ? 4.0 * Settings.contentScale.val
                  : double.infinity),
          child: child,
        ),
      ),
    );
  }
}
