import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/weather/domain/entities/weather_entity.dart';

class WeatherCacheStore {
  WeatherCacheStore._();

  static const _cacheKey = 'last_known_good_weather';

  static Future<void> save(WeatherEntity weather) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(_toJson(weather)));
  }

  static Future<WeatherEntity?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached == null || cached.isEmpty) {
      return null;
    }

    try {
      return _fromJson(jsonDecode(cached) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _toJson(WeatherEntity weather) {
    return {
      'tempCelsius': weather.tempCelsius,
      'feelsLikeCelsius': weather.feelsLikeCelsius,
      'condition': weather.condition.name,
      'windSpeedMs': weather.windSpeedMs,
      'precipProbability': weather.precipProbability,
      'precipitationAmountMm': weather.precipitationAmountMm,
      'uvIndex': weather.uvIndex,
      'humidity': weather.humidity,
      'observedAt': weather.observedAt.toIso8601String(),
      'locationName': weather.locationName,
      'pm10': weather.pm10,
      'pm25': weather.pm25,
      'o3': weather.o3,
      'khaiValue': weather.khaiValue,
      'khaiGrade': weather.khaiGrade,
      'isNight': weather.isNight,
      'hourlyForecasts': weather.hourlyForecasts
          .map(
            (forecast) => {
              'time': forecast.time.toIso8601String(),
              'tempCelsius': forecast.tempCelsius,
              'condition': forecast.condition.name,
            },
          )
          .toList(growable: false),
      'dailyForecasts': weather.dailyForecasts
          .map(
            (forecast) => {
              'date': forecast.date.toIso8601String(),
              'tempMin': forecast.tempMin,
              'tempMax': forecast.tempMax,
              'condition': forecast.condition.name,
              'precipProbability': forecast.precipProbability,
              'expectedPrecipitationMm': forecast.expectedPrecipitationMm,
              'amCondition': forecast.amCondition?.name,
              'pmCondition': forecast.pmCondition?.name,
              'amTempCelsius': forecast.amTempCelsius,
              'pmTempCelsius': forecast.pmTempCelsius,
            },
          )
          .toList(growable: false),
    };
  }

  static WeatherEntity _fromJson(Map<String, dynamic> json) {
    WeatherCondition parseCondition(String? raw) {
      return WeatherCondition.values.firstWhere(
        (condition) => condition.name == raw,
        orElse: () => WeatherCondition.unknown,
      );
    }

    final hourlyForecasts =
        (json['hourlyForecasts'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(
              (forecast) => HourlyForecast(
                time: DateTime.parse(forecast['time'] as String),
                tempCelsius: (forecast['tempCelsius'] as num).toDouble(),
                condition: parseCondition(forecast['condition'] as String?),
              ),
            )
            .toList(growable: false);

    final dailyForecasts =
        (json['dailyForecasts'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(
              (forecast) => DailyForecast(
                date: DateTime.parse(forecast['date'] as String),
                tempMin: (forecast['tempMin'] as num).toDouble(),
                tempMax: (forecast['tempMax'] as num).toDouble(),
                condition: parseCondition(forecast['condition'] as String?),
                precipProbability: (forecast['precipProbability'] as num)
                    .toDouble(),
                expectedPrecipitationMm:
                    (forecast['expectedPrecipitationMm'] as num?)?.toDouble(),
                amCondition: parseNullableCondition(
                  forecast['amCondition'] as String?,
                ),
                pmCondition: parseNullableCondition(
                  forecast['pmCondition'] as String?,
                ),
                amTempCelsius: (forecast['amTempCelsius'] as num?)?.toDouble(),
                pmTempCelsius: (forecast['pmTempCelsius'] as num?)?.toDouble(),
              ),
            )
            .toList(growable: false);

    return WeatherEntity(
      tempCelsius: (json['tempCelsius'] as num).toDouble(),
      feelsLikeCelsius: (json['feelsLikeCelsius'] as num).toDouble(),
      condition: parseCondition(json['condition'] as String?),
      windSpeedMs: (json['windSpeedMs'] as num).toDouble(),
      precipProbability: (json['precipProbability'] as num).toDouble(),
      precipitationAmountMm: (json['precipitationAmountMm'] as num?)
          ?.toDouble(),
      uvIndex: json['uvIndex'] as int,
      humidity: json['humidity'] as int,
      observedAt: DateTime.parse(json['observedAt'] as String),
      locationName: json['locationName'] as String,
      pm10: (json['pm10'] as num?)?.toDouble(),
      pm25: (json['pm25'] as num?)?.toDouble(),
      o3: (json['o3'] as num?)?.toDouble(),
      khaiValue: (json['khaiValue'] as num?)?.toDouble(),
      khaiGrade: json['khaiGrade'] as int?,
      isNight: json['isNight'] as bool? ?? false,
      hourlyForecasts: hourlyForecasts,
      dailyForecasts: dailyForecasts,
    );
  }

  static WeatherCondition? parseNullableCondition(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return WeatherCondition.values.firstWhere(
      (condition) => condition.name == raw,
      orElse: () => WeatherCondition.unknown,
    );
  }
}
