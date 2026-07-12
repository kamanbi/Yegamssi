import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/glassmorphism.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/utils/date_format_helper.dart';
import '../../../core/locale/country_code.dart';
import '../../../core/locale/country_resolver.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/widgets/header_refresh_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../score/domain/entities/activity_score.dart';
import '../../score/domain/entities/score_tier.dart';
import '../../score/presentation/score_provider.dart';
import '../../score/presentation/widgets/score_gauge.dart';
import '../domain/entities/weather_entity.dart';
import 'weather_location_provider.dart';
import 'weather_provider.dart';
import 'widgets/location_dropdown.dart';
import 'widgets/premium_weather_icon.dart';
import 'widgets/weather_icon_mapper.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(weatherLocationNotifierProvider);
    final selectedLocation = locationState.location;
    final weatherAsync = selectedLocation != null
        ? ref.watch(selectedLocationWeatherProvider(selectedLocation))
        : ref.watch(currentWeatherProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: weatherAsync.when(
          loading: () => const _LoadingView(),
          error: (error, _) => _ErrorView(message: error.toString()),
          data: (weather) => _WeatherContent(weather: weather),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.title(brightness)),
          const SizedBox(height: 16),
          Text(
            l10n.weatherLoading,
            style: TextStyle(color: AppColors.body(brightness)),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                color: AppColors.caption(brightness),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.weatherErrorTitle,
                style: TextStyle(
                  color: AppColors.title(brightness),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  color: AppColors.caption(brightness),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherContent extends ConsumerWidget {
  const _WeatherContent({required this.weather});

  final WeatherEntity weather;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedLocation = ref
        .watch(weatherLocationNotifierProvider)
        .location;
    final country = ref.watch(resolvedCountryProvider).valueOrNull;
    final score = selectedLocation == null
        ? ref.watch(currentScoreProvider).valueOrNull
        : calculateActivityScore(
            weather: weather,
            country: country ?? CountryCode.kr,
          );
    final now = DateTime.now();
    final hourlyForecasts = weather.hourlyForecasts
        .where(
          (forecast) =>
              !forecast.time.isBefore(now.subtract(const Duration(minutes: 5))),
        )
        .toList(growable: false);
    final today = DateTime(now.year, now.month, now.day);
    final dailyForecasts = weather.dailyForecasts
        .where((forecast) => !forecast.date.isBefore(today))
        .toList(growable: false);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 60),
      children: [
        const _WeatherHeader(),
        const SizedBox(height: 16),
        _MainWeatherCard(weather: weather),
        const SizedBox(height: 10),
        _DetailGrid(weather: weather),
        if (hourlyForecasts.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionTitle(
            title: AppLocalizations.of(context).weatherHourlyForecast,
            icon: Icons.access_time_rounded,
          ),
          const SizedBox(height: 10),
          _HourlyForecastCard(forecasts: hourlyForecasts),
        ],
        if (dailyForecasts.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionTitle(
            title: AppLocalizations.of(context).weatherWeeklyForecast,
            icon: Icons.calendar_today_rounded,
          ),
          const SizedBox(height: 10),
          _DailyForecastList(forecasts: dailyForecasts),
        ],
        if (score != null) ...[
          const SizedBox(height: 20),
          _SectionTitle(title: l10n.scoreLabel, icon: Icons.star_rounded),
          const SizedBox(height: 10),
          _ScoreSection(
            score: score,
            pm10: weather.pm10,
            pm25: weather.pm25,
            o3: weather.o3,
            khaiValue: weather.khaiValue,
            khaiGrade: weather.khaiGrade,
          ),
        ],
      ],
    );
  }
}

class _ScoreSection extends StatelessWidget {
  const _ScoreSection({
    required this.score,
    this.pm10,
    this.pm25,
    this.o3,
    this.khaiValue,
    this.khaiGrade,
  });

