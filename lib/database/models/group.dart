import 'package:isar/isar.dart';

part 'group.g.dart';

@Collection()
class Group {
  Id? id;
  @Index()
  late int serverId;

  late String name;
  String options = '';
}
