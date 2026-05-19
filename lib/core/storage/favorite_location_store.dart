import 'package:shared_preferences/shared_preferences.dart';

import '../../features/weather/domain/entities/saved_location.dart';

class FavoriteLocationStore {
  static const _key = 'favorite_locations';
  static const maxCount = 5;

  static Future<List<SavedLocation>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return [];
    try {
      return SavedLocation.listFromJsonString(json);
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<SavedLocation> locations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      SavedLocation.listToJsonString(locations),
    );
  }

  static Future<bool> add(SavedLocation location) async {
    final list = await load();
    if (list.length >= maxCount) return false;
    if (list.any((e) => e.name == location.name)) return false;
    list.add(location);
    await save(list);
    return true;
  }

  static Future<void> remove(SavedLocation location) async {
    final list = await load();
    list.removeWhere((e) => e.name == location.name);
    await save(list);
  }
}
