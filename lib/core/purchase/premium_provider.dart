import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/local_storage.dart';
import 'purchase_config.dart';

part 'premium_provider.g.dart';

enum PurchaseMessageType {
  success,
  canceled,
  error,
  storeUnavailable,
  productUnavailable,
}

class PurchaseMessage {
  const PurchaseMessage(this.type);

  final PurchaseMessageType type;
}

/// 광고 제거(remove_ads) 구매 여부.
/// - 캐시된 구매 이력이 있으면 즉시 true 반환 (스토어 호출 생략)
/// - 캐시가 없으면 purchaseStream 구독 후 1회 restorePurchases() 시도
@Riverpod(keepAlive: true)
class PremiumNotifier extends _$PremiumNotifier {
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  bool build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });
    _init();
    return false;
  }

  Future<void> _init() async {
    final cached =
        await LocalStorage.getBool(PurchaseConfig.premiumStorageKey) ?? false;
    if (cached) {
      state = true;
    }

    // 구매 결과 수신은 스토어 가용성과 무관하게 항상 구독해야 함.
    // (buyRemoveAds()가 나중에 별도로 isAvailable()을 확인하므로,
    //  여기서 구독을 건너뛰면 그때의 구매 결과를 영영 받지 못함)
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) => debugPrint('Purchase stream error: $error'),
    );

    if (cached) return;

    try {
      final available = await InAppPurchase.instance.isAvailable();
      if (!available) return;
      await InAppPurchase.instance.restorePurchases();
    } catch (error) {
      debugPrint('restorePurchases failed: $error');
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      var handled = false;

      if (purchase.productID == PurchaseConfig.removeAdsProductId) {
        switch (purchase.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            // completePurchase()를 먼저 호출 → 캐시 저장 전에 프로세스가 죽어도
            // 다음 실행 시 cached==false로 restorePurchases()가 재시도되어 자가 치유됨
            if (purchase.pendingCompletePurchase) {
              await InAppPurchase.instance.completePurchase(purchase);
            }
            await _activatePremium();
            if (purchase.status == PurchaseStatus.purchased) {
              ref.read(purchaseMessageNotifierProvider.notifier).set(
                const PurchaseMessage(PurchaseMessageType.success),
              );
            }
            handled = true;
          case PurchaseStatus.error:
            if (_isAlreadyOwnedError(purchase.error)) {
              await _activatePremium();
            } else {
              ref.read(purchaseMessageNotifierProvider.notifier).set(
                const PurchaseMessage(PurchaseMessageType.error),
              );
            }
          case PurchaseStatus.canceled:
            ref.read(purchaseMessageNotifierProvider.notifier).set(
              const PurchaseMessage(PurchaseMessageType.canceled),
            );
          case PurchaseStatus.pending:
            break;
        }
      }

      if (!handled && purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  /// Android Billing이 이미 소유한 상품에 대해 반환하는 에러인지 느슨하게 판별.
  /// (정상적인 결제 실패와 구분해 자동으로 프리미엄 상태를 복구하기 위함)
  bool _isAlreadyOwnedError(IAPError? error) {
    if (error == null) return false;
    final text = '${error.message} ${error.details}'.toLowerCase();
    return text.contains('already own');
  }

  Future<void> _activatePremium() async {
    state = true;
    await LocalStorage.setBool(PurchaseConfig.premiumStorageKey, true);
  }

  /// 광고 제거 구매 시작. 결과는 purchaseStream을 통해 비동기로 전달됨.
  Future<void> buyRemoveAds() async {
    if (state) return;

    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      ref.read(purchaseMessageNotifierProvider.notifier).set(
        const PurchaseMessage(PurchaseMessageType.storeUnavailable),
      );
      return;
    }

    final response = await InAppPurchase.instance.queryProductDetails({
      PurchaseConfig.removeAdsProductId,
    });
    if (response.error != null || response.productDetails.isEmpty) {
      ref.read(purchaseMessageNotifierProvider.notifier).set(
        const PurchaseMessage(PurchaseMessageType.productUnavailable),
      );
      return;
    }

    final started = await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: response.productDetails.first),
    );
    if (!started) {
      ref.read(purchaseMessageNotifierProvider.notifier).set(
        const PurchaseMessage(PurchaseMessageType.error),
      );
    }
  }
}

/// 광고 제거 상품의 가격/이름 정보. 조회 실패 시 null.
@riverpod
Future<ProductDetails?> removeAdsProductDetails(Ref ref) async {
  final available = await InAppPurchase.instance.isAvailable();
  if (!available) return null;

  final response = await InAppPurchase.instance.queryProductDetails({
    PurchaseConfig.removeAdsProductId,
  });
  if (response.error != null || response.productDetails.isEmpty) return null;
  return response.productDetails.first;
}

/// 구매 진행 결과를 UI(SnackBar)에 1회성으로 전달하기 위한 상태.
@riverpod
class PurchaseMessageNotifier extends _$PurchaseMessageNotifier {
  @override
  PurchaseMessage? build() => null;

  void set(PurchaseMessage message) => state = message;

  void clear() => state = null;
}
