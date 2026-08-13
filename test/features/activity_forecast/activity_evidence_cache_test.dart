import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yegamssi/features/activity_forecast/data/activity_evidence_cache.dart';
import 'package:yegamssi/features/activity_forecast/domain/activity_models.dart';
import 'package:yegamssi/features/weather/domain/entities/weather_entity.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'reuses fresh weather evidence without calling the loader again',
    () async {
      final cache = ActivityEvidenceCache();
      var calls = 0;

      Future<WeatherEntity> load() async {
        calls++;
        return _weather();
      }

      await cache.getWeather(latitude: 37.57, longitude: 126.98, loader: load);
      final cached = await cache.getWeather(
        latitude: 37.571,
        longitude: 126.981,
        loader: load,
      );

      expect(calls, 1);
      expect(cached.locationName, '테스트');
    },
  );

  test('coalesces concurrent requests for the same weather grid', () async {
    final cache = ActivityEvidenceCache();
    final completer = Completer<WeatherEntity>();
    var calls = 0;

    Future<WeatherEntity> load() {
      calls++;
      return completer.future;
    }

    final first = cache.getWeather(
      latitude: 37.57,
      longitude: 126.98,
      loader: load,
    );
    final second = cache.getWeather(
      latitude: 37.57,
      longitude: 126.98,
      loader: load,
    );
    completer.complete(_weather());

    await Future.wait([first, second]);
    expect(calls, 1);
  });

  test('caches unavailable fishing evidence to prevent retry storms', () async {
    final cache = ActivityEvidenceCache();
    final requestedAt = DateTime(2026, 8, 11, 9);
    var calls = 0;

    Future<SeaFishingEvidence?> load() async {
      calls++;
      return null;
    }

    await cache.getSeaFishingEvidence(
      requestedAt: requestedAt,
      requestedUntil: requestedAt.add(const Duration(hours: 2)),
      fishingType: '갯바위',
      placeName: '가거도',
      targetFish: '감성돔',
      loader: load,
    );
    await cache.getSeaFishingEvidence(
      requestedAt: requestedAt,
      requestedUntil: requestedAt.add(const Duration(hours: 2)),
      fishingType: '갯바위',
      placeName: '가거도',
      targetFish: '감성돔',
      loader: load,
    );

    expect(calls, 1);
  });

  test(
    'keeps forest-fire evidence separate by administrative region',
    () async {
      final cache = ActivityEvidenceCache();
      final requestedAt = DateTime(2026, 8, 11, 12);
      var calls = 0;

      Future<ForestFireEvidence?> load() async {
        calls++;
        return ForestFireEvidence(
          forecastAt: requestedAt,
          maxRiskIndex: calls,
          coverageName: '테스트',
        );
      }

      await cache.getForestFireEvidence(
        requestedAt: requestedAt,
        regionKey: '11',
        loader: load,
      );
      await cache.getForestFireEvidence(
        requestedAt: requestedAt,
        regionKey: '26',
        loader: load,
      );

      expect(calls, 2);
    },
  );

  test(
    'reuses the national current-warning response for ten minutes',
    () async {
      final cache = ActivityEvidenceCache();
      var calls = 0;

      Future<WeatherWarningEvidence?> load() async {
        calls++;
        final now = DateTime.now();
        return WeatherWarningEvidence(
          issuedAt: now,
          effectiveAt: now,
          activeWarnings: const [],
        );
      }

      await cache.getWeatherWarningEvidence(loader: load);
      await cache.getWeatherWarningEvidence(loader: load);
      expect(calls, 1);
    },
  );
}

WeatherEntity _weather() {
  return WeatherEntity(
    tempCelsius: 24,
    feelsLikeCelsius: 25,
    condition: WeatherCondition.sunny,
    windSpeedMs: 2,
    precipProbability: 0,
    uvIndex: 4,
    humidity: 55,
    observedAt: DateTime.now(),
    locationName: '테스트',
  );
}
