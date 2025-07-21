import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return "${date.day}.${date.month}.${date.year}";
}

String formatDateTime(DateTime dateTime) {
  return DateFormat('dd.MM.yyyy HH:mm:ss').format(dateTime);
}
