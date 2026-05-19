import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/date_format_helper.dart';
import '../../../core/widgets/header_refresh_button.dart';
import '../../../core/widgets/premium_card.dart';
import '../../fortune/domain/entities/fortune_result.dart';
import '../../fortune/domain/entities/oheng.dart';
import '../../fortune/presentation/fortune_provider.dart';
import '../../score/domain/entities/activity_score.dart';
import '../../score/presentation/score_provider.dart';
import '../../score/presentation/widgets/activity_icon_mapper.dart';
import '../../weather/domain/entities/weather_entity.dart';
import '../../weather/presentation/weather_provider.dart';
import '../../weather/presentation/widgets/premium_weather_icon.dart';
import '../../weather/presentation/widgets/weather_icon_mapper.dart';

class HomeTabScreen extends ConsumerWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);
    final scoreAsync = ref.watch(currentScoreProvider);
    final fortuneAsync = ref.watch(dailyFortuneProvider);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            _HomeHeaderSection(
              titleColor: AppColors.title(brightness),
              bodyColor: AppColors.body(brightness),
            ),
            const SizedBox(height: AppSpacing.x3),
            _CurrentWeatherSection(
              weatherAsync: weatherAsync,
              scoreAsync: scoreAsync,
            ),
            const SizedBox(height: AppSpacing.x2),
            _FortuneHeadlineSection(fortuneAsync: fortuneAsync),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.titleColor, required this.bodyColor});

  final Color titleColor;
  final Color bodyColor;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppDateFormat.format(now),
          style: AppTextStyles.labelMedium.copyWith(color: bodyColor),
        ),
        const SizedBox(height: AppSpacing.x1),
        Text(
          '오늘의 날씨와 예감',
          style: AppTextStyles.headlineLarge.copyWith(color: titleColor),
        ),
      ],
    );
  }
}

class _HomeHeaderSection extends StatelessWidget {
  const _HomeHeaderSection({required this.titleColor, required this.bodyColor});

  final Color titleColor;
  final Color bodyColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _HomeHeader(titleColor: titleColor, bodyColor: bodyColor),
        ),
        const HeaderRefreshButton(),
      ],
    );
  }
}

class _CurrentWeatherSection extends StatelessWidget {
  const _CurrentWeatherSection({
    required this.weatherAsync,
    required this.scoreAsync,
  });

  final AsyncValue<WeatherEntity> weatherAsync;
  final AsyncValue<ActivityScore> scoreAsync;

  @override
  Widget build(BuildContext context) {
    return weatherAsync.when(
      loading: () => const HeroGlassCard(
        child: _AsyncStatusView(
          title: '현재 날씨를 불러오는 중',
          message: '위치와 날씨 정보를 준비하고 있습니다.',
        ),
      ),
      error: (_, __) => HeroGlassCard(
        child: _AsyncStatusView(
          title: '현재 날씨를 불러오지 못했습니다',
          message: '날씨 화면으로 이동해 다시 확인해 주세요.',
          actionLabel: '날씨 보기',
          onTap: () => _goToWeather(context),
        ),
      ),
      data: (weather) {
        final score = scoreAsync.valueOrNull;
        final activitySpec = score == null
            ? null
            : ActivityIconMapper.specFor(score.tier);

        return GestureDetector(
          onTap: () => _goToWeather(context),
          child: HeroGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weather.locationName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.x1),
                          Text(
                            WeatherIconMapper.labelFor(weather.condition),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withAlpha(220),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${weather.tempCelsius.round()}°',
                                style: AppTextStyles.temperature,
                              ),
                              const SizedBox(width: AppSpacing.x1),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  '체감 ${weather.feelsLikeCelsius.round()}°',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    PremiumWeatherIcon(
                      condition: weather.condition,
                      isNight: weather.isNight,
                      size: 84,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x3),
                Wrap(
                  spacing: AppSpacing.x1,
                  runSpacing: AppSpacing.x1,
                  children: [
                    _MetricChip(label: '습도', value: '${weather.humidity}%'),
                    _MetricChip(
                      label: '바람',
                      value: '${weather.windSpeedMs.toStringAsFixed(1)}m/s',
                    ),
                    _MetricChip(
                      label: '강수',
                      value: '${(weather.precipProbability * 100).round()}%',
                    ),
                    if (score != null && activitySpec != null)
                      _MetricChip(
                        label: '야외 점수',
                        value: '${score.score}점 ${activitySpec.label}',
                        icon: activitySpec.icon,
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _goToWeather(BuildContext context) =>
      context.go(AppRoutes.weather);
}

class _FortuneHeadlineSection extends StatelessWidget {
  const _FortuneHeadlineSection({required this.fortuneAsync});

  final AsyncValue<FortuneResult> fortuneAsync;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      tone: PremiumCardTone.accent,
      child: fortuneAsync.when(
        loading: () => const _AsyncStatusView(
          title: '오늘의 운세를 준비하는 중',
          message: '한 줄 요약을 곧 보여드릴게요.',
        ),
        error: (_, __) => _AsyncStatusView(
          title: '운세를 아직 준비하지 못했습니다',
          message: '프로필을 확인하고 운세 화면에서 다시 확인해 주세요.',
          actionLabel: '운세 보기',
          onTap: () => context.go(AppRoutes.fortune),
        ),
        data: (fortune) {
          final line = fortune.messages[FortuneCategory.overall] ?? '';

          return InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => context.go(AppRoutes.fortune),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 한 줄 운세',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.title(Theme.of(context).brightness),
                  ),
                ),
                const SizedBox(height: AppSpacing.x1),
                Text(
                  line,
                  style: AppTextStyles.fortuneLine.copyWith(
                    color: AppColors.body(Theme.of(context).brightness),
                    fontSize: 15,
                    height: 1.55,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.pill,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white.withAlpha(224)),
            const SizedBox(width: AppSpacing.x1),
          ],
          Text(
            '$label  $value',
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white.withAlpha(224),
            ),
          ),
        ],
      ),
    );
  }
}

class _AsyncStatusView extends StatelessWidget {
  const _AsyncStatusView({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.title(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.x1),
        Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.body(brightness),
          ),
        ),
        if (actionLabel != null && onTap != null) ...[
          const SizedBox(height: AppSpacing.x2),
          TextButton(onPressed: onTap, child: Text(actionLabel!)),
        ],
      ],
    );
  }
}
