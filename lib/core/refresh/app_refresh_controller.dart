import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/fortune/presentation/fortune_provider.dart';
import '../../features/fortune/domain/entities/fortune_result.dart';
import '../../features/score/presentation/score_provider.dart';
import '../../features/weather/domain/entities/weather_entity.dart';
import '../../features/weather/presentation/weather_provider.dart';
import '../../features/widget_bridge/widget_snapshot_sync.dart';
import '../locale/country_resolver.dart';
import '../locale/locale_provider.dart';
import '../refresh/refresh_policy.dart';
import '../storage/weather_cache_store.dart';
import '../utils/location_provider.dart';

final appRefreshControllerProvider = Provider<AppRefreshController>(
  (ref) => AppRefreshController(ref),
);

class AppRefreshController {
  AppRefreshController(this._ref);

  final Ref _ref;

  Future<void> refreshSignals({bool force = false}) async {
    final refreshId = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    _logRefresh('start id=$refreshId force=$force');
    final position = await _ref.read(currentPositionProvider.future);
    final cachedWeather = await WeatherCacheStore.load(allowStale: true);
    final weatherRefreshDue = RefreshPolicy.isWeatherRefreshDue(
      cachedWeather,
      force: force,
    );
    final weather = weatherRefreshDue
        ? await _fetchAndPersistWeather(
            lat: position.lat,
            lon: position.lon,
            cachedWeather: cachedWeather,
            refreshId: refreshId,
          )
        : cachedWeather != null && hasUsableForecastSnapshot(cachedWeather)
        ? await localizedWeatherLocation(
            _ref,
            cachedWeather,
            lat: position.lat,
            lon: position.lon,
          )
        : await _fetchAndPersistWeather(
            lat: position.lat,
            lon: position.lon,
            cachedWeather: cachedWeather,
            refreshId: refreshId,
          );
    _logRefresh(
      'id=$refreshId '
      'weather condition=${weather.condition.name} '
      'temp=${weather.tempCelsius.round()} '
      'feels=${weather.feelsLikeCelsius.round()} '
      'observedAt=${weather.observedAt.toIso8601String()}',
    );

    if (force || !identical(weather, cachedWeather)) {
      _ref.invalidate(currentWeatherProvider);
    }
    final language = await loadSavedAppLanguage();
    final country = await _ref.read(resolvedCountryProvider.future);
    final score = calculateActivityScore(weather: weather, country: country);
    _ref.invalidate(currentScoreProvider);
    final fortune = await _loadFortuneForSnapshot(refreshId);
    _logRefresh(
      'id=$refreshId outdoor score=${score.score} tier=${score.tier.name}',
    );
    _logRefresh(
      'id=$refreshId fortune arrow=${widgetFortuneSymbolFor(fortune)}',
    );

    await syncWidgetSnapshot(
      weather: weather,
      score: score,
      latitude: position.lat,
      longitude: position.lon,
      language: language,
      country: country,
      fortune: fortune,
    );
    _logRefresh('done id=$refreshId');
  }

  Future<WeatherEntity> _fetchAndPersistWeather({
    required double lat,
    required double lon,
    required WeatherEntity? cachedWeather,
    required String refreshId,
  }) async {
    final repo = await _ref.read(weatherRepositoryProvider.future);
    final result = await repo.getCurrentWeather(lat: lat, lon: lon);
    if (result.error != null) {
      _logRefresh('id=$refreshId weather refresh failed: ${result.error}');
      throw result.error!;
    }
    final data = result.data;
    if (data == null) {
      _logRefresh('id=$refreshId weather refresh failed: empty response');
      throw StateError('Weather refresh returned no data.');
    }

    final weather = mergeWeatherSnapshot(
      nextWeather: data,
      cachedWeather: cachedWeather,
    );
    await WeatherCacheStore.save(weather);
    return weather;
  }

  void _logRefresh(String message) {
    debugPrint('[AppRefresh][${DateTime.now().toIso8601String()}] $message');
  }

  Future<FortuneResult?> _loadFortuneForSnapshot(String refreshId) async {
    try {
      return await _ref
          .read(dailyFortuneProvider.future)
          .timeout(RefreshPolicy.networkTimeout);
    } catch (error) {
      _logRefresh('id=$refreshId fortune skipped: $error');
      return null;
    }
  }
}
