import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/core/storage/weather_snapshot_cache_codec.dart';
import 'package:yegamssi/features/weather/data/models/weather_response.dart';
import 'package:yegamssi/features/weather/data/sources/kma_daily_temperature_policy.dart';
import 'package:yegamssi/features/weather/domain/entities/weather_entity.dart';

DailyForecast forecast({
  bool minimum = false,
  bool maximum = false,
  double low = 0,
  double high = 0,
  int day = 5,
}) => DailyForecast(
  date: DateTime(2026, 10, day),
  tempMin: low,
  tempMax: high,
  condition: WeatherCondition.cloudy,
  precipProbability: 0.3,
  temperatureAvailable: minimum && maximum,
  tempMinAvailable: minimum,
  tempMaxAvailable: maximum,
);

WeatherEntity entity(DailyForecast daily) => WeatherResponse(
  tempCelsius: 18,
  feelsLikeCelsius: 18,
  condition: WeatherCondition.cloudy,
  windSpeedMs: 1,
  precipProbability: 0,
  uvIndex: 1,
  humidity: 50,
  locationName: 'Test',
  dailyForecasts: [daily],
).toEntity();

void main() {
  test(
    'midterm fallback skipped when short term already covers missing date',
    () {
      expect(
        KmaDailyTemperaturePolicy.needsMidTermFallback((
          weatherDates: {'20261008', '20261009'},
          temperatureDates: {'20261009'},
          completeShortTermDates: {'20261008'},
        )),
        isFalse,
      );
    },
  );

  test('midterm fallback required only for uncovered weather dates', () {
    expect(
      KmaDailyTemperaturePolicy.needsMidTermFallback((
        weatherDates: {'20261009', '20261010'},
        temperatureDates: {'20261010'},
        completeShortTermDates: <String>{},
      )),
      isTrue,
    );
  });

  test('only available daily extreme is visible, zero is valid', () {
    final daily = forecast(maximum: true);
    expect(daily.hasMinTemperature, isFalse);
    expect(daily.hasMaxTemperature, isTrue);
    expect(daily.temperatureAvailable, isFalse);
  });

  test('fills only missing extreme and keeps latest weather and maximum', () {
    final latest = forecast(maximum: true, high: 21);
    final actual = KmaDailyTemperaturePolicy.fillMissing(
      latest,
      forecast(minimum: true, maximum: true, low: 15, high: 20),
    );
    expect(actual.tempMin, 15);
    expect(actual.tempMax, 21);
    expect(actual.temperatureAvailable, isTrue);
    expect(actual.condition, latest.condition);
    expect(actual.precipProbability, latest.precipProbability);
  });

  test('does not import different-date or unavailable sample extrema', () {
    final latest = forecast();
    expect(
      KmaDailyTemperaturePolicy.fillMissing(
        latest,
        forecast(minimum: true, maximum: true, low: 10, high: 20, day: 6),
      ),
      same(latest),
    );
    final actual = KmaDailyTemperaturePolicy.fillMissing(
      latest,
      forecast(low: 14, high: 14),
    );
    expect(actual.hasMinTemperature, isFalse);
    expect(actual.hasMaxTemperature, isFalse);
  });

  test('complete latest extremes are not replaced', () {
    final latest = forecast(minimum: true, maximum: true, low: 16, high: 22);
    expect(
      KmaDailyTemperaturePolicy.fillMissing(latest, forecast()),
      same(latest),
    );
  });

  test('Friday restored from morning issue without replacing Saturday', () {
    final latest = KmaDailyTemperaturePolicy.parseMidTermText(
      '# REG_ID TM_FC TM_EF MOD STN C MIN MAX\n'
          '11B20201 202610051800 202610100000 A01 109 2 14 25\n',
      '11B20201',
    );
    final previous = KmaDailyTemperaturePolicy.parseMidTermText(
      '11B20201 202610050600 202610090000 A01 109 2 13 25\n'
          '11B20201 202610050600 202610100000 A01 109 2 14 24\n',
      '11B20201',
    );
    final actual = KmaDailyTemperaturePolicy.fillMissingDates(latest, previous);
    expect(actual['20261009'], (13, 25));
    expect(actual['20261010'], (14, 25));
  });

  test('malformed rows and different region are ignored', () {
    expect(
      KmaDailyTemperaturePolicy.parseMidTermText(
        '# comment\ninvalid\n'
            '11B20201 202610050600 202610090000 A01 109 2 x 25\n'
            '11B20201 202610050600 202610090000 A01 109 2 30 25\n'
            '11C10301 202610050600 202610090000 A01 109 2 13 25\n',
        '11B20201',
      ),
      isEmpty,
    );
  });

  test('per-extreme availability survives response and cache round trip', () {
    final weather = entity(forecast(maximum: true, high: 20));
    expect(weather.dailyForecasts.single.hasMinTemperature, isFalse);
    expect(weather.dailyForecasts.single.hasMaxTemperature, isTrue);
    final decoded = WeatherSnapshotCacheCodec.fromJson(
      WeatherSnapshotCacheCodec.toJson(weather),
    ).dailyForecasts.single;
    expect(decoded.hasMinTemperature, isFalse);
    expect(decoded.hasMaxTemperature, isTrue);
    expect(decoded.tempMax, 20);
  });

  test('legacy cache remains conservative until weather refresh', () {
    final json = WeatherSnapshotCacheCodec.toJson(entity(forecast()));
    final daily = (json['dailyForecasts'] as List).single as Map;
    daily.remove('tempMinAvailable');
    daily.remove('tempMaxAvailable');
    final restored = WeatherSnapshotCacheCodec.fromJson(
      json,
    ).dailyForecasts.single;
    expect(restored.hasMinTemperature, isFalse);
    expect(restored.hasMaxTemperature, isFalse);
    daily['temperatureAvailable'] = true;
    final legacyComplete = WeatherSnapshotCacheCodec.fromJson(
      json,
    ).dailyForecasts.single;
    expect(legacyComplete.hasMinTemperature, isTrue);
    expect(legacyComplete.hasMaxTemperature, isTrue);
  });
}
