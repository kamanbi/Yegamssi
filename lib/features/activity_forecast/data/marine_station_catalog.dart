import 'dart:convert';

import 'package:flutter/services.dart';

/// 조석·조류 예보지점명 → 관측소 코드(obsCode) 매핑.
///
/// 공공데이터포털 오픈API 활용가이드에 실린 코드표를 그대로 번들한다.
/// 관측소명은 국가어항 카탈로그의 표시명과 정확히 일치하지 않을 수 있어
/// 정확 일치 실패 시 부분 포함(containment) 매칭으로 한 번 더 시도한다.
class MarineStationCatalog {
  MarineStationCatalog({required String assetPath, AssetBundle? bundle})
    : _assetPath = assetPath,
      _bundle = bundle ?? rootBundle;

  static const tideStationsAssetPath =
      'assets/data/activity/tide_stations_20260813.json';
  static const currentStationsAssetPath =
      'assets/data/activity/current_stations_20260813.json';
  static const catalogVersion = '2026-08-13';

  final String _assetPath;
  final AssetBundle _bundle;
  Future<Map<String, String>>? _cachedStations;

  /// 관측지점명(예: "가거도")으로 obsCode를 찾는다. 정확 일치가 없으면
  /// 지점명이 서로 포함 관계인 항목 중 이름이 가장 짧은 것을 반환한다.
  Future<String?> findObsCode(String stationName) async {
    final normalized = _normalize(stationName);
    if (normalized.isEmpty) return null;

    final stations = await (_cachedStations ??= _load());
    final exact = stations[normalized];
    if (exact != null) return exact;

    final candidates = stations.entries
        .where(
          (entry) =>
              normalized.contains(entry.key) || entry.key.contains(normalized),
        )
        .toList(growable: false)
      ..sort((left, right) => left.key.length.compareTo(right.key.length));
    return candidates.isEmpty ? null : candidates.first.value;
  }

  Future<Map<String, String>> _load() async {
    final raw = await _bundle.loadString(_assetPath);
    return decode(raw);
  }

  static Map<String, String> decode(String raw) {
    final document = jsonDecode(raw) as Map<String, dynamic>;
    if (document['schemaVersion'] != 1 ||
        document['catalogVersion'] != catalogVersion) {
      throw const FormatException('지원하지 않는 해양 관측소 코드표입니다.');
    }
    final stations = document['stations'] as Map<String, dynamic>? ?? const {};
    return stations.map(
      (name, code) => MapEntry(_normalize(name), code as String),
    );
  }

  static String _normalize(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), '');
}
