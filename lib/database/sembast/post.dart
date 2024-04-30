class Post {
  int? id;
  late int groupId;
  late String threadId;
  late int number;
  late String messageId;

  late String subject;
  late String from;
  List<int>? source;
  late DateTime dateTime;
  late List<String> references;
  late int bytes;

  late bool isNew;
  late bool isRead;
}
