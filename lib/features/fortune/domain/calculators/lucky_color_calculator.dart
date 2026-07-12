import '../entities/lucky_color.dart';
import '../entities/oheng.dart';
import '../entities/saju.dart';
import 'ganji_calculator.dart';

class LuckyColorInput {
  const LuckyColorInput({
    required this.saju,
    required this.basisDate,
    required this.slot,
    required this.scores,
    required this.weatherOheng,
  });

  final Saju saju;
  final DateTime basisDate;
  final TimeSlot slot;
  final Map<FortuneCategory, int> scores;
  final Oheng? weatherOheng;
}

class LuckyColorCalculator {
  LuckyColorCalculator._();

  static const _signatureSeed = 17;
  static const _signatureMultiplier = 37;
  static const _enumOffset = 1;
  static final _missingWeatherValue = Oheng.values.length;
  static const _hueCycle = 360;
  static const _minimumScore = 0;
  static const _maximumScore = 100;
  static const _scoreScale = 100.0;
  static const _minimumSaturation = 0.54;
  static const _saturationVariationSteps = 24;
  static const _minimumLightness = 0.42;
  static const _lightnessVariationSteps = 16;

  static LuckyColor calculate(LuckyColorInput input) {
    final dailyGanji = GanjiCalculator.todayGanji(input.basisDate);
    var signature = _signatureSeed;

    for (final element in Oheng.values) {
      final count = input.saju.ohengCount[element] ?? 0;
      signature = _mix(signature, count * (element.index + _enumOffset));
    }

    signature = _mix(signature, dailyGanji.$1.index + _enumOffset);
    signature = _mix(signature, dailyGanji.$2.index + _enumOffset);
    signature = _mix(
      signature,
      (input.weatherOheng?.index ?? _missingWeatherValue) + _enumOffset,
    );
    signature = _mix(signature, input.slot.index + _enumOffset);

    var totalScore = 0;
    for (final category in FortuneCategory.values) {
      final score = (input.scores[category] ?? _minimumScore)
          .clamp(_minimumScore, _maximumScore)
          .toInt();
      totalScore += score;
      signature = _mix(signature, score * (category.index + _enumOffset));
    }

    final averageScore = totalScore ~/ FortuneCategory.values.length;
    final hue = (signature % _hueCycle).toDouble();
    final saturation =
        _minimumSaturation +
        ((signature + averageScore) % _saturationVariationSteps) / _scoreScale;
    final lightness =
        _minimumLightness +
        ((signature + totalScore) % _lightnessVariationSteps) / _scoreScale;

    return LuckyColor(hue: hue, saturation: saturation, lightness: lightness);
  }

  static int _mix(int signature, int value) =>
      signature * _signatureMultiplier + value;
}
