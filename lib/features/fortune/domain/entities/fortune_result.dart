import 'oheng.dart';

/// 운세 결과 — FortuneEntity 대체
class FortuneResult {
  const FortuneResult({
    required this.scores,
    required this.messages,
    required this.ohengRatio,
    required this.date,
    required this.slot,
  });

  /// 카테고리별 점수 0~100
  final Map<FortuneCategory, int> scores;

  /// 카테고리별 조합 멘트
  final Map<FortuneCategory, String> messages;

  /// 오행 비율 (UI 게이지용, 합계=1.0)
  final Map<Oheng, double> ohengRatio;

  final DateTime date;
  final TimeSlot slot;

  Map<String, dynamic> toJson() => {
        'scores': scores.map((k, v) => MapEntry(k.name, v)),
        'messages': messages.map((k, v) => MapEntry(k.name, v)),
        'ohengRatio': ohengRatio.map((k, v) => MapEntry(k.name, v)),
        'date': date.toIso8601String(),
        'slot': slot.name,
      };

  factory FortuneResult.fromJson(Map<String, dynamic> json) {
    final scores = <FortuneCategory, int>{};
    final messages = <FortuneCategory, String>{};
    final ohengRatio = <Oheng, double>{};

    (json['scores'] as Map<String, dynamic>).forEach((k, v) {
      final cat =
          FortuneCategory.values.where((e) => e.name == k).firstOrNull;
      if (cat != null) scores[cat] = v as int;
    });

    (json['messages'] as Map<String, dynamic>).forEach((k, v) {
      final cat =
          FortuneCategory.values.where((e) => e.name == k).firstOrNull;
      if (cat != null) messages[cat] = v as String;
    });

    (json['ohengRatio'] as Map<String, dynamic>).forEach((k, v) {
      final oheng = Oheng.values.where((e) => e.name == k).firstOrNull;
      if (oheng != null) ohengRatio[oheng] = (v as num).toDouble();
    });

    return FortuneResult(
      scores: scores,
      messages: messages,
      ohengRatio: ohengRatio,
      date: DateTime.parse(json['date'] as String),
      slot: TimeSlot.values.firstWhere((e) => e.name == json['slot']),
    );
  }
}
