import 'dart:math';

import '../../data/models/fortune_fragment_dto.dart';

/// 조각 멘트 → 완성 문장 조합
class FragmentComposer {
  FragmentComposer._();

  /// 종합운세: 사주 상태(state) 포함 4개 조각
  static const _typesOverall = ['intro', 'state', 'effect', 'action'];

  /// 카테고리 카드: state 제외 3개 조각 (중복 방지)
  static const _typesCategory = ['intro', 'effect', 'action'];

  /// [fragments]: 하나의 code에 해당하는 모든 조각
  /// [seed]: birthDate ^ date ^ slot ^ category 기반 결정론적 seed
  /// [isOverall]: true면 state 조각 포함 (종합운세 전용)
  static String compose(
    List<FortuneFragmentDto> fragments,
    int seed, {
    bool isOverall = false,
  }) {
    if (fragments.isEmpty) return '';

    final rng = Random(seed);
    final parts = <String>[];
    final types = isOverall ? _typesOverall : _typesCategory;

    for (final type in types) {
      final pool = fragments.where((f) => f.type == type).toList();
      if (pool.isEmpty) continue;
      parts.add(_weightedPick(pool, rng).text);
    }

    return _joinParts(parts);
  }

  /// weight 기반 가중 랜덤 선택
  static FortuneFragmentDto _weightedPick(
      List<FortuneFragmentDto> pool, Random rng) {
    final totalWeight = pool.fold(0, (sum, f) => sum + f.weight);
    var roll = rng.nextInt(totalWeight) + 1;
    for (final f in pool) {
      roll -= f.weight;
      if (roll <= 0) return f;
    }
    return pool.last;
  }

  /// 조각 자연스럽게 연결
  static String _joinParts(List<String> parts) {
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first;

    final buffer = StringBuffer();
    buffer.write(parts.first);
    final last = parts.first.trimRight();
    if (!last.endsWith('.') &&
        !last.endsWith('다') &&
        !last.endsWith('요') &&
        !last.endsWith('죠')) {
      buffer.write('.');
    }
    for (int i = 1; i < parts.length; i++) {
      buffer.write(' ');
      buffer.write(parts[i]);
    }
    return buffer.toString();
  }
}
