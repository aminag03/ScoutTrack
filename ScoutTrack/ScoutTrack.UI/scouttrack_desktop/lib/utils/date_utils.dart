import 'package:intl/intl.dart';

String formatDate(DateTime? date) {
  if (date == null) return '';
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}.';
}

String formatDateTime(DateTime dateTime) {
  return DateFormat('dd.MM.yyyy. HH:mm:ss').format(dateTime);
}

DateTime parseDate(dynamic dateInput) {
  if (dateInput is DateTime) {
    return dateInput;
  } else if (dateInput is String) {
    if (dateInput.contains('.')) {
      final parts = dateInput.split('.');
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } else {
      return DateTime.parse(dateInput);
    }
  }
  throw Exception('Invalid date format');
}