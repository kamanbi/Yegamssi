import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/weather_entity.dart';
import '../models/weather_response.dart';
import 'weather_data_source.dart';

/// NOAA/NWS API 구현체 — 미국 전용 (키 불필요)
class NoaaDataSource implements WeatherDataSource {
  NoaaDataSource()
      : _dio = DioClient.create(baseUrl: AppConfig.noaaBaseUrl);

  final Dio _dio;

  @override
  Future<WeatherResponse> fetchCurrent({
    required double lat,
    required double lon,
  }) async {
    try {
      const headers = {'User-Agent': 'yegamssi-app'};
      final pointResponse = await _dio.get(
        '/points/$lat,$lon',
        options: Options(headers: headers),
      );

      final pointData = pointResponse.data as Map<String, dynamic>;
      final properties =
          pointData['properties'] as Map<String, dynamic>? ?? const {};
      final forecastHourlyUrl = properties['forecastHourly'] as String?;
      final forecastUrl = properties['forecast'] as String?;
      final relativeLocation =
          properties['relativeLocation'] as Map<String, dynamic>? ?? const {};
      final relativeLocationProperties =
          relativeLocation['properties'] as Map<String, dynamic>? ?? const {};

      if (forecastHourlyUrl == null || forecastHourlyUrl.isEmpty) {
        throw const ParseException('NOAA forecastHourly URL이 없습니다');
      }

      // 시간별 + 일별 예보 병렬 요청
      final opts = Options(headers: headers);
      final responses = await Future.wait([
        _dio.get(forecastHourlyUrl, options: opts),
        if (forecastUrl != null && forecastUrl.isNotEmpty)
          _dio.get(forecastUrl, options: opts),
      ]);

      final hourlyData = responses[0].data as Map<String, dynamic>;
      final hourlyProps =
          hourlyData['properties'] as Map<String, dynamic>? ?? const {};
      final hourlyPeriods =
          hourlyProps['periods'] as List<dynamic>? ?? const [];

      if (hourlyPeriods.isEmpty) {
        throw const ParseException('NOAA forecast periods가 비어 있습니다');
      }

      // ── 현재 날씨 (첫 번째 시간 슬롯) ──────────────────────────
      final current = hourlyPeriods.first as Map<String, dynamic>;
      final temperature = (current['temperature'] as num?)?.toDouble() ?? 0;
      final temperatureUnit = (current['temperatureUnit'] as String?) ?? 'F';
      final windSpeedText = (current['windSpeed'] as String?) ?? '0 mph';
      final shortForecast = (current['shortForecast'] as String?) ?? '';
      final humidityMap =
          current['relativeHumidity'] as Map<String, dynamic>? ?? const {};
      final precipMap =
          current['probabilityOfPrecipitation'] as Map<String, dynamic>? ??
          const {};

      final city = relativeLocationProperties['city'] as String?;
      final state = relativeLocationProperties['state'] as String?;
      final locationName = [
        if (city != null && city.isNotEmpty) city,
        if (state != null && state.isNotEmpty) state,
      ].join(', ');

      // ── 시간별 예보 (다음 12시간) ────────────────────────────────
      final hourlyForecasts = <HourlyForecast>[];
      for (final raw in hourlyPeriods.skip(1).take(12)) {
        final p = raw as Map<String, dynamic>;
        final startTimeStr = p['startTime'] as String?;
        if (startTimeStr == null) continue;
        final t = (p['temperature'] as num?)?.toDouble() ?? 0;
        final unit = (p['temperatureUnit'] as String?) ?? 'F';
        hourlyForecasts.add(
          HourlyForecast(
            time: DateTime.parse(startTimeStr),
            tempCelsius: _toCelsius(t, unit),
            condition: _mapForecast((p['shortForecast'] as String?) ?? ''),
          ),
        );
      }

      // ── 일별 예보 (7일, 낮/밤 쌍으로 묶기) ────────────────────
      final dailyForecasts = <DailyForecast>[];
      if (responses.length > 1) {
        final dailyData = responses[1].data as Map<String, dynamic>;
        final dailyProps =
            dailyData['properties'] as Map<String, dynamic>? ?? const {};
        final dailyPeriods =
            dailyProps['periods'] as List<dynamic>? ?? const [];

        var i = 0;
        while (i < dailyPeriods.length && dailyForecasts.length < 7) {
          final p = dailyPeriods[i] as Map<String, dynamic>;
          final isDaytime = (p['isDaytime'] as bool?) ?? true;

          if (!isDaytime) {
            // 첫 기간이 밤이면 건너뜀
            i++;
            continue;
          }

          final dayTemp =
              _toCelsius(
                (p['temperature'] as num?)?.toDouble() ?? 0,
                (p['temperatureUnit'] as String?) ?? 'F',
              );
          final dayForecast = (p['shortForecast'] as String?) ?? '';
          final dayPrecipMap =
              p['probabilityOfPrecipitation'] as Map<String, dynamic>? ??
              const {};
          final precipProb =
              ((dayPrecipMap['value'] as num?)?.toDouble() ?? 0) / 100;
          final startTimeStr = p['startTime'] as String?;
          if (startTimeStr == null) {
            i++;
            continue;
          }

          // 다음 기간(밤)에서 최저기온 추출
          double nightTemp = dayTemp - 10; // fallback
          WeatherCondition? nightCondition;
          if (i + 1 < dailyPeriods.length) {
            final n = dailyPeriods[i + 1] as Map<String, dynamic>;
            final isNextNight = !((n['isDaytime'] as bool?) ?? true);
            if (isNextNight) {
              nightTemp = _toCelsius(
                (n['temperature'] as num?)?.toDouble() ?? 0,
                (n['temperatureUnit'] as String?) ?? 'F',
              );
              nightCondition =
                  _mapForecast((n['shortForecast'] as String?) ?? '');
            }
          }

          dailyForecasts.add(
            DailyForecast(
              date: DateTime.parse(startTimeStr),
              tempMin: nightTemp,
              tempMax: dayTemp,
              condition: _mapForecast(dayForecast),
              precipProbability: precipProb,
              amCondition: _mapForecast(dayForecast),
              pmCondition: nightCondition,
            ),
          );
          i += 2; // 낮+밤 한 쌍 처리
        }
      }

      return WeatherResponse(
        tempCelsius: _toCelsius(temperature, temperatureUnit),
        feelsLikeCelsius: _toCelsius(temperature, temperatureUnit),
        condition: _mapForecast(shortForecast),
        windSpeedMs: _parseMphToMs(windSpeedText),
        precipProbability:
            ((precipMap['value'] as num?)?.toDouble() ?? 0) / 100,
        uvIndex: 0,
        humidity: (humidityMap['value'] as num?)?.round() ?? 0,
        locationName: locationName.isEmpty ? 'United States' : locationName,
        hourlyForecasts: hourlyForecasts,
        dailyForecasts: dailyForecasts,
      );
    } on DioException catch (error) {
      throw NetworkException('NOAA API 오류: ${error.message}');
    } catch (error) {
      if (error is AppException) rethrow;
      throw ParseException('NOAA 응답 파싱 실패: $error');
    }
  }

