import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ads/support_interstitial_ad_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/background/background_refresh_permission_service.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/review/app_review_prompt.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/locale/country_code.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/purchase/premium_provider.dart';
import '../../fortune/domain/entities/fortune_tone.dart';
import '../../fortune/presentation/fortune_tone_provider.dart';
import '../../user/domain/entities/user_profile.dart';
import '../../user/presentation/user_profile_provider.dart';
import '../../user/presentation/widgets/birth_picker_sheet.dart';
import 'widgets/remove_ads_card.dart';

final backgroundRefreshStatusProvider = FutureProvider.autoDispose<bool>(
  (ref) => BackgroundRefreshPermissionService.isBatteryOptimizationIgnored(),
);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(backgroundRefreshStatusProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileNotifierProvider);
    final profile = profileAsync.valueOrNull;
    final fortuneTone = ref.watch(fortuneToneProvider);
    final brightness = Theme.of(context).brightness;
    final l10n = AppLocalizations.of(context);
    final toneLabel = _fortuneToneLabel(l10n, fortuneTone);
    final isKorean = ref.watch(appLanguageNotifierProvider) == AppLanguage.ko;
    final themePreference = ref.watch(themePreferenceNotifierProvider);
    final themePreferenceLabel = _themePreferenceLabel(l10n, themePreference);
    final isIgnoringOptimization =
        ref.watch(backgroundRefreshStatusProvider).valueOrNull ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            Text(
              l10n.tabSettings,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.title(brightness),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.x3),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _editBirthProfile(context, ref, profile),
              child: PremiumCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withAlpha(24),
                      ),
                      child: const Icon(
                        Icons.cake_outlined,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsBirthTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.title(brightness),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.x1),
                          Text(
                            profile == null
                                ? l10n.settingsBirthEmpty
                                : _formatBirth(l10n, profile),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.body(brightness)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x1),
                    Container(
                      padding: AppSpacing.pill,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: AppColors.gold.withAlpha(22),
                        border: Border.all(color: AppColors.gold.withAlpha(84)),
                      ),
                      child: Text(
                        l10n.settingsBirthEdit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.title(brightness),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _editGender(context, ref, profile),
              child: PremiumCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withAlpha(24),
                      ),
                      child: const Icon(
                        Icons.wc_rounded,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsGenderTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.title(brightness),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.x1),
                          Text(
                            _genderLabel(
                              l10n,
                              profile?.gender ?? Gender.unspecified,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.body(brightness)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x1),
                    Container(
                      padding: AppSpacing.pill,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: AppColors.gold.withAlpha(22),
                        border: Border.all(color: AppColors.gold.withAlpha(84)),
                      ),
                      child: Text(
                        l10n.settingsBirthEdit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.title(brightness),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isKorean) ...[
              const SizedBox(height: AppSpacing.x2),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _selectFortuneTone(context, ref, fortuneTone),
                child: PremiumCard(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withAlpha(24),
                        ),
                        child: const Icon(
                          Icons.record_voice_over_rounded,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.settingsFortuneToneTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.title(brightness),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.x1),
                            Text(
                              l10n.settingsFortuneToneDescription(toneLabel),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.body(brightness)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x1),
                      Container(
                        constraints: const BoxConstraints(minWidth: 72),
                        padding: AppSpacing.pill,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: AppColors.gold.withAlpha(22),
                          border: Border.all(
                            color: AppColors.gold.withAlpha(84),
                          ),
                        ),
                        child: Text(
                          toneLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.title(brightness),
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ], // isKorean
            const SizedBox(height: AppSpacing.x2),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  _selectThemePreference(context, ref, themePreference),
              child: PremiumCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withAlpha(22),
                      ),
                      child: const Icon(
                        Icons.brightness_6_rounded,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsTheme,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.title(brightness),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.x1),
                          Text(
                            l10n.settingsThemeDescription,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.body(brightness)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x1),
                    Container(
                      constraints: const BoxConstraints(minWidth: 82),
                      padding: AppSpacing.pill,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(18),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(76),
                        ),
                      ),
                      child: Text(
                        themePreferenceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.title(brightness),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await BackgroundRefreshPermissionService.requestBatteryOptimizationException();
                await Future<void>.delayed(const Duration(seconds: 1));
                ref.invalidate(backgroundRefreshStatusProvider);
              },
              child: PremiumCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(18),
                      ),
                      child: Icon(
                        Icons.sync_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsBackgroundRefreshTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.title(brightness),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.x1),
                          Text(
                            l10n.settingsBackgroundRefreshDescription,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.body(brightness)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x1),
                    Text(
                      isIgnoringOptimization
                          ? l10n.settingsBackgroundRefreshStatusEnabled
                          : l10n.settingsBackgroundRefreshAction,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isIgnoringOptimization
                            ? Theme.of(context).colorScheme.primary
                            : AppColors.gold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push(AppRoutes.appInfo),
              child: PremiumCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(18),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsAppInfoTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.title(brightness),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.x1),
                          Text(
                            l10n.settingsAppInfoDescription,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.body(brightness)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showSupportActions(context, ref),
              child: PremiumCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withAlpha(24),
                      ),
                      child: const Icon(
                        Icons.favorite_outline_rounded,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsSupportTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.title(brightness),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.x1),
                          Text(
                            l10n.settingsSupportDescription,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.body(brightness)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            const RemoveAdsCard(),
          ],
        ),
      ),
    );
  }

  static String _formatBirth(AppLocalizations l10n, UserProfile profile) {
    final date = profile.birthDate;
    final dateLabel = l10n.dateYmd(date.year, date.month, date.day);
    final hourLabel = profile.birthHour == UserProfile.unknownBirthHour
        ? l10n.settingsBirthUnknownHour
        : l10n.settingsHourUnit(profile.birthHour);
    return '$dateLabel $hourLabel';
  }

  Future<void> _editBirthProfile(
    BuildContext context,
    WidgetRef ref,
    UserProfile? current,
  ) async {
    final initialProfile = BirthPickerResult(
      birthDate: current?.birthDate ?? DateTime(1990),
      birthHour: current?.birthHour ?? UserProfile.unknownBirthHour,
    );

    final updatedProfile = await BirthPickerSheet.editBirthProfile(
      context,
      initialValue: initialProfile,
    );
    if (updatedProfile == null) return;

    await ref
        .read(userProfileNotifierProvider.notifier)
        .save(
          UserProfile(
            birthDate: updatedProfile.birthDate,
            birthHour: updatedProfile.birthHour,
          ),
        );
  }

  Future<void> _editGender(
    BuildContext context,
    WidgetRef ref,
    UserProfile? current,
  ) async {
    if (current == null) return;

    final selectedGender = await showModalBottomSheet<Gender>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final brightness = Theme.of(sheetContext).brightness;
        final l10n = AppLocalizations.of(sheetContext);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2,
              0,
              AppSpacing.x2,
              AppSpacing.x2,
            ),
            child: PremiumCard(
              padding: const EdgeInsets.all(AppSpacing.x3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsGenderTitle,
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      color: AppColors.title(brightness),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  for (final gender in Gender.values) ...[
                    _GenderChoice(
                      label: _genderLabel(l10n, gender),
                      isSelected: gender == current.gender,
                      onTap: () => Navigator.of(sheetContext).pop(gender),
                    ),
                    if (gender != Gender.values.last)
                      const SizedBox(height: AppSpacing.x1),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedGender == null || selectedGender == current.gender) return;
    await ref
        .read(userProfileNotifierProvider.notifier)
        .save(current.copyWith(gender: selectedGender));
  }

  Future<void> _selectFortuneTone(
    BuildContext context,
    WidgetRef ref,
    FortuneTone currentTone,
  ) async {
    final selectedTone = await showGeneralDialog<FortuneTone>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withAlpha(92),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (sheetContext, animation, secondaryAnimation) {
        final brightness = Theme.of(sheetContext).brightness;
        final l10n = AppLocalizations.of(sheetContext);

        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x2,
                  AppSpacing.x2,
                  AppSpacing.x2,
                  0,
                ),
                child: PremiumCard(
                  padding: const EdgeInsets.all(AppSpacing.x3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.settingsFortuneToneTitle,
                              style: Theme.of(sheetContext).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.title(brightness),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.x1),
                      Text(
                        l10n.settingsFortuneToneSheetDescription,
                        style: Theme.of(sheetContext).textTheme.bodySmall
                            ?.copyWith(color: AppColors.body(brightness)),
                      ),
                      const SizedBox(height: AppSpacing.x3),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.x1,
                        mainAxisSpacing: AppSpacing.x1,
                        childAspectRatio: 2.8,
                        children: [
                          for (final tone in FortuneTone.values)
                            _FortuneToneChoice(
                              tone: tone,
                              isSelected: tone == currentTone,
                              onTap: () => Navigator.of(sheetContext).pop(tone),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.04),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );

    if (selectedTone == null || selectedTone == currentTone) return;
    await ref.read(fortuneToneProvider.notifier).setTone(selectedTone);
  }

  Future<void> _selectThemePreference(
    BuildContext context,
    WidgetRef ref,
    AppThemePreference currentPreference,
  ) async {
    final selectedPreference = await showGeneralDialog<AppThemePreference>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withAlpha(92),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (sheetContext, animation, secondaryAnimation) {
        final brightness = Theme.of(sheetContext).brightness;
        final l10n = AppLocalizations.of(sheetContext);

        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x2,
                  AppSpacing.x2,
                  AppSpacing.x2,
                  0,
                ),
                child: PremiumCard(
                  padding: const EdgeInsets.all(AppSpacing.x3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.settingsTheme,
                              style: Theme.of(sheetContext).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.title(brightness),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.x1),
                      Text(
                        l10n.settingsThemeDescription,
                        style: Theme.of(sheetContext).textTheme.bodySmall
                            ?.copyWith(color: AppColors.body(brightness)),
                      ),
                      const SizedBox(height: AppSpacing.x3),
                      for (final preference in AppThemePreference.values) ...[
                        _ThemePreferenceChoice(
                          preference: preference,
                          isSelected: preference == currentPreference,
                          onTap: () =>
                              Navigator.of(sheetContext).pop(preference),
                        ),
                        if (preference != AppThemePreference.values.last)
                          const SizedBox(height: AppSpacing.x1),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.04),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );

    if (selectedPreference == null || selectedPreference == currentPreference) {
      return;
    }
    await ref
        .read(themePreferenceNotifierProvider.notifier)
        .setPreference(selectedPreference);
  }

  Future<void> _showSupportActions(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<_SupportAction>(
      context: context,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      builder: (sheetContext) {
        final brightness = Theme.of(sheetContext).brightness;
        final l10n = AppLocalizations.of(sheetContext);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2,
              0,
              AppSpacing.x2,
              AppSpacing.x2,
            ),
            child: PremiumCard(
              padding: const EdgeInsets.all(AppSpacing.x2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsSupportTitle,
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(
                          color: AppColors.title(brightness),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    l10n.settingsSupportSheetDescription,
                    style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                      color: AppColors.body(brightness),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  _SupportActionRow(
                    icon: Icons.star_rate_rounded,
                    label: l10n.settingsSupportReviewAction,
                    onTap: () =>
                        Navigator.of(sheetContext).pop(_SupportAction.review),
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  _SupportActionRow(
                    icon: Icons.ondemand_video_rounded,
                    label: l10n.settingsSupportAdAction,
                    onTap: () =>
                        Navigator.of(sheetContext).pop(_SupportAction.ad),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!context.mounted || action == null) return;
    switch (action) {
      case _SupportAction.review:
        await _requestReview(context);
      case _SupportAction.ad:
        await _showSupportAd(context, ref);
    }
  }

  Future<void> _requestReview(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      await AppReviewPromptController.openStoreReview();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsSupportReviewFailed)));
    }
  }

  Future<void> _showSupportAd(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final result = await SupportInterstitialAdService.show(
      isPremium: ref.read(premiumNotifierProvider),
    );
    if (!context.mounted) return;

    final message = switch (result) {
      SupportAdResult.shown => l10n.settingsSupportAdThanks,
      SupportAdResult.skippedPremium => l10n.settingsSupportPremiumThanks,
      SupportAdResult.loadFailed ||
      SupportAdResult.showFailed => l10n.settingsSupportAdFailed,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _SupportAction { review, ad }

class _SupportActionRow extends StatelessWidget {
  const _SupportActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.mutedSurface(brightness).withAlpha(140),
          border: Border.all(color: AppColors.border(brightness)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x2),
          child: Row(
            children: [
              Icon(icon, color: AppColors.gold),
              const SizedBox(width: AppSpacing.x2),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.title(brightness),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreferenceChoice extends StatelessWidget {
  const _ThemePreferenceChoice({
    required this.preference,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemePreference preference;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppLocalizations.of(context);
    final title = _themePreferenceLabel(l10n, preference);
    final description = _themePreferenceDescription(l10n, preference);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withAlpha(24)
              : AppColors.mutedSurface(brightness).withAlpha(140),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withAlpha(130)
                : AppColors.border(brightness),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.title(brightness),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.body(brightness),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.x1),
              AnimatedOpacity(
                opacity: isSelected ? 1 : 0,
                duration: const Duration(milliseconds: 120),
                child: Icon(
                  Icons.check_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FortuneToneChoice extends StatelessWidget {
  const _FortuneToneChoice({
    required this.tone,
    required this.isSelected,
    required this.onTap,
  });

  final FortuneTone tone;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final label = _fortuneToneLabel(AppLocalizations.of(context), tone);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected
              ? AppColors.gold.withAlpha(28)
              : AppColors.mutedSurface(brightness).withAlpha(140),
          border: Border.all(
            color: isSelected
                ? AppColors.gold.withAlpha(150)
                : AppColors.border(brightness),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x2,
            vertical: AppSpacing.x1,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.title(brightness),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.x1),
              AnimatedOpacity(
                opacity: isSelected ? 1 : 0,
                duration: const Duration(milliseconds: 120),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.gold,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _genderLabel(AppLocalizations l10n, Gender gender) {
  return switch (gender) {
    Gender.male => l10n.genderMale,
    Gender.female => l10n.genderFemale,
    Gender.unspecified => l10n.genderUnspecified,
  };
}

class _GenderChoice extends StatelessWidget {
  const _GenderChoice({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected
              ? AppColors.gold.withAlpha(28)
              : AppColors.mutedSurface(brightness).withAlpha(140),
          border: Border.all(
            color: isSelected
                ? AppColors.gold.withAlpha(150)
                : AppColors.border(brightness),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.title(brightness),
                    fontWeight: isSelected
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.x1),
              AnimatedOpacity(
                opacity: isSelected ? 1 : 0,
                duration: const Duration(milliseconds: 120),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.gold,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _fortuneToneLabel(AppLocalizations l10n, FortuneTone tone) {
  return switch (tone) {
    FortuneTone.base => l10n.fortuneToneBase,
    FortuneTone.humor => l10n.fortuneToneHumor,
    FortuneTone.tsundere => l10n.fortuneToneTsundere,
    FortuneTone.cynical => l10n.fortuneToneCynical,
    FortuneTone.emotional => l10n.fortuneToneEmotional,
    FortuneTone.historical => l10n.fortuneToneHistorical,
    FortuneTone.ai => l10n.fortuneToneAi,
  };
}

String _themePreferenceLabel(
  AppLocalizations l10n,
  AppThemePreference preference,
) {
  return switch (preference) {
    AppThemePreference.automatic => l10n.settingsThemeAutomatic,
    AppThemePreference.day => l10n.settingsThemeDay,
    AppThemePreference.night => l10n.settingsThemeNight,
  };
}

String _themePreferenceDescription(
  AppLocalizations l10n,
  AppThemePreference preference,
) {
  return switch (preference) {
    AppThemePreference.automatic => l10n.settingsThemeAutomaticDescription,
    AppThemePreference.day => l10n.settingsThemeDayDescription,
    AppThemePreference.night => l10n.settingsThemeNightDescription,
  };
}
