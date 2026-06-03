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
  String get homeHeadline => 'Weather and signals for today';

  @override
  String get homeWeatherLoadingTitle => 'Loading current weather';

  @override
  String get homeWeatherLoadingMessage =>
      'Preparing location and weather data.';

  @override
  String get homeWeatherErrorTitle => 'Could not load current weather';

  @override
  String get homeWeatherErrorMessage =>
      'Open the weather screen and try again.';

  @override
  String get homeWeatherAction => 'View Weather';

  @override
  String get homeFortuneLoadingTitle => 'Preparing today\'s fortune';

  @override
  String get homeFortuneLoadingMessage => 'A short summary will appear soon.';

  @override
  String get homeFortuneErrorTitle => 'Fortune is not ready yet';

  @override
  String get homeFortuneErrorMessage =>
      'Check your profile and try again on the fortune screen.';

  @override
  String get homeFortuneAction => 'View Fortune';

  @override
  String get homeFortuneHeadline => 'Today\'s fortune in one line';

  @override
  String get appExitTitle => 'Exit app';

  @override
  String get appExitMessage => 'Do you want to close Yegamssi?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'OK';

  @override
  String get close => 'Close';

  @override
  String get later => 'Later';

  @override
  String get exit => 'Exit';

  @override
  String get search => 'Search';

  @override
  String get loadingAd => 'Loading ad...';

  @override
  String get refresh => 'Refresh';

  @override
  String refreshFailed(String error) {
    return 'Refresh failed: $error';
  }

  @override
  String notFoundPage(String error) {
    return 'Page not found: $error';
  }

  @override
  String weatherFeelsLike(String temp) {
    return 'Feels like $temp°C';
  }

  @override
  String weatherFeelsLikeShort(String temp) {
    return 'Feels $temp°';
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
  String get weatherHumidityLabel => 'Humidity';

  @override
  String get weatherWindLabel => 'Wind';

  @override
  String get weatherWindSpeedLabel => 'Wind speed';

  @override
  String get weatherPrecipitationLabel => 'Rain';

  @override
  String weatherPrecipitationAmount(String amount) {
    return 'Rainfall $amount';
  }

  @override
  String get weatherDustPm10 => 'PM10';

  @override
  String get weatherDustPm25 => 'PM2.5';

  @override
  String get weatherHourlyForecast => 'Hourly Forecast';

  @override
  String get weatherWeeklyForecast => 'Weekly Forecast';

  @override
  String get weatherLoading => 'Loading weather...';

  @override
  String get weatherErrorTitle => 'Unable to get weather data';

  @override
  String weatherReturnCurrentLocation(int seconds) {
    return 'Returning to current location in ${seconds}s';
  }

  @override
  String get weatherToday => 'Today';

  @override
  String get weatherAm => 'AM';

  @override
  String get weatherPm => 'PM';

  @override
  String weatherHour(String hour) {
    return '$hour:00';
  }

  @override
  String weatherUvVeryHigh(int uv) {
    return '$uv Very high';
  }

  @override
  String weatherUvHigh(int uv) {
    return '$uv High';
  }

  @override
  String weatherUvModerateHigh(int uv) {
    return '$uv Moderate high';
  }

  @override
  String weatherUvModerate(int uv) {
    return '$uv Moderate';
  }

  @override
  String weatherUvLow(int uv) {
    return '$uv Low';
  }

  @override
  String get weatherConditionSunny => 'Sunny';

  @override
  String get weatherConditionClearNight => 'Clear night';

  @override
  String get weatherConditionPartlyCloudy => 'Partly cloudy';

  @override
  String get weatherConditionPartlyCloudyNight => 'Partly cloudy night';

  @override
  String get weatherConditionCloudy => 'Cloudy';

  @override
  String get weatherConditionHazy => 'Hazy';

  @override
  String get weatherConditionWindy => 'Windy';

  @override
  String get weatherConditionSlightRain => 'Light rain';

  @override
  String get weatherConditionRain => 'Rain';

  @override
  String get weatherConditionHeavyRain => 'Heavy rain';

  @override
  String get weatherConditionThunderstorm => 'Thunderstorm';

  @override
  String get weatherConditionRainThunder => 'Rain and thunder';

  @override
  String get weatherConditionLightSnow => 'Light snow';

  @override
  String get weatherConditionSnow => 'Snow';

  @override
  String get weatherConditionSleet => 'Sleet';

  @override
  String get weatherConditionHot => 'Hot';

  @override
  String get weatherConditionHotNight => 'Hot night';

  @override
  String get weatherConditionColdWave => 'Cold wave';

  @override
  String get weatherConditionUnknown => 'Unknown';

  @override
  String get locationCurrent => 'Current location';

  @override
  String get locationSelectClose => 'Close location selector';

  @override
  String locationAdded(String name) {
    return '$name added';
  }

  @override
  String get locationFavoriteLimit => 'You can add up to 5 locations.';

  @override
  String get locationFavoriteFull => 'Favorites full';

  @override
  String get locationFavoriteAdd => 'Add favorite';

  @override
  String get locationSearchTitle => 'Search Location';

  @override
  String get locationSearchHint => 'Example: Seoul, Busan, Tokyo';

  @override
  String get locationSearchEmpty => 'No results found';

  @override
  String get scoreLabel => 'Outdoor Activity Score';

  @override
  String get scoreLoading => 'Calculating outdoor activity score...';

  @override
  String get scoreErrorTitle => 'Unable to calculate score';

  @override
  String get scoreBreakdownTitle => 'Deductions';

  @override
  String get scoreNoDeduction =>
      'Stable outdoor conditions with almost no deduction factors.';

  @override
  String get scoreInfo =>
      'Outdoor activity score is calculated from rain, wind, feels-like temperature, air quality, and UV data.';

  @override
  String get scoreDeductionRain => 'Rain and snow';

  @override
  String get scoreDeductionWind => 'Wind';

  @override
  String get scoreDeductionTemp => 'Temperature';

  @override
  String get scoreDeductionAir => 'Air quality';

  @override
  String get scoreDeductionUv => 'UV';

  @override
  String get scoreDeductionOzone => 'Ozone';

  @override
  String get scoreAdviceExcellent =>
      'Today is good for outdoor activity.\nStep out lightly and lift your condition.';

  @override
  String get scoreAdviceGood =>
      'Outdoor activity is fine, but check wind and UV once more.';

  @override
  String get scoreAdviceFair =>
      'Outdoor activity is possible, and better preparation will make it easier.';

  @override
  String get scoreAdvicePoor =>
      'It is safer to plan around indoor activities today.';

  @override
  String get scoreTierExcellent => 'Excellent';

  @override
  String get scoreTierGood => 'Good';

  @override
  String get scoreTierFair => 'Fair';

  @override
  String get scoreTierPoor => 'Caution';

  @override
  String scorePointUnit(int score) {
    return '$score pts';
  }

  @override
  String get activityRecommendOutdoor => 'Outdoor activity recommended';

  @override
  String get activityRecommendLight => 'Light activity fits';

  @override
  String get activityRecommendCaution => 'Caution needed';

  @override
  String get activityRecommendIndoor => 'Indoor activity recommended';

  @override
  String get airQualityTitle => 'Air Quality';

  @override
  String get airQualityIntegrated => 'Integrated Air Quality';

  @override
  String get airQualityUnknown => 'No data';

  @override
  String get airGradeGood => 'Good';

  @override
  String get airGradeModerate => 'Moderate';

  @override
  String get airGradeBad => 'Bad';

  @override
  String get airGradeVeryBad => 'Very bad';

  @override
  String get pointUnit => 'pts';

  @override
  String get fortuneTitle => 'Your Daily Fortune';

  @override
  String get fortuneNeedProfileTitle => 'Birth information is needed';

  @override
  String get fortuneNeedProfileMessage =>
      'Enter your birth date and time to receive today\'s fortune in a calm tone.';

  @override
  String get fortuneBirthInputAction => 'Enter Birth Info';

  @override
  String get fortuneLoadFailedTitle => 'Could not load fortune';

  @override
  String get fortuneLoadFailedMessage => 'Please try again later.';

  @override
  String get fortuneCategoryAnalysis => 'Category Analysis';

  @override
  String get fortuneOverall => 'Overall Fortune';

  @override
  String get fortuneCategoryMoney => 'Money';

  @override
  String get fortuneCategoryLove => 'Love';

  @override
  String get fortuneCategoryWork => 'Work';

  @override
  String get fortuneCategoryHealth => 'Health';

  @override
  String get fortuneCategoryDecision => 'Decision';

  @override
  String get fortuneLuckyColor => 'Lucky Color';

  @override
  String get fortuneLuckyNumber => 'Lucky Number';

  @override
  String get fortuneOhengBalance => 'Element Balance';

  @override
  String get fortuneOhengDescription =>
      'A supporting signal for today\'s emotional flow.';

  @override
  String get fortuneCaptureTooltip => 'Capture fortune card';

  @override
  String get fortuneCaptureSaved => 'Fortune card capture saved.';

  @override
  String get fortuneCaptureSaveDone => 'Fortune card capture complete';

  @override
  String fortuneCaptureFailed(String error) {
    return 'Capture failed: $error';
  }

  @override
  String get fortuneOpenFolder => 'Open Folder';

  @override
  String get fortuneAnalyzing => 'Analyzing.';

  @override
  String get fortuneToneBase => 'Base';

  @override
  String get fortuneToneHumor => 'Humor';

  @override
  String get fortuneToneTsundere => 'Tsundere';

  @override
  String get fortuneToneCynical => 'Cynical';

  @override
  String get fortuneToneEmotional => 'Emotional';

  @override
  String get fortuneToneHistorical => 'Historical';

  @override
  String get fortuneToneAi => 'AI';

  @override
  String get fortuneTimeMorning => 'Morning';

  @override
  String get fortuneTimeAfternoon => 'Afternoon';

  @override
  String get ohengMok => 'Wood';

  @override
  String get ohengHwa => 'Fire';

  @override
  String get ohengTo => 'Earth';

  @override
  String get ohengGeum => 'Metal';

  @override
  String get ohengSu => 'Water';

  @override
  String get luckyColorGreen => 'Green';

  @override
  String get luckyColorCoral => 'Coral';

  @override
  String get luckyColorGold => 'Gold';

  @override
  String get luckyColorSilver => 'Silver';

  @override
  String get luckyColorSky => 'Sky blue';

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
  String get settingsBirthTitle => 'Birth Date';

  @override
  String get settingsBirthDescription =>
      'Manage the birth date and time used for fortune calculation.';

  @override
  String get settingsBirthEmpty => 'Not entered';

  @override
  String get settingsBirthUnknownHour => 'Unknown';

  @override
  String settingsHourUnit(int hour) {
    return '$hour:00';
  }

  @override
  String get settingsFortuneToneTitle => 'Tone';

  @override
  String settingsFortuneToneDescription(String tone) {
    return 'Fortune messages are shown in the $tone style.';
  }

  @override
  String get settingsFortuneToneSheetDescription =>
      'Base messages are kept, and the selected style is prioritized.';

  @override
  String get settingsAppInfoTitle => 'App Info';

  @override
  String get settingsAppInfoDescription =>
      'Check homepage, privacy guide, contact email, and links.';

  @override
  String get onboardingTitle => 'Yegamssi';

  @override
  String get onboardingSubtitle =>
      'Enter your birth date and time\nto receive today\'s fortune.';

  @override
  String get onboardingStart => 'Get Started';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get birthHour => 'Birth Time';

  @override
  String get birthHourOptional => 'Birth Time (Optional)';

  @override
  String get birthSelectDate => 'Select a date';

  @override
  String get birthUnknownNoon => 'Unknown (calculated at noon)';

  @override
  String get birthUnknownNoonShort => 'Unknown (noon)';

  @override
  String dateYmd(int year, int month, int day) {
    return '$year-$month-$day';
  }

  @override
  String hourLabel(int hour) {
    return '$hour:00';
  }

  @override
  String get appInfoHomepage => 'Homepage';

  @override
  String get appInfoHomepageDescription =>
      'Open the Yegamssi introduction page.';

  @override
  String get appInfoPrivacy => 'Privacy Policy';

  @override
  String get appInfoPrivacyDescription => 'Open the privacy policy page.';

  @override
  String get appInfoEmail => 'Contact Email';

  @override
  String get appInfoEmailDescription => 'Open the mail app for inquiries.';

  @override
  String get appInfoShare => 'Share Yegamssi';

  @override
  String get appInfoShareDescription => 'Show a QR code linked to the store.';

  @override
  String get appInfoShareQrDescription =>
      'Scan the QR code to open the Yegamssi store page.';

  @override
  String get appInfoCopyLink => 'Copy Link';

  @override
  String get appInfoOpenStore => 'Open Store';

  @override
  String get appInfoStoreLinkCopied => 'Store link copied.';

  @override
  String get appInfoVersionTitle => 'App Version';

  @override
  String appInfoCurrentVersion(String version, String buildNumber) {
    return 'Current version $version+$buildNumber';
  }

  @override
  String get appInfoCheckingVersion => 'Checking version...';

  @override
  String get appInfoDataSource => 'Data Sources';

  @override
  String get appInfoKma => 'Korea Meteorological Administration';

  @override
  String get appInfoKmaDescription => 'Provides weather and forecast data.';

  @override
  String get appInfoAirKorea => 'AirKorea';

  @override
  String get appInfoAirKoreaDescription =>
      'Provides PM10, PM2.5, ozone, and integrated air quality data.';

  @override
  String get appInfoDataSourceNotice =>
      'Some information follows public data portal and public Nuri attribution standards.';

  @override
  String get widgetScoreLabel => 'Score';

  @override
  String get widgetFortuneLabel => 'Fortune';

  @override
  String get widget_description => 'Yegamssi daily summary widget';

  @override
  String get widgetInstallTitle => 'Add the Yegamssi widget';

  @override
  String get widgetInstallMessage =>
      'Check weather, temperature, outdoor score, and fortune directly from your home screen.';

  @override
  String get widgetInstallAction => 'Install Widget';

  @override
  String get widgetInstallManual =>
      'Long-press the home screen and add the Yegamssi widget.';

  @override
  String get updateNoticeTitle => 'Update Notice';

  @override
  String get updateRequiredTitle => 'Update Required';

  @override
  String updateRequiredMessage(String currentVersion, String latestVersion) {
    return 'Current version $currentVersion is no longer supported.\nPlease update to version $latestVersion.';
  }

  @override
  String updateAvailableMessage(String latestVersion) {
    return 'Version $latestVersion is ready.\nUpdate now?';
  }

  @override
  String get updateAction => 'Update';

  @override
  String get updateNewVersionMessage =>
      'A new version has been released.\nUpdate now?';

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
