import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/location_provider.dart';

part 'theme_provider.g.dart';

const _themePreferenceKey = 'theme_preference';
const _dayStartHour = 6;
const _dayEndHour = 19;
const _degreesPerTimeZoneHour = 15.0;
const _koreaJapanUtcOffsetHours = 9;

enum AppThemePreference { automatic, day, night }

@Riverpod(keepAlive: true)
class ThemePreferenceNotifier extends _$ThemePreferenceNotifier {
  @override
  AppThemePreference build() {
    _loadSaved();
    return AppThemePreference.automatic;
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themePreferenceKey);
    if (saved == null) return;

    state = AppThemePreference.values.firstWhere(
      (preference) => preference.name == saved,
      orElse: () => AppThemePreference.automatic,
    );
  }

  Future<void> setPreference(AppThemePreference preference) async {
    state = preference;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, preference.name);
  }
}

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    final preference = ref.watch(themePreferenceNotifierProvider);
    if (preference == AppThemePreference.day) return ThemeMode.light;
    if (preference == AppThemePreference.night) return ThemeMode.dark;

    final position = ref.watch(currentPositionProvider).valueOrNull;
    if (position == null) {
      final hour = DateTime.now().hour;
      return (hour >= _dayStartHour && hour < _dayEndHour)
          ? ThemeMode.light
          : ThemeMode.dark;
    }
    _scheduleNextAutomaticCheck(position);

    return _isDaytimeAtLocation(position)
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  bool _isDaytimeAtLocation(({double lat, double lon}) position) {
    final offsetHours = _utcOffsetHours(position);
    final locationTime = DateTime.now().toUtc().add(
      Duration(hours: offsetHours),
    );
    return locationTime.hour >= _dayStartHour &&
        locationTime.hour < _dayEndHour;
  }

  void _scheduleNextAutomaticCheck(({double lat, double lon}) position) {
    final offsetHours = _utcOffsetHours(position);
    final locationTime = DateTime.now().toUtc().add(
      Duration(hours: offsetHours),
    );
    final nextBoundary = _nextThemeBoundary(locationTime);
    final delay =
        nextBoundary.difference(locationTime) + const Duration(seconds: 1);
    final timer = Timer(delay, ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }

  int _utcOffsetHours(({double lat, double lon}) position) {
    if (_isKoreanPeninsula(position)) return _koreaJapanUtcOffsetHours;
    return (position.lon / _degreesPerTimeZoneHour).round();
  }

  bool _isKoreanPeninsula(({double lat, double lon}) position) {
    return position.lat >= 33 &&
        position.lat <= 39.5 &&
        position.lon >= 124 &&
        position.lon <= 132;
  }

  DateTime _nextThemeBoundary(DateTime locationTime) {
    final dayStart = DateTime(
      locationTime.year,
      locationTime.month,
      locationTime.day,
      _dayStartHour,
    );
    final dayEnd = DateTime(
      locationTime.year,
      locationTime.month,
      locationTime.day,
      _dayEndHour,
    );
    if (locationTime.isBefore(dayStart)) return dayStart;
    if (locationTime.isBefore(dayEnd)) return dayEnd;
    return dayStart.add(const Duration(days: 1));
  }
}
