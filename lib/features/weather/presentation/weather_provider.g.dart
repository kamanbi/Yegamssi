// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weatherRepositoryHash() => r'63320fbd1efdf33b3ab1ff782f8375408b72f9fe';

/// See also [weatherRepository].
@ProviderFor(weatherRepository)
final weatherRepositoryProvider = FutureProvider<WeatherRepository>.internal(
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
typedef WeatherRepositoryRef = FutureProviderRef<WeatherRepository>;
String _$currentWeatherHash() => r'1ad320910a7e8ee867fc9547d2f6b7b789513252';

/// See also [currentWeather].
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
String _$weatherNotifierHash() => r'74cfcec8e68349efb9a6951c3a1eeeae34e2e6bb';

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
