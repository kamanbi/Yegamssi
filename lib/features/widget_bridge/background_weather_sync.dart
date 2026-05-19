import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/storage/location_cache_store.dart';
import '../../core/storage/weather_cache_store.dart';
import '../../core/storage/widget_cache.dart';
import '../../core/utils/date_format_helper.dart';
import '../score/domain/calculators/kr_score_calculator.dart';
import '../weather/data/sources/fallback_weather_data_source.dart';
import '../weather/data/sources/kma_data_source.dart';
import '../weather/domain/entities/weather_entity.dart';
import '../weather/presentation/widgets/weather_icon_mapper.dart';
import 'widget_data_writer.dart';

const String kBackgroundWeatherSyncTask = 'backgroundWeatherSync';

const String _kBgLastAttempt = 'bg_last_attempt';
const String _kBgLastSuccess = 'bg_last_success';
const String _kBgLastError = 'bg_last_error';
const String _kBgLastScore = 'bg_last_score';
const String _kBgLastCondition = 'bg_last_condition';
const String _kBgLastTemperature = 'bg_last_temperature';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    await _recordAttempt();

    try {
      await dotenv.load();

      final position = await LocationCacheStore.load();
      if (position == null) {
        await _logError('no_location');
        return true;
      }

      final dataSource = FallbackWeatherDataSource([KmaDataSource()]);
      final response = await dataSource.fetchCurrent(
        lat: position.lat,
        lon: position.lon,
      );
      final cachedWeather = await WeatherCacheStore.load();
      final weather = _mergeBackgroundWeatherSnapshot(
        nextWeather: response.toEntity(),
        cachedWeather: cachedWeather,
      );
      final score = const KrScoreCalculator().calculate(weather);
      final fortuneSymbol =
          await HomeWidget.getWidgetData<String>(
            WidgetCacheKeys.fortuneSymbol,
          ) ??
          '\u27A1';

      await WeatherCacheStore.save(weather);

      final now = DateTime.now();
      final isNight = _isNightByHour(now);
      final weatherConditionKey = _widgetConditionKey(
        weather.condition,
        isNight,
      );
      await WidgetDataWriter.update(
        weatherCondition: weatherConditionKey,
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
        latitude: position.lat,
        longitude: position.lon,
      );

      await _recordSuccess(
        score: score.score,
        weatherConditionKey: weatherConditionKey,
        temperatureCelsius: weather.tempCelsius.round(),
      );
    } catch (error, stackTrace) {
      await _logError('${error.runtimeType}: $error\n$stackTrace');
      return true;
    }
    return true;
  });
}

WeatherEntity _mergeBackgroundWeatherSnapshot({
  required WeatherEntity nextWeather,
  WeatherEntity? cachedWeather,
}) {
  return nextWeather.copyWith(
    pm10: nextWeather.pm10 ?? cachedWeather?.pm10,
    pm25: nextWeather.pm25 ?? cachedWeather?.pm25,
    o3: nextWeather.o3 ?? cachedWeather?.o3,
    khaiValue: nextWeather.khaiValue ?? cachedWeather?.khaiValue,
    khaiGrade: nextWeather.khaiGrade ?? cachedWeather?.khaiGrade,
    hourlyForecasts: nextWeather.hourlyForecasts.isEmpty
        ? (cachedWeather?.hourlyForecasts ?? nextWeather.hourlyForecasts)
        : nextWeather.hourlyForecasts,
    dailyForecasts: nextWeather.dailyForecasts.isEmpty
        ? (cachedWeather?.dailyForecasts ?? nextWeather.dailyForecasts)
        : nextWeather.dailyForecasts,
  );
}

Future<void> _recordAttempt() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBgLastAttempt, DateTime.now().toIso8601String());
  } catch (_) {}
}

Future<void> _recordSuccess({
  required int score,
  required String weatherConditionKey,
  required int temperatureCelsius,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBgLastSuccess, DateTime.now().toIso8601String());
    await prefs.setInt(_kBgLastScore, score);
    await prefs.setString(_kBgLastCondition, weatherConditionKey);
    await prefs.setInt(_kBgLastTemperature, temperatureCelsius);
    await prefs.remove(_kBgLastError);
  } catch (_) {}
}

Future<void> _logError(String message) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBgLastError, message);
  } catch (_) {}
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
