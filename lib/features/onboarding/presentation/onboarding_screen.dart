import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/glassmorphism.dart';
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

    final profile = UserProfile(
      birthDate: selectedDate,
      birthHour: _selectedHour,
    );

    await ref.read(userProfileNotifierProvider.notifier).save(profile);
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  '예감씨',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '생년월일과 생시를 입력하면\n오늘의 운세를 알려드릴게요.',
                  style: TextStyle(
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
                        const Text(
                          '생년월일',
                          style: TextStyle(
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
                                    ? '날짜를 선택하세요'
                                    : _formatDate(_selectedDate!),
                                style: TextStyle(
                                  color: _selectedDate == null
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
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
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _pickHour,
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '생시 (선택)',
                          style: TextStyle(
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
                                _formatHour(_selectedHour),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
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
                    child: const Text(
                      '시작하기',
                      style: TextStyle(
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

  String _formatDate(DateTime value) {
    return '${value.year}년 ${value.month}월 ${value.day}일';
  }

  String _formatHour(int hour) {
    if (hour == UserProfile.unknownBirthHour) {
      return '모름 (정오 기준 계산)';
    }
    return '$hour시';
  }
}
