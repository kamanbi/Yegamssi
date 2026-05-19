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
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': AppConfig.openWeatherApiKey,
          'units': 'metric',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final main = data['main'] as Map<String, dynamic>? ?? const {};
      final wind = data['wind'] as Map<String, dynamic>? ?? const {};
      final weatherList = data['weather'] as List<dynamic>? ?? const [];
      final weather = weatherList.isNotEmpty
          ? weatherList.first as Map<String, dynamic>
          : const <String, dynamic>{};
      final weatherCode = weather['id'] as int? ?? -1;
      final locationName = (data['name'] as String?)?.trim();

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
