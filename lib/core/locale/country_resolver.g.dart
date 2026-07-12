// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$resolvedCountryHash() => r'f9e0b757dc5aa845b02a605eb2a55bfcf5da7d51';

/// GPS 위치 → CountryCode 결정
/// reverse geocoding 실패(타임아웃/네트워크 오류) 시 직전에 정상 판별된
/// 국가를 유지하고, 캐시도 없는 최초 실행에 한해 한국(kr) 기본값을 사용한다.
///
/// Copied from [resolvedCountry].
@ProviderFor(resolvedCountry)
final resolvedCountryProvider = FutureProvider<CountryCode>.internal(
  resolvedCountry,
  name: r'resolvedCountryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$resolvedCountryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ResolvedCountryRef = FutureProviderRef<CountryCode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
