import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';

abstract class NNTPException implements Exception {
  NNTPException(this.message);

  final String message;

  @override
  String toString() {
    return '$runtimeType: $message';
  }
}

class NNTPTimeoutException extends NNTPException {
  NNTPTimeoutException(super.message);
}

class NNTPReplyException extends NNTPException {
  NNTPReplyException(super.message);
}

class NNTPTemporaryException extends NNTPException {
  NNTPTemporaryException(super.message);
}

class NNTPPermanentException extends NNTPException {
  NNTPPermanentException(super.message);
}

class NNTPProtocolException extends NNTPException {
  NNTPProtocolException(super.message);
}

class NNTPDataException extends NNTPException {
  NNTPDataException(super.message);
}

class NNTPClient {
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
  bool connected = false;
  bool error = false;
  VoidCallback? onProgress;

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

  _getCapabilities() async {
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

  _getOverviewFmt() async {
    try {
      var data = await _longCommand('LIST OVERVIEW.FMT');
      _parseOverviewFmt(data);
    } on NNTPPermanentException {
      overviewFmt = [];
    }
  }

  _parseOverviewFmt(List<String> data) {
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

  Future<List<Map<String, dynamic>>> list() async {
    var data = await _longCommand('LIST');
    return data
        .map((d) => d.split(' '))
        .map((d) => {
              'name': d[0],
              'last': int.parse(d[1]),
              'first': int.parse(d[2]),
              'flag': d[3]
            })
        .toList();
  }

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

  Future<List<Map<String, dynamic>>> xover(int start, int end) async {
    var data = await _longCommand('XOVER $start-$end');
    return _parseOverview(data);
  }

  Future<List<Map<String, dynamic>>> _parseOverview(List<String> data) async {
    var overview = <Map<String, dynamic>>[];
    for (var d in data) {
      var tokens = d.split('\t');
      var number = int.parse(tokens[0]);
      if (tokens.length - 1 < defaultOverviewFmt.length) {
        throw NNTPDataException(
            'OVER/XOVER response fewer than default fields');
      }
      var fields = Map<String, dynamic>.fromIterables(
          defaultOverviewFmt, tokens.sublist(1, defaultOverviewFmt.length + 1));
      fields['number'] = number;
      // fields[defaultOverviewFmt[0]] =
      //     MailCodec.decodeHeader(fields[defaultOverviewFmt[0]]);
      // fields[defaultOverviewFmt[1]] =
      //     MailCodec.decodeHeader(fields[defaultOverviewFmt[1]]);
      fields[defaultOverviewFmt[2]] =
          DateCodec.decodeDate(fields[defaultOverviewFmt[2]]);
      fields[defaultOverviewFmt[5]] =
          int.tryParse(fields[defaultOverviewFmt[5]]) ?? 0;
      fields[defaultOverviewFmt[6]] =
          int.tryParse(fields[defaultOverviewFmt[6]]) ?? 0;

      overview.add(fields);
    }
    return overview;
  }

  Future<List<String>> article(String messageId) async {
    return await _longCommand('ARTICLE $messageId');
  }

  Future<String> post(String data) async {
    await _shortCommand('POST');
    _socket.write('$data\r\n.\r\n');
    await _socket.flush();
    return await _getResponse();
  }
}
