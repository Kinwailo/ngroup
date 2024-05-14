import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:sembast/sembast.dart';
// import 'package:sembast/sembast_memory.dart';
import 'package:sembast/timestamp.dart';
import 'package:synchronized/synchronized.dart';
import 'package:sembast_web/sembast_web.dart';

import '../database.dart';
import '../models.dart';

class DatabaseImp implements AppDatabase {
  DatabaseImp._(this._sembast);

  final Database _sembast;

  StreamController<List<Server>>? _serverListStreamController;
  StreamController<List<Group>>? _groupListStreamController;
  StreamController<dynamic>? _threadChangeStreamController;
  StreamController<dynamic>? _postChangeStreamController;

  final Lock _sembastLock = Lock();

  static Future<DatabaseImp> init(String path) async {
    var sembast = await databaseFactoryWeb.openDatabase('database');
    // var sembast = await databaseFactoryMemory.openDatabase('database');
    return DatabaseImp._(sembast);
  }

  @override
  Future<List<Setting>> settingList() async {
    var store = StoreRef<String, String>('Setting');
    var list = await store.find(_sembast);
    return list
        .map((e) => Setting()
          ..key = e.key
          ..value = e.value)
        .toList();
  }

  @override
  Future<Setting?> getSetting(String key) async {
    var store = StoreRef<String, String>('Setting');
    var value = await store.record('key').get(_sembast);
    return Setting()
      ..key = key
      ..value = value ?? '';
  }

  @override
  Future<void> updateSetting(Setting setting) async {
    await _sembast.transaction((txn) async {
      var store = StoreRef<String, String>('Setting');
      await store.record(setting.key).put(txn, setting.value);
    });
  }

  @override
  Future<int> addServer(String address, int port) async {
    return await _sembast.transaction((txn) async {
      var store = intMapStoreFactory.store('Server');
      return await store.add(txn, {'address': address, 'port': port});
    });
  }

  @override
  Future<void> updateServer(Server server) async {
    await _sembast.transaction((txn) async {
      var store = intMapStoreFactory.store('Server');
      await store
          .record(server.id!)
          .put(txn, {'address': server.address, 'port': server.port});
    });
  }

  Server _toServer(RecordSnapshot<int, Map<String, Object?>> snapshot) {
    return Server()
      ..id = snapshot.key
      ..address = snapshot['address'] as String
      ..port = snapshot['port'] as int;
  }

  @override
  Future<Server?> getServer(int id) async {
    var store = intMapStoreFactory.store('Server');
    var snapshot = await store.record(id).getSnapshot(_sembast);
    if (snapshot == null) return null;
    return _toServer(snapshot);
  }

  @override
  Future<void> deleteServer(int id) async {
    await _sembast.transaction((txn) async {
      var store = intMapStoreFactory.store('Server');
      await store.record(id).delete(txn);
    });
  }

  @override
  Stream<List<Server>> serverListStream() {
    if (_serverListStreamController != null) {
      _serverListStreamController?.close();
    }
    _serverListStreamController = StreamController();

    var store = intMapStoreFactory.store('Server');
    var query = store.query();
    var stream = query
        .onSnapshots(_sembast)
        .map((e) => e.map((e) => _toServer(e)).toList());
    _serverListStreamController?.addStream(stream);
    return _serverListStreamController!.stream;
  }

  @override
  Future<List<Server>> serverList() async {
    var store = intMapStoreFactory.store('Server');
    var list = await store.find(_sembast);
    return list
        .map((e) => Server()
          ..id = e.key
          ..address = e.value['address'] as String
          ..port = e.value['port'] as int)
        .toList();
  }

  @override
  Future<List<Group>> addGroups(List<Group> groups) async {
    return await _sembast.transaction((txn) async {
      var store = intMapStoreFactory.store('Group');
      var list = groups
          .map((e) =>
              {'serverId': e.serverId, 'name': e.name, 'options': e.options})
          .toList();
      var keys = await store.addAll(txn, list);
      return groups.mapIndexed((i, e) => e..id = keys.elementAt(i)).toList();
    });
  }

