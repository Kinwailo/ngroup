import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ngroup/home/home_view.dart';
import 'package:screenshot/screenshot.dart';
import 'package:split_view/split_view.dart';

import '../core/adaptive.dart';
import '../home/home_controller.dart';
import '../settings/settings.dart';
import 'post_view.dart';
import 'post_controller.dart';

class _InheritedCaptureView extends InheritedWidget {
  const _InheritedCaptureView({required super.child});

  @override
  bool updateShouldNotify(_InheritedCaptureView oldWidget) => false;
}

class CapturePage extends ConsumerWidget {
  const CapturePage({super.key});

  static void show(BuildContext context) {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) => const CapturePage()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Catpure Preview'),
        backgroundColor: Colors.black.withOpacity(0.3),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        heroTag: null,
        child: Icon(Adaptive.isDesktop ? Icons.save : Icons.share),
        onPressed: () => ref
            .read(postsLoader)
            .capture(MediaQuery.of(context).devicePixelRatio),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: SplitView(
        viewMode: SplitViewMode.Horizontal,
        gripSize: 8,
        gripColor: theme.highlightColor,
        gripColorActive: theme.highlightColor
            .withOpacity(theme.brightness == Brightness.light ? 0.8 : 0.3),
        indicator: const SplitIndicator(viewMode: SplitViewMode.Horizontal),
        activeIndicator: const SplitIndicator(
          viewMode: SplitViewMode.Horizontal,
          isActive: true,
        ),
        controller: SplitViewController(weights: [
          Settings.captureLeft.val,
          null,
          Settings.captureRight.val
        ], limits: [
          WeightLimit(max: 0.4),
          null,
          WeightLimit(max: 0.4)
        ]),
        onWeightChanged: (w) {
          Settings.captureLeft.val = w[0] ?? 0.2;
          Settings.captureRight.val = w[2] ?? 0.2;
        },
        children: const [
          SizedBox.shrink(),
          CaptureContent(),
          SizedBox.shrink(),
        ],
      ),
    );
  }
}

class CaptureView extends HookConsumerWidget {
  const CaptureView({super.key});

  static var path = 'capture';

  static bool of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_InheritedCaptureView>() !=
        null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Catpure Preview'),
        backgroundColor: Colors.black.withOpacity(0.3),
        actions: [
          FloatingActionButton.small(
            heroTag: null,
            backgroundColor: colorScheme.surfaceVariant,
            child: const Icon(Icons.sms),
            onPressed: () => ref.read(postsLoader).share(),
          ),
          FloatingActionButton.small(
            heroTag: null,
            backgroundColor: colorScheme.surfaceVariant,
            child: const Icon(Icons.html),
            onPressed: () => ref.read(postsLoader).export(),
          ),
          FloatingActionButton.small(
            heroTag: null,
            backgroundColor: colorScheme.surfaceVariant,
            child: const Icon(Icons.image),
            onPressed: () => ref
                .read(postsLoader)
                .capture(MediaQuery.of(context).devicePixelRatio),
          ),
        ],
      ),
      extendBody: true,
      body: const CaptureContent(),
    );
  }
}

class CaptureContent extends HookConsumerWidget {
  const CaptureContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);

    var posts = ref.watch(postsProvider);
    var title = ref.watch(titleProvider);
    var selectedId = ref.watch(selectedPostProvider);
    ref.read(postsLoader);

    final scrollController = useScrollController();

    return _InheritedCaptureView(
      child: HeroMode(
        enabled: false,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top, bottom: 60),
            child: Screenshot(
              controller: ref.read(postsLoader).screenshot,
              child: AbsorbPointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      color: theme.appBarTheme.backgroundColor,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const WidgetSpan(
                              baseline: TextBaseline.ideographic,
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: HomeIcon(),
                              ),
                            ),
                            TextSpan(
                                text: title,
                                style: theme.textTheme.titleLarge!.copyWith(
                                    color: theme.appBarTheme.foregroundColor)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      color: theme.scaffoldBackgroundColor,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        ...List.generate(
                          posts.length,
                          (index) => selectedId != '' &&
                                  selectedId != posts[index].post.messageId
                              ? const SizedBox.shrink()
                              : PostTile(posts[index]),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
