import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/weather_entity.dart';
import '../models/weather_response.dart';
import 'weather_data_source.dart';

/// OpenWeather API 구현체 — 글로벌 fallback
class OpenWeatherDataSource implements WeatherDataSource {
  OpenWeatherDataSource()
      : _dio = DioClient.create(baseUrl: AppConfig.openWeatherBaseUrl);

  final Dio _dio;

  @override
  Future<WeatherResponse> fetchCurrent({
    required double lat,
    required double lon,
  }) async {
    if (AppConfig.openWeatherApiKey.isEmpty) {
      throw const ServerException('OPENWEATHER_API_KEY가 설정되지 않았습니다');
    }

    try {
      final params = {
        'lat': lat,
        'lon': lon,
        'appid': AppConfig.openWeatherApiKey,
        'units': 'metric',
      };

      // 현재 날씨 + 5일 예보 병렬 요청
      final responses = await Future.wait([
        _dio.get('/weather', queryParameters: params),
        _dio.get('/forecast', queryParameters: params),
      ]);

      // ── 현재 날씨 ────────────────────────────────────────────────
      final data = responses[0].data as Map<String, dynamic>;
      final main = data['main'] as Map<String, dynamic>? ?? const {};
      final wind = data['wind'] as Map<String, dynamic>? ?? const {};
      final weatherList = data['weather'] as List<dynamic>? ?? const [];
      final weather = weatherList.isNotEmpty
          ? weatherList.first as Map<String, dynamic>
          : const <String, dynamic>{};
      final weatherCode = weather['id'] as int? ?? -1;
      final locationName = (data['name'] as String?)?.trim();

      // ── 시간별 예보 (3시간 단위 × 12 → 36시간) ─────────────────
      final forecastData = responses[1].data as Map<String, dynamic>;
      final forecastList =
          forecastData['list'] as List<dynamic>? ?? const [];

      final hourlyForecasts = <HourlyForecast>[];
      for (final raw in forecastList.take(12)) {
        final item = raw as Map<String, dynamic>;
        final dt = item['dt'] as int?;
        if (dt == null) continue;
        final itemMain = item['main'] as Map<String, dynamic>? ?? const {};
        final itemWeatherList = item['weather'] as List<dynamic>? ?? const [];
        final itemWeather = itemWeatherList.isNotEmpty
            ? itemWeatherList.first as Map<String, dynamic>
            : const <String, dynamic>{};
        hourlyForecasts.add(
          HourlyForecast(
            time: DateTime.fromMillisecondsSinceEpoch(dt * 1000),
            tempCelsius: (itemMain['temp'] as num?)?.toDouble() ?? 0,
            condition: _mapOwmCode((itemWeather['id'] as int?) ?? -1),
          ),
        );
      }

      // ── 일별 예보 (날짜별 묶기, 최대 7일) ───────────────────────
      final dailyMap = <String, List<Map<String, dynamic>>>{};
      for (final raw in forecastList) {
        final item = raw as Map<String, dynamic>;
        final dtTxt = (item['dt_txt'] as String?) ?? '';
        final dateKey = dtTxt.split(' ').first; // "2026-05-22"
        if (dateKey.isEmpty) continue;
        dailyMap.putIfAbsent(dateKey, () => []).add(item);
      }

      final dailyForecasts = <DailyForecast>[];
      for (final entry in dailyMap.entries.take(7)) {
        final items = entry.value;
        double tempMin = double.infinity;
        double tempMax = double.negativeInfinity;
        double totalPrecip = 0;
        int precipCount = 0;
        WeatherCondition? noonCondition;

        for (final item in items) {
          final itemMain = item['main'] as Map<String, dynamic>? ?? const {};
          final t = (itemMain['temp'] as num?)?.toDouble() ?? 0;
          if (t < tempMin) tempMin = t;
          if (t > tempMax) tempMax = t;
          final pop = (item['pop'] as num?)?.toDouble() ?? 0;
          totalPrecip += pop;
          precipCount++;
          // 정오(12시) 슬롯 → 대표 날씨
          final dtTxt = (item['dt_txt'] as String?) ?? '';
          if (dtTxt.contains('12:00')) {
            final wList = item['weather'] as List<dynamic>? ?? const [];
            if (wList.isNotEmpty) {
              noonCondition = _mapOwmCode(
                (wList.first as Map<String, dynamic>)['id'] as int? ?? -1,
              );
            }
          }
        }

        if (tempMin == double.infinity) continue;
        final avgPrecip = precipCount > 0 ? totalPrecip / precipCount : 0.0;
        // 대표 날씨: 정오 없으면 첫 슬롯 사용
        final firstWeatherList =
            items.first['weather'] as List<dynamic>? ?? const [];
        final fallbackCondition = firstWeatherList.isNotEmpty
            ? _mapOwmCode(
                (firstWeatherList.first as Map<String, dynamic>)['id'] as int? ??
                    -1,
              )
            : WeatherCondition.unknown;

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

      return WeatherResponse(
        tempCelsius: (main['temp'] as num?)?.toDouble() ?? 0,
        feelsLikeCelsius: (main['feels_like'] as num?)?.toDouble() ??
            (main['temp'] as num?)?.toDouble() ??
            0,
        condition: _mapOwmCode(weatherCode),
        windSpeedMs: (wind['speed'] as num?)?.toDouble() ?? 0,
        precipProbability: 0,
        uvIndex: 0,
        humidity: (main['humidity'] as num?)?.toInt() ?? 0,
        locationName:
            locationName == null || locationName.isEmpty ? 'Global' : locationName,
        hourlyForecasts: hourlyForecasts,
        dailyForecasts: dailyForecasts,
      );
    } on DioException catch (error) {
      throw NetworkException('OpenWeather API 오류: ${error.message}');
    } catch (error) {
      if (error is AppException) rethrow;
      throw ParseException('OpenWeather 응답 파싱 실패: $error');
    }
  }

  /// OpenWeather weather condition code → 15종 매핑.
  /// https://openweathermap.org/weather-conditions
  WeatherCondition _mapOwmCode(int code) {
    // 2xx Thunderstorm
    if (code >= 200 && code < 300) {
      // 200-202, 230-232: 비+천둥, 210-221: 천둥
      if ((code >= 200 && code <= 202) || (code >= 230 && code <= 232)) {
        return WeatherCondition.rainThunder;
      }
      return WeatherCondition.thunderstorm;
    }
    // 3xx Drizzle → 약한 비
    if (code >= 300 && code < 400) return WeatherCondition.slightRain;
    // 5xx Rain
    if (code >= 500 && code < 600) {
      if (code == 500 || code == 520) return WeatherCondition.slightRain;
      if (code == 501 || code == 521) return WeatherCondition.rainy;
      if (code == 502 || code == 503 || code == 504 || code == 522 ||
          code == 531) {
        return WeatherCondition.heavyRain;
      }
      if (code == 511) return WeatherCondition.sleet; // 어는 비
      return WeatherCondition.rainy;
    }
    // 6xx Snow
    if (code >= 600 && code < 700) {
      if (code == 600 || code == 620) return WeatherCondition.lightSnow;
      if (code == 611 || code == 612 || code == 613 || code == 615 ||
          code == 616) {
        return WeatherCondition.sleet; // 진눈깨비
      }
      return WeatherCondition.snowy;
    }
    // 7xx Atmosphere
    if (code >= 700 && code < 800) {
      if (code == 771 || code == 781) return WeatherCondition.windy; // 돌풍/토네이도
      return WeatherCondition.hazy; // 안개/연무/먼지
    }
    // 800 Clear
    if (code == 800) return WeatherCondition.sunny;
    // 80x Clouds
    if (code == 801 || code == 802) return WeatherCondition.partlyCloudy;
    if (code > 802) return WeatherCondition.cloudy;
    return WeatherCondition.unknown;
  }
}
