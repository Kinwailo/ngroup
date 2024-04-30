import 'package:isar/isar.dart';

part 'server.g.dart';

@Collection()
class Server {
  Id? id;

  late String address;
  late int port;
}
