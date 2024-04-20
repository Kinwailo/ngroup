import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../core/string_utils.dart';
import '../core/datetime_utils.dart';
import '../core/theme.dart';
import '../group/group_controller.dart';
import '../home/filter_controller.dart';
import '../home/home_controller.dart';
import '../settings/settings.dart';
import 'thread_controller.dart';

class ThreadView extends HookConsumerWidget {
  const ThreadView({super.key});

  static var path = 'threads';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var threads = ref.watch(threadsProvider);
    var loader = ref.read(threadsLoader);
    var groupId = ref.read(selectedGroupProvider);

    var scrollControl = ref.read(threadListScrollProvider);
    ref.listen(threadsProvider,
        (_, __) => scrollControl.jumpLastId((id) => loader.getIndex(id)));
    useEffect(() {
      ref.read(leftNavigator).onPathChanged = (old, now) {
        if (old == ThreadView.path) {
          scrollControl.saveLast((i) => loader.getId(i));
        }
      };
      return null;
      // return () => scrollControl.saveLast((i) => loader.getId(i));
    });

    var filters = ref.read(filterProvider);
    int i = 0;
    var filtered = threads == null
        ? <ThreadData>[]
        : threads
            .map((e) => e..match = filters.filterThread(e.thread))
            .map((e) => e..matchIndex = e.match ? i++ : e.index)
            .toList();

    useAutomaticKeepAlive();
    useListenable(Listenable.merge(
        [filters, ...filters.filters.where((e) => e.useInThread)]));

    return ScrollablePositionedList.builder(
      key: ValueKey(threads),
      initialScrollIndex: loader.getIndex(scrollControl.lastId),
      initialAlignment: scrollControl.lastOffset,
      itemScrollController: scrollControl.itemScrollController,
      itemPositionsListener: scrollControl.itemPositionsListener,
      itemCount: filtered.length + 1,
      itemBuilder: (_, index) {
        if (groupId == -1) return const ListTile(title: Text('No group'));
        if (filtered.isEmpty) return const ListTile(title: Text('No post'));
        if (index >= filtered.length) return const SizedBox(height: 60);
        var thread = filtered[index];
        return ThreadTile(key: ValueKey(thread.thread.messageId), thread);
      },
    );
  }
}

class ThreadTile extends HookConsumerWidget {
  const ThreadTile(this.data, {super.key});

  final ThreadData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var theme = Theme.of(context).extension<NGroupTheme>()!;
    var thread = data.thread;

    var countText = '${thread.unreadCount} / ${thread.totalCount}';
    if (thread.unreadCount == 0 || thread.unreadCount == thread.totalCount) {
      countText = '${thread.totalCount}';
    }

    useListenable(Settings.contentScale);

    return AnimatedCrossFade(
      duration: Durations.short2,
      crossFadeState:
          !data.match ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: const SizedBox.shrink(),
      secondChild: Visibility(
        maintainState: true,
        maintainAnimation: true,
        visible: data.match,
        child: Opacity(
          opacity: thread.unreadCount == 0 ? 0.5 : 1.0,
          child: badges.Badge(
            ignorePointer: true,
            showBadge: data.match,
            position: badges.BadgePosition.topEnd(top: 22, end: 10),
            badgeContent: Text.rich(
              TextSpan(
                children: [
                  if (thread.newCount > 0 &&
                      thread.newCount != thread.unreadCount &&
                      thread.newCount != thread.totalCount)
                    WidgetSpan(
                        child: Padding(
                      padding:
                          const EdgeInsets.only(right: 4, top: 2, bottom: 3),
                      child: Icon(Icons.circle, size: 12, color: theme.isNew!),
                    )),
                  TextSpan(
                    text: countText,
                    style: TextStyle(color: colorScheme.onSecondaryContainer),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: TextScaler.linear(Settings.contentScale.val / 100),
            ),
            badgeStyle: badges.BadgeStyle(
              badgeColor: (thread.newCount > 0 &&
                          thread.newCount == thread.unreadCount) ||
                      thread.newCount == thread.totalCount
                  ? theme.isNew!
                  : colorScheme.secondaryContainer,
              shape: badges.BadgeShape.square,
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
            badgeAnimation: const badges.BadgeAnimation.fade(toAnimate: false),
            child: ThreadTileContent(data),
          ),
        ),
      ),
    );
  }
}

class ThreadState extends ConsumerWidget {
  const ThreadState(this.data, {super.key});

  final ThreadData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context).extension<NGroupTheme>()!;
    var thread = data.thread;

    Widget widget = const SizedBox.shrink();
    if (thread.isRead) {
      widget = Padding(
        padding: const EdgeInsets.only(right: 4, top: 2, bottom: 1),
        child: Icon(Icons.check,
            size: 16, color: thread.isNew ? theme.isNew! : theme.isRead!),
      );
    } else if (thread.isNew) {
      widget = Padding(
        padding: const EdgeInsets.only(right: 4, top: 2, bottom: 3),
        child: Icon(Icons.circle, size: 12, color: theme.isNew!),
      );
    }
    return widget;
  }
}

class ThreadTileContent extends HookConsumerWidget {
  const ThreadTileContent(this.data, {super.key});

  final ThreadData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var theme = Theme.of(context).extension<NGroupTheme>()!;

    var thread = data.thread;
    var selectedThread = ref.watch(selectedThreadProvider);
    var color = data.matchIndex % 2 == 0
        ? colorScheme.background
        : colorScheme.background.withOpacity(0.5);

    useListenable(Settings.contentScale);

    return TweenAnimationBuilder(
        tween: ColorTween(begin: color, end: color),
        duration: Durations.short4,
        builder: (context, value, _) {
          return ListTile(
            tileColor: value,
            selectedTileColor: colorScheme.primaryContainer.withOpacity(0.5),
            selectedColor: colorScheme.onPrimaryContainer,
            title: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  textScaler:
                      TextScaler.linear(Settings.contentScale.val / 100)),
              child: Text(
                thread.subject.noLinebreak,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(child: ThreadState(data)),
                  TextSpan(
                      text: '${thread.from.sender} ',
                      style: TextStyle(color: theme.sender)),
                  const WidgetSpan(child: SizedBox(width: 4)),
                  TextSpan(
                    text: thread.dateTime.toLocal().string,
                    style: TextStyle(color: colorScheme.onTertiaryContainer),
                  ),
                  const WidgetSpan(child: SizedBox(width: 4)),
                  if (data.attachment)
                    const WidgetSpan(child: Icon(Icons.attach_file, size: 16)),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: TextScaler.linear(Settings.contentScale.val / 100),
            ),
            selected: thread.messageId == selectedThread,
            onTap: () => ref.read(threadsLoader).select(data),
          );
        });
  }
}
