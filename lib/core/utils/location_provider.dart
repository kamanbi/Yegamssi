import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/location_cache_store.dart';

part 'location_provider.g.dart';

/// 서울 시청 기본 좌표 — 위치 권한 거부 시 fallback
const _defaultLat = 37.5665;
const _defaultLon = 126.9780;

/// 현재 GPS 위치를 반환하는 provider.
/// 권한이 없거나 서비스가 꺼져 있으면 서울 좌표를 반환.
@Riverpod(keepAlive: true)
Future<({double lat, double lon})> currentPosition(Ref ref) async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return await _loadCachedOrDefault();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return await _loadCachedOrDefault();
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      ),
    );
    await LocationCacheStore.save(
      latitude: pos.latitude,
      longitude: pos.longitude,
    );
    return (lat: pos.latitude, lon: pos.longitude);
  } catch (_) {
    return await _loadCachedOrDefault();
  }
}

Future<({double lat, double lon})> _loadCachedOrDefault() async {
  final cached = await LocationCacheStore.load();
  return cached ?? (lat: _defaultLat, lon: _defaultLon);
}
