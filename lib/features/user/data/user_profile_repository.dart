import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/user_profile.dart';

class UserProfileRepository {
  static const _birthDateKey = 'user_birth_date';
  static const _birthHourKey = 'user_birth_hour';

  Future<UserProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_birthDateKey);
    if (dateStr == null) return null;
    final date = DateTime.tryParse(dateStr);
    if (date == null) return null;
    final hour = prefs.getInt(_birthHourKey) ?? 12;
    return UserProfile(birthDate: date, birthHour: hour);
  }

  Future<void> save(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_birthDateKey, profile.birthDate.toIso8601String());
    await prefs.setInt(_birthHourKey, profile.birthHour);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_birthDateKey);
    await prefs.remove(_birthHourKey);
  }
}
