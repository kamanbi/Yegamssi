import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/weather_proxy_dio.dart';

typedef TemperatureRange = ({double min, double max});
typedef SupplementalDay = ({TemperatureRange? am, TemperatureRange? pm});

class SupplementalTemperatureSource {
  static const cacheLifetime = Duration(hours: 6);
  static const gridScale = 20;
  static const middayHour = 12;
  static const _koreaOffset = Duration(hours: 9);
  static const _minimumSamplesPerDayPart = 2;

  Future<Map<String, SupplementalDay>> load(
    ({double lat, double lon}) position, {
    required bool Function() isActive,
  }) async {
    final lat = (position.lat * gridScale).round() / gridScale;
    final lon = (position.lon * gridScale).round() / gridScale;
    final key = 'met_temperature_v1_${lat}_$lon';
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(key);
    if (cached != null) {
      try {
        final envelope = jsonDecode(cached) as Map<String, dynamic>;
        final expires = DateTime.parse(envelope['expires'] as String);
        if (DateTime.now().isBefore(expires)) {
          final parsed = parse(envelope['data'] as Map<String, dynamic>);
          if (parsed.isNotEmpty) return parsed;
        }
      } catch (_) {
        // Only discard this supplemental cache, never the KMA weather cache.
        await prefs.remove(key);
      }
    }
    if (!isActive() ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return const {};
    }
    final response =
        await WeatherProxyDio.create(
          WeatherProxyProvider.metNorway,
        ).get<Map<String, dynamic>>(
          '/weatherapi/locationforecast/2.0/compact',
          queryParameters: {
            'lat': lat.toStringAsFixed(2),
            'lon': lon.toStringAsFixed(2),
          },
        );
    final data = response.data;
    if (data == null) return const {};
    final parsed = parse(data);
    if (parsed.isEmpty) return parsed;
    await prefs.setString(
      key,
      jsonEncode({
        'expires': DateTime.now().add(cacheLifetime).toIso8601String(),
        'data': data,
      }),
    );
    return parsed;
  }

  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static Map<String, SupplementalDay> parse(Map<String, dynamic> data) {
    final properties = data['properties'] as Map<String, dynamic>?;
    final series = properties?['timeseries'] as List<dynamic>? ?? const [];
    final result = <String, SupplementalDay>{};
    final sampleTimes = <(String, bool), Set<DateTime>>{};
    for (final raw in series) {
      if (raw is! Map<String, dynamic>) continue;
      final time = DateTime.tryParse(raw['time'] as String? ?? '');
      final details =
          ((raw['data'] as Map<String, dynamic>?)?['instant']
                  as Map<String, dynamic>?)?['details']
              as Map<String, dynamic>?;
      final temp = (details?['air_temperature'] as num?)?.toDouble();
      if (time == null || temp == null || !temp.isFinite) continue;
      final localTime = time.toUtc().add(_koreaOffset);
      final key = dateKey(localTime);
      final previous = result[key] ?? (am: null, pm: null);
      final morning = localTime.hour < middayHour;
      sampleTimes.putIfAbsent((key, morning), () => <DateTime>{}).add(time);
      final old = morning ? previous.am : previous.pm;
      final range = (
        min: min(old?.min ?? temp, temp),
        max: max(old?.max ?? temp, temp),
      );
      result[key] = morning
          ? (am: range, pm: previous.pm)
          : (am: previous.am, pm: range);
    }
    return {
      for (final entry in result.entries)
        if ((sampleTimes[(entry.key, true)]?.length ?? 0) >=
                _minimumSamplesPerDayPart ||
            (sampleTimes[(entry.key, false)]?.length ?? 0) >=
                _minimumSamplesPerDayPart)
          entry.key: (
            am:
                (sampleTimes[(entry.key, true)]?.length ?? 0) >=
                    _minimumSamplesPerDayPart
                ? entry.value.am
                : null,
            pm:
                (sampleTimes[(entry.key, false)]?.length ?? 0) >=
                    _minimumSamplesPerDayPart
                ? entry.value.pm
                : null,
          ),
    };
  }
}
