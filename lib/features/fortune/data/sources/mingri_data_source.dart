import 'package:logger/logger.dart';

import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/oheng.dart';
import '../models/fortune_fragment_dto.dart';
import 'fortune_data_source.dart';

/// Supabase 기반 운세 데이터 소스
class MingriDataSource implements FortuneDataSource {
  const MingriDataSource();

  static final Logger _logger = Logger();
  static final Set<String> _loggedFetchFailureKeys = <String>{};

  @override
  Future<List<FortuneFragmentDto>> fetchFragments({
    required List<String> codes,
    required String tableName,
  }) async {
    try {
      final client = SupabaseConfig.client;
      final rows = await client
          .from(tableName)
          .select('code, type, text, weight')
          .inFilter('code', codes);

      return (rows as List<dynamic>)
          .map(
            (row) => FortuneFragmentDto.fromJson(row as Map<String, dynamic>),
          )
          .toList();
    } catch (error, stackTrace) {
      final logKey = '$tableName:${_errorSignature(error)}';
      if (_loggedFetchFailureKeys.add(logKey)) {
        _logger.w(
          '운세 문구 테이블 조회 실패: table=$tableName, codes=$codes',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return [];
    }
  }

  /// Fallback 6계층으로 멘트 조각 조회 + generic variant 병합
  /// B1/B2 같은 세분화 티어 → 부모 티어(B) → 하드코딩 순으로 폴백
  /// 이후 category_tier 단축 코드(e.g. money_B1)의 extra intro/effect/action을 병합하여
  /// FragmentComposer 풀을 확장 → 같은 티어 내에서도 seed 기반 다양한 문구 선택 가능
  Future<List<FortuneFragmentDto>> fetchWithFallback({
    required FortuneCategory category,
    required String baseCode,
    required String selectedTableName,
    required String baseTableName,
  }) async {
    final selectedRows = await _coreWithFallback(
      category,
      baseCode,
      selectedTableName,
    );
    if (selectedRows.isNotEmpty) {
      return _mergeGenericVariants(selectedRows, baseCode, selectedTableName);
    }

    if (selectedTableName != baseTableName) {
      _logger.w(
        '선택한 운세 멘트 테이블에 해당 코드 데이터가 없어 기본 톤 혼합을 차단합니다: '
        'selectedTable=$selectedTableName, category=${category.name}, '
        'baseCode=$baseCode',
      );
      return const [];
    }

    _logger.w(
      '기본 운세 문구도 없어 앱 내장 fallback을 사용합니다: '
      'baseTable=$baseTableName, category=${category.name}, baseCode=$baseCode',
    );
    return _hardcoded(category);
  }

  /// 폴백 6계층 core 로직
  Future<List<FortuneFragmentDto>> _coreWithFallback(
    FortuneCategory category,
    String baseCode,
    String tableName,
  ) async {
    // 1단계: 완전 코드 (e.g. health_B1_geum_ex_fire)
    var rows = await fetchFragments(codes: [baseCode], tableName: tableName);
    if (rows.isNotEmpty) return rows;

    // 2단계: weather 제거 (e.g. health_B1_geum_ex)
    rows = await fetchFragments(
      codes: [FortuneCodeBuilder.removeWeather(baseCode)],
      tableName: tableName,
    );
    if (rows.isNotEmpty) return rows;

    // 3단계: strength 제거 (e.g. health_B1_geum)
    rows = await fetchFragments(
      codes: [FortuneCodeBuilder.removeStrength(baseCode)],
      tableName: tableName,
    );
    if (rows.isNotEmpty) return rows;

    // 4단계: oheng 제거 (e.g. health_B1)
    // overall은 state 타입이 필수 — generic 코드(state 없음)로 끊기면 안 됨
    rows = await fetchFragments(
      codes: [FortuneCodeBuilder.removeOheng(baseCode)],
      tableName: tableName,
    );
    final needsState = category == FortuneCategory.overall;
    final hasState = rows.any((f) => f.type == 'state');
    if (rows.isNotEmpty && (!needsState || hasState)) return rows;

    // 5단계: 부모 티어로 폴백 (B1→B, B2→B, C1→C, C2→C)
    final parentCode = FortuneCodeBuilder.parentTierCode(baseCode);
    if (parentCode != null) {
      rows = await fetchFragments(codes: [parentCode], tableName: tableName);
      if (rows.isNotEmpty) return rows;
    }

    return const [];
  }

  /// generic variant 병합
  /// baseCode에서 category_tier만 추출해 단축 코드로 extra 조각을 조회
  /// intro/effect/action만 병합 (state는 오행 고유이므로 제외)
  Future<List<FortuneFragmentDto>> _mergeGenericVariants(
    List<FortuneFragmentDto> rows,
    String baseCode,
    String tableName,
  ) async {
    final parts = baseCode.split('_');
    if (parts.length < 2) return rows;
    final genericCode = '${parts[0]}_${parts[1]}'; // e.g. money_B1
    final genericRows = await fetchFragments(
      codes: [genericCode],
      tableName: tableName,
    );
    if (genericRows.isEmpty) return rows;
    // state는 오행×강도×날씨 고유 — generic 에서 제외하고 병합
    final extras = genericRows.where((f) => f.type != 'state').toList();
    if (extras.isEmpty) return rows;
    return [...rows, ...extras];
  }

  static String _errorSignature(Object error) {
    final message = error.toString();
    if (message.length <= 120) return message;
    return message.substring(0, 120);
  }

  List<FortuneFragmentDto> _hardcoded(FortuneCategory category) {
    final map = _fallback[category] ?? _fallback[FortuneCategory.overall]!;
    return map.entries
        .map(
          (e) => FortuneFragmentDto(
            code: 'fallback',
            type: e.key,
            text: e.value,
            weight: 1,
          ),
        )
        .toList();
  }

  static const _fallback = <FortuneCategory, Map<String, String>>{
    FortuneCategory.overall: {
      'intro': '오늘 하루도 흐름을 잘 타보세요',
      'state': '에너지의 균형을 유지하며',
      'effect': '작은 변화가 큰 결과를 만들 수 있으며',
      'action': '차분하게 하루를 시작하는 것이 좋습니다',
    },
    FortuneCategory.money: {
      'intro': '재물의 흐름에 주의를 기울이세요',
      'state': '금전 에너지가 흐르는 시기로',
      'effect': '수입과 지출의 균형이 맞아떨어질 수 있으며',
      'action': '충동적인 소비는 자제하는 것이 좋습니다',
    },
    FortuneCategory.love: {
      'intro': '감정의 흐름에 솔직해지는 날입니다',
      'state': '따뜻한 마음으로 상대를 바라보며',
      'effect': '작은 관심이 큰 변화를 만들 수 있으며',
      'action': '먼저 다가가는 용기가 필요합니다',
    },
    FortuneCategory.work: {
      'intro': '업무에서 집중력이 요구되는 하루입니다',
      'state': '계획적으로 일을 처리하며',
      'effect': '꾸준한 노력이 결실을 맺을 수 있으며',
      'action': '우선순위를 정해 하나씩 처리하세요',
    },
    FortuneCategory.health: {
      'intro': '컨디션 관리에 신경 써야 하는 날입니다',
      'state': '몸의 신호에 귀 기울이며',
      'effect': '적절한 휴식이 도움이 될 수 있으며',
      'action': '충분한 수면과 수분 섭취를 권장합니다',
    },
    FortuneCategory.decision: {
      'intro': '선택의 순간에 신중함이 필요합니다',
      'state': '직관과 논리를 함께 활용하며',
      'effect': '결단을 내리면 좋은 결과로 이어질 수 있으며',
      'action': '주변 의견을 참고하되 최종 판단은 본인이 하세요',
    },
  };
}
