// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => '予感さん';

  @override
  String get tabHome => '今日';

  @override
  String get tabWeather => '天気';

  @override
  String get tabScore => 'スコア';

  @override
  String get tabFortune => '運勢';

  @override
  String get tabSettings => '設定';

  @override
  String weatherFeelsLike(String temp) {
    return 'Feels like $temp°';
  }

  @override
  String weatherHumidity(int value) {
    return 'Humidity $value%';
  }

  @override
  String weatherWind(String speed) {
    return 'Wind ${speed}m/s';
  }

  @override
  String get scoreLabel => '活動スコア';

  @override
  String get scoreTierExcellent => '外出日和です';

  @override
  String get scoreTierGood => 'まずまずの天気';

  @override
  String get scoreTierFair => '少し不便かも';

  @override
  String get scoreTierPoor => '室内で過ごしましょう';

  @override
  String get fortuneTitle => '今日の運勢';

  @override
  String get fortuneLuckyColor => 'Lucky Color';

  @override
  String get fortuneLuckyNumber => 'Lucky Number';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsCountry => 'Region';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get onboardingTitle => '予感さん';

  @override
  String get onboardingSubtitle => 'Weather · Score · Fortune';

  @override
  String get onboardingStart => '始める';

  @override
  String get widgetScoreLabel => 'Score';

  @override
  String get widgetFortuneLabel => 'Fortune';

  @override
  String get widget_description => 'Yegamssi daily summary widget';

  @override
  String get activityRunning => 'Running';

  @override
  String get activityCycling => 'Cycling';

  @override
  String get activityHiking => 'Hiking';

  @override
  String get activityWalking => 'Walking';

  @override
  String get activityOutdoor => 'Outdoor Work';

  @override
  String get errorNetwork => 'Please check your internet connection.';

  @override
  String get errorServer => 'Server error occurred.';

  @override
  String get errorLocation => 'Unable to get location.';

  @override
  String get errorUnknown => 'An unknown error occurred.';
}
