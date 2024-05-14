import 'package:isar/isar.dart';

import '../database.dart';
import '../models.dart';

class DatabaseImp implements AppDatabase {
  DatabaseImp._(this._isar);

  final Isar _isar;

  static Future<DatabaseImp> init(String path) async {
    var isar = await Isar.open(
      [
        SettingSchema,
        ServerSchema,
        GroupSchema,
        ThreadSchema,
        PostSchema,
      ],
      directory: path,
      name: 'database',
      compactOnLaunch: const CompactCondition(minBytes: 10 * 102424),
    );
    return DatabaseImp._(isar);
  }

  @override
  Future<List<Setting>> settingList() async {
    return _isar.settings.where().build().findAll();
  }

  @override
  Future<Setting?> getSetting(String key) async {
    return _isar.settings.where().keyEqualTo(key).findFirst();
  }

  @override
  Future<void> updateSetting(Setting setting) async {
    await _isar.writeTxn(() async {
      await _isar.settings.put(setting);
    });
  }

  @override
  Future<int> addServer(String address, int port) async {
    final server = Server()
      ..address = address
      ..port = port;
    return await _isar.writeTxn(() async {
      return await _isar.servers.put(server);
    });
  }

  @override
  Future<void> updateServer(Server server) async {
    await _isar.writeTxn(() async {
      await _isar.servers.put(server);
    });
  }

  @override
  Future<Server?> getServer(int id) async {
    return _isar.servers.get(id);
  }

  @override
  Future<void> deleteServer(int id) async {
    await _isar.writeTxn(() async {
      await _isar.servers.delete(id);
    });
  }

  @override
  Stream<List<Server>> serverListStream() {
    return _isar.servers.where().build().watch(fireImmediately: true);
  }

  @override
  Future<List<Server>> serverList() async {
    return _isar.servers.where().build().findAll();
  }

  @override
  Future<List<Group>> addGroups(List<Group> groups) async {
    return await _isar.writeTxn(() async {
      await _isar.groups.putAll(groups);
      return groups;
    });
  }

  @override
  Future<void> updateGroup(Group group) async {
    await _isar.writeTxn(() async {
      await _isar.groups.put(group);
    });
  }

  @override
  Future<void> updateGroups(List<Group> groups) async {
    await _isar.writeTxn(() async {
      await _isar.groups.putAll(groups);
    });
  }

  @override
  Future<Group?> getGroup(int id) async {
    return _isar.groups.get(id);
  }

  @override
  Stream<List<Group>> groupListStream({int? serverId}) {
    return _isar.groups
        .where()
        .optional(serverId != null, (q) => q.serverIdEqualTo(serverId!))
        .build()
        .watch(fireImmediately: true);
  }

  @override
  Future<List<Group>> groupList({int? serverId}) async {
    return _isar.groups
        .where()
        .optional(serverId != null, (q) => q.serverIdEqualTo(serverId!))
        .findAll();
  }

  @override
  Future<void> deleteGroup(int id) async {
    await resetGroup(id);
    await _isar.writeTxn(() async {
      await _isar.groups.delete(id);
    });
  }

  @override
  Future<void> resetGroup(int id) async {
    await _isar.writeTxn(() async {
      await _isar.posts.where().groupIdEqualToAnyNumber(id).deleteAll();
      await _isar.threads.where().groupIdEqualToAnyNumber(id).deleteAll();
    });
  }

  @override
  Future<void> sweepGroup(int id, int number) async {
    await _isar.writeTxn(() async {
      await _isar.posts
          .where()
          .groupIdEqualToNumberLessThan(id, number)
          .deleteAll();
      await _isar.threads
          .where()
          .groupIdEqualToNumberLessThan(id, number)
          .deleteAll();
    });
  }

  @override
  Stream<dynamic> threadChangeStream(int groupId) {
    return _isar.threads
        .where()
        .groupIdEqualToAnyNumber(groupId)
        .build()
        .watchLazy(fireImmediately: true);
  }

  @override
  Future<List<Thread>> threadList(int groupId) async {
    return _isar.threads
        .where(sort: Sort.desc)
        .groupIdEqualToAnyNumber(groupId)
        .findAll();
  }

  @override
  Future<void> addThreads(List<Thread> threads) async {
    await _isar.writeTxn(() async {
      await _isar.threads.putAll(threads);
    });
  }

  @override
  Future<Thread?> getThread(String messageId) async {
    return _isar.threads.where().messageIdEqualTo(messageId).findFirst();
  }

  @override
  Future<List<Thread>> getThreads(List<String> messageIds) async {
    return messageIds.isEmpty
        ? Future.value([])
        : _isar.threads
            .where()
            .anyOf(messageIds, (q, messageId) => q.messageIdEqualTo(messageId))
            .findAll();
  }

  @override
  Future<void> markThreadRead(String threadId, String messageId) async {
    await _isar.writeTxn(() async {
      var thread = await getThread(threadId);
      if (thread != null) {
        if (thread.messageId == messageId) thread.isRead = true;
        thread.unreadCount--;
        await _isar.threads.put(thread);
      }
    }, silent: true);
  }

  @override
  Future<void> resetAllNewThreads(int groupId) async {
    var threads = await _isar.threads
        .where()
        .groupIdEqualToNewCountGreaterThan(groupId, 0)
        .findAll();
    await _isar.writeTxn(() async {
      for (var thread in threads) {
        thread.isNew = false;
        thread.newCount = 0;
        await _isar.threads.put(thread);
      }
    });
  }

  @override
  Future<void> markAllThreadsRead(int groupId) async {
    var threads = await _isar.threads
        .where()
        .groupIdEqualToUnreadCountGreaterThan(groupId, 0)
        .findAll();
    await _isar.writeTxn(() async {
      for (var thread in threads) {
        thread.isRead = true;
        thread.unreadCount = 0;
        await _isar.threads.put(thread);
      }
    });
  }

  @override
  Stream<dynamic> postChangeStream(String threadId) {
    return _isar.posts
        .where()
        .threadIdEqualTo(threadId)
        .build()
        .watchLazy(fireImmediately: true);
  }

  @override
  Future<List<Post>> postList(String threadId) async {
    return _isar.posts.where().threadIdEqualTo(threadId).findAll();
  }

  @override
  Future<void> addPosts(List<Post> posts) async {
    await _isar.writeTxn(() async {
      await _isar.posts.putAll(posts);
    });
  }

  @override
  Future<void> updatePost(Post post) async {
    await _isar.writeTxn(() async {
      await _isar.posts.put(post);
    }, silent: true);
  }

  @override
  Future<Post?> getPost(String messageId) async {
    return _isar.posts.where().messageIdEqualTo(messageId).findFirst();
  }

  @override
  Future<void> resetAllNewPosts(int groupId) async {
    var posts =
        await _isar.posts.where().groupIdIsNewEqualTo(groupId, true).findAll();
    await _isar.writeTxn(() async {
      for (var post in posts) {
        post.isNew = false;
        await _isar.posts.put(post);
      }
    });
  }

  @override
  Future<void> markAllPostsRead(int groupId) async {
    var posts = await _isar.posts
        .where()
        .groupIdIsReadEqualTo(groupId, false)
        .findAll();
    await _isar.writeTxn(() async {
      for (var post in posts) {
        post.isRead = true;
        await _isar.posts.put(post);
      }
    });
  }
}
