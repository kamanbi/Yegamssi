import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/entities/user_profile.dart';

class UserProfileRepository {
  static const _birthDateKey = 'user_birth_date';
  static const _birthHourKey = 'user_birth_hour';
  static const _genderKey = 'user_gender';
  static const _secureStorage = FlutterSecureStorage();

  Future<UserProfile?> load() async {
    final secureDate = await _secureStorage.read(key: _birthDateKey);
    final secureHour = await _secureStorage.read(key: _birthHourKey);
    final secureGender = await _secureStorage.read(key: _genderKey);
    if (secureDate != null) {
      final profile = _parseProfile(secureDate, secureHour, secureGender);
      if (profile != null) return profile;
    }

    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_birthDateKey);
    if (dateStr == null) return null;
    final profile = _parseProfile(
      dateStr,
      prefs.getInt(_birthHourKey)?.toString(),
      prefs.getString(_genderKey),
    );
    if (profile == null) return null;

    await save(profile);
    await _clearLegacyPreferences(prefs);
    return profile;
  }

  Future<void> save(UserProfile profile) async {
    await _secureStorage.write(
      key: _birthDateKey,
      value: profile.birthDate.toIso8601String(),
    );
    await _secureStorage.write(
      key: _birthHourKey,
      value: profile.birthHour.toString(),
    );
    await _secureStorage.write(key: _genderKey, value: profile.gender.name);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      _secureStorage.delete(key: _birthDateKey),
      _secureStorage.delete(key: _birthHourKey),
      _secureStorage.delete(key: _genderKey),
    ]);
    await _clearLegacyPreferences(prefs);
  }

  UserProfile? _parseProfile(
    String dateValue,
    String? hourValue,
    String? genderValue,
  ) {
    final date = DateTime.tryParse(dateValue);
    if (date == null) return null;
    final hour = int.tryParse(hourValue ?? '') ?? 12;
    return UserProfile(
      birthDate: date,
      birthHour: hour,
      gender: _parseGender(genderValue),
    );
  }

  Future<void> _clearLegacyPreferences(SharedPreferences prefs) async {
    await Future.wait([
      prefs.remove(_birthDateKey),
      prefs.remove(_birthHourKey),
      prefs.remove(_genderKey),
    ]);
  }

  static Gender _parseGender(String? value) {
    if (value == null) return Gender.unspecified;
    for (final gender in Gender.values) {
      if (gender.name == value) return gender;
    }
    return Gender.unspecified;
  }
}
