import 'package:dio/dio.dart';

import '../../../core/network/weather_proxy_dio.dart';
import '../domain/activity_models.dart';
import 'marine_station_catalog.dart';

/// 국립해양조사원 조류예보(시계열) 연동.
/// https://apis.data.go.kr/1192136/crntFcstTime/GetCrntFcstTimeApiService
///
/// 최강창낙조·전류 시각은 별도 API(crntFcstFldEbb)가 필요해 이 소스는
/// [CurrentEvidence.maxFloodAt]/[maxEbbAt]/[slackAt]를 채우지 않는다.
class CurrentDataSource {
  CurrentDataSource({Dio? dio, MarineStationCatalog? stations})
    : _dio = dio ?? WeatherProxyDio.create(WeatherProxyProvider.publicData),
      _stations =
          stations ??
          MarineStationCatalog(
            assetPath: MarineStationCatalog.currentStationsAssetPath,
          );

  static const _path = '/1192136/crntFcstTime/GetCrntFcstTimeApiService';
  static const _rawResponseTtl = Duration(minutes: 30);
  static const _maximumRawCacheEntries = 64;
  static const _hourlyIntervalMinutes = 60;

  final Dio _dio;
  final MarineStationCatalog _stations;
  final Map<String, _CachedItems> _rawResponseCache = {};
  final Map<String, Future<List<Map<String, dynamic>>>> _rawResponseInFlight =
      {};

  Future<CurrentEvidence?> fetch({
    required DateTime requestedAt,
    required DateTime requestedUntil,
    required String stationName,
  }) async {
    if (!requestedUntil.isAfter(requestedAt)) return null;
    final obsCode = await _stations.findObsCode(stationName);
    if (obsCode == null) return null;

    final samples = <_CurrentSample>[];
    var date = DateTime(requestedAt.year, requestedAt.month, requestedAt.day);
    final lastDate = DateTime(
      requestedUntil.year,
      requestedUntil.month,
      requestedUntil.day,
    );
    while (!date.isAfter(lastDate)) {
      final items = await _fetchItems(obsCode: obsCode, requestedDate: date);
      samples.addAll(items.map(_sampleFromItem).whereType<_CurrentSample>());
      date = date.add(const Duration(days: 1));
    }

    final withinWindow = samples
        .where(
          (sample) =>
              !sample.time.isBefore(requestedAt) &&
              !sample.time.isAfter(requestedUntil),
        )
        .toList(growable: false);
    if (withinWindow.isEmpty) return null;

    withinWindow.sort((left, right) => right.speedCms.compareTo(left.speedCms));
    final strongest = withinWindow.first;

    return CurrentEvidence(
      stationName: stationName,
      maxSpeedCms: strongest.speedCms,
      direction: strongest.direction,
    );
  }

  _CurrentSample? _sampleFromItem(Map<String, dynamic> item) {
    final time = DateTime.tryParse(
      (item['predcDt'] ?? item['obsrvnDt'])?.toString() ?? '',
    );
    final speed = double.tryParse(item['crsp']?.toString() ?? '');
    final direction = item['crdir']?.toString();
    if (time == null || speed == null || direction == null || direction.isEmpty) {
      return null;
    }
    return _CurrentSample(time: time, speedCms: speed, direction: direction);
  }

  Future<List<Map<String, dynamic>>> _fetchItems({
    required String obsCode,
    required DateTime requestedDate,
  }) async {
    final key = '$obsCode|${_dateKey(requestedDate)}';
    final cached = _rawResponseCache[key];
    if (cached != null &&
        DateTime.now().difference(cached.storedAt) < _rawResponseTtl) {
      return cached.items;
    }
    final running = _rawResponseInFlight[key];
    if (running != null) return running;

    final request = _loadItems(obsCode: obsCode, requestedDate: requestedDate);
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
    required DateTime requestedDate,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _path,
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

class _CurrentSample {
  const _CurrentSample({
    required this.time,
    required this.speedCms,
    required this.direction,
  });

  final DateTime time;
  final double speedCms;
  final String direction;
}

class _CachedItems {
  const _CachedItems({required this.storedAt, required this.items});

  final DateTime storedAt;
  final List<Map<String, dynamic>> items;
}
