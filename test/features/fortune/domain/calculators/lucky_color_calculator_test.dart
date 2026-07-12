import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/fortune/domain/calculators/lucky_color_calculator.dart';
import 'package:yegamssi/features/fortune/domain/calculators/saju_calculator.dart';
import 'package:yegamssi/features/fortune/domain/entities/oheng.dart';

void main() {
  final saju = SajuCalculator.calculate(DateTime(1990, 5, 15), 9);
  final baseScores = <FortuneCategory, int>{
    FortuneCategory.overall: 68,
    FortuneCategory.money: 64,
    FortuneCategory.love: 72,
    FortuneCategory.work: 61,
    FortuneCategory.health: 75,
    FortuneCategory.decision: 66,
  };

  LuckyColorInput inputFor({
    DateTime? date,
    TimeSlot slot = TimeSlot.morning,
    Map<FortuneCategory, int>? scores,
    Oheng? weatherOheng = Oheng.su,
  }) => LuckyColorInput(
    saju: saju,
    basisDate: date ?? DateTime(2026, 6, 23),
    slot: slot,
    scores: scores ?? baseScores,
    weatherOheng: weatherOheng,
  );

  test('returns the same color for the same fortune input', () {
    final first = LuckyColorCalculator.calculate(inputFor());
    final second = LuckyColorCalculator.calculate(inputFor());

    expect(first.hexCode, second.hexCode);
    expect(first.hue, second.hue);
  });

  test('changes color when the daily fortune context changes', () {
    final first = LuckyColorCalculator.calculate(inputFor());
    final nextDay = LuckyColorCalculator.calculate(
      inputFor(date: DateTime(2026, 6, 24)),
    );
    final afternoon = LuckyColorCalculator.calculate(
      inputFor(slot: TimeSlot.afternoon),
    );

    expect(nextDay.hexCode, isNot(first.hexCode));
    expect(afternoon.hexCode, isNot(first.hexCode));
  });

  test('changes color when score inputs change and outputs a hex color', () {
    final changedScores = Map<FortuneCategory, int>.from(baseScores)
      ..[FortuneCategory.overall] = 35;
    final first = LuckyColorCalculator.calculate(inputFor());
    final changed = LuckyColorCalculator.calculate(
      inputFor(scores: changedScores),
    );

    expect(changed.hexCode, isNot(first.hexCode));
    expect(changed.hexCode, matches(RegExp(r'^#[0-9A-F]{6}$')));
  });
}
