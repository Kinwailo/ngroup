import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../core/block_painter.dart';
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
    useEffect(() {
      ref.read(leftNavigator).onPathChanged = (old, now) {
        if (old == ThreadView.path) {
          scrollControl.saveLast((i) => loader.getId(i));
        }
      };
      return null;
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
        var data = filtered[index];
        return ThreadTile(key: ValueKey(data.thread.messageId), data);
      },
    );
  }
}

TextSpan _senderTextSpan(BuildContext context, ThreadData data,
    {double opacity = 1.0}) {
  var theme = Theme.of(context).extension<NGroupTheme>()!;
  return TextSpan(
    text: '${data.thread.from.sender} ',
    style: TextStyle(color: theme.sender?.withOpacity(opacity)),
    recognizer: TapGestureRecognizer()
      ..onTap = () {
        if (Settings.blockSenders.val.contains(data.thread.from)) {
          Settings.blockSenders.val.remove(data.thread.from);
        } else {
          Settings.blockSenders.val.add(data.thread.from);
        }
        Settings.blockSenders.update();
      },
  );
}

class ThreadTile extends HookConsumerWidget {
  const ThreadTile(this.data, {super.key});

  final ThreadData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useListenable(Settings.contentScale);
    useListenable(Settings.blockSenders);
    return AnimatedCrossFade(
      duration: Durations.short2,
      crossFadeState:
          !data.match ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: const SizedBox.shrink(),
      secondChild: Visibility(
        maintainState: true,
        maintainAnimation: true,
        visible: data.match,
        child: Settings.blockSenders.val.contains(data.thread.from)
            ? ThreadBlockedTile(
                key: ValueKey('${data.thread.messageId} Blocked'), data)
            : ThreadNormalTile(
                key: ValueKey('${data.thread.messageId} Normal'), data),
      ),
    );
  }
}

class ThreadBlockedTile extends HookConsumerWidget {
  const ThreadBlockedTile(this.data, {super.key});

  final ThreadData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var color = data.matchIndex % 2 == 0
        ? colorScheme.background.withOpacity(0.3)
        : colorScheme.background.withOpacity(0.1);
    return CustomPaint(
      painter: BlockPainter(colorScheme.surfaceTint, Colors.yellow),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(Settings.contentScale.val / 100)),
        child: InkWell(
          onTap: () => ref.read(threadsLoader).select(data),
          child: TweenAnimationBuilder(
              tween: ColorTween(begin: color, end: color),
              duration: Durations.short4,
              builder: (context, value, _) {
                return Container(
                  width: double.infinity,
                  color: value,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                    child: Text.rich(
                      TextSpan(children: [
                        WidgetSpan(child: ThreadState(data)),
                        _senderTextSpan(context, data),
                        const WidgetSpan(child: SizedBox(width: 4)),
                        TextSpan(
                          text: data.thread.dateTime.toLocal().string,
                          style:
                              TextStyle(color: colorScheme.onTertiaryContainer),
                        ),
                      ]),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class ThreadNormalTile extends HookConsumerWidget {
  const ThreadNormalTile(this.data, {super.key});

  final ThreadData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var theme = Theme.of(context).extension<NGroupTheme>()!;
    var thread = data.thread;
    var state = ref.watch(threadStateProvider(data.thread.messageId));

    var countText = '${state.unreadCount} / ${thread.totalCount}';
    if (state.unreadCount == 0 || state.unreadCount == thread.totalCount) {
      countText = '${thread.totalCount}';
    }

    return Opacity(
      opacity: state.unreadCount == 0 ? 0.5 : 1.0,
      child: badges.Badge(
        ignorePointer: true,
        showBadge: data.match,
        position: badges.BadgePosition.topEnd(top: 22, end: 10),
        badgeContent: Text.rich(
          TextSpan(
            children: [
              if (state.newCount > 0 &&
                  state.newCount != state.unreadCount &&
                  state.newCount != thread.totalCount)
                WidgetSpan(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 4, top: 2, bottom: 3),
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
          badgeColor:
              (state.newCount > 0 && state.newCount == state.unreadCount) ||
                      state.newCount == thread.totalCount
                  ? theme.isNew!
                  : colorScheme.secondaryContainer,
          shape: badges.BadgeShape.square,
          borderRadius:
              BorderRadius.circular(16 * Settings.contentScale.val / 100),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        ),
        badgeAnimation: const badges.BadgeAnimation.fade(toAnimate: false),
        child: ThreadTileContent(data),
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
    var blocked = Settings.blockSenders.val.contains(data.thread.from);
    var state = ref.watch(threadStateProvider(data.thread.messageId));

    Widget widget = const SizedBox.shrink();
    if (blocked) {
      widget = Padding(
        padding: const EdgeInsets.only(right: 4, top: 2, bottom: 1),
        child: Icon(Icons.block,
            size: 16,
            color: state.isNew
                ? theme.isNew!
                : state.isRead
                    ? theme.isRead!
                    : theme.sender!),
      );
    } else if (state.isRead) {
      widget = Padding(
        padding: const EdgeInsets.only(right: 4, top: 2, bottom: 1),
        child: Icon(Icons.check,
            size: 16, color: state.isNew ? theme.isNew! : theme.isRead!),
      );
    } else if (state.isNew) {
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
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(Settings.contentScale.val / 100)),
            child: ListTile(
              minVerticalPadding: 16,
              tileColor: value,
              selectedTileColor: colorScheme.primaryContainer.withOpacity(0.5),
              selectedColor: colorScheme.onPrimaryContainer,
              title: Text(
                thread.subject.noLinebreak,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(child: ThreadState(data)),
                    _senderTextSpan(context, data),
                    const WidgetSpan(child: SizedBox(width: 4)),
                    TextSpan(
                      text: thread.dateTime.toLocal().string,
                      style: TextStyle(color: colorScheme.onTertiaryContainer),
                    ),
                    const WidgetSpan(child: SizedBox(width: 4)),
                    if (data.attachment)
                      const WidgetSpan(
                          child: Icon(Icons.attach_file, size: 16)),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: TextScaler.linear(Settings.contentScale.val / 100),
              ),
              selected: thread.messageId == selectedThread,
              onTap: () => ref.read(threadsLoader).select(data),
            ),
          );
        });
  }
}
