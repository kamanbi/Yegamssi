import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/locale/country_code.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/date_format_helper.dart';
import '../../../core/widgets/header_refresh_button.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppDateFormat.format(now),
          style: AppTextStyles.labelMedium.copyWith(color: bodyColor),
        ),
        const SizedBox(height: AppSpacing.x1),
        Text(
          l10n.homeHeadline,
          style: AppTextStyles.headlineLarge.copyWith(color: titleColor),
        ),
      ],
    );
  }
}

class _HomeHeaderSection extends ConsumerWidget {
  const _HomeHeaderSection({required this.titleColor, required this.bodyColor});

  final Color titleColor;
  final Color bodyColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _HomeHeader(titleColor: titleColor, bodyColor: bodyColor),
        ),
        const SizedBox(width: AppSpacing.x1),
        _HomeLanguageSelector(ref: ref),
        const SizedBox(width: AppSpacing.x1),
        const HeaderRefreshButton(),
      ],
    );
  }
}

class _HomeLanguageSelector extends StatelessWidget {
  const _HomeLanguageSelector({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(width: AppSpacing.x1),
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

class _CurrentWeatherSection extends StatelessWidget {
  const _CurrentWeatherSection({
    required this.weatherAsync,
    required this.scoreAsync,
  });

  final AsyncValue<WeatherEntity> weatherAsync;
  final AsyncValue<ActivityScore> scoreAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return weatherAsync.when(
      loading: () => HeroGlassCard(
        child: _AsyncStatusView(
          title: l10n.homeWeatherLoadingTitle,
          message: l10n.homeWeatherLoadingMessage,
        ),
      ),
      error: (_, __) => HeroGlassCard(
        child: _AsyncStatusView(
          title: l10n.homeWeatherErrorTitle,
          message: l10n.homeWeatherErrorMessage,
          actionLabel: l10n.homeWeatherAction,
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
                            WeatherIconMapper.localizedLabelFor(
                              context,
                              weather.condition,
                              isNight: weather.isNight,
                            ),
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
                                  l10n.weatherFeelsLikeShort(
                                    weather.feelsLikeCelsius.round().toString(),
                                  ),
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
                    _MetricChip(
                      label: l10n.weatherHumidityLabel,
                      value: '${weather.humidity}%',
                    ),
                    _MetricChip(
                      label: l10n.weatherWindLabel,
                      value: '${weather.windSpeedMs.toStringAsFixed(1)}m/s',
                    ),
                    _MetricChip(
                      label: l10n.weatherPrecipitationLabel,
                      value: '${(weather.precipProbability * 100).round()}%',
                    ),
                    if (score != null && activitySpec != null)
                      _MetricChip(
                        label: l10n.scoreLabel,
                        value:
                            '${l10n.scorePointUnit(score.score)} ${ActivityIconMapper.localizedLabelFor(context, score.tier)}',
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
    final l10n = AppLocalizations.of(context);
    return PremiumCard(
      tone: PremiumCardTone.accent,
      child: fortuneAsync.when(
        loading: () => _AsyncStatusView(
          title: l10n.homeFortuneLoadingTitle,
          message: l10n.homeFortuneLoadingMessage,
        ),
        error: (_, __) => _AsyncStatusView(
          title: l10n.homeFortuneErrorTitle,
          message: l10n.homeFortuneErrorMessage,
          actionLabel: l10n.homeFortuneAction,
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
                  l10n.homeFortuneHeadline,
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
