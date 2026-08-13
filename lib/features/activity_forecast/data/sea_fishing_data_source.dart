import 'package:dio/dio.dart';

import '../../../core/network/weather_proxy_dio.dart';
import '../domain/activity_models.dart';

class SeaFishingDataSource {
  SeaFishingDataSource({Dio? dio})
    : _dio = dio ?? WeatherProxyDio.create(WeatherProxyProvider.publicData);

  static const _path = '/1192136/fcstFishingv2/GetFcstFishingApiServicev2';
  static const _rawResponseTtl = Duration(hours: 6);
  static const _maximumRawCacheEntries = 64;

  final Dio _dio;
  final Map<String, _CachedFishingItems> _rawResponseCache = {};
  final Map<String, Future<List<Map<String, dynamic>>>> _rawResponseInFlight =
      {};

  Future<SeaFishingEvidence?> fetch({
    required DateTime requestedAt,
    required DateTime requestedUntil,
    required String fishingType,
    required String placeName,
    String targetFish = '',
  }) async {
    if (placeName.trim().isEmpty || !requestedUntil.isAfter(requestedAt)) {
      return null;
    }

    final rows = <_FishingForecastRow>[];
    var date = DateTime(requestedAt.year, requestedAt.month, requestedAt.day);
    final lastDate = DateTime(
      requestedUntil.year,
      requestedUntil.month,
      requestedUntil.day,
    );
    while (!date.isAfter(lastDate)) {
      final items = await _fetchItems(
        requestedDate: date,
        fishingType: fishingType,
        placeName: placeName,
      );
      rows.addAll(items.map((item) => _FishingForecastRow(date, item)));
      date = date.add(const Duration(days: 1));
    }

    final normalizedTargetFish = targetFish.trim();
    final candidates = rows
        .where((row) {
          if (row.placeName != placeName.trim()) return false;
          if (normalizedTargetFish.isNotEmpty &&
              row.targetFish != normalizedTargetFish) {
            return false;
          }
          return row.overlaps(requestedAt, requestedUntil) &&
              row.indexRank != null;
        })
        .toList(growable: false);
    if (candidates.isEmpty) return null;

    candidates.sort(
      (left, right) => left.indexRank!.compareTo(right.indexRank!),
    );
    final worst = candidates.first;
    final hasCompleteSafetyData = candidates.every(
      (row) => row.maxWindSpeedMs != null && row.maxWaveHeightM != null,
    );
    final periods = candidates.map((row) => row.period).toSet().join('·');
    final validFrom = candidates
        .map((row) => row.periodStartsAt)
        .reduce((left, right) => left.isBefore(right) ? left : right);
    final validUntil = candidates
        .map((row) => row.periodEndsAt)
        .reduce((left, right) => left.isAfter(right) ? left : right);

    return SeaFishingEvidence(
      stationName: worst.placeName,
      targetFish: normalizedTargetFish.isEmpty ? '전체 어종 최저' : worst.targetFish,
      forecastPeriod: periods,
      officialIndex: worst.officialIndex,
      latitude: worst.latitude!,
      longitude: worst.longitude!,
      maxWindSpeedMs: hasCompleteSafetyData
          ? _maximum(candidates.map((row) => row.maxWindSpeedMs!))
          : null,
      maxWaveHeightM: hasCompleteSafetyData
          ? _maximum(candidates.map((row) => row.maxWaveHeightM!))
          : null,
      maxWaterTemperatureC: _maximumNullable(
        candidates.map((row) => row.maxWaterTemperatureC),
      ),
      tideDescription: candidates
          .map((row) => row.tideDescription)
          .where((value) => value.isNotEmpty)
          .toSet()
          .join('·'),
      forecastStartsAt: validFrom,
      forecastEndsAt: validUntil,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchItems({
    required DateTime requestedDate,
    required String fishingType,
    required String placeName,
  }) async {
    final normalizedPlaceName = placeName.trim();
    final key = '${_dateKey(requestedDate)}|$fishingType|$normalizedPlaceName';
    final cached = _rawResponseCache[key];
    if (cached != null &&
        DateTime.now().difference(cached.storedAt) < _rawResponseTtl) {
      return cached.items;
    }
    final running = _rawResponseInFlight[key];
    if (running != null) return running;

    final request = _loadItems(
      requestedDate: requestedDate,
      fishingType: fishingType,
      placeName: normalizedPlaceName,
    );
    _rawResponseInFlight[key] = request;
    try {
      final items = await request;
      if (_rawResponseCache.length >= _maximumRawCacheEntries) {
        _rawResponseCache.remove(_rawResponseCache.keys.first);
      }
      _rawResponseCache[key] = _CachedFishingItems(
        storedAt: DateTime.now(),
        items: items,
      );
      return items;
    } finally {
      _rawResponseInFlight.remove(key);
    }
  }

  Future<List<Map<String, dynamic>>> _loadItems({
    required DateTime requestedDate,
    required String fishingType,
    required String placeName,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _path,
      queryParameters: {
        'type': 'json',
        'reqDate': _dateKey(requestedDate),
        'gubun': fishingType,
        'placeName': placeName,
        'pageNo': 1,
        'numOfRows': 300,
      },
    );
    final responseBody = response.data?['body'] as Map<String, dynamic>?;
    final rawItems = (responseBody?['items'] as Map<String, dynamic>?)?['item'];
    return switch (rawItems) {
      final List<dynamic> values =>
        values.whereType<Map<String, dynamic>>().toList(growable: false),
      final Map<String, dynamic> value => [value],
      _ => const <Map<String, dynamic>>[],
    };
  }

  double _maximum(Iterable<double> values) =>
      values.reduce((left, right) => left > right ? left : right);

  double? _maximumNullable(Iterable<double?> values) {
    final available = values.whereType<double>();
    return available.isEmpty ? null : _maximum(available);
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}$month$day';
  }
}

class _FishingForecastRow {
  _FishingForecastRow(this.date, this.raw);

