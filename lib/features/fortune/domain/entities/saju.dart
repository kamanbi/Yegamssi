import 'oheng.dart';

/// 사주(四柱) — 년주/월주/일주/시주
class Saju {
  const Saju({
    required this.yearStem,
    required this.yearBranch,
    required this.monthStem,
    required this.monthBranch,
    required this.dayStem,
    required this.dayBranch,
    required this.hourStem,
    required this.hourBranch,
    required this.ohengCount,
  });

  final HeavenlyStem yearStem;
  final EarthlyBranch yearBranch;
  final HeavenlyStem monthStem;
  final EarthlyBranch monthBranch;
  final HeavenlyStem dayStem;
  final EarthlyBranch dayBranch;
  final HeavenlyStem hourStem;
  final EarthlyBranch hourBranch;

  /// 오행별 카운트 (천간+지지 합계, 0~8)
  final Map<Oheng, int> ohengCount;

  /// 가장 많은 오행
  Oheng get dominant {
    var maxCount = -1;
    var result = Oheng.to;
    for (final e in ohengCount.entries) {
      if (e.value > maxCount) {
        maxCount = e.value;
        result = e.key;
      }
    }
    return result;
  }

  /// 지배 오행의 강도
  OhengStrength get dominantStrength {
    final count = ohengCount[dominant] ?? 0;
    if (count >= 3) return OhengStrength.ex;
    return OhengStrength.df;
  }
}
