import 'dart:async';
import 'package:flutter/foundation.dart';

import '../settings/settings.dart';
import 'http_bridge.dart';
import 'nntp_client.dart';

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

class GroupInfo {
  final String name;
  final int first;
  final int last;
  int serverId = -1;
  String display = '';
  GroupInfo(this.name, this.first, this.last);
}

class MessageInfo {
  final int number;
  final String subject;
  final String from;
  final DateTime date;
  final String messageId;
  final String references;
  final int bytes;
  final int lines;
  MessageInfo(this.number, this.subject, this.from, this.date, this.messageId,
      this.references, this.bytes, this.lines);
}

abstract class NNTP {
  bool connected = false;
  bool error = false;
  VoidCallback? onProgress;

  Future<void> close({bool error = false});

  Future<List<GroupInfo>> list();

  Future<({int count, int first, int last})> group(String name);

  Future<List<MessageInfo>> xover(int start, int end);

  Future<List<String>> article(String messageId);

  Future<String> post(String text);

  static Future<NNTP?> connect(String host, int port) async {
    NNTP? client = (kIsWeb || Settings.useHTTPBridge.val)
        ? HTTPBridge(host, port)
        : await NNTPClient.connect(host, port);
    return client;
  }
}
