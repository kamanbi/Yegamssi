import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/locale/country_code.dart';
import '../../../core/locale/country_resolver.dart';
import '../../../core/storage/weather_cache_store.dart';
import '../../../core/utils/location_provider.dart';
import '../data/repositories/weather_repository_impl.dart';
import '../data/sources/fallback_weather_data_source.dart';
import '../data/sources/kma_data_source.dart';
import '../data/sources/noaa_data_source.dart';
import '../data/sources/openweather_data_source.dart';
import '../domain/entities/weather_entity.dart';
import '../domain/repositories/weather_repository.dart';

part 'weather_provider.g.dart';

const Duration _weatherAutoRefreshInterval = Duration(minutes: 15);

DateTime? _lastPassiveWeatherRefreshAt;

@Riverpod(keepAlive: true)
Future<WeatherRepository> weatherRepository(Ref ref) async {
  final country = await ref.watch(resolvedCountryProvider.future);
  final source = switch (country) {
    CountryCode.kr => FallbackWeatherDataSource([KmaDataSource()]),
    CountryCode.us => FallbackWeatherDataSource([
        NoaaDataSource(),
        OpenWeatherDataSource(),
      ]),
    _ => FallbackWeatherDataSource([OpenWeatherDataSource()]),
  };
  debugPrint('[Weather] repository country=${country.isoCode}');
  return WeatherRepositoryImpl(source);
}

@Riverpod(keepAlive: true)
Future<WeatherEntity> currentWeather(Ref ref) async {
  final timer = Timer(_weatherAutoRefreshInterval, () {
    ref.invalidate(currentPositionProvider);
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  final cachedWeather = await WeatherCacheStore.load();
  if (cachedWeather != null) {
    debugPrint(
      '[Weather] cache hit condition=${cachedWeather.condition.name}'
      ' temp=${cachedWeather.tempCelsius.round()}'
      ' feelsLike=${cachedWeather.feelsLikeCelsius.round()}',
    );
    _refreshWeatherInBackground(ref, cachedWeather);
    return cachedWeather;
  }

  final position = await ref.watch(currentPositionProvider.future);
  final repo = await ref.watch(weatherRepositoryProvider.future);
  final result = await repo.getCurrentWeather(
    lat: position.lat,
    lon: position.lon,
  );
  if (result.error != null) {
    debugPrint('[Weather] fetch error: ${result.error}');
    throw result.error!;
  }

  final weather = result.data!;
  debugPrint(
    '[Weather] fetch ok condition=${weather.condition.name}'
    ' temp=${weather.tempCelsius.round()}'
    ' feelsLike=${weather.feelsLikeCelsius.round()}',
  );
  if (shouldPersistWeatherSnapshot(
    nextWeather: weather,
    cachedWeather: cachedWeather,
  )) {
    await WeatherCacheStore.save(weather);
  }
  return weather;
}

void _refreshWeatherInBackground(Ref ref, WeatherEntity cachedWeather) {
  final now = DateTime.now();
  final lastRefreshAt = _lastPassiveWeatherRefreshAt;
  if (lastRefreshAt != null &&
      now.difference(lastRefreshAt) < _weatherAutoRefreshInterval) {
    return;
  }

  _lastPassiveWeatherRefreshAt = now;
  unawaited(() async {
    try {
      final position = await ref.read(currentPositionProvider.future);
      final repo = await ref.read(weatherRepositoryProvider.future);
      final result = await repo.getCurrentWeather(
        lat: position.lat,
        lon: position.lon,
      );
      if (result.error != null || result.data == null) {
        return;
      }

      final weather = mergeWeatherSnapshot(
        nextWeather: result.data!,
        cachedWeather: cachedWeather,
      );
      debugPrint(
        '[Weather] bg refresh ok condition=${weather.condition.name}'
        ' temp=${weather.tempCelsius.round()}',
      );
      if (shouldPersistWeatherSnapshot(
        nextWeather: weather,
        cachedWeather: cachedWeather,
      )) {
        await WeatherCacheStore.save(weather);
      }
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('[Weather] bg refresh error: $e');
    }
  }());
}

@riverpod
class WeatherNotifier extends _$WeatherNotifier {
  @override
  AsyncValue<WeatherEntity> build() {
    return const AsyncValue.loading();
  }

  Future<void> fetch({required double lat, required double lon}) async {
    state = const AsyncValue.loading();
    final cachedWeather = await WeatherCacheStore.load();
    final repo = await ref.read(weatherRepositoryProvider.future);
    final result = await repo.getCurrentWeather(lat: lat, lon: lon);
    if (result.error != null) {
      if (cachedWeather != null) {
        state = AsyncValue.data(cachedWeather);
        return;
      }
      state = AsyncValue.error(result.error!, StackTrace.current);
      return;
    }

    final mergedWeather = mergeWeatherSnapshot(
      nextWeather: result.data!,
      cachedWeather: cachedWeather,
    );
    if (shouldPersistWeatherSnapshot(
      nextWeather: mergedWeather,
      cachedWeather: cachedWeather,
    )) {
      await WeatherCacheStore.save(mergedWeather);
    }
    state = AsyncValue.data(mergedWeather);
  }
}

WeatherEntity mergeWeatherSnapshot({
  required WeatherEntity nextWeather,
  WeatherEntity? cachedWeather,
}) {
  return nextWeather.copyWith(
    pm10: nextWeather.pm10 ?? cachedWeather?.pm10,
    pm25: nextWeather.pm25 ?? cachedWeather?.pm25,
    o3: nextWeather.o3 ?? cachedWeather?.o3,
    khaiValue: nextWeather.khaiValue ?? cachedWeather?.khaiValue,
    khaiGrade: nextWeather.khaiGrade ?? cachedWeather?.khaiGrade,
    hourlyForecasts: nextWeather.hourlyForecasts.isEmpty
        ? (cachedWeather?.hourlyForecasts ?? nextWeather.hourlyForecasts)
        : nextWeather.hourlyForecasts,
    dailyForecasts: nextWeather.dailyForecasts.isEmpty
        ? (cachedWeather?.dailyForecasts ?? nextWeather.dailyForecasts)
        : nextWeather.dailyForecasts,
  );
}

bool shouldPersistWeatherSnapshot({
  required WeatherEntity nextWeather,
  WeatherEntity? cachedWeather,
}) {
  final hasFreshForecasts =
      nextWeather.hourlyForecasts.isNotEmpty &&
      nextWeather.dailyForecasts.isNotEmpty;
  final hasFreshAirQuality =
      nextWeather.pm10 != null ||
      nextWeather.pm25 != null ||
      nextWeather.o3 != null ||
      nextWeather.khaiValue != null ||
      nextWeather.khaiGrade != null;
  final hasNoCachedSnapshot = cachedWeather == null;
  return hasFreshForecasts || hasFreshAirQuality || hasNoCachedSnapshot;
}
