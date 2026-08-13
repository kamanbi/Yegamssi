import 'package:dio/dio.dart';

import '../../../core/network/weather_proxy_dio.dart';
import '../domain/activity_models.dart';
import 'marine_station_catalog.dart';

/// 국립해양조사원 파고·수온 시계열 연동.
/// - 파고: https://apis.data.go.kr/1192136/noonWave/GetNoonWaveApiService
/// - 수온: https://apis.data.go.kr/1192136/twRecent/GetTWRecentApiService
class MarineTimeSeriesDataSource {
  MarineTimeSeriesDataSource({
    Dio? dio,
    MarineStationCatalog? waveStations,
    MarineStationCatalog? buoyStations,
  }) : _dio = dio ?? WeatherProxyDio.create(WeatherProxyProvider.publicData),
       _waveStations =
           waveStations ??
           MarineStationCatalog(
             assetPath: MarineStationCatalog.waveStationsAssetPath,
           ),
       _buoyStations =
           buoyStations ??
           MarineStationCatalog(
             assetPath: MarineStationCatalog.buoyStationsAssetPath,
           );

  static const _wavePath = '/1192136/noonWave/GetNoonWaveApiService';
  static const _waterTemperaturePath = '/1192136/twRecent/GetTWRecentApiService';
  static const _hourlyIntervalMinutes = 60;
  static const _rawResponseTtl = Duration(minutes: 30);
  static const _maximumRawCacheEntries = 64;

  final Dio _dio;
  final MarineStationCatalog _waveStations;
  final MarineStationCatalog _buoyStations;
  final Map<String, _CachedItems> _rawResponseCache = {};
  final Map<String, Future<List<Map<String, dynamic>>>> _rawResponseInFlight =
      {};

  Future<MarineTimeSeriesEvidence?> fetchWaveHeight({
    required DateTime requestedAt,
    required DateTime requestedUntil,
    required String stationName,
  }) => _fetch(
    kind: MarineTimeSeriesKind.waveHeight,
    path: _wavePath,
    stations: _waveStations,
    valueField: 'wvhgt',
    requestedAt: requestedAt,
    requestedUntil: requestedUntil,
    stationName: stationName,
  );

  Future<MarineTimeSeriesEvidence?> fetchWaterTemperature({
    required DateTime requestedAt,
    required DateTime requestedUntil,
    required String stationName,
  }) => _fetch(
    kind: MarineTimeSeriesKind.waterTemperature,
    path: _waterTemperaturePath,
    stations: _buoyStations,
    valueField: 'wtem',
    requestedAt: requestedAt,
    requestedUntil: requestedUntil,
    stationName: stationName,
  );

  Future<MarineTimeSeriesEvidence?> _fetch({
    required MarineTimeSeriesKind kind,
    required String path,
    required MarineStationCatalog stations,
    required String valueField,
    required DateTime requestedAt,
    required DateTime requestedUntil,
    required String stationName,
  }) async {
    if (!requestedUntil.isAfter(requestedAt)) return null;
    final obsCode = await stations.findObsCode(stationName);
    if (obsCode == null) return null;

    final points = <MarineTimeSeriesPoint>[];
    var date = DateTime(requestedAt.year, requestedAt.month, requestedAt.day);
    final lastDate = DateTime(
      requestedUntil.year,
      requestedUntil.month,
      requestedUntil.day,
    );
    while (!date.isAfter(lastDate)) {
      final items = await _fetchItems(
        path: path,
        obsCode: obsCode,
        requestedDate: date,
      );
      for (final item in items) {
        final time = DateTime.tryParse(item['obsrvnDt']?.toString() ?? '');
        final value = double.tryParse(item[valueField]?.toString() ?? '');
        if (time == null || value == null) continue;
        if (time.isBefore(requestedAt) || time.isAfter(requestedUntil)) {
          continue;
        }
        points.add(MarineTimeSeriesPoint(time: time, value: value));
      }
      date = date.add(const Duration(days: 1));
    }
    if (points.isEmpty) return null;

    points.sort((left, right) => left.time.compareTo(right.time));
    return MarineTimeSeriesEvidence(
      kind: kind,
      stationName: stationName,
      points: points,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchItems({
    required String path,
    required String obsCode,
    required DateTime requestedDate,
  }) async {
    final key = '$path|$obsCode|${_dateKey(requestedDate)}';
    final cached = _rawResponseCache[key];
    if (cached != null &&
        DateTime.now().difference(cached.storedAt) < _rawResponseTtl) {
      return cached.items;
    }
    final running = _rawResponseInFlight[key];
    if (running != null) return running;

    final request = _loadItems(
      path: path,
      obsCode: obsCode,
      requestedDate: requestedDate,
    );
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
    required String path,
    required String obsCode,
    required DateTime requestedDate,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {
        'type': 'json',
        'obsCode': obsCode,
        'reqDate': _dateKey(requestedDate),
        'min': _hourlyIntervalMinutes,
        'numOfRows': 30,
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
