// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '예감씨';

  @override
  String get tabHome => '오늘';

  @override
  String get tabWeather => '날씨';

  @override
  String get tabScore => '활동점수';

  @override
  String get tabFortune => '운세';

  @override
  String get tabSettings => '설정';

  @override
  String weatherFeelsLike(String temp) {
    return '체감 $temp°';
  }

  @override
  String weatherHumidity(int value) {
    return '습도 $value%';
  }

  @override
  String weatherWind(String speed) {
    return '바람 ${speed}m/s';
  }

  @override
  String get scoreLabel => '야외활동 점수';

  @override
  String get scoreTierExcellent => '야외 활동하기 완벽한 날';

  @override
  String get scoreTierGood => '나쁘지 않은 날씨예요';

  @override
  String get scoreTierFair => '조금 불편할 수 있어요';

  @override
  String get scoreTierPoor => '오늘은 실내가 좋겠어요';

  @override
  String get fortuneTitle => '오늘의 운세';

  @override
  String get fortuneLuckyColor => '행운의 색';

  @override
  String get fortuneLuckyNumber => '행운의 숫자';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsCountry => '지역';

  @override
  String get settingsTheme => '테마';

  @override
  String get settingsThemeDark => '다크';

  @override
  String get settingsThemeLight => '라이트';

  @override
  String get onboardingTitle => '예감씨';

  @override
  String get onboardingSubtitle => '날씨 · 점수 · 운세';

  @override
  String get onboardingStart => '시작하기';

  @override
  String get widgetScoreLabel => '점수';

  @override
  String get widgetFortuneLabel => '운세';

  @override
  String get widget_description => '예감씨 오늘 요약 위젯';

  @override
  String get activityRunning => '달리기';

  @override
  String get activityCycling => '자전거';

  @override
  String get activityHiking => '등산';

  @override
  String get activityWalking => '걷기';

  @override
  String get activityOutdoor => '야외작업';

  @override
  String get errorNetwork => '인터넷 연결을 확인해주세요.';

  @override
  String get errorServer => '서버 오류가 발생했습니다.';

  @override
  String get errorLocation => '위치 정보를 가져올 수 없습니다.';

  @override
  String get errorUnknown => '알 수 없는 오류가 발생했습니다.';
}
