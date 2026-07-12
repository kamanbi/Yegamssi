import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/weather/domain/entities/weather_entity.dart';
import 'package:yegamssi/features/weather/presentation/weather_provider.dart';

void main() {
  WeatherEntity weatherWithForecasts({
    required List<HourlyForecast> hourlyForecasts,
    required List<DailyForecast> dailyForecasts,
  }) {
    return WeatherEntity(
      tempCelsius: 20,
      feelsLikeCelsius: 20,
      condition: WeatherCondition.sunny,
      windSpeedMs: 1,
      precipProbability: 0,
      uvIndex: 0,
      humidity: 50,
      observedAt: DateTime.now(),
      locationName: 'Test',
      hourlyForecasts: hourlyForecasts,
      dailyForecasts: dailyForecasts,
    );
  }

  DailyForecast daily(DateTime date) {
    return DailyForecast(
      date: date,
      tempMin: 10,
      tempMax: 20,
      condition: WeatherCondition.sunny,
      precipProbability: 0,
    );
  }

  test('does not accept a cache with only expired hourly forecasts', () {
    final now = DateTime.now();
    final weather = weatherWithForecasts(
      hourlyForecasts: [
        HourlyForecast(
          time: now.subtract(const Duration(hours: 1)),
          tempCelsius: 20,
          condition: WeatherCondition.sunny,
        ),
      ],
      dailyForecasts: [daily(now)],
    );

    expect(hasUsableForecastSnapshot(weather), isFalse);
  });

  test('merge removes expired hourly and pre-today daily forecasts', () {
    final now = DateTime.now();
    final next = weatherWithForecasts(
      hourlyForecasts: [
        HourlyForecast(
          time: now.subtract(const Duration(hours: 2)),
          tempCelsius: 18,
          condition: WeatherCondition.cloudy,
        ),
        HourlyForecast(
          time: now.add(const Duration(hours: 1)),
          tempCelsius: 21,
          condition: WeatherCondition.sunny,
        ),
      ],
      dailyForecasts: [
        daily(now.subtract(const Duration(days: 1))),
        daily(now),
      ],
    );

    final merged = mergeWeatherSnapshot(nextWeather: next);

    expect(merged.hourlyForecasts, hasLength(1));
    expect(merged.hourlyForecasts.single.time.isAfter(now), isTrue);
    expect(merged.dailyForecasts, hasLength(1));
    expect(merged.dailyForecasts.single.date.day, now.day);
  });
}
