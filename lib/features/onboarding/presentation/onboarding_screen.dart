import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/locale/country_code.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/glassmorphism.dart';
import '../../../l10n/app_localizations.dart';
import '../../user/domain/entities/user_profile.dart';
import '../../user/presentation/user_profile_provider.dart';
import '../../user/presentation/widgets/birth_picker_sheet.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  DateTime? _selectedDate;
  int _selectedHour = UserProfile.unknownBirthHour;
  Gender _selectedGender = Gender.unspecified;

  bool get _canProceed => _selectedDate != null;

  Future<void> _pickDate() async {
    final picked = await BirthPickerSheet.pickBirthDate(
      context,
      initialDate: _selectedDate ?? DateTime(1990),
    );
    if (picked == null) {
      return;
    }

    setState(() => _selectedDate = picked);
  }

  Future<void> _pickHour() async {
    final picked = await BirthPickerSheet.pickBirthHour(
      context,
      initialHour: _selectedHour,
    );
    if (picked == null) {
      return;
    }

    setState(() => _selectedHour = picked);
  }

  Future<void> _proceed() async {
    final selectedDate = _selectedDate;
    if (selectedDate == null) {
      return;
    }

    await ref
        .read(userProfileNotifierProvider.notifier)
        .save(
          UserProfile(
            birthDate: selectedDate,
            birthHour: _selectedHour,
            gender: _selectedGender,
          ),
        );
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.skyDeep, AppColors.skyMid, AppColors.skyLight],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Align(
                  alignment: Alignment.centerRight,
                  child: _OnboardingLanguageSelector(),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.onboardingTitle,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.onboardingSubtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _pickDate,
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.birthDate,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.gold,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? l10n.birthSelectDate
                                    : _formatDate(l10n, _selectedDate!),
                                style: TextStyle(
                                  color: _selectedDate == null
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.unfold_more_rounded,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.onboardingGenderLabel,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (final gender in Gender.values) ...[
                            Expanded(
                              child: _GenderChoiceChip(
                                label: _genderLabel(l10n, gender),
                                isSelected: _selectedGender == gender,
                                onTap: () =>
                                    setState(() => _selectedGender = gender),
                              ),
                            ),
                            if (gender != Gender.values.last)
                              const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _pickHour,
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.birthHourOptional,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: AppColors.gold,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _formatHour(l10n, _selectedHour),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.unfold_more_rounded,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canProceed ? _proceed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: AppColors.gold.withAlpha(80),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.onboardingStart,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(AppLocalizations l10n, DateTime value) {
    return l10n.dateYmd(value.year, value.month, value.day);
  }

  String _formatHour(AppLocalizations l10n, int hour) {
    if (hour == UserProfile.unknownBirthHour) {
      return l10n.birthUnknownNoon;
    }
    return l10n.hourLabel(hour);
  }

  String _genderLabel(AppLocalizations l10n, Gender gender) {
    return switch (gender) {
      Gender.male => l10n.genderMale,
      Gender.female => l10n.genderFemale,
      Gender.unspecified => l10n.genderUnspecified,
    };
  }
}

class _GenderChoiceChip extends StatelessWidget {
  const _GenderChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.gold.withAlpha(28)
              : Colors.white.withAlpha(14),
          border: Border.all(
            color: isSelected
                ? AppColors.gold.withAlpha(150)
                : Colors.white.withAlpha(28),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OnboardingLanguageSelector extends ConsumerWidget {
  const _OnboardingLanguageSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(appLanguageNotifierProvider);

    return PopupMenuButton<AppLanguage>(
      tooltip: AppLocalizations.of(context).settingsLanguage,
      onSelected: (language) =>
          ref.read(appLanguageNotifierProvider.notifier).setLanguage(language),
      itemBuilder: (context) => [
        for (final language in AppLanguage.values)
          PopupMenuItem(
            value: language,
            child: Row(
              children: [
                SizedBox(width: 32, child: Text(language.shortLabel)),
                const SizedBox(width: 8),
                Text(language.displayName),
              ],
            ),
          ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(18),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withAlpha(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                selectedLanguage.shortLabel,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
