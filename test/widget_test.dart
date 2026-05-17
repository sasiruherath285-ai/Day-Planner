import 'package:day_planner/utils/timeline_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('timeline has 30-minute slots from 5 AM to 9 PM', () {
    final slots = generateDayTimelineLabels();
    expect(slots.first, '05:00 AM');
    expect(slots.last, '09:00 PM');
    expect(slots.length, 33);
  });

  test('month list spans 10 years from anchor', () {
    final months = generateMonthList(anchor: DateTime(2026, 5));
    expect(months.first, DateTime(2026, 5));
    expect(months.last.year, 2036);
    expect(months.last.month, 5);
  });
}
