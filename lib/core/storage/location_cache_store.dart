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

  /// GPS 조회 실패 시 사용할 마지막 정상 좌표.
  /// 정확도가 떨어지더라도 서울 기본값으로 되돌아가는 것보다
  /// 최근 위치를 유지하는 편이 사용자 경험상 낫기 때문에
  /// 캐시 나이와 무관하게 존재하면 그대로 반환한다.
  static Future<({double lat, double lon})?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble(_latitudeKey);
    final longitude = prefs.getDouble(_longitudeKey);
    if (latitude == null || longitude == null) return null;
    return (lat: latitude, lon: longitude);
  }
}
