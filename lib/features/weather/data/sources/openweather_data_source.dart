import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/weather_proxy_dio.dart';
import '../../domain/entities/weather_entity.dart';
import '../models/weather_response.dart';
import 'weather_data_source.dart';

class OpenWeatherDataSource implements WeatherDataSource {
  OpenWeatherDataSource()
    : _dio = WeatherProxyDio.create(WeatherProxyProvider.openWeather);

  static const int _maxHourlyForecasts = 12;
  static const int _maxDailyForecasts = 7;
  static const double _o3UgM3ToPpmDivisor = 1960;

  final Dio _dio;

  @override
  Future<WeatherResponse> fetchCurrent({
    required double lat,
    required double lon,
  }) async {
    try {
      final params = {'lat': lat, 'lon': lon, 'units': 'metric'};

      final responses = await Future.wait([
        _dio.get('/weather', queryParameters: params),
        _dio.get('/forecast', queryParameters: params),
        _dio.get('/air_pollution', queryParameters: params),
      ]);

      final currentData = responses[0].data as Map<String, dynamic>;
      final forecastData = responses[1].data as Map<String, dynamic>;
      final airData = responses[2].data as Map<String, dynamic>;

      final main = currentData['main'] as Map<String, dynamic>? ?? const {};
      final wind = currentData['wind'] as Map<String, dynamic>? ?? const {};
      final weatherList = currentData['weather'] as List<dynamic>? ?? const [];
      final currentWeather = weatherList.isNotEmpty
          ? weatherList.first as Map<String, dynamic>
          : const <String, dynamic>{};
      final weatherCode = currentWeather['id'] as int? ?? -1;
      final locationName = (currentData['name'] as String?)?.trim();

      final forecastList = forecastData['list'] as List<dynamic>? ?? const [];
      final airQuality = _parseAirQuality(airData);

      return WeatherResponse(
        tempCelsius: (main['temp'] as num?)?.toDouble() ?? 0,
        feelsLikeCelsius:
            (main['feels_like'] as num?)?.toDouble() ??
            (main['temp'] as num?)?.toDouble() ??
            0,
        condition: _mapOwmCode(weatherCode),
        windSpeedMs: (wind['speed'] as num?)?.toDouble() ?? 0,
        precipProbability: 0,
        uvIndex: 0,
        humidity: (main['humidity'] as num?)?.toInt() ?? 0,
        locationName: locationName == null || locationName.isEmpty
            ? 'Global'
            : locationName,
        pm10: airQuality.pm10,
        pm25: airQuality.pm25,
        o3: airQuality.o3Ppm,
        khaiValue: airQuality.openWeatherAqi?.toDouble(),
        khaiGrade: airQuality.openWeatherAqi,
        hourlyForecasts: _parseHourlyForecasts(forecastList),
        dailyForecasts: _parseDailyForecasts(forecastList),
      );
    } on DioException catch (error) {
      throw NetworkException('OpenWeather API error: ${error.message}');
    } catch (error) {
      if (error is AppException) rethrow;
      throw ParseException('OpenWeather response parse failed: $error');
    }
  }

  List<HourlyForecast> _parseHourlyForecasts(List<dynamic> forecastList) {
    final hourlyForecasts = <HourlyForecast>[];
    for (final raw in forecastList.take(_maxHourlyForecasts)) {
      final item = raw as Map<String, dynamic>;
      final dt = item['dt'] as int?;
      if (dt == null) continue;
      final itemMain = item['main'] as Map<String, dynamic>? ?? const {};
      final itemWeatherList = item['weather'] as List<dynamic>? ?? const [];
      final itemWeather = itemWeatherList.isNotEmpty
          ? itemWeatherList.first as Map<String, dynamic>
          : const <String, dynamic>{};
      final itemWind = item['wind'] as Map<String, dynamic>? ?? const {};
      hourlyForecasts.add(
        HourlyForecast(
          time: DateTime.fromMillisecondsSinceEpoch(dt * 1000),
          tempCelsius: (itemMain['temp'] as num?)?.toDouble() ?? 0,
          condition: _mapOwmCode((itemWeather['id'] as int?) ?? -1),
          precipitationAmountMm: _forecastPrecipitationAmount(item),
          precipProbability: ((item['pop'] as num?)?.toDouble() ?? 0) * 100,
          windSpeedMs: (itemWind['speed'] as num?)?.toDouble(),
        ),
      );
    }
    return hourlyForecasts;
  }

  double? _forecastPrecipitationAmount(Map<String, dynamic> item) {
    final rain = item['rain'] as Map<String, dynamic>?;
    final snow = item['snow'] as Map<String, dynamic>?;
    return (rain?['3h'] as num?)?.toDouble() ??
        (snow?['3h'] as num?)?.toDouble();
  }

