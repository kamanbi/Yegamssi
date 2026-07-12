import 'monthly_category.dart';

/// 월간 총평 구간 — 초/중/후반 중 가장 흐름이 좋은 구간.
/// 표시 문구는 캐시에 담지 않고 화면에서 l10n으로 매핑한다(언어 무관 재사용).
enum MonthlySummaryPhase { early, mid, late }

/// 카테고리별 좋은 날/조심할 날.
/// title/message는 언어 종속이라 캐시에 담지 않고 화면에서 l10n으로 렌더링한다.
class MonthlyCategoryResult {
  const MonthlyCategoryResult({
    required this.category,
    required this.goodDays,
    required this.cautionDays,
  });

  final MonthlyCategory category;
  final List<int> goodDays;
  final List<int> cautionDays;

  Map<String, dynamic> toJson() => {
    'category': category.name,
    'goodDays': goodDays,
    'cautionDays': cautionDays,
  };

  static MonthlyCategoryResult? fromJson(Map<String, dynamic> json) {
    final category = MonthlyCategory.values
        .where((e) => e.name == json['category'])
        .firstOrNull;
    if (category == null) return null;
    return MonthlyCategoryResult(
      category: category,
      goodDays: (json['goodDays'] as List<dynamic>).cast<int>(),
      cautionDays: (json['cautionDays'] as List<dynamic>).cast<int>(),
    );
  }
}

/// 월간 예감씨 결과 — 순수 로컬 계산 결과. 언어 무관 데이터만 담는다.
class MonthlyYegamssiResult {
  const MonthlyYegamssiResult({
    required this.monthKey,
    required this.profileHash,
    required this.generatedAt,
    required this.targetYear,
    required this.targetMonth,
    required this.summaryPhase,
    required this.categories,
  });

  final String monthKey;
  final String profileHash;
  final DateTime generatedAt;
  final int targetYear;
  final int targetMonth;
  final MonthlySummaryPhase summaryPhase;
  final List<MonthlyCategoryResult> categories;

  Map<String, dynamic> toJson() => {
    'monthKey': monthKey,
    'profileHash': profileHash,
    'generatedAt': generatedAt.toIso8601String(),
    'targetYear': targetYear,
    'targetMonth': targetMonth,
    'summaryPhase': summaryPhase.name,
    'categories': categories.map((c) => c.toJson()).toList(),
  };

  factory MonthlyYegamssiResult.fromJson(Map<String, dynamic> json) {
    final categories = (json['categories'] as List<dynamic>)
        .map((e) => MonthlyCategoryResult.fromJson(e as Map<String, dynamic>))
        .whereType<MonthlyCategoryResult>()
        .toList();
    final summaryPhase = MonthlySummaryPhase.values.firstWhere(
      (e) => e.name == json['summaryPhase'],
      orElse: () => MonthlySummaryPhase.mid,
    );
    return MonthlyYegamssiResult(
      monthKey: json['monthKey'] as String,
      profileHash: json['profileHash'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      targetYear: json['targetYear'] as int,
      targetMonth: json['targetMonth'] as int,
      summaryPhase: summaryPhase,
      categories: categories,
    );
  }
}
