import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:yegamssi/core/purchase/purchase_config.dart';
import 'package:yegamssi/core/purchase/purchase_update_policy.dart';

void main() {
  group('evaluatePurchaseUpdate', () {
    test('activates, completes, and reports a successful purchase', () {
      final decision = _evaluate(
        status: PurchaseStatus.purchased,
        requiresCompletion: true,
      );

      expect(decision.activatePremium, isTrue);
      expect(decision.completePurchase, isTrue);
      expect(decision.feedback, PurchaseUpdateFeedback.success);
    });

    test('restores entitlement without a new-purchase message', () {
      final decision = _evaluate(
        status: PurchaseStatus.restored,
        requiresCompletion: true,
      );

      expect(decision.activatePremium, isTrue);
      expect(decision.completePurchase, isTrue);
      expect(decision.feedback, isNull);
    });

    test(
      'recovers an already-owned entitlement without completing an error',
      () {
        final decision = _evaluate(
          status: PurchaseStatus.error,
          isAlreadyOwned: true,
          requiresCompletion: true,
        );

        expect(decision.activatePremium, isTrue);
        expect(decision.completePurchase, isFalse);
        expect(decision.feedback, isNull);
      },
    );

    test('reports ordinary purchase errors', () {
      final decision = _evaluate(status: PurchaseStatus.error);

      expect(decision.activatePremium, isFalse);
      expect(decision.completePurchase, isFalse);
      expect(decision.feedback, PurchaseUpdateFeedback.error);
    });

    test('reports cancellation without completing the purchase', () {
      final decision = _evaluate(
        status: PurchaseStatus.canceled,
        requiresCompletion: true,
      );

      expect(decision.activatePremium, isFalse);
      expect(decision.completePurchase, isFalse);
      expect(decision.feedback, PurchaseUpdateFeedback.canceled);
    });

    test('leaves pending purchases untouched', () {
      final decision = _evaluate(
        status: PurchaseStatus.pending,
        requiresCompletion: true,
      );

      expect(decision.activatePremium, isFalse);
      expect(decision.completePurchase, isFalse);
      expect(decision.feedback, isNull);
    });

    test('ignores products owned by another feature', () {
      final decision = evaluatePurchaseUpdate(
        update: const PurchaseUpdateContext(
          productId: 'another_product',
          status: PurchaseStatus.purchased,
          isAlreadyOwned: false,
          requiresCompletion: true,
        ),
        premiumProductId: PurchaseConfig.removeAdsProductId,
      );

      expect(decision.activatePremium, isFalse);
      expect(decision.completePurchase, isFalse);
      expect(decision.feedback, isNull);
    });
  });
}

PurchaseUpdateDecision _evaluate({
  required PurchaseStatus status,
  bool isAlreadyOwned = false,
  bool requiresCompletion = false,
}) {
  return evaluatePurchaseUpdate(
    update: PurchaseUpdateContext(
      productId: PurchaseConfig.removeAdsProductId,
      status: status,
      isAlreadyOwned: isAlreadyOwned,
      requiresCompletion: requiresCompletion,
    ),
    premiumProductId: PurchaseConfig.removeAdsProductId,
  );
}
