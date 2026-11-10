import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class KmaForecastHistoryStore {
  static const _prefix = 'kma_forecast_day_v1_';

  static String _key(({int nx, int ny}) grid, String date) =>
      '$_prefix${date}_${grid.nx}_${grid.ny}';

  static Future<List<Map<String, dynamic>>?> load(
    ({int nx, int ny}) grid,
    String date,
  ) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_key(grid, date));
      if (raw == null) return null;
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  static Future<void> save({
    required ({int nx, int ny}) grid,
    required String date,
    required List<Map<String, dynamic>> items,
  }) async {
    if (items.isEmpty) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key(grid, date), jsonEncode(items));
    for (final key in preferences.getKeys()) {
      if (key.startsWith(_prefix) && !key.startsWith('$_prefix${date}_')) {
        await preferences.remove(key);
      }
    }
  }
}
