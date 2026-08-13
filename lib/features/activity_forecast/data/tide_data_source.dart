import 'package:dio/dio.dart';

import '../../../core/network/weather_proxy_dio.dart';
import '../domain/activity_models.dart';
import 'marine_station_catalog.dart';

/// 국립해양조사원 조석예보(고, 저조) 연동.
/// https://apis.data.go.kr/1192136/tideFcstHghLw/GetTideFcstHghLwApiService
class TideDataSource {
  TideDataSource({Dio? dio, MarineStationCatalog? stations})
    : _dio = dio ?? WeatherProxyDio.create(WeatherProxyProvider.publicData),
      _stations =
          stations ??
          MarineStationCatalog(
            assetPath: MarineStationCatalog.tideStationsAssetPath,
          );

  static const _path = '/1192136/tideFcstHghLw/GetTideFcstHghLwApiService';
  static const _rawResponseTtl = Duration(hours: 6);
  static const _maximumRawCacheEntries = 64;

  final Dio _dio;
  final MarineStationCatalog _stations;
  final Map<String, _CachedItems> _rawResponseCache = {};
  final Map<String, Future<List<Map<String, dynamic>>>> _rawResponseInFlight =
      {};

  /// [stationName]에 대응하는 관측지점을 찾지 못하거나 응답에 만조·간조
  /// 이벤트가 없으면 null을 반환한다.
  Future<TideEvidence?> fetch({
    required DateTime requestedAt,
    required String stationName,
  }) async {
    final obsCode = await _stations.findObsCode(stationName);
    if (obsCode == null) return null;

    final items = await _fetchItems(obsCode: obsCode, requestedAt: requestedAt);
    final events = items
        .map(_eventFromItem)
        .whereType<TideEventEntry>()
        .toList(growable: false)
      ..sort((left, right) => left.time.compareTo(right.time));
    if (events.isEmpty) return null;

    return TideEvidence(
      stationName: stationName,
      events: events,
      forecastAt: requestedAt,
    );
  }

  TideEventEntry? _eventFromItem(Map<String, dynamic> item) {
    final time = _parseDt(item['predcDt']?.toString());
    final levelCm = double.tryParse(item['predcTdlvVl']?.toString() ?? '');
    final extrSe = item['extrSe']?.toString();
    if (time == null || levelCm == null || extrSe == null) return null;

    final type = switch (extrSe) {
      '1' || '3' => TideEventType.highTide,
      '2' || '4' => TideEventType.lowTide,
      _ => null,
    };
    if (type == null) return null;

    return TideEventEntry(type: type, time: time, levelCm: levelCm.round());
  }

  Future<List<Map<String, dynamic>>> _fetchItems({
    required String obsCode,
    required DateTime requestedAt,
  }) async {
    final key = '$obsCode|${_dateKey(requestedAt)}';
    final cached = _rawResponseCache[key];
    if (cached != null &&
        DateTime.now().difference(cached.storedAt) < _rawResponseTtl) {
      return cached.items;
    }
    final running = _rawResponseInFlight[key];
    if (running != null) return running;

    final request = _loadItems(obsCode: obsCode, requestedAt: requestedAt);
    _rawResponseInFlight[key] = request;
    try {
      final items = await request;
      if (_rawResponseCache.length >= _maximumRawCacheEntries) {
        _rawResponseCache.remove(_rawResponseCache.keys.first);
      }
      _rawResponseCache[key] = _CachedItems(
        storedAt: DateTime.now(),
        items: items,
      );
      return items;
    } finally {
      _rawResponseInFlight.remove(key);
    }
  }

  Future<List<Map<String, dynamic>>> _loadItems({
    required String obsCode,
    required DateTime requestedAt,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _path,
      queryParameters: {
        'type': 'json',
        'obsCode': obsCode,
        'reqDate': _dateKey(requestedAt),
        'numOfRows': 10,
      },
    );
    final body = response.data?['body'] as Map<String, dynamic>?;
    final rawItems = (body?['items'] as Map<String, dynamic>?)?['item'];
    return switch (rawItems) {
      final List<dynamic> values =>
        values.whereType<Map<String, dynamic>>().toList(growable: false),
      final Map<String, dynamic> value => [value],
      _ => const <Map<String, dynamic>>[],
    };
  }

  static DateTime? _parseDt(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized = value.length == 16 ? '$value:00' : value;
    return DateTime.tryParse(normalized);
  }

  static String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}$month$day';
  }
}

class _CachedItems {
  const _CachedItems({required this.storedAt, required this.items});

  final DateTime storedAt;
  final List<Map<String, dynamic>> items;
}
