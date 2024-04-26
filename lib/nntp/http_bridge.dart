import 'dart:convert';

import 'package:enough_mail/enough_mail.dart';
import 'package:http/http.dart' as http;

import 'nntp.dart';

class HTTPBridgeException extends NNTPException {
  HTTPBridgeException(super.message);
}

class HTTPBridge extends NNTP {
  final String host;
  final int port;

  String _lastGroup = '';

  static const bridgeUrl =
      'https://asia-east2-moonlit-sphinx-420604.cloudfunctions.net/http2nntp';

  HTTPBridge(this.host, this.port) {
    connected = true;
  }

  Future<http.Response> httpPost(Map<String, Object> cmd) async {
    var url = Uri.parse(bridgeUrl);
    var headers = {'Content-type': 'application/json'};
    var req = {'server': host, 'port': port};
    req.addAll(cmd);
    var resp = await http.post(url, headers: headers, body: json.encode(req));
    if (resp.statusCode >= 400) {
      throw HTTPBridgeException('Error on HTTP brigde');
    }
    var data = json.decode(resp.body);
    if (data is Map && data.containsKey('error')) {
      throw HTTPBridgeException(data['error']);
    }
    return resp;
  }

  @override
  Future<void> close({bool error = false}) async {
    connected = false;
    if (error) this.error = true;
  }

  @override
  Future<List<GroupInfo>> list() async {
    var cmd = {'cmd': 'list'};
    var resp = await httpPost(cmd);
    var data = json.decode(resp.body) as List;
    return data
        .map((d) => GroupInfo(d['group'], d['first'], d['last']))
        .toList();
  }

  @override
  Future<({int count, int first, int last})> group(String name) async {
    _lastGroup = name;
    var cmd = {'cmd': 'group', 'group': name};
    var resp = await httpPost(cmd);
    var data = json.decode(resp.body) as Map;
    int count = data['count'];
    int first = data['first'];
    int last = data['last'];
    return (count: count, first: first, last: last);
  }

  @override
  Future<List<MessageInfo>> xover(int start, int end) async {
    var cmd = {'cmd': 'xover', 'group': _lastGroup, 'start': start, 'end': end};
    var resp = await httpPost(cmd);
    var data = json.decode(resp.body) as List;
    return data.map((d) {
      var date = DateCodec.decodeDate(d['date']) ?? DateTime.now();
      var bytes = int.tryParse(d[':bytes']) ?? 0;
      var line = int.tryParse(d[':lines']) ?? 0;
      return MessageInfo(d['number'], d['subject'], d['from'], date,
          d['message-id'], d['references'], bytes, line);
    }).toList();
  }

  @override
  Future<List<String>> article(String messageId) async {
    var cmd = {'cmd': 'article', 'message_id': messageId};
    var resp = await httpPost(cmd);
    var data = json.decode(resp.body) as List;
    return data.cast();
  }

  @override
  Future<String> post(String text) async {
    var cmd = {'cmd': 'post', 'text': text};
    var resp = await httpPost(cmd);
    var data = json.decode(resp.body) as String;
    return data;
  }
}
