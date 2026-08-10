import 'package:in_app_purchase/in_app_purchase.dart';

enum PurchaseUpdateFeedback { success, canceled, error }

class PurchaseUpdateContext {
  const PurchaseUpdateContext({
    required this.productId,
    required this.status,
    required this.isAlreadyOwned,
    required this.requiresCompletion,
  });

  final String productId;
  final PurchaseStatus status;
  final bool isAlreadyOwned;
  final bool requiresCompletion;
}

class PurchaseUpdateDecision {
  const PurchaseUpdateDecision({
    this.activatePremium = false,
    this.completePurchase = false,
    this.feedback,
  });

  final bool activatePremium;
  final bool completePurchase;
  final PurchaseUpdateFeedback? feedback;
}

PurchaseUpdateDecision evaluatePurchaseUpdate({
  required PurchaseUpdateContext update,
  required String premiumProductId,
}) {
  if (update.productId != premiumProductId) {
    return const PurchaseUpdateDecision();
  }

  return switch (update.status) {
    PurchaseStatus.purchased => PurchaseUpdateDecision(
      activatePremium: true,
      completePurchase: update.requiresCompletion,
      feedback: PurchaseUpdateFeedback.success,
    ),
    PurchaseStatus.restored => PurchaseUpdateDecision(
      activatePremium: true,
      completePurchase: update.requiresCompletion,
    ),
    PurchaseStatus.error when update.isAlreadyOwned =>
      const PurchaseUpdateDecision(activatePremium: true),
    PurchaseStatus.error => const PurchaseUpdateDecision(
      feedback: PurchaseUpdateFeedback.error,
    ),
    PurchaseStatus.canceled => const PurchaseUpdateDecision(
      feedback: PurchaseUpdateFeedback.canceled,
    ),
    PurchaseStatus.pending => const PurchaseUpdateDecision(),
  };
}
