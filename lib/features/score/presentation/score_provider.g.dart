// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentScoreHash() => r'e5bee5ea5ea9b100f8c2483dc5c21016d29fe61c';

/// 현재 날씨 기반 활동 점수 provider.
/// 국가 코드에 따라 가중치 계산기를 자동 선택.
///
/// Copied from [currentScore].
@ProviderFor(currentScore)
final currentScoreProvider = FutureProvider<ActivityScore>.internal(
  currentScore,
  name: r'currentScoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentScoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentScoreRef = FutureProviderRef<ActivityScore>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
