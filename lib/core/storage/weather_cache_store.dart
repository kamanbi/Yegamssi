import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/weather/domain/entities/weather_entity.dart';
import '../refresh/refresh_policy.dart';
import 'weather_snapshot_cache_codec.dart';

class WeatherCacheStore {
  WeatherCacheStore._();

  static const _cacheKey = 'last_known_good_weather';

  static Future<void> save(WeatherEntity weather) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(WeatherSnapshotCacheCodec.toJson(weather)),
    );
  }

  static const cacheTtl = RefreshPolicy.cacheDisplayTtl;

  static Future<WeatherEntity?> load({bool allowStale = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached == null || cached.isEmpty) return null;

    try {
      final weather = WeatherSnapshotCacheCodec.fromJson(
        jsonDecode(cached) as Map<String, dynamic>,
      );
      // observedAt 기준 1시간 초과 시 만료 → 신선한 API 데이터 강제 조회
      if (!allowStale && !isFresh(weather)) {
        return null;
      }
      return weather;
    } catch (_) {
      return null;
    }
  }

  static bool isFresh(WeatherEntity weather) {
    return RefreshPolicy.isDisplayCacheFresh(weather);
  }

  static WeatherCondition? parseNullableCondition(String? raw) {
    return WeatherSnapshotCacheCodec.parseNullableCondition(raw);
  }
}
