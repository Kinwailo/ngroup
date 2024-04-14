import 'package:intl/intl.dart';

extension DateTimeUtils on DateTime {
  String get string => _string(this);

  String _string(DateTime from) {
    var now = DateTime.now();
    var days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(from.year, from.month, from.day))
        .inDays;
    var df = from.year == now.year ? "dd/MM " : "dd/MM/yy ";
    var string = days == 0 ? '' : DateFormat(df).format(from);
    string += DateFormat("HH:mm").format(from);
    return string;
  }
}
