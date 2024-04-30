import 'dart:math';

import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/adaptive.dart';
import '../database/database.dart';
import '../database/models.dart';
import '../home/home_controller.dart';
import '../nntp/nntp_service.dart';
import '../post/thread_controller.dart';
import '../post/thread_view.dart';
import '../settings/settings.dart';
import '../widgets/progress_dialog.dart';
import '../widgets/selection_dialog.dart';
import 'add_view.dart';
import 'group_options.dart';

final groupListProvider = StreamProvider<List<Group>>((ref) {
  return AppDatabase.get.groupListStream().map((g) => g.sorted((a, b) {
        var index = Settings.groupOrder.val.indexOf(a.id!);
        if (index == -1) return a.id!.compareTo(b.id!);
        var index2 = Settings.groupOrder.val.indexOf(b.id!);
        if (index2 == -1) return -1;
        return index.compareTo(index2);
      }));
});

final selectedGroupProvider =
    NotifierProvider<SelectedGroupNotifier, int>(SelectedGroupNotifier.new);

final groupDataProvider =
    AsyncNotifierProvider<GroupDataNotifier, GroupData>(GroupDataNotifier.new);

class SelectedGroupNotifier extends Notifier<int> {
  @override
  int build() {
    return Settings.group.val;
  }

  void selectGroup(int id) async {
    var group = await AppDatabase.get.getGroup(id);
    id = group == null ? -1 : id;
    state = id;
    Settings.group.val = id;
  }
}

class GroupData {
  const GroupData(this.server, this.group, this.options);
  final Server server;
  final Group group;
  final GroupOptions options;
}

class GroupDataNotifier extends AsyncNotifier<GroupData> {
  @override
  Future<GroupData> build() async {
    var id = ref.watch(selectedGroupProvider);
    var group = await AppDatabase.get.getGroup(id);
    if (group == null) throw Exception('Cannot load group.');

    var server = await AppDatabase.get.getServer(group.serverId);
    if (server == null) throw Exception('Cannot load server.');

    return GroupData(server, group, GroupOptions(group));
  }

  void resetGroup(ProgressDialog pd) async {
    var data = await future;

    ref.invalidate(selectedThreadProvider);
    pd
      ..message.value = 'Removing data...'
      ..show();

    await AppDatabase.get.resetGroup(data.group.id!);
    data.options.lastView.val = -1;
    data.options.lastDownload.val = -1;
    pd.completed.value = true;
  }

  Future<void> markAllRead() async {
    var data = await future;
    await AppDatabase.get.markAllThreadsRead(data.group.id!);
    await AppDatabase.get.markAllPostsRead(data.group.id!);
  }

  Future<void> resetAllNew() async {
    var data = await future;
    await AppDatabase.get.resetAllNewPosts(data.group.id!);
    await AppDatabase.get.resetAllNewThreads(data.group.id!);
  }

  Future<void> deleteGroup(ProgressDialog pd) async {
    var data = await future;

    ref.invalidate(selectedThreadProvider);
    pd
      ..message.value = 'Removing data...'
      ..show();
    await _deleteGroup(data.group);

    pd.completed.value = true;
  }

  Future<void> _deleteGroup(Group group) async {
    var id = -1;
    var groups = await AppDatabase.get.groupList();
    if (Settings.groupOrder.val.isEmpty) {
      Settings.groupOrder.val = groups.map((e) => e.id!).toList();
    }
    if (groups.length > 1) {
      id = Settings.groupOrder.val[0];
      id = group.id == id ? Settings.groupOrder.val[1] : id;
    }
    Settings.groupOrder.val.remove(group.id!);
    Settings.groupOrder.update();
    if (id == -1) {
      var nav = Adaptive.useTwoPaneUI ? rightNavigator : leftNavigator;
      ref.read(nav).goto(AddView.path);
    } else if (!Adaptive.useTwoPaneUI) {
      ref.read(leftNavigator).goto(ThreadView.path);
    }
    await AppDatabase.get.deleteGroup(group.id!);
    ref.read(selectedGroupProvider.notifier).selectGroup(id);
  }

