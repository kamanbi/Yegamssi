import 'entities/weather_entity.dart';

class DayPartTemperaturePolicy {
  static ({double min, double max})? selectRange({
    required DailyForecast forecast,
    required bool morning,
    ({double min, double max})? supplemental,
    bool requireCompleteCoverage = true,
  }) {
    final minimum = morning
        ? forecast.amTempMinCelsius
        : forecast.pmTempMinCelsius;
    final maximum = morning
        ? forecast.amTempMaxCelsius
        : forecast.pmTempMaxCelsius;
    if (!requireCompleteCoverage && minimum != null && maximum != null) {
      return (min: minimum, max: maximum);
    }
    if (shouldSupplement(forecast, morning: morning)) return supplemental;
    return (min: minimum!, max: maximum!);
  }

  static const middayHour = 12;
  static const coverageIntervalHours = 3;
  static const _intervalsPerHalfDay = middayHour ~/ coverageIntervalHours;

  static bool isComplete(Iterable<int> sampleHours, {required bool morning}) {
    final start = morning ? 0 : middayHour;
    final intervals = sampleHours
        .where((hour) => hour >= start && hour < start + middayHour)
        .map((hour) => (hour - start) ~/ coverageIntervalHours)
        .toSet();
    return intervals.length == _intervalsPerHalfDay;
  }

  static bool shouldSupplement(
    DailyForecast forecast, {
    required bool morning,
  }) {
    final complete = morning
        ? forecast.amTemperatureComplete
        : forecast.pmTemperatureComplete;
    final minimum = morning
        ? forecast.amTempMinCelsius
        : forecast.pmTempMinCelsius;
    final maximum = morning
        ? forecast.amTempMaxCelsius
        : forecast.pmTempMaxCelsius;
    return complete != true || minimum == null || maximum == null;
  }
}