  List<DailyForecast> _parseDailyForecasts(List<dynamic> forecastList) {
    final dailyMap = <String, List<Map<String, dynamic>>>{};
    for (final raw in forecastList) {
      final item = raw as Map<String, dynamic>;
      final dtTxt = (item['dt_txt'] as String?) ?? '';
      final dateKey = dtTxt.split(' ').first;
      if (dateKey.isEmpty) continue;
      dailyMap.putIfAbsent(dateKey, () => []).add(item);
    }

    final dailyForecasts = <DailyForecast>[];
    for (final entry in dailyMap.entries.take(_maxDailyForecasts)) {
      final items = entry.value;
      double tempMin = double.infinity;
      double tempMax = double.negativeInfinity;
      double totalPrecip = 0;
      int precipCount = 0;
      WeatherCondition? noonCondition;

      for (final item in items) {
        final itemMain = item['main'] as Map<String, dynamic>? ?? const {};
        final temp = (itemMain['temp'] as num?)?.toDouble() ?? 0;
        if (temp < tempMin) tempMin = temp;
        if (temp > tempMax) tempMax = temp;
        totalPrecip += (item['pop'] as num?)?.toDouble() ?? 0;
        precipCount++;

        final dtTxt = (item['dt_txt'] as String?) ?? '';
        if (dtTxt.contains('12:00')) {
          final weatherList = item['weather'] as List<dynamic>? ?? const [];
          if (weatherList.isNotEmpty) {
            noonCondition = _mapOwmCode(
              (weatherList.first as Map<String, dynamic>)['id'] as int? ?? -1,
            );
          }
        }
      }

      if (tempMin == double.infinity) continue;
      final firstWeatherList =
          items.first['weather'] as List<dynamic>? ?? const [];
      final fallbackCondition = firstWeatherList.isNotEmpty
          ? _mapOwmCode(
              (firstWeatherList.first as Map<String, dynamic>)['id'] as int? ??
                  -1,
            )
          : WeatherCondition.unknown;
      final avgPrecip = precipCount > 0 ? totalPrecip / precipCount : 0.0;

      dailyForecasts.add(
        DailyForecast(
          date: DateTime.parse(entry.key),
          tempMin: tempMin,
          tempMax: tempMax,
          condition: noonCondition ?? fallbackCondition,
          precipProbability: avgPrecip,
        ),
      );
    }
    return dailyForecasts;
  }

  _OpenWeatherAirQuality _parseAirQuality(Map<String, dynamic> data) {
    final list = data['list'] as List<dynamic>? ?? const [];
    if (list.isEmpty) return const _OpenWeatherAirQuality();

    final first = list.first as Map<String, dynamic>;
    final main = first['main'] as Map<String, dynamic>? ?? const {};
    final components = first['components'] as Map<String, dynamic>? ?? const {};
    final o3UgM3 = (components['o3'] as num?)?.toDouble();
    return _OpenWeatherAirQuality(
      openWeatherAqi: (main['aqi'] as num?)?.toInt(),
      pm10: (components['pm10'] as num?)?.toDouble(),
      pm25: (components['pm2_5'] as num?)?.toDouble(),
      o3Ppm: o3UgM3 == null ? null : o3UgM3 / _o3UgM3ToPpmDivisor,
    );
  }

  WeatherCondition _mapOwmCode(int code) {
    if (code >= 200 && code < 300) {
      if ((code >= 200 && code <= 202) || (code >= 230 && code <= 232)) {
        return WeatherCondition.rainThunder;
      }
      return WeatherCondition.thunderstorm;
    }
    if (code >= 300 && code < 400) return WeatherCondition.slightRain;
    if (code >= 500 && code < 600) {
      if (code == 500 || code == 520) return WeatherCondition.slightRain;
      if (code == 501 || code == 521) return WeatherCondition.rainy;
      if (code == 502 ||
          code == 503 ||
          code == 504 ||
          code == 522 ||
          code == 531) {
        return WeatherCondition.heavyRain;
      }
      if (code == 511) return WeatherCondition.sleet;
      return WeatherCondition.rainy;
    }
    if (code >= 600 && code < 700) {
      if (code == 600 || code == 620) return WeatherCondition.lightSnow;
      if (code == 611 ||
          code == 612 ||
          code == 613 ||
          code == 615 ||
          code == 616) {
        return WeatherCondition.sleet;
      }
      return WeatherCondition.snowy;
    }
    if (code >= 700 && code < 800) {
      if (code == 771 || code == 781) return WeatherCondition.windy;
      return WeatherCondition.hazy;
    }
    if (code == 800) return WeatherCondition.sunny;
    if (code == 801 || code == 802) return WeatherCondition.partlyCloudy;
    if (code > 802) return WeatherCondition.cloudy;
    return WeatherCondition.unknown;
  }
}

class _OpenWeatherAirQuality {
  const _OpenWeatherAirQuality({
    this.openWeatherAqi,
    this.pm10,
    this.pm25,
    this.o3Ppm,
  });

  final int? openWeatherAqi;
  final double? pm10;
  final double? pm25;
  final double? o3Ppm;
}
