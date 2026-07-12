import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'country_code.dart';

part 'locale_provider.g.dart';

const _localeKey = 'selected_locale';
const _langKey = 'selected_app_language';

Future<AppLanguage> loadSavedAppLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_langKey);
  if (saved == null) return AppLanguage.ko;
  return AppLanguage.values.where((e) => e.name == saved).firstOrNull ??
      AppLanguage.ko;
}

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    _loadSaved();
    return const Locale('ko');
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localeKey);
    if (saved != null) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}

@riverpod
class AppLanguageNotifier extends _$AppLanguageNotifier {
  @override
  AppLanguage build() {
    _loadSaved();
    return AppLanguage.ko;
  }

  Future<void> _loadSaved() async {
    state = await loadSavedAppLanguage();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    // 저장을 먼저 완료해야 상태 변경으로 재계산되는 쪽(dailyFortune 등)이
    // 옛 저장값을 읽는 레이스가 없다.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang.name);
    await prefs.setString(_localeKey, lang.name);
    state = lang;
  }
}
