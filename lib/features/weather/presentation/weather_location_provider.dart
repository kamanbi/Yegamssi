import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/weather_cache_store.dart';
import '../../../core/storage/favorite_location_store.dart';
import '../domain/entities/saved_location.dart';
import '../domain/entities/weather_entity.dart';
import 'weather_provider.dart';

part 'weather_location_provider.g.dart';

// ─── 선택 지역 상태 ───────────────────────────────────────────
// null = 현재 위치
typedef LocationState = ({SavedLocation? location, int? countdown});

@riverpod
class WeatherLocationNotifier extends _$WeatherLocationNotifier {
  Timer? _timer;
  static const _countdownSeconds = 20;

  @override
  LocationState build() {
    ref.onDispose(() => _timer?.cancel());
    return (location: null, countdown: null);
  }

  void select(SavedLocation location) {
    _timer?.cancel();
    state = (location: location, countdown: _countdownSeconds);
    _startCountdown();
  }

  void reset() {
    _timer?.cancel();
    state = (location: null, countdown: null);
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.countdown;
      if (remaining == null || remaining <= 1) {
        _timer?.cancel();
        state = (location: null, countdown: null);
      } else {
        state = (location: state.location, countdown: remaining - 1);
      }
    });
  }
}

// ─── 즐겨찾기 목록 ───────────────────────────────────────────
@riverpod
class FavoriteLocations extends _$FavoriteLocations {
  @override
  Future<List<SavedLocation>> build() async {
    return FavoriteLocationStore.load();
  }

  Future<bool> add(SavedLocation location) async {
    final success = await FavoriteLocationStore.add(location);
    if (success) ref.invalidateSelf();
    return success;
  }

  Future<void> remove(SavedLocation location) async {
    await FavoriteLocationStore.remove(location);
    ref.invalidateSelf();
  }
}

// ─── 선택 지역 날씨 조회 ─────────────────────────────────────
@riverpod
Stream<WeatherEntity> selectedLocationWeather(
  Ref ref,
  SavedLocation location,
) async* {
  final cachedWeather = await WeatherCacheStore.load();
  if (cachedWeather != null) {
    yield cachedWeather;
  }

  final repo = ref.watch(weatherRepositoryProvider);
  final result = await repo.getCurrentWeather(
    lat: location.lat,
    lon: location.lon,
  );
  if (result.error != null) {
    if (cachedWeather != null) {
      return;
    }
    throw result.error!;
  }

  final weather = result.data!;
  final mergedWeather = weather.copyWith(
    hourlyForecasts: weather.hourlyForecasts.isEmpty
        ? (cachedWeather?.hourlyForecasts ?? weather.hourlyForecasts)
        : weather.hourlyForecasts,
    dailyForecasts: weather.dailyForecasts.isEmpty
        ? (cachedWeather?.dailyForecasts ?? weather.dailyForecasts)
        : weather.dailyForecasts,
  );
  if (shouldPersistWeatherSnapshot(
    nextWeather: mergedWeather,
    cachedWeather: cachedWeather,
  )) {
    await WeatherCacheStore.save(mergedWeather);
  }
  yield mergedWeather;
}

// ─── 지역명 검색 (geocoding) ─────────────────────────────────
@riverpod
Future<List<SavedLocation>> searchLocation(Ref ref, String query) async {
  if (query.trim().isEmpty) return [];
  try {
    final geoLocations = await geo.locationFromAddress(query);
    return geoLocations
        .map((l) => SavedLocation(
              name: query.trim(),
              lat: l.latitude,
              lon: l.longitude,
            ))
        .take(3)
        .toList();
  } catch (_) {
    return [];
  }
}
