import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';

import 'nntp.dart';

class NNTPClient extends NNTP {
  static const longResponse = [
    '100', // HELP
    '101', // CAPABILITIES
    '211', // LISTGROUP (also not multi-line with GROUP)
    '215', // LIST
    '220', // ARTICLE
    '221', // HEAD, XHDR
    '222', // BODY
    '224', // OVER, XOVER
    '225', // HDR
    '230', // NEWNEWS
    '231', // NEWGROUPS
    '282', // XGTITLE
  ];

  static const defaultOverviewFmt = [
    'subject',
    'from',
    'date',
    'message-id',
    'references',
    ':bytes',
    ':lines'
  ];

  static const overviewFmtAlternatives = {
    'bytes': ':bytes',
    'lines': ':lines',
  };

  final String host;
  final int port;

  var welcome = '';
  var capabilities = <String, List<String>>{};
  var overviewFmt = <String>[];

  late Socket _socket;
  late StreamIterator<String> _stream;
  late StreamSubscription<Uint8List> _subscription;
  late StreamController<Uint8List> _controller;

  NNTPClient._(this.host, this.port);

  static Future<NNTPClient?> connect(String host, int port) async {
    var client = NNTPClient._(host, port);
    await client._connect(host, port);
    return client.connected ? client : null;
  }

  Future<void> _connect(String host, int port) async {
    _socket =
        await Socket.connect(host, port, timeout: const Duration(seconds: 5));
    _socket.encoding = utf8;
    _controller = StreamController<Uint8List>();
    _subscription = _socket.listen((e) => _controller.add(e),
        onError: (_) => close(error: true), onDone: () => close(error: true));
    _stream = StreamIterator(const LineSplitter().bind(
        const Latin1Decoder(allowInvalid: true).bind(_controller.stream)));
    await _getResponse();
    await _getCapabilities();
    welcome = await _shortCommand('MODE READER');
    if (capabilities.isNotEmpty) {
      await _getOverviewFmt();
    }
    connected = true;
  }

  @override
  Future<void> close({bool error = false}) async {
    await _subscription.cancel();
    await _stream.cancel();
    await _socket.close();
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

  Future<String> _getStreamData() async {
    try {
      await _stream.moveNext().timeout(
            const Duration(seconds: 5),
            onTimeout: () =>
                throw NNTPTimeoutException('No response from server.'),
          );
      return _stream.current;
    } catch (e) {
      await close(error: true);
      rethrow;
    }
  }

  Future<String> _getResponse() async {
    var response = await _getStreamData();
    _checkResponse(response);
    return response;
  }

  Future<List<String>> _getLongResponse() async {
    var response = await _getStreamData();
    _checkResponse(response);

    var data = <String>[];
    while (true) {
      var line = await _getStreamData();
      if (line.startsWith('..')) {
        line = line.substring(1);
      } else if (line == '.') {
        break;
      }
      data.add(line);
      onProgress?.call();
    }
    return data;
  }

  Future<String> _shortCommand(String cmd) async {
    _socket.writeln(cmd);
    await _socket.flush();
    return await _getResponse();
  }

  Future<List<String>> _longCommand(String cmd) async {
    _socket.writeln(cmd);
    await _socket.flush();
    return await _getLongResponse();
  }

  Future<void> _getCapabilities() async {
    try {
      var data = await _longCommand('CAPABILITIES');
      data.map((d) => d.split(' '));
      capabilities = {
        for (var d in data.map((d) => d.split(' '))) d[0]: d.sublist(1)
      };
    } catch (e) {
      if (e is! NNTPException) {
        rethrow;
      }
      capabilities = {};
    }
  }

  Future<void> _getOverviewFmt() async {
    try {
      var data = await _longCommand('LIST OVERVIEW.FMT');
      _parseOverviewFmt(data);
    } on NNTPPermanentException {
      overviewFmt = [];
    }
  }

  void _parseOverviewFmt(List<String> data) {
    var fmt = <String>[];
    for (var d in data) {
      String name;
      if (d[0] == ':') {
        name = ':${d.substring(1).split(':')[0]}';
      } else {
        name = d.split(':')[0];
      }
      name = name.toLowerCase();
      name = overviewFmtAlternatives[name] ?? name;
      fmt.add(name);
    }
    if (fmt.length < defaultOverviewFmt.length) {
      throw NNTPDataException('LIST OVERVIEW.FMT response too short');
    }
    if (!listEquals(
        fmt.sublist(0, defaultOverviewFmt.length), defaultOverviewFmt)) {
      throw NNTPDataException('LIST OVERVIEW.FMT redefines default fields');
    }
    overviewFmt = fmt;
  }

  @override
  Future<List<GroupInfo>> list() async {
    var data = await _longCommand('LIST');
    return data
        .map((d) => d.split(' '))
        .map((d) => GroupInfo(d[0], int.parse(d[2]), int.parse(d[1])))
        .toList();
  }

  @override
  Future<({int count, int first, int last})> group(String name) async {
    var response = await _shortCommand('GROUP $name');
    if (!response.startsWith('211')) {
      throw NNTPReplyException(response);
    }
    var data = response.split(' ');
    var info = [0, 0, 0];

    var n = data.length;
    if (n > 1) info[0] = int.parse(data[1]);
    if (n > 2) info[1] = int.parse(data[2]);
    if (n > 3) info[2] = int.parse(data[3]);
    return (count: info[0], first: info[1], last: info[2]);
  }

  @override
  Future<List<MessageInfo>> xover(int start, int end) async {
    var data = await _longCommand('XOVER $start-$end');
    return _parseOverview(data);
  }

  Future<List<MessageInfo>> _parseOverview(List<String> data) async {
    var overview = <MessageInfo>[];
    for (var d in data) {
      var tokens = d.split('\t');
      var number = int.parse(tokens[0]);
      if (tokens.length - 1 < defaultOverviewFmt.length) {
        throw NNTPDataException(
            'OVER/XOVER response fewer than default fields');
      }
      var fields = Map<String, dynamic>.fromIterables(
          defaultOverviewFmt, tokens.sublist(1, defaultOverviewFmt.length + 1));
      var subject = fields[defaultOverviewFmt[0]];
      var from = fields[defaultOverviewFmt[1]];
      var date =
          DateCodec.decodeDate(fields[defaultOverviewFmt[2]]) ?? DateTime.now();
      var messageId = fields[defaultOverviewFmt[3]];
      var references = fields[defaultOverviewFmt[4]];
      var bytes = int.tryParse(fields[defaultOverviewFmt[5]]) ?? 0;
      var line = int.tryParse(fields[defaultOverviewFmt[6]]) ?? 0;
      var info = MessageInfo(
          number, subject, from, date, messageId, references, bytes, line);
      overview.add(info);
    }
    return overview;
  }

  @override
  Future<List<String>> article(String messageId) async {
    return await _longCommand('ARTICLE $messageId');
  }

  @override
  Future<String> post(String text) async {
    await _shortCommand('POST');
    _socket.write('$text\r\n.\r\n');
    await _socket.flush();
    return await _getResponse();
  }
}
