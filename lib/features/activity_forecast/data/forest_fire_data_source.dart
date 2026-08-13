import 'package:dio/dio.dart';

import '../../../core/network/weather_proxy_dio.dart';
import '../domain/activity_models.dart';

class ForestFireDataSource {
  ForestFireDataSource({Dio? dio})
    : _dio = dio ?? WeatherProxyDio.create(WeatherProxyProvider.publicData);

  static const _nationalPath =
      '/1400377/forestPointV2/forestPointListGeongugSearchV2';
  static const _provincePath =
      '/1400377/forestPointV2/forestPointListSidoSearchV2';
  static const _maximumForecastDifference = Duration(hours: 2);

  static const _provinceCodes = <String, String>{
    '서울': '11',
    '부산': '26',
    '대구': '27',
    '인천': '28',
    '광주': '29',
    '대전': '30',
    '울산': '31',
    '세종': '36',
    '경기': '41',
    '충북': '43',
    '충청북도': '43',
    '충남': '44',
    '충청남도': '44',
    '전북': '52',
    '전북특별자치도': '52',
    '전남': '46',
    '전라남도': '46',
    '경북': '47',
    '경상북도': '47',
    '경남': '48',
    '경상남도': '48',
    '제주': '50',
    '강원': '51',
    '강원특별자치도': '51',
  };

  final Dio _dio;

  Future<ForestFireEvidence?> fetch({
    required DateTime requestedAt,
    required String destinationAreaName,
  }) async {
    final provinceCode = provinceCodeFor(destinationAreaName);
    final response = await _dio.get<Map<String, dynamic>>(
      provinceCode == null ? _nationalPath : _provincePath,
      queryParameters: {
        '_type': 'json',
        'pageNo': 1,
        'numOfRows': 100,
        'excludeForecast': 0,
        if (provinceCode != null) 'localAreas': provinceCode,
      },
    );
    final data = response.data;
    if (data == null) return null;
    return parseResponse(
      data,
      requestedAt: requestedAt,
      fallbackCoverageName: provinceCode == null ? '전국 최대위험' : null,
    );
  }

  static String? provinceCodeFor(String address) {
    final normalized = address.replaceAll(' ', '');
    for (final entry in _provinceCodes.entries) {
      if (normalized.startsWith(entry.key)) return entry.value;
    }
    return null;
  }

  static ForestFireEvidence? parseResponse(
    Map<String, dynamic> data, {
    required DateTime requestedAt,
    String? fallbackCoverageName,
  }) {
    final body = data['response']?['body'] as Map<String, dynamic>?;
    final rawItems = (body?['items'] as Map<String, dynamic>?)?['item'];
    final items = switch (rawItems) {
      final List<dynamic> values =>
        values.whereType<Map<String, dynamic>>().toList(),
      final Map<String, dynamic> value => [value],
      _ => const <Map<String, dynamic>>[],
    };
    if (items.isEmpty) return null;

    Map<String, dynamic>? nearest;
    Duration? nearestDifference;
    DateTime? nearestAt;
    for (final item in items) {
      final analysisAt = _parseAnalysisAt(item['analdate']?.toString());
      if (analysisAt == null) continue;
      final difference = analysisAt.difference(requestedAt).abs();
      if (nearestDifference == null || difference < nearestDifference) {
        nearest = item;
        nearestAt = analysisAt;
        nearestDifference = difference;
      }
    }
    final maxRiskIndex = int.tryParse(nearest?['maxi']?.toString() ?? '');
    if (nearest == null ||
        nearestAt == null ||
        nearestDifference == null ||
        nearestDifference > _maximumForecastDifference ||
        maxRiskIndex == null) {
      return null;
    }
    final coverageName = nearest['doname']?.toString().trim();
    return ForestFireEvidence(
      forecastAt: nearestAt,
      maxRiskIndex: maxRiskIndex,
      coverageName: coverageName == null || coverageName.isEmpty
          ? fallbackCoverageName ?? '지역 산불위험'
          : coverageName,
    );
  }

  static DateTime? _parseAnalysisAt(String? value) {
    if (value == null) return null;
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})\s+(\d{1,2})',
    ).firstMatch(value);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
    );
  }
}
