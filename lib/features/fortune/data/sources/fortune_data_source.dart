import '../../domain/entities/oheng.dart';
import '../models/fortune_fragment_dto.dart';

abstract interface class FortuneDataSource {
  /// 코드 기반 멘트 조각 조회
  /// code 형식: {category}_{tier}_{oheng}_{strength}_{weather}
  Future<List<FortuneFragmentDto>> fetchFragments({
    required List<String> codes,
    required String tableName, // fortune_ko / fortune_en
  });
}

/// 운세 코드 생성 유틸
class FortuneCodeBuilder {
  FortuneCodeBuilder._();

  static String build({
    required FortuneCategory category,
    required int score,
    required Oheng dominantOheng,
    required OhengStrength strength,
    required Oheng? weatherOheng,
  }) {
    final tier = _tierForScore(score);
    final wx = switch (weatherOheng) {
      Oheng.hwa => 'fire',
      Oheng.to => 'earth',
      Oheng.su => 'water',
      Oheng.mok => 'wood',
      _ => 'earth',
    };
    return '${category.name}_${tier}_${dominantOheng.name}_${strength.name}_$wx';
  }

  static String _tierForScore(int score) {
    if (score >= 80) return 'A';
    if (score >= 63) return 'B';
    if (score >= 50) return 'B1';
    if (score >= 38) return 'C';
    if (score >= 25) return 'C1';
    return 'D';
  }

  /// Fallback 2단계: weather 제거
  static String removeWeather(String code) {
    final parts = code.split('_');
    return parts.length >= 5 ? parts.sublist(0, 4).join('_') : code;
  }

  /// Fallback 3단계: strength 제거
  static String removeStrength(String code) {
    final parts = code.split('_');
    return parts.length >= 4 ? parts.sublist(0, 3).join('_') : code;
  }

  /// Fallback 4단계: oheng 제거
  static String removeOheng(String code) {
    final parts = code.split('_');
    return parts.length >= 3 ? '${parts[0]}_${parts[1]}' : code;
  }

  /// Fallback 5단계: 세분화 티어 → 부모 티어.
  /// 한국어 데이터 기준으로 B1은 B, C1은 C로 완화한다.
  static String? parentTierCode(String code) {
    final parts = code.split('_');
    if (parts.length < 2) return null;
    final tier = parts[1];
    final String? parent = switch (tier) {
      'B1' => 'B',
      'C1' => 'C',
      _ => null,
    };
    if (parent == null) return null;
    return '${parts[0]}_$parent';
  }
}
