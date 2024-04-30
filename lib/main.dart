import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'core/adaptive.dart';
import 'core/theme.dart';
import 'database/database.dart';
import 'home/home_view.dart';
import 'settings/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Adaptive.initDataPath();
  await AppDatabase.init(Adaptive.dataPath);
  await Settings.init();
  await Adaptive.initWindow();
  if (kIsWeb) {
    Settings.disableWebContextMenu.val
        ? await BrowserContextMenu.disableContextMenu()
        : await BrowserContextMenu.enableContextMenu();
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    useListenable(Settings.theme);
    useListenable(Settings.customFrame);
    useValueChanged(
        Settings.customFrame.val,
        (_, __) => Settings.customFrame.val
            ? windowManager.setAsFrameless()
            : windowManager.setTitleBarStyle(TitleBarStyle.normal));
    return MaterialApp(
      title: 'NGroup',
      scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      }),
      themeMode: Settings.theme.val,
      theme: lightNGroupThemeData,
      darkTheme: darkNGroupThemeData,
      debugShowCheckedModeBanner: false,
      home: const HomeView(),
      builder: (_, child) {
        return Adaptive.desktopFrame(child!);
      },
    );
  }
}
