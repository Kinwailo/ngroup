import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'nntp.dart';

class HTTPBridgeException extends NNTPException {
  HTTPBridgeException(super.message);
}

class HTTPBridge extends NNTP {
  final String host;
  final int port;

  String _lastGroup = '';

  // static const bridgeUrl =
  //     'https://asia-east2-moonlit-sphinx-420604.cloudfunctions.net/http2nntp';
  static const bridgeUrl = 'https://nntp.kinwailo.workers.dev/';

  HTTPBridge(this.host, this.port) {
    connected = true;
  }

  Future<http.Response> httpPost(Map<String, Object> cmd) async {
    var url = Uri.parse(bridgeUrl);
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    var req = {'server': host, 'port': port};
    req.addAll(cmd);
    var resp = await http.post(url, headers: headers, body: json.encode(req));
    if (resp.statusCode >= 400) {
      throw HTTPBridgeException('HTTP brigde error: ${resp.reasonPhrase}');
    }
    return resp;
  }

  @override
  Future<void> close({bool error = false}) async {
    connected = false;
    if (error) this.error = true;
  }

  void _checkResponse(String response) {
    if (response[3] != ' ' || int.tryParse(response.substring(0, 3)) == null) {
      throw NNTPReplyException(response);
    }
    switch (response[0]) {
      case '1':
      case '2':
      case '3':
        break;
      case '4':
        throw NNTPTemporaryException(response);
      case '5':
        throw NNTPPermanentException(response);
      default:
        throw NNTPProtocolException(response);
    }
  }

  @override
  Future<List<GroupInfo>> list() async {
    var cmd = {'cmd': 'list'};
    var resp = await httpPost(cmd);
    var data = resp.body.split(RegExp(r'\r\n|\n|\r'));
    _checkResponse(data.first);
    return data
        .skip(1)
        .map((d) => d.split(' '))
        .map((d) => GroupInfo(d[0], int.parse(d[2]), int.parse(d[1])))
        .toList();
  }

  @override
  Future<({int count, int first, int last})> group(String name) async {
    _lastGroup = name;
    var cmd = {'cmd': 'group', 'group': name};
    var resp = await httpPost(cmd);
    _checkResponse(resp.body);
    if (!resp.body.startsWith('211')) {
      throw NNTPReplyException(resp.body);
    }

    var data = resp.body.split(' ');
    var info = [0, 0, 0];

    var n = data.length;
    if (n > 1) info[0] = int.parse(data[1]);
    if (n > 2) info[1] = int.parse(data[2]);
    if (n > 3) info[2] = int.parse(data[3]);
    return (count: info[0], first: info[1], last: info[2]);
  }

  @override
  Future<List<MessageInfo>> xover(int start, int end) async {
    var cmd = {'cmd': 'xover', 'group': _lastGroup, 'start': start, 'end': end};
    var resp = await httpPost(cmd);
    var data = resp.body.split(RegExp(r'\r\n|\n|\r'));
    _checkResponse(data.first);
    return parseOverview(data.skip(1));
  }

  @override
  Future<List<String>> article(String messageId) async {
    var cmd = {'cmd': 'article', 'message_id': messageId};
    var resp = await httpPost(cmd);
    var data = resp.body.split(RegExp(r'\r\n|\n|\r'));
    _checkResponse(data.first);
    return data.skip(1).toList();
  }

  @override
  Future<String> post(String text) async {
    var cmd = {'cmd': 'post', 'text': text};
    var resp = await httpPost(cmd);
    _checkResponse(resp.body);
    return resp.body;
  }
}
