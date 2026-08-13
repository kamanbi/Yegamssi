import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/activity_models.dart';

/// 어종별 포획금지기간·금지체장 정적 자산 로더.
///
/// 해양수산부·국립수산과학원 안내자료(수산자원관리법 시행령 별표1·2 근거)를
/// 그대로 번들한 것으로, API 호출 없이 오프라인으로 조회한다.
class FishRegulationCatalog {
  FishRegulationCatalog({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const assetPath = 'assets/data/activity/fish_regulations_20260813.json';
  static const catalogVersion = '2026-08-13';

  final AssetBundle _bundle;
  Future<Map<String, FishRegulationEvidence>>? _cachedByName;

  /// 어종명으로 규제 정보를 조회한다. 해당 어종이 목록에 없으면 null.
  Future<FishRegulationEvidence?> findByName(String fishName) async {
    final normalized = _normalize(fishName);
    if (normalized.isEmpty) return null;
    final byName = await (_cachedByName ??= _load());
    return byName[normalized];
  }

  Future<Map<String, FishRegulationEvidence>> _load() async {
    final raw = await _bundle.loadString(assetPath);
    return decode(raw);
  }

  static Map<String, FishRegulationEvidence> decode(String raw) {
    final document = jsonDecode(raw) as Map<String, dynamic>;
    if (document['schemaVersion'] != 1 ||
        document['catalogVersion'] != catalogVersion) {
      throw const FormatException('지원하지 않는 어종 규제 카탈로그입니다.');
    }

    final source = document['source'] as String? ?? '';
    final items = (document['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>();

    final byName = <String, FishRegulationEvidence>{};
    for (final item in items) {
      final inhibitionPeriod = item['inhibitionPeriod'] as String?;
      final prohibitedSize = item['prohibitedSize'] as String?;
      if (inhibitionPeriod == null && prohibitedSize == null) continue;

      final name = item['name'] as String;
      byName[_normalize(name)] = FishRegulationEvidence(
        fishName: name,
        inhibitionPeriodLabel: inhibitionPeriod ?? '지정된 금어기 없음',
        prohibitedSizeCm: prohibitedSize,
        source: source,
      );
    }
    return byName;
  }

  static String _normalize(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), '');
}
