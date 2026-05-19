// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Yegamssi';

  @override
  String get tabHome => 'Today';

  @override
  String get tabWeather => 'Weather';

  @override
  String get tabScore => 'Score';

  @override
  String get tabFortune => 'Fortune';

  @override
  String get tabSettings => 'Settings';

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
  String get scoreLabel => 'Activity Score';

  @override
  String get scoreTierExcellent => 'Perfect conditions';

  @override
  String get scoreTierGood => 'Good conditions';

  @override
  String get scoreTierFair => 'Manageable';

  @override
  String get scoreTierPoor => 'Stay indoors';

  @override
  String get fortuneTitle => 'Your Daily Fortune';

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
  String get onboardingTitle => 'Yegamssi';

  @override
  String get onboardingSubtitle => 'Weather · Score · Fortune';

  @override
  String get onboardingStart => 'Get Started';

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
