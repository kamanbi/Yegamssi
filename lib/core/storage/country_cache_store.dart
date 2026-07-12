import 'package:shared_preferences/shared_preferences.dart';

import '../locale/country_code.dart';

/// 마지막으로 정상 판별된 국가 코드 캐시.
/// reverse geocoding 실패(타임아웃/네트워크 오류) 시 한국으로 잘못 되돌아가는
/// 것을 막고 최근 판별 결과를 유지하기 위함.
class CountryCacheStore {
  CountryCacheStore._();

  static const _countryKey = 'last_resolved_country';

  static Future<void> save(CountryCode country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countryKey, country.name);
  }

  static Future<CountryCode?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_countryKey);
    if (saved == null) return null;
    for (final country in CountryCode.values) {
      if (country.name == saved) return country;
    }
    return null;
  }
}
