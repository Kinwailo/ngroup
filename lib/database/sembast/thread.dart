class Thread {
  int? id;
  late int groupId;
  late int number;
  late String messageId;

  late String subject;
  late String from;
  late DateTime dateTime;
  late int bytes;

  late bool isNew;
  late bool isRead;
  late int newCount;
  late int unreadCount;
  late int totalCount;
  late List<String> senders;
  late List<DateTime> dates;
  late List<int> sizes;
}
