// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '预感先生';

  @override
  String get tabHome => '今天';

  @override
  String get tabWeather => '天气';

  @override
  String get tabScore => '评分';

  @override
  String get tabFortune => '运势';

  @override
  String get tabSettings => '设置';

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
  String get scoreLabel => '户外活动评分';

  @override
  String get scoreTierExcellent => '完美的户外天气';

  @override
  String get scoreTierGood => '天气不错';

  @override
  String get scoreTierFair => '稍有不便';

  @override
  String get scoreTierPoor => '建议待在室内';

  @override
  String get fortuneTitle => '今日运势';

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
  String get onboardingTitle => '预感先生';

  @override
  String get onboardingSubtitle => 'Weather · Score · Fortune';

  @override
  String get onboardingStart => '开始';

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
