import 'dart:math' as math;

import 'package:dio/dio.dart';

import '../../../core/network/weather_proxy_dio.dart';
import '../domain/activity_models.dart';

class MidSeaForecastDataSource {
  MidSeaForecastDataSource({Dio? dio})
    : _dio = dio ?? WeatherProxyDio.create(WeatherProxyProvider.kma);

  static const path = '/api/typ02/openApi/MidFcstInfoService/getMidSeaFcst';

  final Dio _dio;

  Future<MidSeaForecastEvidence?> fetch({
    required DateTime requestedAt,
    required DateTime requestedUntil,
    required double latitude,
    required double longitude,
  }) async {
    final region = regionFor(latitude: latitude, longitude: longitude);
    if (region == null) return null;
    for (final issueAt in _candidateIssueTimes(DateTime.now())) {
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          path,
          queryParameters: {
            'pageNo': 1,
            'numOfRows': 10,
            'dataType': 'JSON',
            'regId': region.id,
            'tmFc': _formatIssueAt(issueAt),
          },
        );
        final body =
            response.data?['response']?['body'] as Map<String, dynamic>?;
        final rawItem = (body?['items'] as Map<String, dynamic>?)?['item'];
        final item = switch (rawItem) {
          final List<dynamic> values =>
            values.whereType<Map<String, dynamic>>().firstOrNull,
          final Map<String, dynamic> value => value,
          _ => null,
        };
        if (item == null) continue;
        final evidence = parseItem(
          item,
          issueAt: issueAt,
          requestedAt: requestedAt,
          requestedUntil: requestedUntil,
          region: region,
        );
        if (evidence != null) return evidence;
      } on DioException {
        continue;
      }
    }
    return null;
  }

  static MidSeaForecastEvidence? parseItem(
    Map<String, dynamic> item, {
    required DateTime issueAt,
    required DateTime requestedAt,
    required DateTime requestedUntil,
    required MidSeaRegion region,
  }) {
    final dayOffset = DateTime(
      requestedAt.year,
      requestedAt.month,
      requestedAt.day,
    ).difference(DateTime(issueAt.year, issueAt.month, issueAt.day)).inDays;
    if (dayOffset < 4 || dayOffset > 10) return null;
    final periodSuffix = dayOffset <= 7
        ? (requestedAt.hour < 12 ? 'Am' : 'Pm')
        : '';
    final weatherKey = 'wf$dayOffset$periodSuffix';
    final waveSuffix = dayOffset <= 7 ? periodSuffix : '';
    final minWave = _double(item['wh${dayOffset}A$waveSuffix']);
    final maxWave = _double(item['wh${dayOffset}B$waveSuffix']);
    final weather = item[weatherKey]?.toString().trim() ?? '';
    if (minWave == null || maxWave == null || weather.isEmpty) return null;
    final periodStart = DateTime(
      requestedAt.year,
      requestedAt.month,
      requestedAt.day,
      dayOffset <= 7 && periodSuffix == 'Pm' ? 12 : 0,
    );
    final periodEnd = dayOffset <= 7
        ? periodStart.add(const Duration(hours: 12))
        : periodStart.add(const Duration(days: 1));
    if (!periodStart.isBefore(requestedUntil) ||
        !periodEnd.isAfter(requestedAt)) {
      return null;
    }
    return MidSeaForecastEvidence(
      seaRegionId: region.id,
      seaRegionName: region.name,
      forecastPeriod: dayOffset <= 7
          ? (periodSuffix == 'Am' ? '오전' : '오후')
          : '일',
      weatherSummary: weather,
      minWaveHeightM: math.min(minWave, maxWave),
      maxWaveHeightM: math.max(minWave, maxWave),
      forecastStartsAt: periodStart,
      forecastEndsAt: periodEnd,
    );
  }

  static MidSeaRegion? regionFor({
    required double latitude,
    required double longitude,
  }) {
    if (latitude < 34.2 && longitude >= 125.5 && longitude <= 128.5) {
      return const MidSeaRegion('12D00000', '제주도해상');
    }
    if (longitude < 127.0) {
      return latitude >= 35.2
          ? const MidSeaRegion('12A10000', '서해중부')
          : const MidSeaRegion('12A20000', '서해남부');
    }
    if (longitude < 129.0 && latitude < 35.5) {
      return const MidSeaRegion('12B10000', '남해서부');
    }
    if (latitude < 35.5) {
      return const MidSeaRegion('12B20000', '남해동부');
    }
    if (longitude >= 128.5) {
      return latitude >= 38.0
          ? const MidSeaRegion('12C30000', '동해북부')
          : latitude >= 36.5
          ? const MidSeaRegion('12C20000', '동해중부')
          : const MidSeaRegion('12C10000', '동해남부');
    }
    return null;
  }

  static List<DateTime> _candidateIssueTimes(DateTime now) {
    final todayMorning = DateTime(now.year, now.month, now.day, 6);
    final todayEvening = DateTime(now.year, now.month, now.day, 18);
    final yesterdayMorning = todayMorning.subtract(const Duration(days: 1));
    final yesterdayEvening = todayEvening.subtract(const Duration(days: 1));
    if (!now.isBefore(todayEvening)) {
      return [todayEvening, todayMorning, yesterdayEvening];
    }
    if (!now.isBefore(todayMorning)) {
      return [todayMorning, yesterdayEvening, yesterdayMorning];
    }
    return [yesterdayEvening, yesterdayMorning];
  }

  static String _formatIssueAt(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}'
      '${value.month.toString().padLeft(2, '0')}'
      '${value.day.toString().padLeft(2, '0')}'
      '${value.hour.toString().padLeft(2, '0')}00';

  static double? _double(Object? value) =>
      double.tryParse(value?.toString() ?? '');
}

class MidSeaRegion {
  const MidSeaRegion(this.id, this.name);

  final String id;
  final String name;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