  @override
  Future<void> updateGroup(Group group) async {
    await _sembast.transaction((txn) async {
      var store = intMapStoreFactory.store('Group');
      await store.record(group.id!).put(txn, {
        'serverId': group.serverId,
        'name': group.name,
        'options': group.options
      });
    });
  }

  @override
  Future<void> updateGroups(List<Group> groups) async {
    await _sembast.transaction((txn) async {
      var store = intMapStoreFactory.store('Group');
      var keys = groups.map((e) => e.id!);
      var values = groups
          .map((e) =>
              {'serverId': e.serverId, 'name': e.name, 'options': e.options})
          .toList();
      await store.records(keys).update(txn, values);
    });
  }

  Group _toGroup(RecordSnapshot<int, Map<String, Object?>> snapshot) {
    return Group()
      ..id = snapshot.key
      ..serverId = snapshot.value['serverId'] as int
      ..name = snapshot.value['name'] as String
      ..options = snapshot.value['options'] as String;
  }

  @override
  Future<Group?> getGroup(int id) async {
    var store = intMapStoreFactory.store('Group');
    var snapshot = await store.record(id).getSnapshot(_sembast);
    if (snapshot == null) return null;
    return _toGroup(snapshot);
  }

  @override
  Stream<List<Group>> groupListStream({int? serverId}) {
    if (_groupListStreamController != null) {
      _groupListStreamController?.close();
    }
    _groupListStreamController = StreamController();

    var store = intMapStoreFactory.store('Group');
    var finder = Finder(filter: Filter.equals('serverId', serverId));
    var query = store.query(finder: serverId == null ? null : finder);
    var stream = query
        .onSnapshots(_sembast)
        .map((e) => e.map((e) => _toGroup(e)).toList());
    _groupListStreamController?.addStream(stream);
    return _groupListStreamController!.stream;
  }

  @override
  Future<List<Group>> groupList({int? serverId}) async {
    var store = intMapStoreFactory.store('Group');
    var finder = Finder(filter: Filter.equals('serverId', serverId));
    var list =
        await store.find(_sembast, finder: serverId == null ? null : finder);
    return list.map((e) => _toGroup(e)).toList();
  }

  @override
  Future<void> deleteGroup(int id) async {
    await _sembast.transaction((txn) async {
      var store = intMapStoreFactory.store('Group');
      await store.record(id).delete(txn);
    });
  }

  @override
  Future<void> resetGroup(int id) async {
    await _sembast.transaction((txn) async {
      var store = stringMapStoreFactory.store('Post');
      var finder = Finder(filter: Filter.equals('groupId', id));
      await store.delete(txn, finder: finder);
      store = stringMapStoreFactory.store('Thread');
      await store.delete(txn, finder: finder);
    });
  }

  @override
  Future<void> sweepGroup(int id, int number) async {
    await _sembast.transaction((txn) async {
      var store = stringMapStoreFactory.store('Post');
      var finder = Finder(
          filter:
              Filter.equals('groupId', id) & Filter.lessThan('number', number));
      await store.delete(txn, finder: finder);
      store = stringMapStoreFactory.store('Thread');
      await store.delete(txn, finder: finder);
    });
  }

  Thread _toThread(RecordSnapshot<String, Map<String, Object?>> snapshot) {
    return Thread()
      ..groupId = snapshot.value['groupId'] as int
      ..number = snapshot.value['number'] as int
      ..messageId = snapshot.key
      ..subject = snapshot.value['subject'] as String
      ..from = snapshot.value['from'] as String
      ..dateTime = (snapshot.value['dateTime'] as Timestamp).toDateTime()
      ..bytes = snapshot.value['bytes'] as int
      ..isNew = snapshot.value['isNew'] as bool
      ..isRead = snapshot.value['isRead'] as bool
      ..newCount = snapshot.value['newCount'] as int
      ..unreadCount = snapshot.value['unreadCount'] as int
      ..totalCount = snapshot.value['totalCount'] as int
      ..senders =
          (snapshot.value['senders'] as ListBase).cast<String>().toList()
      ..dates = (snapshot.value['dates'] as ListBase)
          .cast<Timestamp>()
          .map((e) => e.toDateTime())
          .toList()
      ..sizes = (snapshot.value['sizes'] as ListBase).cast<int>().toList();
  }

