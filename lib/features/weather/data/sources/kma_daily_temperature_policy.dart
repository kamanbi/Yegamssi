import '../../domain/entities/weather_entity.dart';

class KmaDailyTemperaturePolicy {
  static List<Map<String, dynamic>> mergeForecastDay(
    ({
      List<Map<String, dynamic>> history,
      List<Map<String, dynamic>> latest,
      String date,
    })
    input,
  ) {
    final byTimeAndCategory = <(String, String), Map<String, dynamic>>{};
    for (final item in [...input.history, ...input.latest]) {
      if (item['fcstDate'] != input.date) continue;
      final time = item['fcstTime'];
      final category = item['category'];
      if (time is! String || category is! String) continue;
      byTimeAndCategory[(time, category)] = item;
    }
    return byTimeAndCategory.values.toList(growable: false);
  }

  static const _requiredColumns = 8;
  static const _dateLength = 8;
  static const _effectiveTimeColumn = 2;
  static const _minimumColumn = 6;
  static const _maximumColumn = 7;

  static Map<String, (int, int)> parseMidTermText(
    String text,
    String regionId,
  ) {
    final result = <String, (int, int)>{};
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final columns = trimmed.split(RegExp(r'\s+'));
      if (columns.length < _requiredColumns || columns.first != regionId) {
        continue;
      }
      final effectiveTime = columns[_effectiveTimeColumn];
      if (effectiveTime.length < _dateLength) continue;
      final minimum = int.tryParse(columns[_minimumColumn]);
      final maximum = int.tryParse(columns[_maximumColumn]);
      if (minimum == null || maximum == null || minimum > maximum) continue;
      result.putIfAbsent(
        effectiveTime.substring(0, _dateLength),
        () => (minimum, maximum),
      );
    }
    return result;
  }

  static Map<String, (int, int)> fillMissingDates(
    Map<String, (int, int)> latest,
    Map<String, (int, int)> previous,
  ) => {...previous, ...latest};

  static bool needsMidTermFallback(
    ({
      Set<String> weatherDates,
      Set<String> temperatureDates,
      Set<String> completeShortTermDates,
    })
    coverage,
  ) => coverage.weatherDates.any(
    (date) =>
        !coverage.temperatureDates.contains(date) &&
        !coverage.completeShortTermDates.contains(date),
  );

  static DailyForecast fillMissing(
    DailyForecast latest,
    DailyForecast fallback,
  ) {
    if (latest.date.year != fallback.date.year ||
        latest.date.month != fallback.date.month ||
        latest.date.day != fallback.date.day) {
      return latest;
    }
    if (latest.hasMinTemperature && latest.hasMaxTemperature) return latest;

    final hasMin = latest.hasMinTemperature || fallback.hasMinTemperature;
    final hasMax = latest.hasMaxTemperature || fallback.hasMaxTemperature;
    return latest.copyWith(
      tempMin: latest.hasMinTemperature ? latest.tempMin : fallback.tempMin,
      tempMax: latest.hasMaxTemperature ? latest.tempMax : fallback.tempMax,
      tempMinAvailable: hasMin,
      tempMaxAvailable: hasMax,
      temperatureAvailable: hasMin && hasMax,
    );
  }
}
