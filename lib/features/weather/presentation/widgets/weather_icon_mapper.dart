import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/weather_entity.dart';

class WeatherVisualSpec {
  const WeatherVisualSpec({
    required this.label,
    required this.assetPath,
    required this.primaryColor,
    required this.accentColor,
    required this.surfaceTint,
    required this.widgetSymbol,
  });

  final String label;
  final String assetPath;
  final Color primaryColor;
  final Color accentColor;
  final Color surfaceTint;
  final String widgetSymbol;
}

class WeatherIconMapper {
  WeatherIconMapper._();

  static WeatherVisualSpec specFor(WeatherCondition condition, {bool isNight = false}) {
    return switch (condition) {
      WeatherCondition.sunny => isNight
          ? const WeatherVisualSpec(
              label: '맑은 밤',
              assetPath: AppAssets.weatherSunnyNight,
              primaryColor: Color(0xFFDFE8FF),
              accentColor: Color(0xFF9DB5FF),
              surfaceTint: Color(0x1A7A95D8),
              widgetSymbol: '☆',
            )
          : const WeatherVisualSpec(
              label: '맑음',
              assetPath: AppAssets.weatherSunny,
              primaryColor: Color(0xFFF6F8FF),
              accentColor: AppColors.gold,
              surfaceTint: Color(0x1FD9B24C),
              widgetSymbol: '☼',
            ),
      WeatherCondition.partlyCloudy => isNight
          ? const WeatherVisualSpec(
              label: '구름 조금 밤',
              assetPath: AppAssets.weatherPartlyCloudyNight,
              primaryColor: Color(0xFFE5EFF9),
              accentColor: Color(0xFF8FA3C6),
              surfaceTint: Color(0x1A6A7FB0),
              widgetSymbol: '◑',
            )
          : const WeatherVisualSpec(
              label: '구름 조금',
              assetPath: AppAssets.weatherPartlyCloudy,
              primaryColor: Color(0xFFF4F7FF),
              accentColor: AppColors.gold,
              surfaceTint: Color(0x1A9CB8FF),
              widgetSymbol: '◐',
            ),
      WeatherCondition.cloudy => const WeatherVisualSpec(
          label: '흐림',
          assetPath: AppAssets.weatherCloudy,
          primaryColor: Color(0xFFF2F5FC),
          accentColor: Color(0xFFB9C7E3),
          surfaceTint: Color(0x1A8FA3C6),
          widgetSymbol: '☁',
        ),
      WeatherCondition.hazy => isNight
          ? const WeatherVisualSpec(
              label: '안개 밤',
              assetPath: AppAssets.weatherHazyNight,
              primaryColor: Color(0xFFE8EEF7),
              accentColor: Color(0xFFB0BDD4),
              surfaceTint: Color(0x1A7A8FB5),
              widgetSymbol: '≋',
            )
          : const WeatherVisualSpec(
              label: '안개',
              assetPath: AppAssets.weatherHazy,
              primaryColor: Color(0xFFF3F5F8),
              accentColor: Color(0xFFD5DFEE),
              surfaceTint: Color(0x1A96A8BE),
              widgetSymbol: '≋',
            ),
      WeatherCondition.windy => const WeatherVisualSpec(
          label: '바람',
          assetPath: AppAssets.weatherWindy,
          primaryColor: Color(0xFFF0F5FA),
          accentColor: Color(0xFFB4D1E8),
          surfaceTint: Color(0x1A7EAACC),
          widgetSymbol: '≈',
        ),
      WeatherCondition.slightRain => const WeatherVisualSpec(
          label: '약한 비',
          assetPath: AppAssets.weatherSlightRain,
          primaryColor: Color(0xFFF4F8FF),
          accentColor: Color(0xFF9EC6FF),
          surfaceTint: Color(0x1A87B5E8),
          widgetSymbol: '☂',
        ),
      WeatherCondition.rainy => const WeatherVisualSpec(
          label: '비',
          assetPath: AppAssets.weatherRain,
          primaryColor: Color(0xFFF4F8FF),
          accentColor: Color(0xFF89B8FF),
          surfaceTint: Color(0x1A71A9FF),
          widgetSymbol: '☂',
        ),
      WeatherCondition.heavyRain => const WeatherVisualSpec(
          label: '강한 비',
          assetPath: AppAssets.weatherHeavyRain,
          primaryColor: Color(0xFFF3F7FF),
          accentColor: Color(0xFF5E8DFF),
          surfaceTint: Color(0x1A4D79E2),
          widgetSymbol: '☔',
        ),
      WeatherCondition.thunderstorm => const WeatherVisualSpec(
          label: '뇌우',
          assetPath: AppAssets.weatherThunderstorm,
          primaryColor: Color(0xFFF6F8FF),
          accentColor: AppColors.gold,
          surfaceTint: Color(0x1A6B75B8),
          widgetSymbol: '⚡',
        ),
      WeatherCondition.rainThunder => const WeatherVisualSpec(
          label: '비와 천둥',
          assetPath: AppAssets.weatherRainThunder,
          primaryColor: Color(0xFFF5F8FF),
          accentColor: Color(0xFF7CA0FF),
          surfaceTint: Color(0x1A5A7FE2),
          widgetSymbol: '⛈',
        ),
      WeatherCondition.lightSnow => const WeatherVisualSpec(
          label: '약한 눈',
          assetPath: AppAssets.weatherLightSnow,
          primaryColor: Color(0xFFF8FBFF),
          accentColor: Color(0xFFDAE9FF),
          surfaceTint: Color(0x1AB4D1EE),
          widgetSymbol: '❅',
        ),
      WeatherCondition.snowy => const WeatherVisualSpec(
          label: '눈',
          assetPath: AppAssets.weatherSnow,
          primaryColor: Color(0xFFF8FBFF),
          accentColor: Color(0xFFC9E2FF),
          surfaceTint: Color(0x1A9EC7FF),
          widgetSymbol: '❄',
        ),
      WeatherCondition.sleet => const WeatherVisualSpec(
          label: '진눈깨비',
          assetPath: AppAssets.weatherSleet,
          primaryColor: Color(0xFFF4F8FC),
          accentColor: Color(0xFFB8D5F0),
          surfaceTint: Color(0x1A8FB4D8),
          widgetSymbol: '❆',
        ),
      WeatherCondition.hot => isNight
          ? const WeatherVisualSpec(
              label: '열대야',
              assetPath: AppAssets.weatherHotNight,
              primaryColor: Color(0xFFFFEEDD),
              accentColor: Color(0xFFFFB84A),
              surfaceTint: Color(0x1FD97D1F),
              widgetSymbol: '🌙',
            )
          : const WeatherVisualSpec(
              label: '폭염',
              assetPath: AppAssets.weatherHot,
              primaryColor: Color(0xFFFFF6E8),
              accentColor: Color(0xFFFFB84A),
              surfaceTint: Color(0x1FD98A2C),
              widgetSymbol: '🔥',
            ),
      WeatherCondition.coldWave => const WeatherVisualSpec(
          label: '한파',
          assetPath: AppAssets.weatherColdWave,
          primaryColor: Color(0xFFF0F7FF),
          accentColor: Color(0xFF7AAFFF),
          surfaceTint: Color(0x1F4D7FCF),
          widgetSymbol: '🥶',
        ),
      WeatherCondition.unknown => const WeatherVisualSpec(
          label: '정보 없음',
          assetPath: AppAssets.weatherUnknown,
          primaryColor: Color(0xFFE7EDF7),
          accentColor: Color(0xFFB6C1D8),
          surfaceTint: Color(0x1A7C8DA9),
          widgetSymbol: '•',
        ),
    };
  }

  static String labelFor(WeatherCondition condition, {bool isNight = false}) =>
      specFor(condition, isNight: isNight).label;

  static Color colorFor(WeatherCondition condition, {bool isNight = false}) =>
      specFor(condition, isNight: isNight).primaryColor;

  static String widgetSymbolFor(WeatherCondition condition, {bool isNight = false}) =>
      specFor(condition, isNight: isNight).widgetSymbol;

  static String assetFor(WeatherCondition condition, {bool isNight = false}) =>
      specFor(condition, isNight: isNight).assetPath;
}
