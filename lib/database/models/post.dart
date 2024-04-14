import 'package:isar/isar.dart';

part 'post.g.dart';

@Collection()
class Post {
  Id? id;
  @Index(composite: [CompositeIndex('number')])
  @Index(composite: [CompositeIndex('isNew')])
  late int groupId;
  @Index()
  late String threadId;
  late int number;
  @Index()
  late String messageId;

  late String subject;
  late String from;
  List<byte>? source;
  late DateTime dateTime;
  late List<String> references;
  late int bytes;

  late bool isNew;
  late bool isRead;
}
