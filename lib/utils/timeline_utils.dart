import 'package:intl/intl.dart';

/// Generates 30-minute slots from 5:00 AM through 9:00 PM (inclusive).
List<String> generateDayTimelineLabels() {
  final slots = <String>[];
  var hour = 5;
  var minute = 0;

  while (hour < 21 || (hour == 21 && minute == 0)) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    slots.add(
      '${displayHour.toString().padLeft(2, '0')}:$minuteStr $period',
    );

    minute += 30;
    if (minute >= 60) {
      minute = 0;
      hour += 1;
    }
  }

  return slots;
}

String formatDateHeader(DateTime date) {
  return DateFormat('EEEE, MMMM d, yyyy').format(date);
}

String dateStorageKey(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

/// Months to display: from current month through 10 years ahead.
List<DateTime> generateMonthList({DateTime? anchor}) {
  final start = anchor ?? DateTime.now();
  final firstMonth = DateTime(start.year, start.month);
  final end = DateTime(start.year + 10, start.month);
  final months = <DateTime>[];
  var cursor = firstMonth;

  while (!cursor.isAfter(end)) {
    months.add(cursor);
    cursor = DateTime(cursor.year, cursor.month + 1);
  }

  return months;
}

int daysInMonth(DateTime month) {
  return DateTime(month.year, month.month + 1, 0).day;
}
