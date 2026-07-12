import '../../../fortune/domain/entities/oheng.dart';
import '../../../fortune/domain/entities/saju.dart';
import '../../../fortune/domain/calculators/ganji_calculator.dart';
import '../entities/monthly_category.dart';
import 'sinsal_calculator.dart';

/// 월간 예감씨 — 카테고리별 좋은 날/조심할 날 산정
class MonthlyDayScorer {
  MonthlyDayScorer._();

  // 카테고리별 담당 오행. enum 주석의 규칙을 따른다.
  // decision은 금 단독, travel은 오행 보조라 목·수(이동·흐름)를 절반 가중으로만 반영.
  static const _categoryOhengs = <MonthlyCategory, List<Oheng>>{
    MonthlyCategory.love: [Oheng.hwa, Oheng.mok],
    MonthlyCategory.work: [Oheng.geum, Oheng.to],
    MonthlyCategory.money: [Oheng.to, Oheng.geum],
    MonthlyCategory.relationship: [Oheng.hwa, Oheng.mok],
    MonthlyCategory.health: [Oheng.su, Oheng.mok],
    MonthlyCategory.decision: [Oheng.geum],
    MonthlyCategory.travel: [Oheng.mok, Oheng.su],
  };

  static const int _maxCoOccurrence = 3; // 4개 이상 동시 등장 방지 → 최대 3

  static Map<MonthlyCategory, ({List<int> goodDays, List<int> cautionDays})>
  scoreMonth({
    required Saju saju,
    required int targetYear,
    required int targetMonth,
    required int lastDayOfMonth,
    required String seed,
  }) {
    // 1. 각 날짜의 일진 산출
    final dayGanji = <int, (HeavenlyStem, EarthlyBranch)>{};
    for (var day = 1; day <= lastDayOfMonth; day++) {
      dayGanji[day] = GanjiCalculator.todayGanji(
        DateTime(targetYear, targetMonth, day),
      );
    }

    // 2. 카테고리별 날짜 점수
    final scores = <MonthlyCategory, Map<int, int>>{};
    for (final category in MonthlyCategory.values) {
      final perDay = <int, int>{};
      for (var day = 1; day <= lastDayOfMonth; day++) {
        perDay[day] = _dayScore(category, saju, dayGanji[day]!);
      }
      scores[category] = perDay;
    }

    // 3~4. 카테고리별 좋은 날/조심할 날 선정 (결정적 정렬)
    final result =
        <MonthlyCategory, ({List<int> goodDays, List<int> cautionDays})>{};
    for (final category in MonthlyCategory.values) {
      final ordered = _orderedDays(scores[category]!, seed);
      final total = lastDayOfMonth;

      final goodCount = (total * 0.175).round().clamp(4, 6);
      final cautionCount = (total * 0.125).round().clamp(3, 5);

      final goodDays = ordered.take(goodCount).toList();
      final cautionDays = ordered.reversed.take(cautionCount).toList();

      result[category] = (goodDays: goodDays, cautionDays: cautionDays);
    }

    // 6. 분산 규칙: 한 날짜가 4개 이상 카테고리 좋은 날에 동시 등장하면 초과분 교체
    _rebalanceGoodDays(result, scores, seed);

    return result;
  }

