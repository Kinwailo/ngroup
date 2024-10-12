import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';

BaseClient getClient() {
  var client = HttpClient();
  client.userAgent = 'TelegramBot (like TwitterBot)';
  return IOClient(client);
}
