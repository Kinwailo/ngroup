import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:badges/badges.dart' as badges;

import '../core/adaptive.dart';
import '../core/theme.dart';
import '../database/database.dart';
import '../group/add_view.dart';
import '../group/group_controller.dart';
import '../group/group_options.dart';
import '../group/group_reorder.dart';
import '../group/options_view.dart';
import '../post/post_view.dart';
import '../post/post_controller.dart';
import '../post/thread_controller.dart';
import '../post/thread_view.dart';
import '../post/write_controller.dart';
import '../settings/settings.dart';
import '../widgets/progress_dialog.dart';
import '../widgets/selection_dialog.dart';
import 'filter_controller.dart';
import 'home_controller.dart';
import 'slide_pane.dart';
import 'two_pane.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(selectedGroupProvider, (_, groupId) async {
      if (groupId != -1) {
        var pd = ProgressDialog(context);
        var sd = SelectionDialog(context);
        var group = await Database.getGroup(groupId);
        if (group != null && GroupOptions(group).autoRefresh.val) {
          ref.read(groupDataProvider.notifier).reload(pd, sd);
        }
      }
    });
    useListenable(Settings.twoPane);
    useValueChanged(Settings.twoPane.val, (_, void __) {
      ref.invalidate(leftNavigator);
      ref.invalidate(rightNavigator);
      ref.invalidate(filterProvider);
    });
    return Adaptive.useTwoPaneUI ? const TwoPane() : const SlidePane();
  }
}

class HomeIcon extends HookWidget {
  const HomeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    useListenable(Settings.customFrame);
    return Visibility(
      visible: Settings.customFrame.val,
      child: Image.asset(
        'assets/home.png',
        width: 32,
        height: 32,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

class HomeTitle extends ConsumerWidget {
  const HomeTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var title = ref.watch(titleProvider);
    return Text(
      title,
      maxLines: Adaptive.isDesktop ? 1 : 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class GroupMenu extends HookConsumerWidget {
  const GroupMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var groups = ref.watch(groupListProvider);
    var groupId = ref.watch(selectedGroupProvider);

    return groups.when(
      loading: () => const Text('Loading...'),
      error: (e, __) => const Text('Error...'),
      data: (data) => Theme(
        data: darkNGroupThemeData,
        child: DropdownButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          value: groupId,
          underline: const SizedBox(),
          items: [
            const DropdownMenuItem(
              value: -1,
              child: Text(
                'Add...',
              ),
            ),
            if (data.isNotEmpty)
              const DropdownMenuItem(
                value: -2,
                child: Text(
                  'Reorder...',
                ),
              ),
            ...data.map(
              (e) => DropdownMenuItem(
                value: e.id,
                child: Text(
                  GroupOptions(e).display.val,
                ),
              ),
            ),
          ],
          onChanged: (int? value) {
            var left = ref.read(leftNavigator);
            var right = ref.read(rightNavigator);
            if (value == -1) {
              Adaptive.useTwoPaneUI
                  ? right.goto(AddView.path)
                  : left.goto(AddView.path);
            } else if (value == -2) {
              GroupReorder(context).show(data);
            } else {
              ref.read(selectedGroupProvider.notifier).selectGroup(value ?? -1);
              Adaptive.useTwoPaneUI
                  ? right.goto(OptionsView.path)
                  : left.goto(ThreadView.path);
            }
          },
        ),
      ),
    );
  }
}

class BottomAppBarButton extends StatelessWidget {
  const BottomAppBarButton({
    super.key,
    this.active = false,
    this.enabled = true,
    required this.icon,
    this.onPressed,
  });

  final bool active;
  final bool enabled;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      color: active ? colorScheme.primary : null,
      icon: Icon(icon),
      onPressed: enabled ? onPressed : null,
    );
  }
}

class HomeActionButton extends HookConsumerWidget {
  const HomeActionButton(this.nav, {super.key});

  final NavigatorController nav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context).extension<NGroupTheme>()!;

    var controller = ref.read(writeController);
    var loader = ref.read(postsLoader);
    var nextCount = ref.read(threadsLoader).getNextCount();
    var nextThread = Settings.threadOnNext.val && loader.unread.value == 0;
    ref.watch(threadsProvider);
    var threadId = ref.watch(selectedThreadProvider);
    var groupId = ref.watch(selectedGroupProvider);

    useListenable(loader.unread);
    useListenable(controller.sendable);
    useListenable(nav.path);
    useListenable(Settings.nextThreadDirection);

