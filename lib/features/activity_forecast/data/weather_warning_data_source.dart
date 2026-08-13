import 'package:dio/dio.dart';

import '../../../core/network/weather_proxy_dio.dart';
import '../domain/activity_models.dart';

class WeatherWarningDataSource {
  WeatherWarningDataSource({Dio? dio})
    : _dio = dio ?? WeatherProxyDio.create(WeatherProxyProvider.publicData);

  static const _path = '/1360000/WthrWrnInfoService/getPwnStatus';

  final Dio _dio;

  Future<WeatherWarningEvidence?> fetch() async {
    final response = await _dio.get<Map<String, dynamic>>(
      _path,
      queryParameters: const {'dataType': 'JSON', 'pageNo': 1, 'numOfRows': 10},
    );
    final data = response.data;
    return data == null ? null : parseResponse(data);
  }

  static WeatherWarningEvidence? parseResponse(Map<String, dynamic> data) {
    final body = data['response']?['body'] as Map<String, dynamic>?;
    final rawItem = (body?['items'] as Map<String, dynamic>?)?['item'];
    final item = switch (rawItem) {
      final List<dynamic> values =>
        values.whereType<Map<String, dynamic>>().firstOrNull,
      final Map<String, dynamic> value => value,
      _ => null,
    };
    if (item == null) return null;

    final issuedAt = _parseKmaDateTime(item['tmFc']);
    final effectiveAt = _parseKmaDateTime(item['tmEf']);
    if (issuedAt == null || effectiveAt == null) return null;

    return WeatherWarningEvidence(
      issuedAt: issuedAt,
      effectiveAt: effectiveAt,
      activeWarnings: _parseActiveWarnings(item['t6']?.toString() ?? ''),
    );
  }

  static List<ActiveWeatherWarning> _parseActiveWarnings(String raw) {
    final warnings = <ActiveWeatherWarning>[];
    for (final line in raw.split(RegExp(r'[\r\n]+'))) {
      final match = RegExp(
        r'^\s*o\s+([^:：]+?)\s*[:：]\s*(.+)$',
      ).firstMatch(line);
      if (match == null) continue;
      final phenomenon = match.group(1)!.trim();
      final areas = match
          .group(2)!
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
      if (areas.isEmpty) continue;
      warnings.add(ActiveWeatherWarning(phenomenon: phenomenon, areas: areas));
    }
    return warnings;
  }

  static DateTime? _parseKmaDateTime(Object? raw) {
    final value = raw?.toString().trim() ?? '';
    if (!RegExp(r'^\d{12}$').hasMatch(value)) return null;
    return DateTime(
      int.parse(value.substring(0, 4)),
      int.parse(value.substring(4, 6)),
      int.parse(value.substring(6, 8)),
      int.parse(value.substring(8, 10)),
      int.parse(value.substring(10, 12)),
    );
  }
}