  final ActivityScore score;
  final double? pm10;
  final double? pm25;
  final double? o3;
  final double? khaiValue;
  final int? khaiGrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;

    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: ScoreGauge(score: score.score, tier: score.tier),
              ),
              const SizedBox(height: 16),
              Text(
                _adviceFor(l10n, score.tier),
                style: TextStyle(
                  color: AppColors.body(brightness),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        if (pm10 != null ||
            pm25 != null ||
            o3 != null ||
            khaiValue != null) ...[
          const SizedBox(height: 16),
          _AirQualityCard(
            pm10: pm10,
            pm25: pm25,
            o3: o3,
            khaiValue: khaiValue,
            khaiGrade: khaiGrade,
          ),
        ],
        const SizedBox(height: 16),
        _ScoreSectionLabel(text: l10n.scoreBreakdownTitle),
        const SizedBox(height: 8),
        if (score.breakdown.total > 0)
          GlassCard(
            child: Column(
              children: [
                if (score.breakdown.rainDeduction > 0)
                  _BreakdownRow(
                    icon: Icons.umbrella_rounded,
                    iconColor: const Color(0xFF64B5F6),
                    label: l10n.scoreDeductionRain,
                    deduction: score.breakdown.rainDeduction,
                  ),
                if (score.breakdown.windDeduction > 0)
                  _BreakdownRow(
                    icon: Icons.air_rounded,
                    iconColor: const Color(0xFF80CBC4),
                    label: l10n.scoreDeductionWind,
                    deduction: score.breakdown.windDeduction,
                  ),
                if (score.breakdown.heatDeduction > 0)
                  _BreakdownRow(
                    icon: Icons.thermostat_rounded,
                    iconColor: const Color(0xFFEF9A9A),
                    label: l10n.scoreDeductionTemp,
                    deduction: score.breakdown.heatDeduction,
                  ),
                if (score.breakdown.dustDeduction > 0)
                  _BreakdownRow(
                    icon: Icons.masks_rounded,
                    iconColor: const Color(0xFFCE93D8),
                    label: l10n.scoreDeductionAir,
                    deduction: score.breakdown.dustDeduction,
                  ),
                if (score.breakdown.uvDeduction > 0)
                  _BreakdownRow(
                    icon: Icons.wb_sunny_outlined,
                    iconColor: const Color(0xFFFFB74D),
                    label: l10n.scoreDeductionUv,
                    deduction: score.breakdown.uvDeduction,
                    isLast: score.breakdown.ozoneDeduction == 0,
                  ),
                if (score.breakdown.ozoneDeduction > 0)
                  _BreakdownRow(
                    icon: Icons.blur_on_rounded,
                    iconColor: const Color(0xFFA5D6A7),
                    label: l10n.scoreDeductionOzone,
                    deduction: score.breakdown.ozoneDeduction,
                    isLast: true,
                  ),
              ],
            ),
          )
        else
          GlassCard(
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.scoreExcellent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.scoreNoDeduction,
                    style: TextStyle(
                      color: AppColors.title(brightness),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        GlassCard(
          backgroundColor: AppColors.glassWhite,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.gold,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.scoreInfo,
                  style: TextStyle(
                    color: AppColors.caption(brightness),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _adviceFor(AppLocalizations l10n, ScoreTier tier) {
    return switch (tier) {
      ScoreTier.excellent => l10n.scoreAdviceExcellent,
      ScoreTier.good => l10n.scoreAdviceGood,
      ScoreTier.fair => l10n.scoreAdviceFair,
      ScoreTier.poor => l10n.scoreAdvicePoor,
    };
  }
}

class _AirQualityCard extends StatelessWidget {
  const _AirQualityCard({
    this.pm10,
    this.pm25,
    this.o3,
    this.khaiValue,
    this.khaiGrade,
  });

  final double? pm10;
  final double? pm25;
  final double? o3;
  final double? khaiValue;
  final int? khaiGrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    final integratedGrade = _integratedGrade(l10n);
    final thresholdLabels = [
      l10n.airGradeGood,
      l10n.airGradeModerate,
      l10n.airGradeBad,
      l10n.airGradeVeryBad,
    ];
    final metrics = <_AirMetric>[
      if (pm10 != null)
        _AirMetric(
          title: l10n.weatherDustPm10,
          value: pm10!,
          unit: 'μg/m³',
          grade: _pm10Grade(l10n, pm10!),
          maxValue: 200,
          thresholdLabels: thresholdLabels,
        ),
      if (pm25 != null)
        _AirMetric(
          title: l10n.weatherDustPm25,
          value: pm25!,
          unit: 'μg/m³',
          grade: _pm25Grade(l10n, pm25!),
          maxValue: 100,
          thresholdLabels: thresholdLabels,
        ),
      if (o3 != null)
        _AirMetric(
          title: l10n.scoreDeductionOzone,
          value: o3!,
          unit: 'ppm',
          grade: _o3Grade(l10n, o3!),
          maxValue: 0.2,
          thresholdLabels: thresholdLabels,
          fractionDigits: 3,
        ),
      if (khaiValue != null || khaiGrade != null)
        _AirMetric(
          title: l10n.airQualityIntegrated,
          value: khaiValue ?? _khaiValueFromGrade(khaiGrade),
          unit: l10n.pointUnit,
          grade: integratedGrade,
          maxValue: 250,
          thresholdLabels: thresholdLabels,
        ),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.masks_rounded,
                color: Color(0xFFCE93D8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.airQualityTitle,
                style: TextStyle(
                  color: AppColors.title(brightness),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: integratedGrade.color.withAlpha(36),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: integratedGrade.color.withAlpha(100),
                  ),
                ),
                child: Text(
                  integratedGrade.label,
                  style: TextStyle(
                    color: integratedGrade.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...metrics.asMap().entries.map((entry) {
            final isLast = entry.key == metrics.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: _AirMetricBar(metric: entry.value),
            );
          }),
        ],
      ),
    );
  }

  _AirGrade _integratedGrade(AppLocalizations l10n) {
    if (khaiGrade != null) {
      return _khaiGrade(l10n, khaiGrade!);
    }
    if (pm25 != null) {
      return _pm25Grade(l10n, pm25!);
    }
    if (pm10 != null) {
      return _pm10Grade(l10n, pm10!);
    }
    if (o3 != null) {
      return _o3Grade(l10n, o3!);
    }
    return _AirGrade(l10n.airQualityUnknown, AppColors.textMuted);
  }

  double _khaiValueFromGrade(int? grade) {
    return switch (grade) {
      1 => 40,
      2 => 90,
      3 => 140,
      4 => 220,
      _ => 0,
    };
  }

  _AirGrade _pm10Grade(AppLocalizations l10n, double value) {
    if (value <= 30) {
      return _AirGrade(l10n.airGradeGood, const Color(0xFF4CAF50));
    }
    if (value <= 80) {
      return _AirGrade(l10n.airGradeModerate, const Color(0xFFFFC107));
    }
    if (value <= 150) {
      return _AirGrade(l10n.airGradeBad, const Color(0xFFFF7043));
    }
    return _AirGrade(l10n.airGradeVeryBad, const Color(0xFFE53935));
  }

  _AirGrade _pm25Grade(AppLocalizations l10n, double value) {
    if (value <= 15) {
      return _AirGrade(l10n.airGradeGood, const Color(0xFF4CAF50));
    }
    if (value <= 35) {
      return _AirGrade(l10n.airGradeModerate, const Color(0xFFFFC107));
    }
    if (value <= 75) {
      return _AirGrade(l10n.airGradeBad, const Color(0xFFFF7043));
    }
    return _AirGrade(l10n.airGradeVeryBad, const Color(0xFFE53935));
  }

  _AirGrade _o3Grade(AppLocalizations l10n, double value) {
    if (value <= 0.030) {
      return _AirGrade(l10n.airGradeGood, const Color(0xFF4CAF50));
    }
    if (value <= 0.090) {
      return _AirGrade(l10n.airGradeModerate, const Color(0xFFFFC107));
    }
    if (value <= 0.150) {
      return _AirGrade(l10n.airGradeBad, const Color(0xFFFF7043));
    }
    return _AirGrade(l10n.airGradeVeryBad, const Color(0xFFE53935));
  }

  _AirGrade _khaiGrade(AppLocalizations l10n, int value) {
    return switch (value) {
      1 => _AirGrade(l10n.airGradeGood, const Color(0xFF4CAF50)),
      2 => _AirGrade(l10n.airGradeModerate, const Color(0xFFFFC107)),
      3 => _AirGrade(l10n.airGradeBad, const Color(0xFFFF7043)),
      _ => _AirGrade(l10n.airGradeVeryBad, const Color(0xFFE53935)),
    };
  }
}

class _AirMetric {
  const _AirMetric({
    required this.title,
    required this.value,
    required this.unit,
    required this.grade,
    required this.maxValue,
    required this.thresholdLabels,
    this.fractionDigits = 0,
  });

  final String title;
  final double value;
  final String unit;
  final _AirGrade grade;
  final double maxValue;
  final List<String> thresholdLabels;
  final int fractionDigits;
}

class _AirMetricBar extends StatelessWidget {
  const _AirMetricBar({required this.metric});

  final _AirMetric metric;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final ratio = (metric.value / metric.maxValue).clamp(0.0, 1.0);
    final valueLabel = metric.fractionDigits == 0
        ? metric.value.round().toString()
        : metric.value.toStringAsFixed(metric.fractionDigits);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                metric.title,
                style: TextStyle(
                  color: AppColors.title(brightness),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: metric.grade.color.withAlpha(36),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                metric.grade.label,
                style: TextStyle(
                  color: metric.grade.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$valueLabel ${metric.unit}',
              style: TextStyle(
                color: AppColors.body(brightness),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final markerLeft = (ratio * constraints.maxWidth - 5).clamp(
              0.0,
              constraints.maxWidth - 10,
            );
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF4CAF50),
                          Color(0xFFFFC107),
                          Color(0xFFFF7043),
                          Color(0xFFE53935),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: markerLeft,
                    top: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white70),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: metric.thresholdLabels
              .map(
                (label) => Text(
                  label,
                  style: TextStyle(
                    color: AppColors.caption(brightness),
                    fontSize: 10,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _AirGrade {
  const _AirGrade(this.label, this.color);

  final String label;
  final Color color;
}

class _ScoreSectionLabel extends StatelessWidget {
  const _ScoreSectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Text(
      text,
      style: TextStyle(
        color: AppColors.body(brightness),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.deduction,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int deduction;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.title(brightness),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '-$deduction',
                style: const TextStyle(
                  color: AppColors.scorePoor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: AppColors.border(brightness), height: 1),
      ],
    );
  }
}

class _WeatherHeader extends ConsumerWidget {
  const _WeatherHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(weatherLocationNotifierProvider);
    final language = ref.watch(appLanguageNotifierProvider);
    final countdown = locationState.countdown;
    final isLocationSelected = locationState.location != null;
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppDateFormat.formatWithTime(
                      DateTime.now(),
                      language: language,
                    ),
                    style: AppTextStyles.pageDateTime.copyWith(
                      color: AppColors.body(brightness),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const LocationDropdown(),
                ],
              ),
            ),
            if (!isLocationSelected) const HeaderRefreshButton(),
          ],
        ),
        if (countdown != null) ...[
          const SizedBox(height: 6),
          _CountdownBanner(seconds: countdown),
        ],
      ],
    );
  }
}

