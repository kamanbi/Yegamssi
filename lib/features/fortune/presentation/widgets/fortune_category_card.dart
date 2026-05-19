import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../domain/entities/oheng.dart';

class FortuneCategoryCard extends StatelessWidget {
  const FortuneCategoryCard({
    super.key,
    required this.category,
    required this.score,
    required this.message,
  });

  final FortuneCategory category;
  final int score;
  final String message;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _scoreColor(score);
    final resolvedMessage = message.isEmpty ? '분석 중입니다.' : message;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withAlpha(18),
                ),
                child: Icon(
                  _icon,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.x1),
              Expanded(
                child: Text(
                  category.korean,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.title(brightness),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withAlpha(16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent.withAlpha(70)),
                ),
                child: Text(
                  '$score점',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x2),
          LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: Theme.of(context).colorScheme.outlineVariant,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            resolvedMessage,
            style: AppTextStyles.fortuneLine.copyWith(
              color: AppColors.body(brightness),
            ),
          ),
        ],
      ),
    );
  }

  IconData get _icon => switch (category) {
        FortuneCategory.overall => Icons.auto_awesome_rounded,
        FortuneCategory.money => Icons.account_balance_wallet_rounded,
        FortuneCategory.love => Icons.favorite_rounded,
        FortuneCategory.work => Icons.work_rounded,
        FortuneCategory.health => Icons.favorite_border_rounded,
        FortuneCategory.decision => Icons.lightbulb_rounded,
      };

  Color _scoreColor(int value) {
    if (value >= 75) return AppColors.scoreExcellent;
    if (value >= 50) return AppColors.scoreGood;
    if (value >= 25) return AppColors.scoreFair;
    return AppColors.scorePoor;
  }
}