  final DateTime date;
  final Map<String, dynamic> raw;

  String get placeName => raw['seafsPstnNm']?.toString().trim() ?? '';
  String get targetFish => raw['seafsTgfshNm']?.toString().trim() ?? '';
  String get period => raw['predcNoonSeCd']?.toString().trim() ?? '';
  String get officialIndex => raw['totalIndex']?.toString().trim() ?? '';
  String get tideDescription => raw['tdlvHrCn']?.toString().trim() ?? '';
  double? get latitude => _double(raw['lat']);
  double? get longitude => _double(raw['lot']);
  double? get maxWindSpeedMs => _double(raw['maxWspd']);
  double? get maxWaveHeightM => _double(raw['maxWvhgt']);
  double? get maxWaterTemperatureC => _double(raw['maxWtem']);

  int? get indexRank => switch (officialIndex.replaceAll(' ', '')) {
    '매우나쁨' => 0,
    '나쁨' => 1,
    '보통' => 2,
    '좋음' => 3,
    '매우좋음' => 4,
    _ => null,
  };

  DateTime get periodStartsAt =>
      period == '오후' ? DateTime(date.year, date.month, date.day, 12) : date;

  DateTime get periodEndsAt => period == '오전'
      ? DateTime(date.year, date.month, date.day, 12)
      : date.add(const Duration(days: 1));

  bool overlaps(DateTime startsAt, DateTime endsAt) {
    if (period != '오전' && period != '오후' && period != '일') return false;
    return periodStartsAt.isBefore(endsAt) && periodEndsAt.isAfter(startsAt);
  }

  static double? _double(Object? value) =>
      double.tryParse(value?.toString() ?? '');
}

class _CachedFishingItems {
  const _CachedFishingItems({required this.storedAt, required this.items});

  final DateTime storedAt;
  final List<Map<String, dynamic>> items;
}
