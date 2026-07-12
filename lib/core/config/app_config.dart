import '../locale/country_code.dart';

class AppConfig {
  AppConfig._();

  // Values are injected by the local release build command. No .env file is
  // packaged with the Flutter asset bundle.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static const String kmaBaseUrl = 'https://apihub.kma.go.kr';
  static const String airkoreaBaseUrl = 'https://apis.data.go.kr';
  static const String openWeatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const String noaaBaseUrl = 'https://api.weather.gov';
  static const String airnowBaseUrl = 'https://www.airnowapi.org';

  static String get weatherProxyUrl {
    if (supabaseUrl.isEmpty) return '';
    return '$supabaseUrl/functions/v1/weather-proxy';
  }

  static String weatherBaseUrlFor(CountryCode country) {
    return switch (country) {
      CountryCode.kr => kmaBaseUrl,
      CountryCode.us => noaaBaseUrl,
      _ => openWeatherBaseUrl,
    };
  }
}
