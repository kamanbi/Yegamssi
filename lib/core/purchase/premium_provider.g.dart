// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$removeAdsProductDetailsHash() =>
    r'61d3d10d4393ef4f1eae0c5035214a9263592eb4';

/// 광고 제거 상품의 가격/이름 정보. 조회 실패 시 null.
///
/// Copied from [removeAdsProductDetails].
@ProviderFor(removeAdsProductDetails)
final removeAdsProductDetailsProvider =
    AutoDisposeFutureProvider<ProductDetails?>.internal(
      removeAdsProductDetails,
      name: r'removeAdsProductDetailsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$removeAdsProductDetailsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RemoveAdsProductDetailsRef =
    AutoDisposeFutureProviderRef<ProductDetails?>;
String _$premiumNotifierHash() => r'51c66aaa44de52eac01887639434bf8a2869819f';

/// 광고 제거(remove_ads) 구매 여부.
/// - 캐시된 구매 이력이 있으면 즉시 true 반환 (스토어 호출 생략)
/// - 캐시가 없으면 purchaseStream 구독 후 1회 restorePurchases() 시도
///
/// Copied from [PremiumNotifier].
@ProviderFor(PremiumNotifier)
final premiumNotifierProvider =
    NotifierProvider<PremiumNotifier, bool>.internal(
      PremiumNotifier.new,
      name: r'premiumNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$premiumNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PremiumNotifier = Notifier<bool>;
String _$purchaseMessageNotifierHash() =>
    r'651346f368ba6ae9fdc59d0ead03d283d92c279a';

/// 구매 진행 결과를 UI(SnackBar)에 1회성으로 전달하기 위한 상태.
///
/// Copied from [PurchaseMessageNotifier].
@ProviderFor(PurchaseMessageNotifier)
final purchaseMessageNotifierProvider =
    AutoDisposeNotifierProvider<
      PurchaseMessageNotifier,
      PurchaseMessage?
    >.internal(
      PurchaseMessageNotifier.new,
      name: r'purchaseMessageNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$purchaseMessageNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PurchaseMessageNotifier = AutoDisposeNotifier<PurchaseMessage?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
