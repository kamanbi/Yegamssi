/// Supabase fortune_ko / fortune_en 테이블의 한 행
class FortuneFragmentDto {
  const FortuneFragmentDto({
    required this.code,
    required this.type,
    required this.text,
    required this.weight,
  });

  final String code;
  final String type; // intro / state / effect / action
  final String text;
  final int weight;

  factory FortuneFragmentDto.fromJson(Map<String, dynamic> json) {
    return FortuneFragmentDto(
      code: json['code'] as String,
      type: json['type'] as String,
      text: json['text'] as String,
      weight: (json['weight'] as num?)?.toInt() ?? 1,
    );
  }
}
