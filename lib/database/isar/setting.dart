import 'package:isar/isar.dart';

part 'setting.g.dart';

@Collection()
class Setting {
  Id? id;
  @Index(unique: true, replace: true)
  late String key;

  late String value;
}
