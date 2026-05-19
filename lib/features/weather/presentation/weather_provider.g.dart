// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weatherRepositoryHash() => r'068e17057179d3ec8aa4167c8709f7b0b336ca50';

/// See also [weatherRepository].
@ProviderFor(weatherRepository)
final weatherRepositoryProvider = Provider<WeatherRepository>.internal(
  weatherRepository,
  name: r'weatherRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weatherRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeatherRepositoryRef = ProviderRef<WeatherRepository>;
String _$currentWeatherHash() => r'a0b48a2c8025c095bd75cd3f8636c4f14cce3a44';

/// 위치 기반 현재 날씨 자동 조회 provider.
/// currentPositionProvider가 바뀌면 자동으로 재조회.
/// 1시간 경과 시 위치·날씨를 함께 재조회한다.
///
/// Copied from [currentWeather].
@ProviderFor(currentWeather)
final currentWeatherProvider = FutureProvider<WeatherEntity>.internal(
  currentWeather,
  name: r'currentWeatherProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentWeatherHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentWeatherRef = FutureProviderRef<WeatherEntity>;
String _$weatherNotifierHash() => r'49904956831e63c12102aa88d798117a5b7974a5';

/// See also [WeatherNotifier].
@ProviderFor(WeatherNotifier)
final weatherNotifierProvider =
    AutoDisposeNotifierProvider<
      WeatherNotifier,
      AsyncValue<WeatherEntity>
    >.internal(
      WeatherNotifier.new,
      name: r'weatherNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weatherNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WeatherNotifier = AutoDisposeNotifier<AsyncValue<WeatherEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
