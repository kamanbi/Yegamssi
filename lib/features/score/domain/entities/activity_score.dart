import 'score_tier.dart';

class ActivityScore {
  const ActivityScore({
    required this.score,
    required this.tier,
    required this.breakdown,
  });

  final int score; // 0 ~ 100
  final ScoreTier tier;
  final ScoreBreakdown breakdown; // 항목별 감점 내역

  factory ActivityScore.fromRaw(int raw, ScoreBreakdown breakdown) {
    final clamped = raw.clamp(0, 100);
    return ActivityScore(
      score: clamped,
      tier: ScoreTierExtension.fromScore(clamped),
      breakdown: breakdown,
    );
  }
}

class ScoreBreakdown {
  const ScoreBreakdown({
    this.rainDeduction = 0,
    this.windDeduction = 0,
    this.heatDeduction = 0,
    this.dustDeduction = 0,
    this.uvDeduction = 0,
    this.ozoneDeduction = 0,
  });

  final int rainDeduction;
  final int windDeduction;
  final int heatDeduction;
  final int dustDeduction;
  final int uvDeduction;
  final int ozoneDeduction;

  int get total =>
      rainDeduction + windDeduction + heatDeduction +
      dustDeduction + uvDeduction + ozoneDeduction;
}
