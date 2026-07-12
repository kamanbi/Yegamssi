import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/fortune/domain/entities/oheng.dart';

void main() {
  group('TimeSlot.forNow', () {
    test('uses previous afternoon before 06:00', () {
      final result = TimeSlot.forNow(now: DateTime(2026, 7, 1, 5, 59));

      expect(result.slot, TimeSlot.afternoon);
      expect(result.date.year, 2026);
      expect(result.date.month, 6);
      expect(result.date.day, 30);
    });

    test('uses morning from 06:00 until before 13:00', () {
      final start = TimeSlot.forNow(now: DateTime(2026, 7, 1, 6));
      final end = TimeSlot.forNow(now: DateTime(2026, 7, 1, 12, 59));

      expect(start.slot, TimeSlot.morning);
      expect(start.date.day, 1);
      expect(end.slot, TimeSlot.morning);
      expect(end.date.day, 1);
    });

    test('uses afternoon from 13:00', () {
      final result = TimeSlot.forNow(now: DateTime(2026, 7, 1, 13));

      expect(result.slot, TimeSlot.afternoon);
      expect(result.date.day, 1);
    });
  });
}