class _CountdownBanner extends ConsumerWidget {
  const _CountdownBanner({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    return GestureDetector(
      onTap: () => ref.read(weatherLocationNotifierProvider.notifier).reset(),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 13,
            color: AppColors.caption(brightness),
          ),
          const SizedBox(width: 4),
          Text(
            l10n.weatherReturnCurrentLocation(seconds),
            style: TextStyle(
              color: AppColors.caption(brightness),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MainWeatherCard extends StatelessWidget {
  const _MainWeatherCard({required this.weather});

  final WeatherEntity weather;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    return HeroGlassCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppColors.caption(brightness),
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  weather.locationName,
                  style: TextStyle(
                    color: AppColors.caption(brightness),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.tempCelsius.round()}',
                          style: TextStyle(
                            color: AppColors.title(brightness),
                            fontSize: 76,
                            fontWeight: FontWeight.w200,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            '\u2103',
                            style: TextStyle(
                              color: AppColors.body(brightness),
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.weatherFeelsLike(
                        weather.feelsLikeCelsius.round().toString(),
                      ),
                      style: TextStyle(
                        color: AppColors.body(brightness),
                        fontSize: 14,
                      ),
                    ),
                    if (_hasPrecipitation(weather.precipitationAmountMm)) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.weatherPrecipitationAmount(
                          _formatPrecipitation(weather.precipitationAmountMm),
                        ),
                        style: TextStyle(
                          color: AppColors.body(brightness),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  PremiumWeatherIcon(
                    condition: weather.condition,
                    isNight: weather.isNight,
                    size: 86,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    WeatherIconMapper.localizedLabelFor(
                      context,
                      weather.condition,
                      isNight: weather.isNight,
                    ),
                    style: TextStyle(
                      color: AppColors.body(brightness),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.weather});

  final WeatherEntity weather;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DetailCard(
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFF64B5F6),
                label: l10n.weatherHumidityLabel,
                value: '${weather.humidity}%',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailCard(
                icon: Icons.air_rounded,
                iconColor: const Color(0xFF80CBC4),
                label: l10n.weatherWindSpeedLabel,
                value: '${weather.windSpeedMs.toStringAsFixed(1)}m/s',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DetailCard(
                icon: Icons.wb_sunny_outlined,
                iconColor: const Color(0xFFFFB74D),
                label: 'UV',
                value: _uvLabel(l10n, weather.uvIndex),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailCard(
                icon: Icons.umbrella_rounded,
                iconColor: const Color(0xFF90CAF9),
                label: l10n.weatherPrecipitationLabel,
                value: '${(weather.precipProbability * 100).round()}%',
              ),
            ),
          ],
        ),
        if (weather.pm10 != null || weather.pm25 != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (weather.pm10 != null)
                Expanded(
                  child: _DetailCard(
                    icon: Icons.masks_rounded,
                    iconColor: const Color(0xFFCE93D8),
                    label: l10n.weatherDustPm10,
                    value: '${weather.pm10!.round()}',
                  ),
                ),
              if (weather.pm10 != null && weather.pm25 != null)
                const SizedBox(width: 8),
              if (weather.pm25 != null)
                Expanded(
                  child: _DetailCard(
                    icon: Icons.blur_circular_rounded,
                    iconColor: const Color(0xFFEF9A9A),
                    label: l10n.weatherDustPm25,
                    value: '${weather.pm25!.round()}',
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  String _uvLabel(AppLocalizations l10n, int uvIndex) {
    if (uvIndex >= 11) return l10n.weatherUvVeryHigh(uvIndex);
    if (uvIndex >= 8) return l10n.weatherUvHigh(uvIndex);
    if (uvIndex >= 6) return l10n.weatherUvModerateHigh(uvIndex);
    if (uvIndex >= 3) return l10n.weatherUvModerate(uvIndex);
    return l10n.weatherUvLow(uvIndex);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      children: [
        Icon(icon, color: AppColors.body(brightness), size: 16),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: AppColors.body(brightness),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HourlyForecastCard extends StatelessWidget {
  const _HourlyForecastCard({required this.forecasts});

  final List<HourlyForecast> forecasts;

  @override
  Widget build(BuildContext context) {
    final limited = forecasts.take(24).toList();
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: SizedBox(
        height: 126,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: limited.length,
          separatorBuilder: (_, __) => const SizedBox(width: 2),
          itemBuilder: (context, index) {
            final forecast = limited[index];
            final forecastIsNight = _isNightByHour(forecast.time);
            return SizedBox(
              width: 52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${forecast.time.month}/${forecast.time.day}',
                    style: TextStyle(
                      color: AppColors.caption(brightness),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    l10n.weatherHour(
                      forecast.time.hour.toString().padLeft(2, '0'),
                    ),
                    style: TextStyle(
                      color: AppColors.body(brightness),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  PremiumWeatherIcon(
                    condition: forecast.condition,
                    isNight: forecastIsNight,
                    size: 34,
                  ),
                  Text(
                    '${forecast.tempCelsius.round()}\u2103',
                    style: TextStyle(
                      color: AppColors.title(brightness),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (forecast.precipitationAmountMm case final amount?
                      when amount > 0)
                    Text(
                      _formatPrecipitationAmount(amount),
                      maxLines: 1,
                      style: const TextStyle(
                        color: Color(0xFF64B5F6),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatPrecipitationAmount(double amount) {
    final value = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(1);
    return '$value mm';
  }
}

class _DailyForecastList extends ConsumerWidget {
  const _DailyForecastList({required this.forecasts});

  static const _probabilityOnlyDisplayThreshold = 40;

  final List<DailyForecast> forecasts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(appLanguageNotifierProvider);
    final brightness = Theme.of(context).brightness;
    return Column(
      children: forecasts.map((forecast) {
        final weekday = AppDateFormat.weekdayLabel(
          forecast.date,
          language: language,
        );
        final isToday = _isToday(forecast.date);
        final precipitationSummary = _dailyPrecipitationSummary(forecast);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 98,
                      child: Text(
                        isToday
                            ? l10n.weatherToday
                            : '${forecast.date.month}/${forecast.date.day} ($weekday)',
                        style: TextStyle(
                          color: isToday
                              ? AppColors.gold
                              : AppColors.body(brightness),
                          fontSize: 13,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (precipitationSummary != null) ...[
                      const Icon(
                        Icons.water_drop_rounded,
                        size: 12,
                        color: Color(0xFF64B5F6),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        precipitationSummary,
                        style: const TextStyle(
                          color: Color(0xFF64B5F6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${forecast.tempMin.round()}\u2103',
                      style: TextStyle(
                        color: AppColors.caption(brightness),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      ' ~ ',
                      style: TextStyle(
                        color: AppColors.caption(brightness),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${forecast.tempMax.round()}\u2103',
                      style: TextStyle(
                        color: AppColors.title(brightness),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DayPartForecastChip(
                        label: l10n.weatherAm,
                        condition: forecast.amCondition ?? forecast.condition,
                        temperature: forecast.amTempCelsius ?? forecast.tempMin,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DayPartForecastChip(
                        label: l10n.weatherPm,
                        condition: forecast.pmCondition ?? forecast.condition,
                        temperature: forecast.pmTempCelsius ?? forecast.tempMax,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  String? _dailyPrecipitationSummary(DailyForecast forecast) {
    final probability = (forecast.precipProbability * 100).round();
    final amount = forecast.expectedPrecipitationMm;
    final hasExpectedAmount = amount != null && amount > 0;
    if (hasExpectedAmount) {
      final amountLabel = _formatPrecipitation(amount);
      return probability > 0 ? '$probability% / $amountLabel' : amountLabel;
    }
    if (probability < _probabilityOnlyDisplayThreshold) {
      return null;
    }
    return '$probability%';
  }
}

class _DayPartForecastChip extends StatelessWidget {
  const _DayPartForecastChip({
    required this.label,
    required this.condition,
    required this.temperature,
  });

  final String label;
  final WeatherCondition condition;
  final double temperature;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha(18)
            : AppColors.mutedSurface(brightness).withAlpha(180),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(20)
              : AppColors.border(brightness),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.body(brightness),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          PremiumWeatherIcon(condition: condition, size: 22),
          const Spacer(),
          Text(
            '${temperature.round()}\u2103',
            style: TextStyle(
              color: AppColors.title(brightness),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.caption(brightness),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.title(brightness),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

bool _isNightByHour(DateTime time) {
  return time.hour < 6 || time.hour >= 19;
}

String _formatPrecipitation(double? amountMm) {
  if (amountMm == null || amountMm <= 0) {
    return '0mm';
  }
  if (amountMm < 1) {
    return '${amountMm.toStringAsFixed(1)}mm';
  }
  return '${amountMm.round()}mm';
}

bool _hasPrecipitation(double? amountMm) {
  return amountMm != null && amountMm > 0;
}
