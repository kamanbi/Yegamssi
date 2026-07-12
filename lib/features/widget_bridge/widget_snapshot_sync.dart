import 'package:flutter/foundation.dart';

import '../../core/utils/date_format_helper.dart';
import '../../core/locale/country_code.dart';
import '../fortune/domain/entities/fortune_result.dart';
import '../fortune/domain/entities/oheng.dart';
import '../score/domain/entities/activity_score.dart';
import '../weather/domain/entities/weather_entity.dart';
import '../weather/presentation/widgets/weather_icon_mapper.dart';
import 'widget_data_writer.dart';

class WidgetSnapshotPayload {
  const WidgetSnapshotPayload({
    required this.weather,
    required this.score,
    required this.latitude,
    required this.longitude,
    required this.language,
    required this.country,
    required this.updatedAt,
    this.fortune,
  });

  final WeatherEntity weather;
  final ActivityScore score;
  final double latitude;
  final double longitude;
  final AppLanguage language;
  final CountryCode country;
  final DateTime updatedAt;
  final FortuneResult? fortune;
}

Future<void> syncWidgetPayload(WidgetSnapshotPayload payload) {
  final weather = payload.weather;
  final isNight = weather.isNight;
  final conditionKey = widgetConditionKeyFor(weather.condition, isNight);
  final fortuneSymbol = widgetFortuneSymbolFor(payload.fortune);
  debugPrint(
    '[WidgetRefresh][${payload.updatedAt.toIso8601String()}] weather=$conditionKey'
    ' temp=${weather.tempCelsius.round()}'
    ' outdoorScore=${payload.score.score}'
    ' fortuneArrow=$fortuneSymbol',
  );
  return WidgetDataWriter.update(
    weatherCondition: conditionKey,
    weatherSymbol: WeatherIconMapper.widgetSymbolFor(
      weather.condition,
      isNight: isNight,
    ),
    temperatureCelsius: weather.tempCelsius.round(),
    feelsLikeCelsius: weather.feelsLikeCelsius.round(),
    fortuneSymbol: fortuneSymbol,
    score: payload.score.score,
    dateLabel: AppDateFormat.widgetDate(
      payload.updatedAt,
      language: payload.language,
    ),
    timeLabel: AppDateFormat.widgetTime(
      payload.updatedAt,
      language: payload.language,
    ),
    language: payload.language.name,
    countryIso: payload.country.isoCode,
    latitude: payload.latitude,
    longitude: payload.longitude,
  );
}

Future<void> syncWidgetSnapshot({
  required WeatherEntity weather,
  required ActivityScore score,
  required double latitude,
  required double longitude,
  required AppLanguage language,
  required CountryCode country,
  FortuneResult? fortune,
}) {
  return syncWidgetPayload(
    WidgetSnapshotPayload(
      weather: weather,
      score: score,
      latitude: latitude,
      longitude: longitude,
      language: language,
      country: country,
      fortune: fortune,
      updatedAt: DateTime.now(),
    ),
  );
}

String widgetConditionKeyFor(WeatherCondition condition, bool isNight) {
  const nightVariants = {
    WeatherCondition.sunny,
    WeatherCondition.partlyCloudy,
    WeatherCondition.cloudy,
    WeatherCondition.hazy,
    WeatherCondition.hot,
  };
  if (isNight && nightVariants.contains(condition)) {
    return '${condition.name}_night';
  }
  return condition.name;
}

String widgetFortuneSymbolFor(FortuneResult? fortune) {
  final overallScore = fortune?.scores[FortuneCategory.overall] ?? 55;
  if (overallScore >= 75) return '\u2B06';
  if (overallScore >= 45) return '\u27A1';
  return '\u2B07';
}
