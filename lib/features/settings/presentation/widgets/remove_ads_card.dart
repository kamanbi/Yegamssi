import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/purchase/premium_provider.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../l10n/app_localizations.dart';

class RemoveAdsCard extends ConsumerWidget {
  const RemoveAdsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumNotifierProvider);
    final productDetails = ref.watch(removeAdsProductDetailsProvider);
    final brightness = Theme.of(context).brightness;
    final l10n = AppLocalizations.of(context);

    ref.listen(purchaseMessageNotifierProvider, (_, message) {
      if (message == null) return;
      final text = switch (message.type) {
        PurchaseMessageType.success => l10n.premiumMsgSuccess,
        PurchaseMessageType.canceled => l10n.premiumMsgCanceled,
        PurchaseMessageType.error => l10n.premiumMsgError,
        PurchaseMessageType.storeUnavailable => l10n.premiumMsgStoreUnavailable,
        PurchaseMessageType.productUnavailable =>
          l10n.premiumMsgProductUnavailable,
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(text)));
      ref.read(purchaseMessageNotifierProvider.notifier).clear();
    });

    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withAlpha(24),
            ),
            child: Icon(
              isPremium ? Icons.check_circle_rounded : Icons.block_rounded,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium
                      ? l10n.settingsPremiumPurchasedTitle
                      : l10n.settingsPremiumTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.title(brightness),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.x1),
                Text(
                  isPremium
                      ? l10n.settingsPremiumPurchasedDescription
                      : l10n.settingsPremiumDescription,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.body(brightness)),
                ),
                if (!isPremium) ...[
                  const SizedBox(height: AppSpacing.x2),
                  AppPrimaryButton(
                    label: productDetails.valueOrNull != null
                        ? l10n.settingsPremiumButtonPriced(
                            productDetails.valueOrNull!.price,
                          )
                        : l10n.settingsPremiumButton,
                    onPressed: () =>
                        ref.read(premiumNotifierProvider.notifier).buyRemoveAds(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
