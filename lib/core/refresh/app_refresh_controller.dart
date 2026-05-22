import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/fortune/presentation/fortune_provider.dart';
import '../../features/score/presentation/score_provider.dart';
import '../../features/weather/presentation/weather_provider.dart';
import '../../features/widget_bridge/widget_snapshot_sync.dart';
import '../storage/weather_cache_store.dart';
import '../utils/location_provider.dart';

final appRefreshControllerProvider = Provider<AppRefreshController>(
  (ref) => AppRefreshController(ref),
);

class AppRefreshController {
  AppRefreshController(this._ref);

  final Ref _ref;

  Future<void> refreshSignals() async {
    _ref.invalidate(currentPositionProvider);
    _ref.invalidate(currentScoreProvider);

    final position = await _ref.read(currentPositionProvider.future);
    final repo = await _ref.read(weatherRepositoryProvider.future);
    final cachedWeather = await WeatherCacheStore.load();
    final result = await repo.getCurrentWeather(
      lat: position.lat,
      lon: position.lon,
    );
    final weather = result.data == null
        ? await _ref.read(currentWeatherProvider.future)
        : mergeWeatherSnapshot(
            nextWeather: result.data!,
            cachedWeather: cachedWeather,
          );
    if (result.data != null &&
        shouldPersistWeatherSnapshot(
          nextWeather: weather,
          cachedWeather: cachedWeather,
        )) {
      await WeatherCacheStore.save(weather);
    }
    _ref.invalidate(currentWeatherProvider);
    final score = await _ref.read(currentScoreProvider.future);
    final fortune = _ref.read(dailyFortuneProvider).valueOrNull;

    await syncWidgetSnapshot(
      weather: weather,
      score: score,
      latitude: position.lat,
      longitude: position.lon,
      fortune: fortune,
    );
  }
}
