import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/country_cache_store.dart';
import '../utils/location_provider.dart';
import 'country_code.dart';

part 'country_resolver.g.dart';

/// GPS 위치 → CountryCode 결정
/// reverse geocoding 실패(타임아웃/네트워크 오류) 시 직전에 정상 판별된
/// 국가를 유지하고, 캐시도 없는 최초 실행에 한해 한국(kr) 기본값을 사용한다.
@Riverpod(keepAlive: true)
Future<CountryCode> resolvedCountry(Ref ref) async {
  try {
    final position = await ref.watch(currentPositionProvider.future);

    final placemarks = await placemarkFromCoordinates(
      position.lat,
      position.lon,
    ).timeout(const Duration(seconds: 5));

    if (placemarks.isEmpty) return await _loadCachedOrDefault();

    final isoCode = placemarks.first.isoCountryCode ?? '';
    final country = _isoToCountryCode(isoCode);
    await CountryCacheStore.save(country);
    return country;
  } catch (_) {
    return await _loadCachedOrDefault();
  }
}

Future<CountryCode> _loadCachedOrDefault() async {
  final cached = await CountryCacheStore.load();
  return cached ?? CountryCode.kr;
}

CountryCode _isoToCountryCode(String isoCode) {
  return switch (isoCode.toUpperCase()) {
    'KR' => CountryCode.kr,
    'US' => CountryCode.us,
    'JP' => CountryCode.jp,
    'CN' => CountryCode.cn,
    _ => CountryCode.global,
  };
}
