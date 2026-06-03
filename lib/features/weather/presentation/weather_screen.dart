import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/glassmorphism.dart';
import '../../../core/utils/date_format_helper.dart';
import '../../../core/widgets/header_refresh_button.dart';
import '../../../l10n/app_localizations.dart';
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            l10n.weatherLoading,
            style: const TextStyle(color: AppColors.textSecondary),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Colors.white54,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.weatherErrorTitle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.textMuted,
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

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({required this.weather});

  final WeatherEntity weather;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        const _WeatherHeader(),
        const SizedBox(height: 16),
        _MainWeatherCard(weather: weather),
        const SizedBox(height: 10),
        _DetailGrid(weather: weather),
        if (weather.hourlyForecasts.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionTitle(
            title: AppLocalizations.of(context).weatherHourlyForecast,
            icon: Icons.access_time_rounded,
          ),
          const SizedBox(height: 10),
          _HourlyForecastCard(forecasts: weather.hourlyForecasts),
        ],
        if (weather.dailyForecasts.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionTitle(
            title: AppLocalizations.of(context).weatherWeeklyForecast,
            icon: Icons.calendar_today_rounded,
          ),
          const SizedBox(height: 10),
          _DailyForecastList(forecasts: weather.dailyForecasts),
        ],
      ],
    );
  }
}

class _WeatherHeader extends ConsumerWidget {
  const _WeatherHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(weatherLocationNotifierProvider);
    final countdown = locationState.countdown;
    final isLocationSelected = locationState.location != null;

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
                    AppDateFormat.format(DateTime.now()),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
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
    return GestureDetector(
      onTap: () => ref.read(weatherLocationNotifierProvider.notifier).reset(),
      child: Row(
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 13,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.weatherReturnCurrentLocation(seconds),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
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
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.textMuted,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  weather.locationName,
                  style: const TextStyle(
                    color: AppColors.textMuted,
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
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 76,
                            fontWeight: FontWeight.w200,
                            height: 1,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            '°C',
                            style: TextStyle(
                              color: AppColors.textSecondary,
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
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (_hasPrecipitation(weather.precipitationAmountMm)) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.weatherPrecipitationAmount(
                          _formatPrecipitation(weather.precipitationAmountMm),
                        ),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
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
                    isNight: _isNightByHour(DateTime.now()),
                    size: 86,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    WeatherIconMapper.localizedLabelFor(
                      context,
                      weather.condition,
                      isNight: _isNightByHour(DateTime.now()),
                    ),
                    style: TextStyle(
                      color: WeatherIconMapper.colorFor(
                        weather.condition,
                        isNight: _isNightByHour(DateTime.now()),
                      ),
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
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
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
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: SizedBox(
        height: 108,
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
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    l10n.weatherHour(
                      forecast.time.hour.toString().padLeft(2, '0'),
                    ),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
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
                    '${forecast.tempCelsius.round()}°',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DailyForecastList extends StatelessWidget {
  const _DailyForecastList({required this.forecasts});

  final List<DailyForecast> forecasts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: forecasts.map((forecast) {
        final weekday = AppDateFormat.weekdayLabel(forecast.date);
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
                              : AppColors.textSecondary,
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
                      '${forecast.tempMin.round()}°',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const Text(
                      ' ~ ',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${forecast.tempMax.round()}°',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
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
    if (probability <= 0 && (amount == null || amount <= 0)) {
      return null;
    }
    if (amount == null || amount <= 0) {
      return '$probability%';
    }
    return '$probability% · ${_formatPrecipitation(amount)}';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          PremiumWeatherIcon(condition: condition, size: 22),
          const Spacer(),
          Text(
            '${temperature.round()}°',
            style: const TextStyle(
              color: AppColors.textPrimary,
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
              style: const TextStyle(
                color: AppColors.textMuted,
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
            style: const TextStyle(
              color: AppColors.textPrimary,
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
  return time.hour < 6 || time.hour >= 20;
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