  void editServer(Server server) async {
    await AppDatabase.get.updateServer(server);
  }

  void deleteServer(Server server, ProgressDialog pd) async {
    var data = await future;

    ref.invalidate(selectedThreadProvider);
    pd
      ..message.value = 'Removing data...'
      ..show();

    var groups = await AppDatabase.get.groupList(serverId: server.id!);
    for (var e in groups.where((e) => e.id != data.group.id)) {
      await AppDatabase.get.deleteGroup(e.id!);
    }
    await _deleteGroup(data.group);
    await AppDatabase.get.deleteServer(server.id!);

    pd.completed.value = true;
  }

  void identityRemoved(int index) async {
    var groups = await AppDatabase.get.groupList();
    for (var group in groups) {
      var options = GroupOptions(group);
      var id = options.identity.val;
      if (id == index) options.identity.val = -1;
      if (id > index) options.identity.val = id - 1;
    }
    await AppDatabase.get.updateGroups(groups);
    ref.invalidateSelf();
  }

  void reload(
    ProgressDialog pd,
    SelectionDialog sd, {
    bool silently = false,
  }) async {
    var data = await future;
    data.options.firstRefresh.val = false;

    pd.message.value = 'Downloading...';
    pd.show();

    if (!silently) await resetAllNew();
    data.options.lastView.val = data.options.lastDownload.val;

    try {
      var nntp = await NNTPService.fromGroup(data.group.id!);
      var (:count, :first, :last) = await nntp!.getGroupRange(data.group.id!);

      first = max(first, last - count + 1);
      first = max(first, data.options.lastDownload.val + 1);
      int total = last - first + 1;
      if (last > first + data.options.refreshMax.val - 1) {
        last = first + data.options.refreshMax.val - 1;
      }
      count = first > last ? 0 : last - first + 1;

      if (count == 0) {
        pd.message.value = 'Removing old data...';
        await AppDatabase.get.sweepGroup(data.group.id!,
            data.options.lastDownload.val - data.options.keepMessage.val);

        pd.message.value = 'No new post.';
        pd.completed.value = true;
        return;
      }

      if (total > data.options.refreshMax.val && data.options.askIfMore.val) {
        pd.close();
        var action = await sd.show(
            '$total posts in server',
            [
              'Download all',
              'Continue to next ${data.options.refreshMax.val}',
              'Skip to newest ${data.options.refreshMax.val}'
            ],
            dismissible: false);

        if (action == 0) {
          count = total;
        }
        if (action != 1) {
          last = first + total - 1;
        }
        if (action == 2) {
          first = last - count + 1;
        }
        pd.show();
      }
      data.options.lastDownload.val = last;

      nntp.onProgress(() {
        pd.max.value = count;
        pd.prepare.value = false;
        pd.step(1);
        pd.message.value =
            'Downloading ${pd.progress.value} / ${pd.max.value}.';
      });

      var (:threads, :posts) = await nntp.reloadGroup(
          data.group.id!, first, last, data.options.charset.val);
      nntp.onProgress(null);

      pd.message.value = 'Removing old data...';
      pd.prepare.value = true;
      await AppDatabase.get.sweepGroup(data.group.id!,
          data.options.lastDownload.val - data.options.keepMessage.val);

      var msg = threads == 0 ? 'Downloaded ' : 'Downloaded $threads thread';
      msg += threads > 1 ? 's' : '';
      msg += threads > 0 ? ' and ' : '';
      msg += '$posts post';
      msg += posts > 1 ? 's.' : '.';
      pd.message.value = msg;
      pd.completed.value = true;
    } catch (e) {
      pd.message.value = e.toString();
      pd.error.value = true;
    }
  }
}
