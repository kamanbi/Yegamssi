import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/locale/country_code.dart';
import '../../../core/locale/country_resolver.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/refresh/refresh_policy.dart';
import '../../../core/storage/weather_cache_store.dart';
import '../../../core/utils/geocoding_service.dart';
import '../../../core/utils/location_provider.dart';
import '../data/repositories/weather_repository_impl.dart';
import '../data/sources/fallback_weather_data_source.dart';
import '../data/sources/kma_data_source.dart';
import '../data/sources/noaa_data_source.dart';
import '../data/sources/openweather_data_source.dart';
import '../domain/entities/weather_entity.dart';
import '../domain/repositories/weather_repository.dart';

part 'weather_provider.g.dart';

DateTime? _lastPassiveWeatherRefreshAt;

/// 포그라운드 복귀 시 15분 쓰로틀 초기화 — HomeScreen에서 호출
void resetPassiveWeatherThrottle() {
  _lastPassiveWeatherRefreshAt = null;
}

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
  final language = ref.watch(appLanguageNotifierProvider);
  final timer = Timer(RefreshPolicy.weatherRefreshInterval, () {
    ref.invalidate(currentPositionProvider);
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  final position = await ref.watch(currentPositionProvider.future);
  final country = await ref.watch(resolvedCountryProvider.future);
  final cachedWeather = await WeatherCacheStore.load(allowStale: true);
  if (cachedWeather != null && hasUsableForecastSnapshot(cachedWeather)) {
    final localizedWeather = await _withLocalizedLocationName(
      cachedWeather,
      lat: position.lat,
      lon: position.lon,
      language: language,
      country: country,
    );
    debugPrint(
      '[Weather] cache hit fresh=${WeatherCacheStore.isFresh(cachedWeather)}'
      ' condition=${localizedWeather.condition.name}'
      ' temp=${localizedWeather.tempCelsius.round()}'
      ' feelsLike=${localizedWeather.feelsLikeCelsius.round()}',
    );
    if (RefreshPolicy.isWeatherRefreshDue(cachedWeather)) {
      _refreshWeatherInBackground(ref, localizedWeather);
    }
    return localizedWeather;
  }

  final repo = await ref.watch(weatherRepositoryProvider.future);
  final result = await repo.getCurrentWeather(
    lat: position.lat,
    lon: position.lon,
  );
  if (result.error != null) {
    debugPrint('[Weather] fetch error: ${result.error}');
    throw result.error!;
  }

  final weather = await _withLocalizedLocationName(
    result.data!,
    lat: position.lat,
    lon: position.lon,
    language: language,
    country: country,
  );
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
      now.difference(lastRefreshAt) < RefreshPolicy.weatherRefreshInterval) {
    return;
  }

  _lastPassiveWeatherRefreshAt = now;
  unawaited(() async {
    try {
      final position = await ref.read(currentPositionProvider.future);
      final language = ref.read(appLanguageNotifierProvider);
      final country = await ref.read(resolvedCountryProvider.future);
      final repo = await ref.read(weatherRepositoryProvider.future);
      final result = await repo.getCurrentWeather(
        lat: position.lat,
        lon: position.lon,
      );
      if (result.error != null || result.data == null) {
        return;
      }

      final mergedWeather = mergeWeatherSnapshot(
        nextWeather: result.data!,
        cachedWeather: cachedWeather,
      );
      final weather = await _withLocalizedLocationName(
        mergedWeather,
        lat: position.lat,
        lon: position.lon,
        language: language,
        country: country,
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
    final cachedWeather = await WeatherCacheStore.load(allowStale: true);
    if (cachedWeather != null && hasUsableForecastSnapshot(cachedWeather)) {
      state = AsyncValue.data(cachedWeather);
    } else {
      state = const AsyncValue.loading();
    }
    final repo = await ref.read(weatherRepositoryProvider.future);
    final result = await repo.getCurrentWeather(lat: lat, lon: lon);
    if (result.error != null) {
      if (cachedWeather != null && hasUsableForecastSnapshot(cachedWeather)) {
        state = AsyncValue.data(cachedWeather);
        return;
      }
      state = AsyncValue.error(result.error!, StackTrace.current);
      return;
    }

    final country = await ref.read(resolvedCountryProvider.future);
    final mergedWeather = mergeWeatherSnapshot(
      nextWeather: result.data!,
      cachedWeather: cachedWeather,
    );
    final localizedWeather = await _withLocalizedLocationName(
      mergedWeather,
      lat: lat,
      lon: lon,
      language: ref.read(appLanguageNotifierProvider),
      country: country,
    );
    if (shouldPersistWeatherSnapshot(
      nextWeather: localizedWeather,
      cachedWeather: cachedWeather,
    )) {
      await WeatherCacheStore.save(localizedWeather);
    }
    state = AsyncValue.data(localizedWeather);
  }
}

Future<WeatherEntity> localizedWeatherLocation(
  Ref ref,
  WeatherEntity weather, {
  required double lat,
  required double lon,
}) async {
  final country = await ref.read(resolvedCountryProvider.future);
  return _withLocalizedLocationName(
    weather,
    lat: lat,
    lon: lon,
    language: ref.read(appLanguageNotifierProvider),
    country: country,
  );
}

Future<WeatherEntity> _withLocalizedLocationName(
  WeatherEntity weather, {
  required double lat,
  required double lon,
  required AppLanguage language,
  required CountryCode country,
}) async {
  final locationName = await GeocodingService.reverseGeocode(
    lat,
    lon,
    language: language,
    fallbackCountry: country,
  );
  return weather.copyWith(locationName: locationName);
}

WeatherEntity mergeWeatherSnapshot({
  required WeatherEntity nextWeather,
  WeatherEntity? cachedWeather,
}) {
  final now = DateTime.now();
  final nextHourlyForecasts = _upcomingHourlyForecasts(
    nextWeather.hourlyForecasts,
    now,
  );
  final cachedHourlyForecasts = _upcomingHourlyForecasts(
    cachedWeather?.hourlyForecasts ?? const <HourlyForecast>[],
    now,
  );
  final nextDailyForecasts = _upcomingDailyForecasts(
    nextWeather.dailyForecasts,
    now,
  );
  final cachedDailyForecasts = _upcomingDailyForecasts(
    cachedWeather?.dailyForecasts ?? const <DailyForecast>[],
    now,
  );

  return nextWeather.copyWith(
    pm10: nextWeather.pm10 ?? cachedWeather?.pm10,
    pm25: nextWeather.pm25 ?? cachedWeather?.pm25,
    o3: nextWeather.o3 ?? cachedWeather?.o3,
    khaiValue: nextWeather.khaiValue ?? cachedWeather?.khaiValue,
    khaiGrade: nextWeather.khaiGrade ?? cachedWeather?.khaiGrade,
    hourlyForecasts: nextHourlyForecasts.isNotEmpty
        ? nextHourlyForecasts
        : cachedHourlyForecasts,
    dailyForecasts: nextDailyForecasts.isNotEmpty
        ? nextDailyForecasts
        : cachedDailyForecasts,
  );
}

bool hasUsableForecastSnapshot(WeatherEntity weather) {
  final now = DateTime.now();
  return _upcomingHourlyForecasts(weather.hourlyForecasts, now).isNotEmpty &&
      _upcomingDailyForecasts(weather.dailyForecasts, now).isNotEmpty;
}

List<HourlyForecast> _upcomingHourlyForecasts(
  List<HourlyForecast> forecasts,
  DateTime now,
) {
  final cutoff = now.subtract(RefreshPolicy.forecastCutoffGrace);
  return forecasts.where((forecast) => !forecast.time.isBefore(cutoff)).toList()
    ..sort((left, right) => left.time.compareTo(right.time));
}

List<DailyForecast> _upcomingDailyForecasts(
  List<DailyForecast> forecasts,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  return forecasts.where((forecast) => !forecast.date.isBefore(today)).toList()
    ..sort((left, right) => left.date.compareTo(right.date));
}

bool shouldPersistWeatherSnapshot({
  required WeatherEntity nextWeather,
  WeatherEntity? cachedWeather,
}) {
  final hasFreshForecasts = hasUsableForecastSnapshot(nextWeather);
  final hasFreshAirQuality =
      nextWeather.pm10 != null ||
      nextWeather.pm25 != null ||
      nextWeather.o3 != null ||
      nextWeather.khaiValue != null ||
      nextWeather.khaiGrade != null;
  final hasNewObservation =
      cachedWeather == null ||
      nextWeather.observedAt.isAfter(cachedWeather.observedAt);
  return hasFreshForecasts || hasFreshAirQuality || hasNewObservation;
}
