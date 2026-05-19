// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_update_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inAppUpdateManagerHash() =>
    r'0911ddf234bcffa5e38a491e750a48788112f2cb';

/// See also [inAppUpdateManager].
@ProviderFor(inAppUpdateManager)
final inAppUpdateManagerProvider =
    AutoDisposeProvider<InAppUpdateManager>.internal(
      inAppUpdateManager,
      name: r'inAppUpdateManagerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inAppUpdateManagerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InAppUpdateManagerRef = AutoDisposeProviderRef<InAppUpdateManager>;
String _$checkForAppUpdateHash() => r'952c3da85acad1cc3de479c46baedf67ea1fc2c7';

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

/// 앱 시작 시 업데이트 확인
///
/// Copied from [checkForAppUpdate].
@ProviderFor(checkForAppUpdate)
const checkForAppUpdateProvider = CheckForAppUpdateFamily();

/// 앱 시작 시 업데이트 확인
///
/// Copied from [checkForAppUpdate].
class CheckForAppUpdateFamily extends Family<AsyncValue<void>> {
  /// 앱 시작 시 업데이트 확인
  ///
  /// Copied from [checkForAppUpdate].
  const CheckForAppUpdateFamily();

  /// 앱 시작 시 업데이트 확인
  ///
  /// Copied from [checkForAppUpdate].
  CheckForAppUpdateProvider call(BuildContext context) {
    return CheckForAppUpdateProvider(context);
  }

  @override
  CheckForAppUpdateProvider getProviderOverride(
    covariant CheckForAppUpdateProvider provider,
  ) {
    return call(provider.context);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'checkForAppUpdateProvider';
}

/// 앱 시작 시 업데이트 확인
///
/// Copied from [checkForAppUpdate].
class CheckForAppUpdateProvider extends AutoDisposeFutureProvider<void> {
  /// 앱 시작 시 업데이트 확인
  ///
  /// Copied from [checkForAppUpdate].
  CheckForAppUpdateProvider(BuildContext context)
    : this._internal(
        (ref) => checkForAppUpdate(ref as CheckForAppUpdateRef, context),
        from: checkForAppUpdateProvider,
        name: r'checkForAppUpdateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$checkForAppUpdateHash,
        dependencies: CheckForAppUpdateFamily._dependencies,
        allTransitiveDependencies:
            CheckForAppUpdateFamily._allTransitiveDependencies,
        context: context,
      );

  CheckForAppUpdateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.context,
  }) : super.internal();

  final BuildContext context;

  @override
  Override overrideWith(
    FutureOr<void> Function(CheckForAppUpdateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CheckForAppUpdateProvider._internal(
        (ref) => create(ref as CheckForAppUpdateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        context: context,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _CheckForAppUpdateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CheckForAppUpdateProvider && other.context == context;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, context.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CheckForAppUpdateRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `context` of this provider.
  BuildContext get context;
}

class _CheckForAppUpdateProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with CheckForAppUpdateRef {
  _CheckForAppUpdateProviderElement(super.provider);

  @override
  BuildContext get context => (origin as CheckForAppUpdateProvider).context;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
