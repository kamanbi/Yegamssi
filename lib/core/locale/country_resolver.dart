import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/location_provider.dart';
import 'country_code.dart';

part 'country_resolver.g.dart';

/// GPS 위치 → CountryCode 결정
/// 위치 권한 없을 시 한국(kr) 기본값
@Riverpod(keepAlive: true)
Future<CountryCode> resolvedCountry(Ref ref) async {
  try {
    final position = await ref.watch(currentPositionProvider.future);

    final placemarks = await placemarkFromCoordinates(
      position.lat,
      position.lon,
    );

    if (placemarks.isEmpty) return CountryCode.kr;

    final isoCode = placemarks.first.isoCountryCode ?? '';
    return _isoToCountryCode(isoCode);
  } catch (_) {
    return CountryCode.kr;
  }
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