  @override
  Stream<dynamic> threadChangeStream(int groupId) {
    if (_threadChangeStreamController != null) {
      _threadChangeStreamController?.close();
    }
    _threadChangeStreamController = StreamController();

    var store = stringMapStoreFactory.store('Thread');
    var finder = Finder(filter: Filter.equals('groupId', groupId));
    var query = store.query(finder: finder);
    var stream = query.onCount(_sembast).distinct();
    _threadChangeStreamController?.addStream(stream);
    return _threadChangeStreamController!.stream;
  }

  @override
  Future<List<Thread>> threadList(int groupId) async {
    var store = stringMapStoreFactory.store('Thread');
    var finder = Finder(
      filter: Filter.equals('groupId', groupId),
      sortOrders: [SortOrder('number', false)],
    );
    var list = await store.find(_sembast, finder: finder);
    return list.map((e) => _toThread(e)).toList();
  }

  @override
  Future<void> addThreads(List<Thread> threads) async {
    await _sembast.transaction((txn) async {
      var store = stringMapStoreFactory.store('Thread');
      var keys = threads.map((e) => e.messageId);
      var list = threads
          .map((e) => {
                'groupId': e.groupId,
                'number': e.number,
                'subject': e.subject,
                'from': e.from,
                'dateTime': Timestamp.fromDateTime(e.dateTime),
                'bytes': e.bytes,
                'isNew': e.isNew,
                'isRead': e.isRead,
                'newCount': e.newCount,
                'unreadCount': e.unreadCount,
                'totalCount': e.totalCount,
                'senders': e.senders,
                'dates': e.dates.map((e) => Timestamp.fromDateTime(e)),
                'sizes': e.sizes,
              })
          .toList();
      await store.records(keys).put(txn, list);
    });
  }

  @override
  Future<Thread?> getThread(String messageId) async {
    var store = stringMapStoreFactory.store('Thread');
    var snapshot = await store.record(messageId).getSnapshot(_sembast);
    if (snapshot == null) return null;
    return _toThread(snapshot);
  }

  @override
  Future<List<Thread>> getThreads(List<String> messageIds) async {
    var store = stringMapStoreFactory.store('Thread');
    var list = await store.records(messageIds).getSnapshots(_sembast);
    return list.where((e) => e != null).map((e) => _toThread(e!)).toList();
  }

  @override
  Future<void> markThreadRead(String threadId, String messageId) async {
    await _sembastLock.synchronized(() async {
      var store = stringMapStoreFactory.store('Thread');
      var snapshot = await store.record(threadId).getSnapshot(_sembast);
      if (snapshot == null) return;
      var thread = _toThread(snapshot);
      if (snapshot.key == messageId) thread.isRead = true;
      thread.unreadCount--;
      await addThreads([thread]);
    });
  }

  @override
  Future<void> resetAllNewThreads(int groupId) async {
    var store = stringMapStoreFactory.store('Thread');
    var finder = Finder(
        filter: Filter.equals('groupId', groupId) &
            Filter.greaterThan('newCount', 0));
    var list = (await store.find(_sembast, finder: finder))
        .map((e) => _toThread(e)
          ..isNew = false
          ..newCount = 0)
        .toList();
    await addThreads(list);
  }

  @override
  Future<void> markAllThreadsRead(int groupId) async {
    var store = stringMapStoreFactory.store('Thread');
    var finder = Finder(
        filter: Filter.equals('groupId', groupId) &
            Filter.greaterThan('unreadCount', 0));
    var list = (await store.find(_sembast, finder: finder))
        .map((e) => _toThread(e)
          ..isRead = true
          ..unreadCount = 0)
        .toList();
    await addThreads(list);
  }

