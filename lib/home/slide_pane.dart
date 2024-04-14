import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
import '../settings/settings_view.dart';
import 'filter_bar.dart';
import 'filter_controller.dart';
import 'home_view.dart';
import 'home_controller.dart';

class SlidePane extends HookConsumerWidget {
  const SlidePane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var selectThread = ref.watch(selectedThreadProvider);
    var leftNav = ref.read(leftNavigator);
    var rightNav = ref.read(rightNavigator);

    var scroll =
        selectThread.isNotEmpty && leftNav.path.value == ThreadView.path;
    var slidePane = ref.read(slidePaneProvider);
    var noGroup = ref.read(selectedGroupProvider) == -1;

    useListenable(leftNav.path);
    useListenable(slidePane.isLeft);

    return PopScope(
      canPop: noGroup ||
          (slidePane.isLeft.value && leftNav.path.value == ThreadView.path),
      onPopInvoked: (didPop) {
        if (noGroup) return;
        if (slidePane.isLeft.value) {
          leftNav.goto(ThreadView.path);
        } else if (rightNav.path.value != PostView.path) {
          rightNav.goto(PostView.path);
        } else {
          slidePane.slideToLeft();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: PageView(
          physics: scroll
              ? const ScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          controller: slidePane.controller,
          children: const [
            MasterPane(),
            DetailPane(),
          ],
        ),
      ),
    );
  }
}

class MasterPane extends HookConsumerWidget {
  const MasterPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);

    var nav = ref.read(leftNavigator);
    var filters = ref.read(filterProvider);

    useListenable(nav.path);
    useAutomaticKeepAlive();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const HomeIcon(),
        title: const GroupMenu(),
        toolbarHeight: Adaptive.appBarHeight,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => filters.toggleThreadFilter(false),
          )
        ],
      ),
      extendBody: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterBar.thread(filters),
          Expanded(
            child: Navigator(
              key: nav.key,
              initialRoute: nav.initialRoute,
              onGenerateRoute: nav.generateRoute,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: HomeActionButton(nav),
      bottomNavigationBar: Consumer(
        builder: (context, ref, _) {
          var noGroup = ref.watch(selectedGroupProvider) == -1;
          return BottomAppBar(
            elevation: 2,
            color: theme.colorScheme.surfaceVariant,
            shape: const LongCircularNotchedRectangle(),
            notchMargin: 5,
            child: Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  BottomAppBarButton(
                    active: nav.path.value == ThreadView.path,
                    icon: Icons.chat,
                    enabled: !noGroup,
                    onPressed: () => nav.goto(ThreadView.path),
                  ),
                  BottomAppBarButton(
                    active: nav.path.value == WriteView.path,
                    icon: Icons.create,
                    enabled: !noGroup,
                    onPressed: () {
                      ref.read(writeController).create(null);
                      nav.goto(WriteView.path);
                    },
                  ),
                  BottomAppBarButton(
                    active: nav.path.value == OptionsView.path,
                    icon: Icons.menu_open,
                    enabled: !noGroup,
                    onPressed: () => nav.goto(OptionsView.path),
                  ),
                  BottomAppBarButton(
                    active: nav.path.value == SettingsView.path,
                    icon: Icons.settings,
                    enabled: !noGroup,
                    onPressed: () => nav.goto(SettingsView.path),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DetailPane extends HookConsumerWidget {
  const DetailPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);

    var nav = ref.read(rightNavigator);
    var filters = ref.read(filterProvider);

    useListenable(nav.path);
    useAutomaticKeepAlive();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
            onPressed: () => ref.read(slidePaneProvider).slideToLeft()),
        title: const HomeTitle(),
        toolbarHeight: Adaptive.appBarHeight,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => filters.togglePostFilter(false),
          )
        ],
      ),
      extendBody: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterBar.post(filters),
          Expanded(
            child: Navigator(
              key: nav.key,
              initialRoute: nav.initialRoute,
              onGenerateRoute: nav.generateRoute,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: HomeActionButton(nav),
      bottomNavigationBar: Consumer(
        builder: (context, ref, _) {
          var postId = ref.watch(selectedPostProvider);
          var data = ref.read(postsLoader).getPostData(postId);
          return BottomAppBar(
            elevation: 2,
            color: theme.colorScheme.surfaceVariant,
            shape: const LongCircularNotchedRectangle(),
            notchMargin: 5,
            child: Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  BottomAppBarButton(
                    active: nav.path.value == PostView.path,
                    icon: Icons.chat,
                    onPressed: () => nav.goto(PostView.path),
                  ),
                  BottomAppBarButton(
                    active: nav.path.value == WriteView.path,
                    icon: Icons.reply,
                    enabled: data != null,
                    onPressed: () {
                      ref.read(writeController).create(data);
                      nav.goto(WriteView.path);
                    },
                  ),
                  BottomAppBarButton(
                    active: nav.path.value == CaptureView.path,
                    icon: Icons.share,
                    onPressed: () => nav.goto(CaptureView.path),
                  ),
                  BottomAppBarButton(
                    active: nav.path.value == GalleryView.path,
                    icon: Icons.photo_library,
                    enabled: ref.watch(postImagesProvider).isNotEmpty,
                    onPressed: () => nav.goto(GalleryView.path),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
