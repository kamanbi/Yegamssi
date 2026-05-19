// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedLocationWeatherHash() =>
    r'6d1bbe596632a4e4b740dbfeb64ccbe0c1d57184';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [selectedLocationWeather].
@ProviderFor(selectedLocationWeather)
const selectedLocationWeatherProvider = SelectedLocationWeatherFamily();

/// See also [selectedLocationWeather].
class SelectedLocationWeatherFamily extends Family<AsyncValue<WeatherEntity>> {
  /// See also [selectedLocationWeather].
  const SelectedLocationWeatherFamily();

  /// See also [selectedLocationWeather].
  SelectedLocationWeatherProvider call(SavedLocation location) {
    return SelectedLocationWeatherProvider(location);
  }

  @override
  SelectedLocationWeatherProvider getProviderOverride(
    covariant SelectedLocationWeatherProvider provider,
  ) {
    return call(provider.location);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'selectedLocationWeatherProvider';
}

/// See also [selectedLocationWeather].
class SelectedLocationWeatherProvider
    extends AutoDisposeStreamProvider<WeatherEntity> {
  /// See also [selectedLocationWeather].
  SelectedLocationWeatherProvider(SavedLocation location)
    : this._internal(
        (ref) => selectedLocationWeather(
          ref as SelectedLocationWeatherRef,
          location,
        ),
        from: selectedLocationWeatherProvider,
        name: r'selectedLocationWeatherProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$selectedLocationWeatherHash,
        dependencies: SelectedLocationWeatherFamily._dependencies,
        allTransitiveDependencies:
            SelectedLocationWeatherFamily._allTransitiveDependencies,
        location: location,
      );

  SelectedLocationWeatherProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.location,
  }) : super.internal();

  final SavedLocation location;

  @override
  Override overrideWith(
    Stream<WeatherEntity> Function(SelectedLocationWeatherRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SelectedLocationWeatherProvider._internal(
        (ref) => create(ref as SelectedLocationWeatherRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        location: location,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<WeatherEntity> createElement() {
    return _SelectedLocationWeatherProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedLocationWeatherProvider &&
        other.location == location;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, location.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SelectedLocationWeatherRef
    on AutoDisposeStreamProviderRef<WeatherEntity> {
  /// The parameter `location` of this provider.
  SavedLocation get location;
}

class _SelectedLocationWeatherProviderElement
    extends AutoDisposeStreamProviderElement<WeatherEntity>
    with SelectedLocationWeatherRef {
  _SelectedLocationWeatherProviderElement(super.provider);

  @override
  SavedLocation get location =>
      (origin as SelectedLocationWeatherProvider).location;
}

String _$searchLocationHash() => r'd8da7f23e649716a6914d3721409069034e9d1e1';

/// See also [searchLocation].
@ProviderFor(searchLocation)
const searchLocationProvider = SearchLocationFamily();

/// See also [searchLocation].
class SearchLocationFamily extends Family<AsyncValue<List<SavedLocation>>> {
  /// See also [searchLocation].
  const SearchLocationFamily();

  /// See also [searchLocation].
  SearchLocationProvider call(String query) {
    return SearchLocationProvider(query);
  }

  @override
  SearchLocationProvider getProviderOverride(
    covariant SearchLocationProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchLocationProvider';
}

/// See also [searchLocation].
class SearchLocationProvider
    extends AutoDisposeFutureProvider<List<SavedLocation>> {
  /// See also [searchLocation].
  SearchLocationProvider(String query)
    : this._internal(
        (ref) => searchLocation(ref as SearchLocationRef, query),
        from: searchLocationProvider,
        name: r'searchLocationProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchLocationHash,
        dependencies: SearchLocationFamily._dependencies,
        allTransitiveDependencies:
            SearchLocationFamily._allTransitiveDependencies,
        query: query,
      );

  SearchLocationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<SavedLocation>> Function(SearchLocationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchLocationProvider._internal(
        (ref) => create(ref as SearchLocationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SavedLocation>> createElement() {
    return _SearchLocationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchLocationProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchLocationRef on AutoDisposeFutureProviderRef<List<SavedLocation>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchLocationProviderElement
    extends AutoDisposeFutureProviderElement<List<SavedLocation>>
    with SearchLocationRef {
  _SearchLocationProviderElement(super.provider);

  @override
  String get query => (origin as SearchLocationProvider).query;
}

String _$weatherLocationNotifierHash() =>
    r'd16665f50f185bde76efb03086e4e075b96b122f';

/// See also [WeatherLocationNotifier].
@ProviderFor(WeatherLocationNotifier)
final weatherLocationNotifierProvider =
    AutoDisposeNotifierProvider<
      WeatherLocationNotifier,
      LocationState
    >.internal(
      WeatherLocationNotifier.new,
      name: r'weatherLocationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weatherLocationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WeatherLocationNotifier = AutoDisposeNotifier<LocationState>;
String _$favoriteLocationsHash() => r'f9d99c2f462d2a96bd9a95e5ccb4b6d9498dcd95';

/// See also [FavoriteLocations].
@ProviderFor(FavoriteLocations)
final favoriteLocationsProvider =
    AutoDisposeAsyncNotifierProvider<
      FavoriteLocations,
      List<SavedLocation>
    >.internal(
      FavoriteLocations.new,
      name: r'favoriteLocationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoriteLocationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FavoriteLocations = AutoDisposeAsyncNotifier<List<SavedLocation>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
