import 'package:shared_preferences/shared_preferences.dart';

class LocationCacheStore {
  LocationCacheStore._();

  static const _latitudeKey = 'last_known_latitude';
  static const _longitudeKey = 'last_known_longitude';

  static Future<void> save({
    required double latitude,
    required double longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latitudeKey, latitude);
    await prefs.setDouble(_longitudeKey, longitude);
  }

  static Future<({double lat, double lon})?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble(_latitudeKey);
    final longitude = prefs.getDouble(_longitudeKey);
    if (latitude == null || longitude == null) {
      return null;
    }
    return (lat: latitude, lon: longitude);
  }
}
