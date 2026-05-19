import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../locale/country_code.dart';

class AppConfig {
  AppConfig._();

  // KMA (기상청) API Hub
  static String get kmaApiKey => dotenv.env['KMA_API_KEY'] ?? '';
  // 초단기실황: /api/typ02/obs/sfc/aws/hrly-obs-hgt-ta
  // 동네예보:    /api/typ02/fc/af/pred-unis
  static const String kmaBaseUrl = 'https://apihub.kma.go.kr';

  // 에어코리아 (한국환경공단 대기오염정보)
  static String get airkoreaApiKey => dotenv.env['AIRKOREA_API_KEY'] ?? '';
  static const String airkoreaBaseUrl = 'https://apis.data.go.kr';

  // OpenWeather API (글로벌 fallback)
  static String get openWeatherApiKey =>
      dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  static const String openWeatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  // NOAA / NWS (미국) — 무료, 키 불필요
  static const String noaaBaseUrl = 'https://api.weather.gov';

  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// 국가 코드에 따른 날씨 API base URL 반환
  static String weatherBaseUrlFor(CountryCode country) {
    return switch (country) {
      CountryCode.kr => kmaBaseUrl,
      CountryCode.us => noaaBaseUrl,
      _ => openWeatherBaseUrl,
    };
  }
}
