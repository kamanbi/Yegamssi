// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentPositionHash() => r'c29b4876f06c4b33f66098bc744859a56580b33c';

/// 현재 위치를 반환하는 provider.
/// 권한이 없거나 서비스가 꺼져 있으면 서울 좌표를 반환.
///
/// Copied from [currentPosition].
@ProviderFor(currentPosition)
final currentPositionProvider =
    FutureProvider<({double lat, double lon})>.internal(
      currentPosition,
      name: r'currentPositionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentPositionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentPositionRef = FutureProviderRef<({double lat, double lon})>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
