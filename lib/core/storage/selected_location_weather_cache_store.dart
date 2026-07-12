import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/weather/domain/entities/saved_location.dart';
import '../../features/weather/domain/entities/weather_entity.dart';
import '../refresh/refresh_policy.dart';
import 'weather_snapshot_cache_codec.dart';

class SelectedLocationWeatherCacheStore {
  SelectedLocationWeatherCacheStore._();

  static const _cacheKeyPrefix = 'selected_location_weather_';

  static Future<void> save({
    required SavedLocation location,
    required WeatherEntity weather,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey(location),
      jsonEncode(WeatherSnapshotCacheCodec.toJson(weather)),
    );
  }

  static Future<WeatherEntity?> load(SavedLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey(location));
    if (cached == null || cached.isEmpty) return null;

    try {
      final weather = WeatherSnapshotCacheCodec.fromJson(
        jsonDecode(cached) as Map<String, dynamic>,
      );
      if (!RefreshPolicy.isDisplayCacheFresh(weather)) {
        return null;
      }
      return weather;
    } catch (_) {
      return null;
    }
  }

  static String _cacheKey(SavedLocation location) {
    final latKey = (location.lat * 10000).round();
    final lonKey = (location.lon * 10000).round();
    return '$_cacheKeyPrefix${latKey}_$lonKey';
  }
}
