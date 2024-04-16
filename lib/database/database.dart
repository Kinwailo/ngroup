import 'package:isar/isar.dart';

import 'models.dart';

class Database {
  Database._();

  static late Isar _isar;

  static Future<void> init(String path) async {
    _isar = await Isar.open(
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
  }

  static Future<List<Setting>> settingList() async {
    return _isar.settings.where().build().findAll();
  }

  static Future<int> addSetting(String key, String value) async {
    final setting = Setting()
      ..key = key
      ..value = value;
    return await _isar.writeTxn(() async {
      return await _isar.settings.put(setting);
    });
  }

  static Future<Setting?> getSetting(String key) async {
    return _isar.settings.where().keyEqualTo(key).findFirst();
  }

  static Future<int> updateSetting(Setting setting) async {
    return await _isar.writeTxn(() async {
      return await _isar.settings.put(setting);
    });
  }

  static Future<int> addServer(String address, int port) async {
    final server = Server()
      ..address = address
      ..port = port;
    return await _isar.writeTxn(() async {
      return await _isar.servers.put(server);
    });
  }

  static Future<void> updateServer(Server server) async {
    await _isar.writeTxn(() async {
      await _isar.servers.put(server);
    });
  }

  static Future<Server?> getServer(int id) async {
    return _isar.servers.get(id);
  }

  static Future<void> deleteServer(int id) async {
    await _isar.writeTxn(() async {
      await _isar.servers.delete(id);
    });
  }

  static Stream<List<Server>> serverListStream() {
    return _isar.servers.where().build().watch(fireImmediately: true);
  }

  static Future<List<Server>> serverList() async {
    return _isar.servers.where().build().findAll();
  }

  static Future<int> addGroup(int serverId, String name) async {
    final group = Group()
      ..serverId = serverId
      ..name = name;
    return await _isar.writeTxn(() async {
      return await _isar.groups.put(group);
    });
  }

  static Future<void> addGroups(List<Group> groups) async {
    await _isar.writeTxn(() async {
      await _isar.groups.putAll(groups);
    });
  }

  static Future<void> updateGroup(Group group) async {
    await _isar.writeTxn(() async {
      await _isar.groups.put(group);
    });
  }

  static Future<void> updateGroups(List<Group> groups) async {
    await _isar.writeTxn(() async {
      await _isar.groups.putAll(groups);
    });
  }

  static Future<Group?> getGroup(int id) async {
    return _isar.groups.get(id);
  }

  static Stream<List<Group>> groupListStream({int? serverId}) {
    return _isar.groups
        .where()
        .optional(serverId != null, (q) => q.serverIdEqualTo(serverId!))
        .build()
        .watch(fireImmediately: true);
  }

  static Future<List<Group>> groupList({int? serverId}) async {
    return _isar.groups
        .where()
        .optional(serverId != null, (q) => q.serverIdEqualTo(serverId!))
        .findAll();
  }

  static Future<void> deleteGroup(int id) async {
    await resetGroup(id);
    await _isar.writeTxn(() async {
      await _isar.groups.delete(id);
    });
  }

  static Future<void> resetGroup(int id) async {
    await _isar.writeTxn(() async {
      await _isar.posts.where().groupIdEqualToAnyNumber(id).deleteAll();
      await _isar.threads.where().groupIdEqualToAnyNumber(id).deleteAll();
    });
  }

  static Future<void> sweepGroup(int id, int number) async {
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

  static Stream<List<Thread>> threadListStream(int groupId) {
    return _isar.threads
        .where(sort: Sort.desc)
        .groupIdEqualToAnyNumber(groupId)
        .build()
        .watch(fireImmediately: true);
  }

  static Future<List<Thread>> threadList(int groupId) {
    return _isar.threads
        .where(sort: Sort.desc)
        .groupIdEqualToAnyNumber(groupId)
        .findAll();
  }

  static Future<void> addThreads(List<Thread> threads) async {
    await _isar.writeTxn(() async {
      await _isar.threads.putAll(threads);
    });
  }

  static Future<Thread?> getThread(String messageId) async {
    return _isar.threads.where().messageIdEqualTo(messageId).findFirst();
  }

  static Future<List<Thread>> getThreads(List<String> messageIds) async {
    return messageIds.isEmpty
        ? Future.value([])
        : _isar.threads
            .where()
            .anyOf(messageIds, (q, messageId) => q.messageIdEqualTo(messageId))
            .findAll();
  }

  static Future<void> markThreadRead(String threadId, String messageId) async {
    await _isar.writeTxn(() async {
      var thread = await getThread(threadId);
      if (thread != null) {
        if (thread.messageId == messageId) thread.isRead = true;
        thread.unreadCount--;
        await _isar.threads.put(thread);
      }
    });
  }

  static Future<void> resetAllNewThreads(int groupId) async {
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

  static Future<void> markAllThreadsRead(int groupId) async {
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

  static Stream<List<Post>> postListStream(String threadId) {
    return _isar.posts
        .where()
        .threadIdEqualTo(threadId)
        .build()
        .watch(fireImmediately: true);
  }

  static Stream<void> postListChange(String threadId) {
    return _isar.posts.where().threadIdEqualTo(threadId).build().watchLazy();
  }

  static Future<List<Post>> postList(String threadId) async {
    return _isar.posts.where().threadIdEqualTo(threadId).findAll();
  }

  static Future<List<Post>> groupPostList(int groupId) async {
    return _isar.posts.where().groupIdEqualToAnyNumber(groupId).findAll();
  }

  static Future<void> addPosts(List<Post> posts) async {
    await _isar.writeTxn(() async {
      await _isar.posts.putAll(posts);
    });
  }

  static Future<void> updatePost(Post post) async {
    await _isar.writeTxn(() async {
      await _isar.posts.put(post);
    }, silent: true);
  }

  static Future<Post?> getPost(String messageId) async {
    return _isar.posts.where().messageIdEqualTo(messageId).findFirst();
  }

  static Future<void> resetAllNewPosts(int groupId) async {
    var posts =
        await _isar.posts.where().groupIdIsNewEqualTo(groupId, true).findAll();
    await _isar.writeTxn(() async {
      for (var post in posts) {
        post.isNew = false;
        await _isar.posts.put(post);
      }
    });
  }

  static Future<void> markAllPostsRead(int groupId) async {
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
