import 'package:flutter/foundation.dart';

import '../../core/utils/date_format_helper.dart';
import '../fortune/domain/entities/fortune_result.dart';
import '../fortune/domain/entities/oheng.dart';
import '../score/domain/entities/activity_score.dart';
import '../weather/domain/entities/weather_entity.dart';
import '../weather/presentation/widgets/weather_icon_mapper.dart';
import 'widget_data_writer.dart';

Future<void> syncWidgetSnapshot({
  required WeatherEntity weather,
  required ActivityScore score,
  required double latitude,
  required double longitude,
  FortuneResult? fortune,
}) {
  final now = DateTime.now();
  final isNight = _isNightByHour(now);

  final conditionKey = _widgetConditionKey(weather.condition, isNight);
  final fortuneSymbol = widgetFortuneSymbolFor(fortune);
  debugPrint(
    '[Widget] sync condition=$conditionKey'
    ' temp=${weather.tempCelsius.round()}'
    ' score=${score.score}'
    ' fortune=$fortuneSymbol',
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
    score: score.score,
    dateLabel: AppDateFormat.widgetDate(now),
    timeLabel: AppDateFormat.widgetTime(now),
    latitude: latitude,
    longitude: longitude,
  );
}

bool _isNightByHour(DateTime time) {
  return time.hour < 6 || time.hour >= 20;
}

String _widgetConditionKey(WeatherCondition condition, bool isNight) {
  const nightVariants = {
    WeatherCondition.sunny,
    WeatherCondition.partlyCloudy,
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
