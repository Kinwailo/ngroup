import 'dart:async';

import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/scroll_control.dart';
import '../database/database.dart';
import '../database/models.dart';
import '../group/group_controller.dart';
import '../home/home_controller.dart';
import '../settings/settings.dart';
import 'post_view.dart';

final selectedThreadProvider = StateProvider<String>((ref) {
  ref.watch(selectedGroupProvider);
  return '';
});

final threadsLoader = Provider<ThreadsLoader>(ThreadsLoader.new);

final threadsProvider = StateProvider<List<ThreadData>?>((ref) => null);

final threadListScrollProvider =
    Provider<ScrollControl>((_) => ScrollControl());

class ThreadData {
  ThreadData(this.thread);
  Thread thread;
  var index = -1;
  var match = false;
  var matchIndex = -1;
  var attachment = false;
}

class ThreadsLoader {
  final Ref ref;
  final _threads = <String, ThreadData>{};
  StreamSubscription? _subscription;

  ThreadsLoader(this.ref) {
    var scrollControl = ref.read(threadListScrollProvider);
    ref.listen(selectedGroupProvider, (_, groupId) {
      scrollControl.jumpTop();
      _subscription?.cancel();
      _subscription = Database.threadListStream(groupId).listen(
        (e) {
          scrollControl.saveLast((i) => getId(i));
          _threads.clear();
          _threads.addEntries(e.mapIndexed((i, t) => MapEntry(
              t.messageId,
              ThreadData(t)
                ..index = i
                ..attachment = t.bytes > Settings.attachmentSize.val)));
          ref.read(threadsProvider.notifier).state = _threads.values.toList();
        },
      );
    }, fireImmediately: true);
  }

  String getId(int index) {
    return index >= _threads.length
        ? ''
        : _threads.values.elementAt(index).thread.messageId;
  }

  int getIndex(String id) {
    return _threads[id]?.index ?? 0;
  }

  ThreadData? getThreadData(String threadId) {
    return _threads[threadId];
  }

  Iterable<ThreadData> getNextIterable() {
    var id = ref.read(selectedThreadProvider);
    if (id.isEmpty) return const Iterable.empty();
    var index = getIndex(id);
    var threads = Settings.nextThreadDirection.val == NextDirection.newer
        ? _threads.values.take(index).toList().reversed
        : _threads.values.skip(index + 1);
    return switch (Settings.nextThreadMode.val) {
      NextThread.nextWithNew =>
        threads.where((e) => e.thread.newCount > 0 && e.thread.unreadCount > 0),
      NextThread.nextWithUnread =>
        threads.where((e) => e.thread.unreadCount > 0),
      _ => threads,
    };
  }

  void next() {
    var next = getNext();
    if (next == null) return;
    select(next);
    var index = getIndex(next.thread.messageId);
    ref.read(threadListScrollProvider).scrollTo(index, onlyNotVisible: true);
  }

  int getNextCount() {
    return getNextIterable().length;
  }

  ThreadData? getNext() {
    return getNextIterable().firstOrNull;
  }

  void select(ThreadData? data) {
    ref.read(selectedThreadProvider.notifier).state =
        data?.thread.messageId ?? '';
    ref.read(rightNavigator).goto(PostView.path);
    ref.read(slidePaneProvider).slideToRight();
  }
}