  Post _toPost(RecordSnapshot<String, Map<String, Object?>> snapshot) {
    return Post()
      ..groupId = snapshot.value['groupId'] as int
      ..threadId = snapshot.value['threadId'] as String
      ..number = snapshot.value['number'] as int
      ..messageId = snapshot.key
      ..subject = snapshot.value['subject'] as String
      ..from = snapshot.value['from'] as String
      ..source = (snapshot.value['source'] as ListBase?)?.cast<int>().toList()
      ..dateTime = (snapshot.value['dateTime'] as Timestamp).toDateTime()
      ..references =
          (snapshot.value['references'] as ListBase).cast<String>().toList()
      ..bytes = snapshot.value['bytes'] as int
      ..isNew = snapshot.value['isNew'] as bool
      ..isRead = snapshot.value['isRead'] as bool;
  }

  @override
  Stream<dynamic> postChangeStream(String threadId) {
    if (_postChangeStreamController != null) {
      _postChangeStreamController?.close();
    }
    _postChangeStreamController = StreamController();

    var store = stringMapStoreFactory.store('Post');
    var finder = Finder(filter: Filter.equals('threadId', threadId));
    var query = store.query(finder: finder);
    var stream = query.onCount(_sembast).distinct();
    _postChangeStreamController?.addStream(stream);
    return _postChangeStreamController!.stream;
  }

  @override
  Future<List<Post>> postList(String threadId) async {
    var store = stringMapStoreFactory.store('Post');
    var finder = Finder(
      filter: Filter.equals('threadId', threadId),
      sortOrders: [SortOrder('number')],
    );
    var list = await store.find(_sembast, finder: finder);
    return list.map((e) => _toPost(e)).toList();
  }

  Map<String, Object?> _postMap(Post post) {
    return {
      'groupId': post.groupId,
      'threadId': post.threadId,
      'number': post.number,
      'subject': post.subject,
      'from': post.from,
      'source': post.source,
      'dateTime': Timestamp.fromDateTime(post.dateTime),
      'references': post.references,
      'bytes': post.bytes,
      'isNew': post.isNew,
      'isRead': post.isRead,
    };
  }

  @override
  Future<void> addPosts(List<Post> posts) async {
    await _sembast.transaction((txn) async {
      var store = stringMapStoreFactory.store('Post');
      var keys = posts.map((e) => e.messageId);
      var list = posts.map((e) => _postMap(e)).toList();
      await store.records(keys).put(txn, list);
    });
  }

  @override
  Future<void> updatePost(Post post) async {
    await _sembast.transaction((txn) async {
      var store = stringMapStoreFactory.store('Post');
      await store.record(post.messageId).put(txn, _postMap(post));
    });
  }

  @override
  Future<Post?> getPost(String messageId) async {
    var store = stringMapStoreFactory.store('Post');
    var snapshot = await store.record(messageId).getSnapshot(_sembast);
    if (snapshot == null) return null;
    return _toPost(snapshot);
  }

  @override
  Future<void> resetAllNewPosts(int groupId) async {
    var store = stringMapStoreFactory.store('Post');
    var finder = Finder(
        filter:
            Filter.equals('groupId', groupId) & Filter.equals('isNew', true));
    var list = (await store.find(_sembast, finder: finder))
        .map((e) => _toPost(e)..isNew = false)
        .toList();
    await addPosts(list);
  }

  @override
  Future<void> markAllPostsRead(int groupId) async {
    var store = stringMapStoreFactory.store('Post');
    var finder = Finder(
        filter:
            Filter.equals('groupId', groupId) & Filter.equals('isRead', false));
    var list = (await store.find(_sembast, finder: finder))
        .map((e) => _toPost(e)..isRead = true)
        .toList();
    await addPosts(list);
  }
}
