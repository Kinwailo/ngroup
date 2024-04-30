import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

import '../database/database.dart';
import '../database/models.dart';
import '../core/string_utils.dart';
import 'nntp.dart';

class NNTPService {
  static const int defaultPort = 119;

  static final Map<String, NNTPService> _pool = {};
  static final Lock _lock = Lock();

  final Lock _nntpLock = Lock();

  NNTP _client;
  int _serverId;
  final String _host;
  final int _port;

  NNTPService._(this._client, this._serverId, this._host, this._port);

  static Future<NNTPService?> fromGroup(int id) async {
    var group = await AppDatabase.get.getGroup(id);
    var server = await AppDatabase.get.getServer(group!.serverId);
    return await connectAddress(server!.address, server.port);
  }

  static Future<NNTPService?> connectAddress(String host, int port) async {
    return await _lock.synchronized(() async {
      final key = '$host:$port';
      var nntp = _pool[key];
      if (nntp == null) {
        var client = await NNTP.connect(host, port);
        if (client != null && client.connected) {
          var id = await _detectServerId(host, port);
          nntp = NNTPService._(client, id, host, port);
          _pool[key] = nntp;
        }
      }
      return nntp;
    });
  }

  static Future<int> _detectServerId(String host, int port) async {
    var servers = await AppDatabase.get.serverList();
    var check = servers
        .where((server) => server.address == host && server.port == port);
    if (check.isNotEmpty) {
      return check.first.id!;
    }
    return -1;
  }

  Future<bool> _checkConnection() async {
    if (!_client.error) return true;
    var client = await NNTP.connect(_host, _port);
    if (client == null || !client.connected) return false;
    _client = client;
    return true;
  }

  void onProgress(VoidCallback? action) {
    _client.onProgress = action;
  }

  Future<List<GroupInfo>> getGroupList() async {
    if (!await _checkConnection()) return [];
    return await _nntpLock.synchronized(() async {
      var ignore = (await AppDatabase.get.groupList(serverId: _serverId))
          .map((group) => group.name)
          .toSet();
      var list = (await _client.list())
          .where((e) => !ignore.contains(e.name))
          .map((e) => e..serverId = _serverId)
          .toList();
      return list;
    });
  }

  Future<List<Group>> addGroups(List<Group> list) async {
    return await _nntpLock.synchronized(() async {
      if (_serverId == -1) {
        _serverId = await AppDatabase.get.addServer(_host, _port);
      }
      list = list.map((e) => e..serverId = _serverId).toList();
      return await AppDatabase.get.addGroups(list);
    });
  }

  Future<({int count, int first, int last})> getGroupRange(int id) async {
    if (!await _checkConnection()) return (count: 0, first: 0, last: 0);
    return await _nntpLock.synchronized(() async {
      var group = await AppDatabase.get.getGroup(id);
      return await _client.group(group!.name);
    });
  }

  Future<String> post(String data) async {
    if (!await _checkConnection()) return '';
    return await _nntpLock.synchronized(() async {
      return await _client.post(data);
    });
  }

  Future<({int threads, int posts})> reloadGroup(
      int id, int first, int last, String charset) async {
    if (!await _checkConnection()) return (threads: 0, posts: 0);
    return await _nntpLock.synchronized(() async {
      return await _reloadGroup(id, first, last, charset);
    });
  }

  Future<({int threads, int posts})> _reloadGroup(
      int id, int first, int last, String charset) async {
    var list = await _client.xover(first, last);

    var children = <String, List<(String, DateTime, int)>>{};
    Thread updateChildren(Thread thread) {
      var c = children[thread.messageId];
      if (c != null) {
        thread.newCount += c.length;
        thread.unreadCount += c.length;
        thread.totalCount += c.length;
        thread.senders = [
          ...{...thread.senders, ...c.map((e) => e.$1)}
        ];
        thread.dates = [
          ...{...thread.dates, ...c.map((e) => e.$2)}
        ];
        thread.sizes = [
          ...{...thread.sizes, ...c.map((e) => e.$3)}
        ];
        children.remove(thread.messageId);
      }
      return thread;
    }

    var posts = list.map((e) {
      var p = Post()
        ..subject = e.subject.decodeText(charset).trim()
        ..from = e.from.decodeText(charset).trim()
        ..dateTime = e.date
        ..messageId = e.messageId
        ..number = e.number
        ..bytes = e.bytes
        ..isNew = true
        ..isRead = false
        ..groupId = id;
      var ref = e.references.trim();
      p.references = ref.isEmpty ? [] : ref.split(' ');
      p.threadId = p.references.isEmpty ? p.messageId : p.references[0];
      children
          .putIfAbsent(p.threadId, () => [])
          .add((p.from.sender, p.dateTime, p.bytes));
      return p;
    }).toList();

    var threads = list.where((e) => e.references == '').map((e) {
      var t = Thread()
        ..subject = e.subject.decodeText(charset).trim()
        ..from = e.from.decodeText(charset).trim()
        ..dateTime = e.date
        ..messageId = e.messageId
        ..number = e.number
        ..bytes = e.bytes
        ..isNew = true
        ..isRead = false
        ..newCount = 0
        ..unreadCount = 0
        ..totalCount = 0
        ..senders = []
        ..dates = []
        ..sizes = []
        ..groupId = id;
      return updateChildren(t);
    }).toList();

    var result = (threads: threads.length, posts: posts.length);
    var updates = await AppDatabase.get.getThreads(children.keys.toList());
    updates.forEach(updateChildren);
    threads.addAll(updates);

    await AppDatabase.get.addPosts(posts);
    await AppDatabase.get.addThreads(threads);
    return result;
  }

  Future<String> downloadBody(Post post) async {
    if (!await _checkConnection()) return '';
    return await _nntpLock.synchronized(() async {
      var data = await _client.article(post.messageId);
      var body = data.join('\r\n');
      if (kIsWeb) {
        post.source = Uint8List.fromList(latin1.encode(body));
      } else {
        post.source = Uint8List.fromList(gzip.encode(latin1.encode(body)));
      }
      AppDatabase.get.updatePost(post);
      return body;
    });
  }
}
