import '../models/weather_response.dart';

/// 모든 날씨 API 구현체가 따르는 공통 인터페이스
abstract interface class WeatherDataSource {
  Future<WeatherResponse> fetchCurrent({
    required double lat,
    required double lon,
  });
}
