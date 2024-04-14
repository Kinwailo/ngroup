import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:synchronized/synchronized.dart';
import 'package:window_manager/window_manager.dart';

import '../core/adaptive.dart';
import '../home/home_controller.dart';
import '../settings/settings.dart';

class WindowFrame extends HookConsumerWidget {
  const WindowFrame(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var state = ref.read(windowStateProvider);

    var listener = useMemoized(() => _WindowListener(ref));
    useEffect(() {
      windowManager.addListener(listener);
      return () => windowManager.removeListener(listener);
    });
    useListenable(state.isMaximized);
    useListenable(state.isFullScreen);
    useListenable(Settings.customFrame);

    if (!Adaptive.isDesktop || !Settings.customFrame.val) return child;
    return DragToResizeArea(
      resizeEdgeSize: 6,
      enableResizeEdges:
          (state.isMaximized.value || state.isFullScreen.value) ? [] : null,
      child: Stack(children: [
        child,
        const DragToMoveArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Spacer(), WindowButtons()],
          ),
        ),
      ]),
    );
  }
}

class WindowShadow extends HookConsumerWidget {
  const WindowShadow(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var state = ref.read(windowStateProvider);

    useListenable(state.isMaximized);
    useListenable(Settings.customFrame);

    if (state.isMaximized.value || !Settings.customFrame.val) return child;
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 22),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: kElevationToShadow[8],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }
}

class _WindowListener extends WindowListener {
  _WindowListener(this.ref);

  final WidgetRef ref;
  final Lock lock = Lock();

  @override
  void onWindowResize() async {
    await lock.synchronized(() async {
      var size = await windowManager.getSize();
      Settings.width.val = size.width;
      Settings.height.val = size.height;
    });
  }

  @override
  void onWindowMove() async {
    await lock.synchronized(() async {
      var pos = await windowManager.getPosition();
      Settings.left.val = pos.dx;
      Settings.top.val = pos.dy;
    });
  }

  @override
  void onWindowMaximize() async {
    var state = ref.read(windowStateProvider);
    state.isMaximized.value = true;
    Settings.maximize.val = true;
  }

  @override
  void onWindowUnmaximize() {
    var state = ref.read(windowStateProvider);
    state.isMaximized.value = false;
    Settings.maximize.val = false;
  }

  @override
  void onWindowEnterFullScreen() {
    var state = ref.read(windowStateProvider);
    state.isFullScreen.value = true;
  }

  @override
  void onWindowLeaveFullScreen() {
    var state = ref.read(windowStateProvider);
    state.isFullScreen.value = false;
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 138,
      height: 32,
      child: WindowCaption(
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
