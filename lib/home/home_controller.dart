import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/adaptive.dart';
import '../group/add_view.dart';
import '../group/options_view.dart';
import '../group/group_controller.dart';
import '../post/capture_view.dart';
import '../post/gallery_view.dart';
import '../post/post_view.dart';
import '../post/thread_view.dart';
import '../post/write_view.dart';
import '../settings/settings_view.dart';

final titleProvider = StateProvider<String>((ref) {
  ref.watch(selectedGroupProvider);
  return '';
});

final windowStateProvider = Provider<WindowState>((_) => WindowState());

final slidePaneProvider =
    Provider<SlidePaneController>((_) => SlidePaneController());

final leftNavigator = Provider<NavigatorController>((ref) =>
    NavigatorController(
        NavigatorController.left,
        !Adaptive.useTwoPaneUI && ref.read(selectedGroupProvider) == -1
            ? 'add'
            : 'threads'));

final rightNavigator =
    Provider<NavigatorController>((ref) => NavigatorController(
        NavigatorController.right,
        Adaptive.useTwoPaneUI
            ? ref.read(selectedGroupProvider) == -1
                ? 'add'
                : 'options'
            : 'posts'));

class WindowState {
  var isMaximized = ValueNotifier(false);
  var isFullScreen = ValueNotifier(false);
}

class NavigatorController {
  final key = GlobalKey<NavigatorState>();
  final String initialRoute;
  final String tag;

  static String left = 'left';
  static String right = 'right';

  final _paths = {
    AddView.path: AddView.new,
    SettingsView.path: SettingsView.new,
    OptionsView.path: OptionsView.new,
    ThreadView.path: ThreadView.new,
    PostView.path: PostView.new,
    GalleryView.path: GalleryView.new,
    WriteView.path: WriteView.new,
    CaptureView.path: CaptureView.new,
  };

  late ValueNotifier<String> path;
  void Function(String old, String now)? onPathChanged;

  NavigatorController(this.tag, this.initialRoute) {
    path = ValueNotifier(initialRoute);
  }

  Route? generateRoute(RouteSettings settings) {
    var builder = _paths[settings.name];
    if (builder == null) throw Exception('Invalid route: ${settings.name}');
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => builder(key: ValueKey(settings.name)),
    );
  }

  void goto(String path) {
    if (this.path.value == path) return;
    onPathChanged?.call(this.path.value, path);
    this.path.value = path;
    key.currentState!.pushReplacementNamed(path);
  }
}

class SlidePaneController {
  final controller = PageController();
  var isLeft = ValueNotifier(true);

  SlidePaneController() {
    controller.addListener(() => isLeft.value = controller.page == 0);
  }

  void slideToLeft() {
    if (controller.hasClients && !isLeft.value) {
      controller.previousPage(curve: Curves.ease, duration: Durations.short4);
      isLeft.value = true;
    }
  }

  void slideToRight() {
    if (controller.hasClients && isLeft.value) {
      controller.nextPage(curve: Curves.ease, duration: Durations.short4);
      isLeft.value = false;
    }
  }
}
