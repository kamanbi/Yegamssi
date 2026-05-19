import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'country_code.dart';

part 'locale_provider.g.dart';

const _localeKey = 'selected_locale';
const _langKey = 'selected_app_language';

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
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_langKey);
    if (saved != null) {
      final lang =
          AppLanguage.values.where((e) => e.name == saved).firstOrNull;
      if (lang != null) state = lang;
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang.name);
  }
}
