import 'package:http/browser_client.dart';
import 'package:http/http.dart';

BaseClient getClient() {
  return BrowserClient();
}
