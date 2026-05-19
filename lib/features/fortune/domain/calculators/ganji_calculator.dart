import '../entities/oheng.dart';

/// 오늘의 간지 계산
class GanjiCalculator {
  GanjiCalculator._();

  /// 날짜 → (천간, 지지)
  static (HeavenlyStem, EarthlyBranch) todayGanji(DateTime date) {
    final base = DateTime(1900);
    final diff = date.difference(base).inDays;
    final stemIdx = ((diff % 10) + 10) % 10;
    final branchIdx = ((diff % 12) + 12) % 12;
    return (HeavenlyStem.values[stemIdx], EarthlyBranch.values[branchIdx]);
  }
}
