import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:split_view/split_view.dart';

import '../core/adaptive.dart';
import '../core/notched_shape.dart';
import '../group/options_view.dart';
import '../group/group_controller.dart';
import '../post/capture_view.dart';
import '../post/gallery_view.dart';
import '../post/post_view.dart';
import '../post/post_controller.dart';
import '../post/thread_controller.dart';
import '../post/thread_view.dart';
import '../post/write_controller.dart';
import '../post/write_view.dart';
import '../settings/settings.dart';
import '../settings/settings_view.dart';
import 'filter_bar.dart';
import 'filter_controller.dart';
import 'home_view.dart';
import 'home_controller.dart';

class TwoPane extends HookConsumerWidget {
  const TwoPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    var nav = ref.read(rightNavigator);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Adaptive.isDesktop ? null : const HomeIcon(),
        title: Row(
          children: [
            if (Adaptive.isDesktop) ...const [HomeIcon(), SizedBox(width: 8)],
            const GroupMenu(),
            const SizedBox(width: 8),
            const Expanded(child: HomeTitle()),
            if (Adaptive.isDesktop) const SizedBox(width: 138),
          ],
        ),
        toolbarHeight: Adaptive.appBarHeight,
        elevation: 2,
      ),
      extendBody: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterBar(ref.read(filterProvider)),
          Expanded(
            child: SplitView(
              viewMode: SplitViewMode.Horizontal,
              gripSize: 8,
              gripColor: theme.colorScheme.surfaceVariant,
              gripColorActive: theme.colorScheme.surfaceVariant,
              indicator: SplitIndicator(
                viewMode: SplitViewMode.Horizontal,
                color: theme.colorScheme.tertiary,
              ),
              activeIndicator: SplitIndicator(
                viewMode: SplitViewMode.Horizontal,
                isActive: true,
                color: theme.colorScheme.tertiary,
              ),
              controller: SplitViewController(
                  weights: [null, Settings.messageWeight.val],
                  limits: [WeightLimit(min: 0.2), WeightLimit(min: 0.2)]),
              onWeightChanged: (w) => Settings.messageWeight.val = w[1] ?? 0.6,
              children: [
                const ThreadView(),
                Navigator(
                  key: nav.key,
                  initialRoute: nav.initialRoute,
                  onGenerateRoute: nav.generateRoute,
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: HomeActionButton(nav),
      bottomNavigationBar: HookConsumer(builder: (context, ref, _) {
        var noGroup = ref.watch(selectedGroupProvider) == -1;
        var noThread = ref.watch(selectedThreadProvider) == '';
        var postId = ref.watch(selectedPostProvider);
        var data = ref.read(postsLoader).getPostData(postId);
        var filters = ref.read(filterProvider);
        var reply = ref.read(writeController).data;

        useListenable(nav.path);
        useListenable(reply);

        return BottomAppBar(
          elevation: 2,
          color: theme.colorScheme.surfaceVariant,
          shape: const LongCircularNotchedRectangle(),
          notchMargin: 5,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              BottomAppBarButton(
                active: nav.path.value == SettingsView.path,
                icon: Icons.settings,
                enabled: !noGroup,
                onPressed: () => nav.goto(SettingsView.path),
              ),
              BottomAppBarButton(
                active: nav.path.value == OptionsView.path,
                icon: Icons.menu_open,
                enabled: !noGroup,
                onPressed: () => nav.goto(OptionsView.path),
              ),
              BottomAppBarButton(
                icon: Icons.filter_alt,
                enabled: !noGroup,
                onPressed: filters.toggle,
              ),
              Expanded(child: IconButton(icon: Container(), onPressed: null)),
              BottomAppBarButton(
                active: nav.path.value == WriteView.path && reply.value == null,
                icon: Icons.create,
                enabled: !noGroup,
                onPressed: () {
                  ref.read(writeController).create(null);
                  nav.goto(WriteView.path);
                },
              ),
              BottomAppBarButton(
                active: nav.path.value == WriteView.path && reply.value != null,
                icon: Icons.reply,
                enabled: data != null,
                onPressed: () {
                  ref.read(writeController).create(data);
                  nav.goto(WriteView.path);
                },
              ),
              const SizedBox(width: 16),
              if (!Adaptive.isDesktop)
                BottomAppBarButton(
                  icon: Icons.share,
                  enabled: !noThread,
                  onPressed: () => ref.read(postsLoader).share(),
                ),
              BottomAppBarButton(
                icon: Icons.save_alt,
                enabled: !noThread,
                onPressed: () => ref.read(postsLoader).export(),
              ),
              BottomAppBarButton(
                icon: Icons.screenshot,
                enabled: !noThread,
                onPressed: () => CapturePage.show(context),
              ),
              const SizedBox(width: 16),
              BottomAppBarButton(
                active: nav.path.value == PostView.path,
                icon: Icons.chat,
                enabled: !noThread,
                onPressed: () => nav.goto(PostView.path),
              ),
              BottomAppBarButton(
                active: nav.path.value == GalleryView.path,
                icon: Icons.photo_library,
                enabled: ref.watch(postImagesProvider).isNotEmpty,
                onPressed: () => nav.goto(GalleryView.path),
              ),
              SizedBox(width: Adaptive.isDesktop ? 108 : 140)
            ],
          ),
        );
      }),
    );
  }
}
