import '../entities/oheng.dart';
import '../entities/saju.dart';

/// 카테고리별 운세 점수 계산
class FortuneScoreCalculator {
  FortuneScoreCalculator._();

  static const int minimumDisplayScore = 10;
  static const int _normalizationMin = -80;
  static const int _normalizationMax = 80;

  /// Saju + 오늘 간지 + 날씨 오행으로 카테고리별 표시 점수(0~100)를 계산한다.
  static Map<FortuneCategory, int> calculate(
    Saju saju,
    (HeavenlyStem, EarthlyBranch) todayGanji,
    Oheng? weatherOheng,
  ) {
    final rawScores = calculateRawScores(saju, todayGanji, weatherOheng);
    return rawScores.map(
      (category, rawCategoryScore) =>
          MapEntry(category, _normalize(rawCategoryScore)),
    );
  }

  /// 진단 로그용 raw score. 화면 표시 점수와 달리 최소 점수 보정 전 값이다.
  static Map<FortuneCategory, int> calculateRawScores(
    Saju saju,
    (HeavenlyStem, EarthlyBranch) todayGanji,
    Oheng? weatherOheng,
  ) {
    final todayStem = todayGanji.$1;
    final result = <FortuneCategory, int>{};
    for (final category in FortuneCategory.values) {
      result[category] = _rawScore(category, saju, todayStem, weatherOheng);
    }
    return result;
  }

  static int _rawScore(
    FortuneCategory cat,
    Saju saju,
    HeavenlyStem todayStem,
    Oheng? weatherOheng,
  ) {
    final base = _baseScore(cat, saju, todayStem);
    final weatherAdjustment = weatherOheng != null
        ? _weatherBonus(saju.ohengCount[weatherOheng] ?? 0)
        : 0;
    return base + weatherAdjustment;
  }

  static int _baseScore(
    FortuneCategory cat,
    Saju saju,
    HeavenlyStem todayStem,
  ) {
    return switch (cat) {
      // 종합운: 년·월·일·시 4간(干) 전체 합산 → -80 ~ +80 full range
      FortuneCategory.overall => _allStemsScore(saju, todayStem),

      // 재물운: 금(金) 카운트 × 20 + 월간 관계 보너스
      FortuneCategory.money => _moneyScore(saju, todayStem),

      // 연애운: 화(火)·수(水) 편차 × 20 + 년간 관계 보너스
      FortuneCategory.love => _loveScore(saju, todayStem),

      // 직장운: 목(木)+금(金) 합계 × 12 + 월간 관계 보너스
      FortuneCategory.work => _workScore(saju, todayStem),

      // 건강운: 오행 불균형 분산 × 8 → 균형 사주는 높고 편중 사주는 낮음
      FortuneCategory.health => _healthScore(saju),

      // 결정운: 일간 ×2 + 월간 + 년간 합산
      FortuneCategory.decision =>
        _ohengRelation(saju.dayStem.oheng, todayStem.oheng) * 2 +
            _ohengRelation(saju.monthStem.oheng, todayStem.oheng) +
            _ohengRelation(saju.yearStem.oheng, todayStem.oheng),
    };
  }

  // ── 년·월·일·시 4간 관계 합산 ─────────────────────────────────
  // 각 stem이 -20, 0, +10, +20 중 하나 → 합계 -80 ~ +80
  static int _allStemsScore(Saju saju, HeavenlyStem todayStem) {
    return _ohengRelation(saju.yearStem.oheng, todayStem.oheng) +
        _ohengRelation(saju.monthStem.oheng, todayStem.oheng) +
        _ohengRelation(saju.dayStem.oheng, todayStem.oheng) +
        _ohengRelation(saju.hourStem.oheng, todayStem.oheng);
  }

  // ── 오행 상생/상극 관계 ────────────────────────────────────────
  static int _ohengRelation(Oheng from, Oheng to) {
    if (from == to) return 10; // 동일
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
    if (saeng[from] == to) return 20;
    if (gek[from] == to) return -20;
    return 0;
  }

  // ── 재물운: 金 강도 × 20 + 월간 보너스 ─────────────────────────
  // 금 count 0~6 기준: -40~+100 → clamp 후 정규화
  static int _moneyScore(Saju saju, HeavenlyStem todayStem) {
    final count = saju.ohengCount[Oheng.geum] ?? 0;
    final stemBonus = _ohengRelation(saju.monthStem.oheng, todayStem.oheng);
    return (count - 2) * 20 + stemBonus;
  }

  // ── 연애운: 火·水 편차 × 20 + 년간 보너스 ──────────────────────
  // 편차 0~8: range -140~+20 → 실질 -60~+20
  static int _loveScore(Saju saju, HeavenlyStem todayStem) {
    final hwa = saju.ohengCount[Oheng.hwa] ?? 0;
    final su = saju.ohengCount[Oheng.su] ?? 0;
    final stemBonus = _ohengRelation(saju.yearStem.oheng, todayStem.oheng);
    return -(hwa - su).abs() * 20 + 20 + stemBonus;
  }

  // ── 직장운: 木+金 합계 × 12 + 월간 보너스 ──────────────────────
  // 합계 0~8, 기준 2: -24~+72 + bonus
  static int _workScore(Saju saju, HeavenlyStem todayStem) {
    final mok = saju.ohengCount[Oheng.mok] ?? 0;
    final geum = saju.ohengCount[Oheng.geum] ?? 0;
    final stemBonus = _ohengRelation(saju.monthStem.oheng, todayStem.oheng);
    return (mok + geum - 2) * 12 + stemBonus;
  }

  // ── 건강운: 오행 균형도 (분산 × 8) ─────────────────────────────
  // 균형 사주(분산≈0): +30 고득점 / 편중 사주(분산 큼): 큰 감점
  static int _healthScore(Saju saju) {
    final values = saju.ohengCount.values.toList();
    final total = values.fold(0, (a, b) => a + b);
    if (total == 0) return 0;
    final avg = total / values.length;
    final variance =
        values.map((v) => (v - avg) * (v - avg)).fold(0.0, (a, b) => a + b) /
        values.length;
    return (30 - variance * 8).round().clamp(-80, 30);
  }

  // ── 날씨 보정 ───────────────────────────────────────────────
  static int _weatherBonus(int ohengCount) => switch (ohengCount) {
    0 => 8,
    1 => 4,
    2 => 0,
    3 => -4,
    _ => -8,
  };

  // ── 정규화: rawScore → 0~100 ────────────────────────────────
  // 기준 범위 -80 ~ +80 (full range 활용)
  static int _normalize(int rawCategoryScore) {
    final normalized =
        ((rawCategoryScore - _normalizationMin) /
                (_normalizationMax - _normalizationMin) *
                100)
            .round();
    return normalized.clamp(minimumDisplayScore, 100).toInt();
  }
}