  // 하루 점수: 기본 오행 매칭 + 카테고리별 신살 가감
  static int _dayScore(
    MonthlyCategory category,
    Saju saju,
    (HeavenlyStem, EarthlyBranch) ganji,
  ) {
    final dayStemOheng = ganji.$1.oheng;
    final dayBranch = ganji.$2;

    var ohengScore = 0;
    for (final catOheng in _categoryOhengs[category]!) {
      ohengScore += _ohengRelation(dayStemOheng, catOheng);
    }

    // travel은 역마 중심이라 오행 매칭 가중치 절반
    if (category == MonthlyCategory.travel) {
      ohengScore = (ohengScore * 0.5).round();
    }

    final sinsal = switch (category) {
      MonthlyCategory.love =>
        SinsalCalculator.isDohwa(saju.dayBranch, dayBranch) ? 15 : 0,
      MonthlyCategory.relationship =>
        SinsalCalculator.isHap(saju.dayBranch, dayBranch) ? 15 : 0,
      MonthlyCategory.money =>
        SinsalCalculator.jaeseongOhengFor(saju.dayStem) == dayBranch.oheng
            ? 15
            : 0,
      MonthlyCategory.health =>
        SinsalCalculator.isChung(saju.dayBranch, dayBranch) ? -15 : 0,
      MonthlyCategory.travel =>
        SinsalCalculator.isYeokma(saju.dayBranch, dayBranch) ? 20 : 0,
      MonthlyCategory.work || MonthlyCategory.decision => 0,
    };

    return ohengScore + sinsal;
  }

  // 오행 관계: 동일 +10, 상생(catOheng를 dayStem이 생함) +20, 상극(catOheng가 dayStem을 극함) -20
  static int _ohengRelation(Oheng dayStemOheng, Oheng catOheng) {
    if (dayStemOheng == catOheng) return 10;
    // 상생: 木→火, 火→土, 土→金, 金→水, 水→木
    const saeng = {
      Oheng.mok: Oheng.hwa,
      Oheng.hwa: Oheng.to,
      Oheng.to: Oheng.geum,
      Oheng.geum: Oheng.su,
      Oheng.su: Oheng.mok,
    };
    // 상극: 木→土, 土→水, 水→火, 火→金, 金→木
    const gek = {
      Oheng.mok: Oheng.to,
      Oheng.to: Oheng.su,
      Oheng.su: Oheng.hwa,
      Oheng.hwa: Oheng.geum,
      Oheng.geum: Oheng.mok,
    };
    if (saeng[dayStemOheng] == catOheng) return 20; // 일간이 카테고리 오행을 생함
    if (gek[catOheng] == dayStemOheng) return -20; // 카테고리 오행이 일간을 극함
    return 0;
  }

  // 점수 내림차순 정렬. 동점은 (seed+day) 해시 오름차순으로 결정적 타이브레이크.
  static List<int> _orderedDays(Map<int, int> perDay, String seed) {
    final days = perDay.keys.toList();
    days.sort((a, b) {
      final cmp = perDay[b]!.compareTo(perDay[a]!);
      if (cmp != 0) return cmp;
      return _tiebreak(seed, a).compareTo(_tiebreak(seed, b));
    });
    return days;
  }

  static int _tiebreak(String seed, int day) => (seed + day.toString()).hashCode;

  // 분산 규칙: enum 순서대로 처리, 초과 카테고리에서 날짜를 차순위로 교체
  static void _rebalanceGoodDays(
    Map<MonthlyCategory, ({List<int> goodDays, List<int> cautionDays})> result,
    Map<MonthlyCategory, Map<int, int>> scores,
    String seed,
  ) {
    final counts = <int, int>{};
    for (final entry in result.values) {
      for (final d in entry.goodDays) {
        counts[d] = (counts[d] ?? 0) + 1;
      }
    }

    for (final category in MonthlyCategory.values) {
      final good = List<int>.from(result[category]!.goodDays);
      final caution = result[category]!.cautionDays;
      final ordered = _orderedDays(scores[category]!, seed);

      for (var i = 0; i < good.length; i++) {
        final day = good[i];
        if ((counts[day] ?? 0) <= _maxCoOccurrence) continue;

        // 초과 → 이 카테고리 차순위(아직 이 리스트에 없고 조심할 날도 아닌) 날짜로 교체
        final replacement = ordered.firstWhere(
          (d) => !good.contains(d) && !caution.contains(d),
          orElse: () => day,
        );
        if (replacement == day) continue;

        counts[day] = (counts[day] ?? 1) - 1;
        counts[replacement] = (counts[replacement] ?? 0) + 1;
        good[i] = replacement;
      }

      result[category] = (goodDays: good, cautionDays: caution);
    }
  }
}
