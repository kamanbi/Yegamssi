import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../weather/data/sources/kma_grid_converter.dart';
import '../../weather/domain/entities/weather_entity.dart';
import '../../../core/refresh/refresh_policy.dart';
import '../../../core/storage/weather_snapshot_cache_codec.dart';
import '../domain/activity_models.dart';

typedef EvidenceLoader<T> = Future<T> Function();

class ActivityEvidenceCache {
  ActivityEvidenceCache({Future<SharedPreferences> Function()? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance;

  static const _keyPrefix = 'activity_evidence_v3_';
  static const cacheRetention = Duration(hours: 24);
  static const seaFishingTtl = Duration(hours: 6);
  static const forestFireTtl = Duration(hours: 3);
  static const midSeaForecastTtl = Duration(hours: 12);
  static const weatherWarningTtl = Duration(minutes: 10);
  static const tideTtl = Duration(hours: 12);
  static const currentTtl = Duration(minutes: 30);
  static const waveTtl = Duration(minutes: 30);
  static const waterTemperatureTtl = Duration(minutes: 30);
  static const unavailableEvidenceTtl = Duration(minutes: 10);

  final Future<SharedPreferences> Function() _preferences;
  final Map<String, Future<Object?>> _inFlight = {};
  bool _hasPruned = false;

  Future<WeatherEntity> getWeather({
    required double latitude,
    required double longitude,
    required EvidenceLoader<WeatherEntity> loader,
  }) {
    final grid = KmaGridConverter.latLonToGrid(latitude, longitude);
    final key = 'weather_${grid.nx}_${grid.ny}';
    return _singleFlight(key, () async {
      final cached = await _read<WeatherEntity>(
        key,
        WeatherSnapshotCacheCodec.fromJson,
      );
      if (cached != null &&
          !RefreshPolicy.isWeatherRefreshDue(cached.value) &&
          !_isExpired(cached.storedAt, RefreshPolicy.weatherRefreshInterval)) {
        _log('weather', 'HIT');
        return cached.value;
      }

      _log('weather', 'MISS');
      final weather = await loader();
      await _write(key, WeatherSnapshotCacheCodec.toJson(weather));
      return weather;
    });
  }

  Future<SeaFishingEvidence?> getSeaFishingEvidence({
    required DateTime requestedAt,
    required DateTime requestedUntil,
    required String fishingType,
    required String placeName,
    required String targetFish,
    required EvidenceLoader<SeaFishingEvidence?> loader,
  }) {
    final key = [
      'fishing',
      _dateKey(requestedAt),
      requestedAt.hour,
      requestedUntil.toIso8601String(),
      fishingType,
      placeName.trim(),
      targetFish.trim(),
    ].join('_');
    return _singleFlight(key, () async {
      final cached = await _readNullable<SeaFishingEvidence>(
        key,
        SeaFishingEvidence.fromJson,
      );
      if (cached != null &&
          !_isExpired(
            cached.storedAt,
            cached.hasValue ? seaFishingTtl : unavailableEvidenceTtl,
          )) {
        _log('sea_fishing', cached.hasValue ? 'HIT' : 'NEGATIVE_HIT');
        return cached.value;
      }

      _log('sea_fishing', 'MISS');
      final evidence = await loader();
      await _writeNullable(key, evidence?.toJson());
      return evidence;
    });
  }

  Future<ForestFireEvidence?> getForestFireEvidence({
    required DateTime requestedAt,
    required String regionKey,
    required EvidenceLoader<ForestFireEvidence?> loader,
  }) {
    final key = 'forest_fire_${_dateKey(requestedAt)}_${regionKey.trim()}';
    return _singleFlight(key, () async {
      final cached = await _readNullable<ForestFireEvidence>(
        key,
        ForestFireEvidence.fromJson,
      );
      if (cached != null &&
          !_isExpired(
            cached.storedAt,
            cached.hasValue ? forestFireTtl : unavailableEvidenceTtl,
          )) {
        _log('forest_fire', cached.hasValue ? 'HIT' : 'NEGATIVE_HIT');
        return cached.value;
      }

      _log('forest_fire', 'MISS');
      final evidence = await loader();
      await _writeNullable(key, evidence?.toJson());
      return evidence;
    });
  }

  Future<MidSeaForecastEvidence?> getMidSeaForecastEvidence({
    required DateTime requestedAt,
    required String seaRegionId,
    required EvidenceLoader<MidSeaForecastEvidence?> loader,
  }) {
    final key = 'mid_sea_${_dateKey(requestedAt)}_${seaRegionId.trim()}';
    return _singleFlight(key, () async {
      final cached = await _readNullable<MidSeaForecastEvidence>(
        key,
        MidSeaForecastEvidence.fromJson,
      );
      if (cached != null &&
          !_isExpired(
            cached.storedAt,
            cached.hasValue ? midSeaForecastTtl : unavailableEvidenceTtl,
          )) {
        _log('mid_sea', cached.hasValue ? 'HIT' : 'NEGATIVE_HIT');
        return cached.value;
      }
      _log('mid_sea', 'MISS');
      final evidence = await loader();
      await _writeNullable(key, evidence?.toJson());
      return evidence;
    });
  }

  Future<WeatherWarningEvidence?> getWeatherWarningEvidence({
    required EvidenceLoader<WeatherWarningEvidence?> loader,
  }) {
    const key = 'weather_warning_current';
    return _singleFlight(key, () async {
      final cached = await _readNullable<WeatherWarningEvidence>(
        key,
        WeatherWarningEvidence.fromJson,
      );
      if (cached != null &&
          !_isExpired(
            cached.storedAt,
            cached.hasValue ? weatherWarningTtl : unavailableEvidenceTtl,
          )) {
        _log('weather_warning', cached.hasValue ? 'HIT' : 'NEGATIVE_HIT');
        return cached.value;
      }

      _log('weather_warning', 'MISS');
      final evidence = await loader();
      await _writeNullable(key, evidence?.toJson());
      return evidence;
    });
  }

  Future<TideEvidence?> getTideEvidence({
    required DateTime requestedAt,
    required String stationName,
    required EvidenceLoader<TideEvidence?> loader,
  }) {
    final key = 'tide_${_dateKey(requestedAt)}_${stationName.trim()}';
    return _singleFlight(key, () async {
      final cached = await _readNullable<TideEvidence>(
        key,
        TideEvidence.fromJson,
      );
      if (cached != null &&
          !_isExpired(
            cached.storedAt,
            cached.hasValue ? tideTtl : unavailableEvidenceTtl,
          )) {
        _log('tide', cached.hasValue ? 'HIT' : 'NEGATIVE_HIT');
        return cached.value;
      }

      _log('tide', 'MISS');
      final evidence = await loader();
      await _writeNullable(key, evidence?.toJson());
      return evidence;
    });
  }

  Future<CurrentEvidence?> getCurrentEvidence({
    required DateTime requestedAt,
    required DateTime requestedUntil,
    required String stationName,
    required EvidenceLoader<CurrentEvidence?> loader,
  }) {
    final key = [
      'current',
      _dateKey(requestedAt),
      requestedAt.hour,
      requestedUntil.toIso8601String(),
      stationName.trim(),
    ].join('_');
    return _singleFlight(key, () async {
      final cached = await _readNullable<CurrentEvidence>(
        key,
        CurrentEvidence.fromJson,
      );
      if (cached != null &&
          !_isExpired(
            cached.storedAt,
            cached.hasValue ? currentTtl : unavailableEvidenceTtl,
          )) {
        _log('current', cached.hasValue ? 'HIT' : 'NEGATIVE_HIT');
        return cached.value;
      }

      _log('current', 'MISS');
      final evidence = await loader();
      await _writeNullable(key, evidence?.toJson());
      return evidence;
    });
  }

  Future<MarineTimeSeriesEvidence?> getWaveEvidence({
    required DateTime requestedAt,
    required DateTime requestedUntil,
    required String stationName,
    required EvidenceLoader<MarineTimeSeriesEvidence?> loader,
  }) {
    final key = [
      'wave',
      _dateKey(requestedAt),
      requestedAt.hour,
      requestedUntil.toIso8601String(),
      stationName.trim(),
    ].join('_');
    return _singleFlight(key, () async {
      final cached = await _readNullable<MarineTimeSeriesEvidence>(
        key,
        MarineTimeSeriesEvidence.fromJson,
      );
      if (cached != null &&
          !_isExpired(
            cached.storedAt,
            cached.hasValue ? waveTtl : unavailableEvidenceTtl,
          )) {
        _log('wave', cached.hasValue ? 'HIT' : 'NEGATIVE_HIT');
        return cached.value;
      }

      _log('wave', 'MISS');
      final evidence = await loader();
      await _writeNullable(key, evidence?.toJson());
      return evidence;
    });
  }

  Future<MarineTimeSeriesEvidence?> getWaterTemperatureEvidence({
    required DateTime requestedAt,
    required DateTime requestedUntil,
    required String stationName,
    required EvidenceLoader<MarineTimeSeriesEvidence?> loader,
  }) {
    final key = [
      'water_temp',
      _dateKey(requestedAt),
      requestedAt.hour,
      requestedUntil.toIso8601String(),
      stationName.trim(),
    ].join('_');
    return _singleFlight(key, () async {
      final cached = await _readNullable<MarineTimeSeriesEvidence>(
        key,
        MarineTimeSeriesEvidence.fromJson,
      );
      if (cached != null &&
          !_isExpired(
            cached.storedAt,
            cached.hasValue ? waterTemperatureTtl : unavailableEvidenceTtl,
          )) {
        _log('water_temp', cached.hasValue ? 'HIT' : 'NEGATIVE_HIT');
        return cached.value;
      }

      _log('water_temp', 'MISS');
      final evidence = await loader();
      await _writeNullable(key, evidence?.toJson());
      return evidence;
    });
  }

  Future<T> _singleFlight<T>(String rawKey, Future<T> Function() operation) {
    final key = _storageKey(rawKey);
    final running = _inFlight[key];
    if (running != null) {
      _log('request', 'COALESCED');
      return running.then((value) => value as T);
    }

    final future = operation();
    _inFlight[key] = future;
    return future.whenComplete(() => _inFlight.remove(key));
  }

  Future<_CacheValue<T>?> _read<T>(
    String rawKey,
    T Function(Map<String, dynamic>) decode,
  ) async {
    final nullable = await _readNullable(rawKey, decode);
    if (nullable == null || !nullable.hasValue || nullable.value == null) {
      return null;
    }
    return _CacheValue(storedAt: nullable.storedAt, value: nullable.value as T);
  }

  Future<_NullableCacheValue<T>?> _readNullable<T>(
    String rawKey,
    T Function(Map<String, dynamic>) decode,
  ) async {
    final preferences = await _preferences();
    final raw = preferences.getString(_storageKey(rawKey));
    if (raw == null || raw.isEmpty) return null;

    try {
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      final storedAt = DateTime.parse(envelope['storedAt'] as String);
      final value = envelope['value'];
      return _NullableCacheValue(
        storedAt: storedAt,
        hasValue: value != null,
        value: value == null ? null : decode(value as Map<String, dynamic>),
      );
    } catch (_) {
      await preferences.remove(_storageKey(rawKey));
      return null;
    }
  }

  Future<void> _write(String rawKey, Map<String, dynamic> value) {
    return _writeNullable(rawKey, value);
  }

  Future<void> _writeNullable(
    String rawKey,
    Map<String, dynamic>? value,
  ) async {
    final preferences = await _preferences();
    await _pruneExpiredEntriesOnce(preferences);
    await preferences.setString(
      _storageKey(rawKey),
      jsonEncode({
        'storedAt': DateTime.now().toIso8601String(),
        'value': value,
      }),
    );
  }

  Future<void> _pruneExpiredEntriesOnce(SharedPreferences preferences) async {
    if (_hasPruned) return;
    _hasPruned = true;

    final cutoff = DateTime.now().subtract(cacheRetention);
    for (final key in preferences.getKeys()) {
      if (!key.startsWith(_keyPrefix)) continue;
      final raw = preferences.getString(key);
      if (raw == null) continue;
      try {
        final envelope = jsonDecode(raw) as Map<String, dynamic>;
        final storedAt = DateTime.parse(envelope['storedAt'] as String);
        if (storedAt.isBefore(cutoff)) {
          await preferences.remove(key);
        }
      } catch (_) {
        await preferences.remove(key);
      }
    }
  }

  bool _isExpired(DateTime storedAt, Duration ttl) {
    return DateTime.now().difference(storedAt) >= ttl;
  }

  String _storageKey(String rawKey) {
    final encoded = base64Url.encode(utf8.encode(rawKey)).replaceAll('=', '');
    return '$_keyPrefix$encoded';
  }

  String _dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}$month$day';
  }

  void _log(String source, String result) {
    debugPrint('[ActivityCache] source=$source result=$result');
  }
}

class _CacheValue<T> {
  const _CacheValue({required this.storedAt, required this.value});

  final DateTime storedAt;
  final T value;
}

class _NullableCacheValue<T> {
  const _NullableCacheValue({
    required this.storedAt,
    required this.hasValue,
    required this.value,
  });

  final DateTime storedAt;
  final bool hasValue;
  final T? value;
}
