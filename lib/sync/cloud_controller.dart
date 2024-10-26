import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../database/database.dart';
import '../database/models.dart';
import '../group/group_options.dart';
import 'google_drive.dart';

typedef DataEntry = Map<String, dynamic>;
typedef DataEntries = List<DataEntry>;

final cloudProvider = Provider<CloudController>((_) => CloudController());

class CloudController {
  CloudController() {
    GoogleDrive.i.addListener(loadCloudData);
  }

  final cloudData = ValueNotifier<DataEntry?>(null);
  final localData = ValueNotifier<DataEntry?>(null);

  Future<void> loadCloudData() async {
    cloudData.value = await GoogleDrive.i.read('groups.json') ??
        DataEntry.from({'servers': [], 'groups': []});
  }

  Future<void> loadLocalData() async {
    var servers = await AppDatabase.get.serverList();
    var groups = await AppDatabase.get.groupList();
    localData.value = {
      'servers': servers
          .map((e) => DataEntry.from({
                'host': '${e.address}:${e.port}',
                'user': e.user,
                'password': e.password,
                'secure': e.secure,
              }))
          .toList(),
      'groups': groups.map((e) {
        var server = servers.firstWhere((s) => s.id == e.serverId);
        var options = GroupOptions(e);
        return DataEntry.from({
          'name': e.name,
          'display': options.display.val,
          'options': e.options,
          'server': '${server.address}:${server.port}',
        });
      }).toList(),
    };
  }

  String getGroupId(DataEntry group) {
    return '${group['name']}@${group['server']}';
  }

  String getGroupDisplay(DataEntry group) {
    return group['name'] == group['display']
        ? group['name']
        : '${group['name']} (${group['display']})';
  }

  DataEntries getGroupList(DataEntry? data) {
    return data == null ? [] : DataEntries.from(data['groups'] as List);
  }

  List<String> getCommonGroups() {
    var cloud = getGroupList(cloudData.value);
    var local = getGroupList(localData.value);
    return cloud
        .where((c) => local.any((l) => getGroupId(l) == getGroupId(c)))
        .map(getGroupId)
        .toList();
  }

  Future<void> syncToCloud(Map<String, DataEntry> list) async {
    if (cloudData.value == null || localData.value == null) return;
    var serversLocal = DataEntries.from(localData.value!['servers'] as List);
    var serversCloud = DataEntries.from(cloudData.value!['servers'] as List);
    var groupsCloud = DataEntries.from(cloudData.value!['groups'] as List);
    serversCloud = serversCloud
        .map((c) =>
            serversLocal.firstWhereOrNull((l) => c['host'] == l['host']) ?? c)
        .toList()
      ..addAll(serversLocal
          .whereNot((l) => serversCloud.any((c) => c['host'] == l['host'])));
    groupsCloud = groupsCloud
        .map((c) =>
            list.values
                .firstWhereOrNull((l) => getGroupId(l) == getGroupId(c)) ??
            c)
        .toList()
      ..addAll(list.values.whereNot(
          (l) => groupsCloud.any((c) => getGroupId(l) == getGroupId(c))));
    cloudData.value = {'servers': serversCloud, 'groups': groupsCloud};
    await GoogleDrive.i.write('groups.json', cloudData.value!);
  }

  Future<void> syncFromCloud(Map<String, DataEntry> list) async {
    if (cloudData.value == null) return;
    var serversCloud = DataEntries.from(cloudData.value!['servers'] as List);

    var servers = await AppDatabase.get.serverList();
    var hostIdMap = {for (var e in servers) '${e.address}:${e.port}': e.id};
    for (var data in serversCloud) {
      var host = '${data['host']}'.split(':');
      var port = int.tryParse(host[1]) ?? -1;
      var server = servers
          .firstWhereOrNull((e) => '${e.address}:${e.port}' == data['host']);
      if (server == null) {
        var id = await AppDatabase.get.addServer(host[0], port);
        hostIdMap[data['host']] = id;
        server = await AppDatabase.get.getServer(id);
        server!
          ..user = data['user']
          ..password = data['password']
          ..secure = data['secure'];
      } else {
        server
          ..address = host[0]
          ..port = port
          ..user = data['user']
          ..password = data['password']
          ..secure = data['secure'];
      }
      await AppDatabase.get.updateServer(server);
    }

    var groups = await AppDatabase.get.groupList();
    for (var data in list.values) {
      var group = groups.firstWhereOrNull((g) {
        var server = servers.firstWhereOrNull((s) => s.id == g.serverId);
        var host = '${server?.address}:${server?.port}';
        return g.name == data['name'] && host == data['server'];
      });
      if (group == null) {
        var id = hostIdMap[data['server']];
        if (id == null) continue;
        group = Group()
          ..name = data['name']
          ..options = data['options']
          ..serverId = id;
        var options = GroupOptions(group);
        options.identity.val = -1;
        options.lastView.val = -1;
        options.lastDownload.val = -1;
        group.options = options.json;
        await AppDatabase.get.addGroups([group]);
      } else {
        group.options = data['options'];
        var options = GroupOptions(group);
        options.identity.val = -1;
        options.lastView.val = -1;
        options.lastDownload.val = -1;
        group.options = options.json;
        await AppDatabase.get.updateGroup(group);
      }
    }
    loadLocalData();
  }

  Future<void> deleteOnCloud(Map<String, DataEntry> list) async {
    if (cloudData.value == null) return;
    var serversCloud = DataEntries.from(cloudData.value!['servers'] as List);
    var groupsCloud = DataEntries.from(cloudData.value!['groups'] as List);
    groupsCloud.removeWhere((e) => list.containsKey(getGroupId(e)));
    serversCloud
        .removeWhere((s) => !groupsCloud.any((g) => s['host'] == g['server']));
    cloudData.value = {'servers': serversCloud, 'groups': groupsCloud};
    await GoogleDrive.i.write('groups.json', cloudData.value!);
  }
}
