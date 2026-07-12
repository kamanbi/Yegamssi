// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themePreferenceNotifierHash() =>
    r'20f0b6d018a4086c6f8b19fdd85f5b26fba89662';

/// See also [ThemePreferenceNotifier].
@ProviderFor(ThemePreferenceNotifier)
final themePreferenceNotifierProvider =
    NotifierProvider<ThemePreferenceNotifier, AppThemePreference>.internal(
      ThemePreferenceNotifier.new,
      name: r'themePreferenceNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themePreferenceNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemePreferenceNotifier = Notifier<AppThemePreference>;
String _$themeNotifierHash() => r'3201138bfcaa8d149b28d75dba23bab9b2813d9b';

/// See also [ThemeNotifier].
@ProviderFor(ThemeNotifier)
final themeNotifierProvider =
    AutoDisposeNotifierProvider<ThemeNotifier, ThemeMode>.internal(
      ThemeNotifier.new,
      name: r'themeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemeNotifier = AutoDisposeNotifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
