import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/premium_card.dart';
import '../../fortune/domain/entities/fortune_tone.dart';
import '../../fortune/presentation/fortune_tone_provider.dart';
import '../../user/domain/entities/user_profile.dart';
import '../../user/presentation/user_profile_provider.dart';
import '../../user/presentation/widgets/birth_picker_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileNotifierProvider);
    final profile = profileAsync.valueOrNull;
    final fortuneTone = ref.watch(fortuneToneProvider);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '설정',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.title(brightness),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x3),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _editBirthProfile(context, ref, profile),
              child: PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '생년월일',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.title(brightness),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    Text(
                      '운세 계산에 사용하는 생년월일과 생시를 관리합니다.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.body(brightness),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    Row(
                      children: [
                        const Icon(
                          Icons.cake_outlined,
                          color: AppColors.gold,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.x1),
                        Expanded(
                          child: Text(
                            profile == null ? '입력하지 않음' : _formatBirth(profile),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.title(brightness),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
                            '멘트 선택',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.title(brightness),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.x1),
                          Text(
                            '운세 문구 톤을 ${fortuneTone.label} 스타일로 표시합니다.',
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
                        border: Border.all(color: AppColors.gold.withAlpha(84)),
                      ),
                      child: Text(
                        fortuneTone.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.title(brightness),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x1),
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
                            '앱 정보',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.title(brightness),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.x1),
                          Text(
                            '홈페이지, 개인정보 처리 안내, 문의 이메일 및 링크를 확인합니다.',
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
          ],
        ),
      ),
    );
  }

  static String _formatBirth(UserProfile profile) {
    final date = profile.birthDate;
    final dateLabel =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    final hourLabel = profile.birthHour == UserProfile.unknownBirthHour
        ? '미상'
        : '${profile.birthHour}시';
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
    if (updatedProfile == null) {
      return;
    }

    await ref
        .read(userProfileNotifierProvider.notifier)
        .save(
          UserProfile(
            birthDate: updatedProfile.birthDate,
            birthHour: updatedProfile.birthHour,
          ),
        );
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
                              '멘트 선택',
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
                        '기본 문구는 유지하고 선택한 스타일 문구를 우선 사용합니다.',
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

    if (selectedTone == null || selectedTone == currentTone) {
      return;
    }

    await ref.read(fortuneToneProvider.notifier).setTone(selectedTone);
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
                  tone.label,
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