    var refresh = Opacity(
      key: ValueKey('refresh ${groupId != -1}'),
      opacity: groupId == -1 ? 0.3 : 1.0,
      child: FloatingActionButton(
        mini: Adaptive.isDesktop,
        heroTag: null,
        onPressed: groupId == -1
            ? null
            : () => ref
                .read(groupDataProvider.notifier)
                .reload(ProgressDialog(context), SelectionDialog(context)),
        child: const Icon(Icons.refresh),
      ),
    );

    var fab = switch (nav.path.value) {
      'threads' when !Adaptive.useTwoPaneUI => refresh,
      'posts' when nextThread => badges.Badge(
          key: ValueKey(
              'next thread ${nextCount > 0} ${Settings.nextThreadDirection.val}'),
          ignorePointer: true,
          showBadge: Settings.unreadOnNext.val && nextCount > 0,
          position: badges.BadgePosition.topEnd(top: 0, end: -2),
          badgeContent: AnimatedSwitcher(
            duration: Durations.medium2,
            child: Text('$nextCount',
                key: ValueKey('next badge $nextCount'),
                style: TextStyle(fontSize: Adaptive.isDesktop ? 11 : 16)),
          ),
          badgeStyle: badges.BadgeStyle(
            badgeColor: theme.isNew!,
            shape: badges.BadgeShape.square,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          ),
          badgeAnimation: const badges.BadgeAnimation.fade(toAnimate: false),
          child: Opacity(
            opacity: nextCount == 0 ? 0.3 : 1.0,
            child: GestureDetector(
              onLongPress: () => Settings.nextThreadDirection.val =
                  Settings.nextThreadDirection.val == NextDirection.newer
                      ? NextDirection.older
                      : NextDirection.newer,
              child: FloatingActionButton(
                mini: Adaptive.isDesktop,
                heroTag: null,
                onPressed: nextCount == 0
                    ? null
                    : () => ref.read(threadsLoader).next(),
                child: RotatedBox(
                  quarterTurns:
                      Settings.nextThreadDirection.val == NextDirection.newer
                          ? 0
                          : 2,
                  child: const Icon(Icons.double_arrow),
                ),
              ),
            ),
          ),
        ),
      'posts' => badges.Badge(
          key: const ValueKey('next unread'),
          ignorePointer: true,
          showBadge: Settings.unreadOnNext.val && loader.unread.value > 0,
          position: badges.BadgePosition.topEnd(top: 0, end: -2),
          badgeContent: AnimatedSwitcher(
            duration: Durations.medium2,
            child: Text('${loader.unread.value}',
                key: ValueKey('unread badge ${loader.unread.value}'),
                style: TextStyle(fontSize: Adaptive.isDesktop ? 11 : 16)),
          ),
          badgeStyle: badges.BadgeStyle(
            badgeColor: theme.isNew!,
            shape: badges.BadgeShape.square,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          ),
          badgeAnimation: const badges.BadgeAnimation.fade(toAnimate: false),
          child: Opacity(
            opacity: loader.unread.value == 0 ? 0.3 : 1.0,
            child: FloatingActionButton(
              mini: Adaptive.isDesktop,
              heroTag: null,
              onPressed: loader.unread.value == 0
                  ? null
                  : () => ref.read(postsLoader).nextUnread(),
              child: const Icon(Icons.arrow_downward),
            ),
          )),
      'write' => Opacity(
          key: ValueKey('write ${controller.sendable.value}'),
          opacity: !controller.sendable.value ? 0.3 : 1.0,
          child: FloatingActionButton(
            mini: Adaptive.isDesktop,
            heroTag: null,
            onPressed: !controller.sendable.value
                ? null
                : () async {
                    await controller.send(context);
                    nav.goto(nav.tag == NavigatorController.left
                        ? ThreadView.path
                        : threadId == ''
                            ? OptionsView.path
                            : PostView.path);
                  },
            child: const Icon(Icons.send),
          ),
        ),
      _ => null,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: Durations.medium2,
          transform: fab == null
              ? Matrix4.identity().scaled(0.1, 0.1, 0.1)
              : Matrix4.identity(),
          alignment: Alignment.centerLeft,
          transformAlignment: Alignment.center,
          width: fab == null
              ? 0
              : Adaptive.isDesktop
                  ? 44
                  : 60,
          height: fab == null
              ? 0
              : Adaptive.isDesktop
                  ? 40
                  : 56,
          child: AnimatedSwitcher(
              duration: Durations.medium2,
              switchInCurve: Easing.standardAccelerate,
              switchOutCurve: Easing.standardDecelerate,
              child: fab ?? SizedBox.shrink(key: UniqueKey())),
        ),
        if (Adaptive.useTwoPaneUI) refresh,
      ],
    );
  }
}
