import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/weather/domain/day_part_temperature_policy.dart';
import 'package:yegamssi/features/weather/domain/entities/weather_entity.dart';

void main() {
  final partialMonday = DailyForecast(
    date: DateTime(2026, 10, 19),
    tempMin: 17,
    tempMax: 17,
    condition: WeatherCondition.sunny,
    precipProbability: 0,
    amTempMinCelsius: 17,
    amTempMaxCelsius: 17,
    amTemperatureComplete: false,
  );

  test('Monday midnight alone is not a morning range', () {
    expect(
      DayPartTemperaturePolicy.selectRange(
        forecast: partialMonday,
        morning: true,
      ),
      isNull,
    );
  });

  test('supplement replaces the incomplete Monday range', () {
    expect(
      DayPartTemperaturePolicy.selectRange(
        forecast: partialMonday,
        morning: true,
        supplemental: (min: 11.8, max: 13.3),
      ),
      (min: 11.8, max: 13.3),
    );
  });

  test('complete constant-temperature coverage takes priority', () {
    expect(
      DayPartTemperaturePolicy.selectRange(
        forecast: partialMonday.copyWith(amTemperatureComplete: true),
        morning: true,
        supplemental: (min: 11.8, max: 13.3),
      ),
      (min: 17.0, max: 17.0),
    );
  });

  test('non-Korean ranges do not require KMA coverage metadata', () {
    expect(
      DayPartTemperaturePolicy.selectRange(
        forecast: partialMonday,
        morning: true,
        requireCompleteCoverage: false,
      ),
      (min: 17.0, max: 17.0),
    );
  });
}
