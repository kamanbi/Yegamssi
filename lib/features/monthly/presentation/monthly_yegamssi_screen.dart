import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/locale/country_code.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/monthly_category.dart';
import '../domain/entities/monthly_yegamssi_result.dart';
import 'monthly_yegamssi_provider.dart';

class MonthlyYegamssiScreen extends ConsumerWidget {
  const MonthlyYegamssiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyAsync = ref.watch(monthlyYegamssiProvider);
    final stale = monthlyAsync.valueOrNull;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: monthlyAsync.when(
          loading: () => stale != null
              ? _MonthlyDataView(result: stale)
              : const _StatusView(isError: false),
          error: (error, _) {
            if (error is MonthlyNoProfileException) {
              return _NoProfileView(
                onTap: () => context.go(AppRoutes.onboarding),
              );
            }
            return stale != null
                ? _MonthlyDataView(result: stale)
                : const _StatusView(isError: true);
          },
          data: (result) => _MonthlyDataView(result: result),
        ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({required this.isError});

  final bool isError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: Text(
          isError ? l10n.monthlyFailedMessage : l10n.monthlyGeneratingMessage,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.body(brightness),
          ),
        ),
      ),
    );
  }
}

class _NoProfileView extends StatelessWidget {
  const _NoProfileView({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: PremiumCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.fortuneNeedProfileTitle,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.title(brightness),
                ),
              ),
              const SizedBox(height: AppSpacing.x1),
              Text(
                l10n.fortuneNeedProfileMessage,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.body(brightness),
                ),
              ),
              const SizedBox(height: AppSpacing.x3),
              AppPrimaryButton(
                label: l10n.fortuneBirthInputAction,
                onPressed: onTap,
                icon: Icons.arrow_forward_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlyDataView extends ConsumerWidget {
  const _MonthlyDataView({required this.result});

  final MonthlyYegamssiResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(appLanguageNotifierProvider);
    // 배너 유무와 무관하게 하단 여백을 동적으로 계산(지시서 7.2).
    final bottomPadding = 16 + MediaQuery.of(context).padding.bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.x2,
        AppSpacing.x1,
        AppSpacing.x2,
        bottomPadding,
      ),
      children: [
        Text(
          l10n.monthlyYegamssiTitle,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.title(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.x1),
        Text(
          _monthTitle(result.targetYear, result.targetMonth, language),
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.body(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.x1),
        Text(
          l10n.monthlyYegamssiSubtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.body(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        PremiumCard(
          child: Text(
            _summaryText(l10n, result.summaryPhase),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.title(brightness),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x3),
        for (final category in MonthlyCategory.values) ...[
          _CategoryCard(
            category: category,
            data: result.categories.firstWhere(
              (c) => c.category == category,
            ),
            targetMonth: result.targetMonth,
          ),
          const SizedBox(height: AppSpacing.x2),
        ],
        const SizedBox(height: AppSpacing.x1),
        Text(
          l10n.monthlyDisclaimer,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.caption(brightness),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.data,
    required this.targetMonth,
  });

  final MonthlyCategory category;
  final MonthlyCategoryResult data;
  final int targetMonth;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppLocalizations.of(context);

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _categoryTitle(l10n, category),
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.title(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          _DayRow(
            label: l10n.monthlyGoodDaysLabel,
            days: data.goodDays,
            targetMonth: targetMonth,
            accent: AppColors.accentGold,
          ),
          const SizedBox(height: AppSpacing.x1),
          _DayRow(
            label: l10n.monthlyCautionDaysLabel,
            days: data.cautionDays,
            targetMonth: targetMonth,
            accent: AppColors.caption(brightness),
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            _categoryMessage(l10n, category),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.body(brightness),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.label,
    required this.days,
    required this.targetMonth,
    required this.accent,
  });

  final String label;
  final List<int> days;
  final int targetMonth;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final text = days.map((d) => '$targetMonth/$d').join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: accent),
          ),
        ),
        const SizedBox(width: AppSpacing.x1),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.title(brightness),
            ),
          ),
        ),
      ],
    );
  }
}

String _monthTitle(int year, int month, AppLanguage language) {
  return switch (language) {
    AppLanguage.ko => '$year년 $month월',
    AppLanguage.ja => '$year年 $month月',
    AppLanguage.zh => '$year年 $month月',
    _ => '${_monthName(month)} $year',
  };
}

String _monthName(int month) {
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return names[(month - 1).clamp(0, 11)];
}

String _summaryText(AppLocalizations l10n, MonthlySummaryPhase phase) {
  return switch (phase) {
    MonthlySummaryPhase.early => l10n.monthlySummaryEarly,
    MonthlySummaryPhase.mid => l10n.monthlySummaryMid,
    MonthlySummaryPhase.late => l10n.monthlySummaryLate,
  };
}

String _categoryTitle(AppLocalizations l10n, MonthlyCategory category) {
  return switch (category) {
    MonthlyCategory.love => l10n.monthlyCategoryLove,
    MonthlyCategory.work => l10n.monthlyCategoryWork,
    MonthlyCategory.money => l10n.monthlyCategoryMoney,
    MonthlyCategory.relationship => l10n.monthlyCategoryRelationship,
    MonthlyCategory.health => l10n.monthlyCategoryHealth,
    MonthlyCategory.decision => l10n.monthlyCategoryDecision,
    MonthlyCategory.travel => l10n.monthlyCategoryTravel,
  };
}

String _categoryMessage(AppLocalizations l10n, MonthlyCategory category) {
  return switch (category) {
    MonthlyCategory.love => l10n.monthlyCategoryLoveMessage,
    MonthlyCategory.work => l10n.monthlyCategoryWorkMessage,
    MonthlyCategory.money => l10n.monthlyCategoryMoneyMessage,
    MonthlyCategory.relationship => l10n.monthlyCategoryRelationshipMessage,
    MonthlyCategory.health => l10n.monthlyCategoryHealthMessage,
    MonthlyCategory.decision => l10n.monthlyCategoryDecisionMessage,
    MonthlyCategory.travel => l10n.monthlyCategoryTravelMessage,
  };
}
