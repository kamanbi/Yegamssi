import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yegamssi/core/storage/weather_cache_migration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'removes weather cache keys without clearing user and fortune data',
    () async {
      SharedPreferences.setMockInitialValues({
        'last_known_good_weather': '{"hourlyForecasts":[]}',
        'bg_weather_updated_at': '2026-06-22T23:00:00',
        'bg_air_updated_at': '2026-06-22T23:00:00',
        'user_profile': '{"birthHour":2}',
        'fortune_v6_example': '{"score":60}',
        'weather_cache_schema_version': 1,
      });

      await WeatherCacheMigration.migrateLegacyForecastCache();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('last_known_good_weather'), isNull);
      expect(prefs.getString('bg_weather_updated_at'), isNull);
      expect(prefs.getString('bg_air_updated_at'), isNull);
      expect(prefs.getString('user_profile'), '{"birthHour":2}');
      expect(prefs.getString('fortune_v6_example'), '{"score":60}');
      expect(prefs.getInt('weather_cache_schema_version'), 3);
    },
  );

  test(
    'does not clear a cache after the migration version is recorded',
    () async {
      SharedPreferences.setMockInitialValues({
        'last_known_good_weather': '{"hourlyForecasts":[]}',
        'weather_cache_schema_version': 3,
      });

      await WeatherCacheMigration.migrateLegacyForecastCache();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('last_known_good_weather'), isNotNull);
    },
  );
}
