import 'fortune_tone.dart';
import 'oheng.dart';

class FortuneEvaluationContext {
  const FortuneEvaluationContext({
    required this.basisDate,
    required this.slot,
    required this.profileFingerprint,
    required this.language,
    required this.tone,
    required this.weatherOheng,
  });

  final DateTime basisDate;
  final TimeSlot slot;
  final String profileFingerprint;
  final String language;
  final FortuneTone tone;
  final Oheng? weatherOheng;

  int messageSeed({required int categoryIndex, required int score}) {
    return _stableHash(profileFingerprint) ^
        (basisDate.year * 10000 + basisDate.month * 100 + basisDate.day) ^
        (slot.index * 997) ^
        (weatherOheng?.index ?? -1) * 131 ^
        (categoryIndex * 31) ^
        (score * 17);
  }

  String get diagnosticFingerprint => stableFingerprint(profileFingerprint);

  static String stableFingerprint(String value) {
    return _stableHash(value).toRadixString(16);
  }

  static int _stableHash(String value) {
    var hash = 17;
    for (final unit in value.codeUnits) {
      hash = 37 * hash + unit;
    }
    return hash;
  }
}