  double _toCelsius(double temperature, String unit) {
    if (unit.toUpperCase() == 'C') return temperature;
    return (temperature - 32) * 5 / 9;
  }

  double _parseMphToMs(String windSpeedText) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(windSpeedText);
    final mph = double.tryParse(match?.group(1) ?? '0') ?? 0;
    return mph * 0.44704;
  }

  WeatherCondition _mapForecast(String forecast) {
    final n = forecast.toLowerCase();
    // 비+천둥 우선 (예: "rain and thunderstorms")
    final hasThunder = n.contains('thunder');
    final hasRain = n.contains('rain') || n.contains('shower');
    final hasHeavy = n.contains('heavy');
    if (hasThunder && hasRain) return WeatherCondition.rainThunder;
    if (hasThunder) return WeatherCondition.thunderstorm;
    // 진눈깨비 / 싸락눈
    if (n.contains('sleet') ||
        (n.contains('rain') && n.contains('snow')) ||
        n.contains('wintry mix')) {
      return WeatherCondition.sleet;
    }
    if (n.contains('snow') || n.contains('flurr') || n.contains('blizzard')) {
      if (hasHeavy || n.contains('blizzard')) return WeatherCondition.snowy;
      if (n.contains('light') || n.contains('flurr')) {
        return WeatherCondition.lightSnow;
      }
      return WeatherCondition.snowy;
    }
    if (hasRain || n.contains('drizzle')) {
      if (hasHeavy) return WeatherCondition.heavyRain;
      if (n.contains('light') || n.contains('drizzle')) {
        return WeatherCondition.slightRain;
      }
      return WeatherCondition.rainy;
    }
    if (n.contains('fog') || n.contains('mist') || n.contains('haze')) {
      return WeatherCondition.hazy;
    }
    if (n.contains('wind') || n.contains('breezy') || n.contains('blustery')) {
      return WeatherCondition.windy;
    }
    if (n.contains('partly cloudy') ||
        n.contains('mostly sunny') ||
        n.contains('partly sunny')) {
      return WeatherCondition.partlyCloudy;
    }
    if (n.contains('cloudy') || n.contains('overcast')) {
      return WeatherCondition.cloudy;
    }
    if (n.contains('hot')) return WeatherCondition.hot;
    if (n.contains('cold') || n.contains('freez')) return WeatherCondition.coldWave;
    if (n.contains('sunny') || n.contains('clear') || n.contains('fair')) {
      return WeatherCondition.sunny;
    }
    return WeatherCondition.unknown;
  }
}
