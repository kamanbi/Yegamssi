import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/weather/data/sources/noaa_data_source.dart';

void main() {
  test('NOAA uses location wall time instead of UTC for AM/PM', () {
    final result = NoaaDataSource.parseHourlyDayParts([
      {
        'startTime': '2026-10-06T09:00:00-07:00',
        'temperature': 50,
        'temperatureUnit': 'F',
        'shortForecast': 'Sunny',
      },
      {
        'startTime': '2026-10-06T11:00:00-07:00',
        'temperature': 68,
        'temperatureUnit': 'F',
        'shortForecast': 'Sunny',
      },
      {
        'startTime': '2026-10-06T12:00:00-07:00',
        'temperature': 77,
        'temperatureUnit': 'F',
        'shortForecast': 'Sunny',
      },
      {
        'startTime': '2026-10-06T23:00:00-07:00',
        'temperature': 59,
        'temperatureUnit': 'F',
        'shortForecast': 'Clear',
      },
    ]);
    final forecast = result['2026-10-06']!;
    expect(forecast.amTempMinCelsius, 10);
    expect(forecast.amTempMaxCelsius, 20);
    expect(forecast.pmTempMinCelsius, 15);
    expect(forecast.pmTempMaxCelsius, 25);
    expect(forecast.temperatureAvailable, isFalse);
  });

  test('missing temperatures do not create fake ranges', () {
    final result = NoaaDataSource.parseHourlyDayParts([
      {'startTime': '2026-10-06T09:00:00+09:00', 'temperature': null},
      {'startTime': 'invalid', 'temperature': 20},
    ]);
    expect(result, isEmpty);
  });
}
