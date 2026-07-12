import 'package:shared_preferences/shared_preferences.dart';

class WeatherCacheMigration {
  WeatherCacheMigration._();

  static const _schemaVersionKey = 'weather_cache_schema_version';
  static const _legacyCombinedWeatherKey = 'last_known_good_weather';
  static const _backgroundWeatherUpdatedAtKey = 'bg_weather_updated_at';
  static const _backgroundAirUpdatedAtKey = 'bg_air_updated_at';
  static const _currentSchemaVersion = 3;

  static Future<void> migrateLegacyForecastCache() async {
    final prefs = await SharedPreferences.getInstance();
    final storedVersion = prefs.getInt(_schemaVersionKey) ?? 0;
    if (storedVersion >= _currentSchemaVersion) {
      return;
    }

    // User profile, fortune, language, theme, and purchase keys are untouched.
    // Version 3 also removes snapshots where widget refresh preserved expired
    // hourly and daily forecast arrays behind a fresh observation timestamp.
    await prefs.remove(_legacyCombinedWeatherKey);
    await prefs.remove(_backgroundWeatherUpdatedAtKey);
    await prefs.remove(_backgroundAirUpdatedAtKey);
    await prefs.setInt(_schemaVersionKey, _currentSchemaVersion);
  }
}
