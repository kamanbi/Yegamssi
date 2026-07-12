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
  String get tabMonthlyYegamssi => 'Monthly';

  @override
  String get monthlyYegamssiTitle => 'Monthly Yegamssi';

  @override
  String get monthlyYegamssiSubtitle =>
      'See this month\'s good days and days to watch for each category.';

  @override
  String get monthlyGoodDaysLabel => 'Good days';

  @override
  String get monthlyCautionDaysLabel => 'Watch out';

  @override
  String get monthlyGeneratingMessage =>
      'Preparing this month\'s Monthly Yegamssi.';

  @override
  String get monthlyFailedMessage =>
      'We couldn\'t prepare this month\'s Monthly Yegamssi. Please restart the app.';

  @override
  String get monthlyDisclaimer =>
      'Monthly Yegamssi is reference content based on Myeongri flow. Please weigh important decisions against real-world conditions.';

  @override
  String get monthlySummaryEarly =>
      'The flow is strong early this month, so moving ahead sooner works in your favor.';

  @override
  String get monthlySummaryMid =>
      'The flow improves from mid-month onward, so watching for the right moment beats rushing.';

  @override
  String get monthlySummaryLate =>
      'Push through later in the month and good results will follow.';

  @override
  String get monthlyCategoryLove => 'Love';

  @override
  String get monthlyCategoryLoveMessage =>
      'Good days are great for expressing how you feel first. On days to watch, a calm conversation works better.';

  @override
  String get monthlyCategoryWork => 'Work';

  @override
  String get monthlyCategoryWorkMessage =>
      'Good days are great for starting something new. On days to watch, ease off and focus on wrapping things up.';

  @override
  String get monthlyCategoryMoney => 'Money';

  @override
  String get monthlyCategoryMoneyMessage =>
      'Good days are great for tidying up your finances. On days to watch, double-check before any big spending.';

  @override
  String get monthlyCategoryRelationship => 'Relationships';

  @override
  String get monthlyCategoryRelationshipMessage =>
      'Good days are great for talking with people. On days to watch, choose your words carefully to avoid misunderstandings.';

  @override
  String get monthlyCategoryHealth => 'Health';

  @override
  String get monthlyCategoryHealthMessage =>
      'Good days are great for getting your body moving. On days to watch, don\'t overdo it and make room for rest.';

  @override
  String get monthlyCategoryDecision => 'Decisions';

  @override
  String get monthlyCategoryDecisionMessage =>
      'Good days are great for making an important call. On days to watch, hold off and look things over a bit more.';

  @override
  String get monthlyCategoryTravel => 'Travel';

  @override
  String get monthlyCategoryTravelMessage =>
      'Good days are great for planning an outing or trip. On days to watch, leave some slack in your schedule.';

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
    return 'Feels $temp℃';
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
  String get fortuneHelpTooltip => 'Fortune help';

  @override
  String get fortuneHelpTitle => 'How Yegamssi Reads Fortune';

  @override
  String get fortuneHelpIntro =>
      'Yegamssi reads the flow of today\'s fortune based on Myeongri.';

  @override
  String get fortuneHelpMyeongri =>
      'Myeongri is an East Asian fortune system that looks at the Four Pillars and the balance of the five elements using your birth date and time. Yegamssi calculates your basic personal energy from your birth date and birth time, compares it with today\'s flow, and guides your overall, money, love, work, health, and decision fortune.';

  @override
  String get fortuneHelpBirthTime =>
      'If you do not know your birth time, you can use noon as the default. Entering the birth time helps produce a more detailed reading.';

  @override
  String get fortuneHelpWeather =>
      'Yegamssi also reflects weather and activity scores, not only fortune. If today\'s energy is good but the weather is poor, the outdoor recommendation can be lower. If fortune and weather are both stable, it can be a better day to act.';

  @override
  String get fortuneHelpReference =>
      'Fortune is a reference, not a fixed answer. Use it to preview today\'s flow and choose contacts, outings, spending, contracts, and important decisions with a little more care.';

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
  String get luckyColorRed => 'Red';

  @override
  String get luckyColorOrange => 'Orange';

  @override
  String get luckyColorYellow => 'Yellow';

  @override
  String get luckyColorTeal => 'Teal';

  @override
  String get luckyColorBlue => 'Blue';

  @override
  String get luckyColorPurple => 'Purple';

  @override
  String get luckyColorPink => 'Pink';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsCountry => 'Region';

  @override
  String get countryKorea => 'Korea';

  @override
  String get countryUnitedStates => 'United States';

  @override
  String get countryJapan => 'Japan';

  @override
  String get countryChina => 'China';

  @override
  String get countryGlobal => 'Global';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get settingsThemeDescription =>
      'Default theme uses the day theme from 6:00 AM to 7:00 PM based on the connected location\'s local time, and the night theme outside that range. Day theme and night theme stay fixed regardless of time.';

  @override
  String get settingsThemeAutomatic => 'Default theme';

  @override
  String get settingsThemeAutomaticDescription =>
      'Uses the day theme from 06:00 to 19:00 at the connected location, then switches to the night theme from 19:00 until before 06:00 the next day.';

  @override
  String get settingsThemeDay => 'Day theme';

  @override
  String get settingsThemeDayDescription =>
      'Always uses the bright day theme regardless of time.';

  @override
  String get settingsThemeNight => 'Night theme';

  @override
  String get settingsThemeNightDescription =>
      'Always uses the existing dark night theme regardless of time.';

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
  String get settingsBirthEdit => 'Edit';

  @override
  String get settingsBirthUnknownHour => 'Unknown';

  @override
  String get onboardingGenderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderUnspecified => 'Prefer not to say';

  @override
  String get settingsGenderTitle => 'Gender';

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
  String get settingsPremiumTitle => 'Remove Ads (Lifetime)';

  @override
  String get settingsPremiumDescription =>
      'Permanently remove banner and interstitial ads.';

  @override
  String get settingsPremiumButton => 'Remove Ads';

  @override
  String settingsPremiumButtonPriced(String price) {
    return 'Remove Ads — $price';
  }

  @override
  String get settingsPremiumPurchasedTitle => 'Ads Removed';

  @override
  String get settingsPremiumPurchasedDescription =>
      'Thank you for your support.';

  @override
  String get premiumMsgSuccess => 'Ads have been removed. Thank you!';

  @override
  String get premiumMsgCanceled => 'Purchase canceled.';

  @override
  String get premiumMsgError => 'Purchase failed. Please try again later.';

  @override
  String get premiumMsgStoreUnavailable =>
      'Cannot connect to the store. Please try again later.';

  @override
  String get premiumMsgProductUnavailable =>
      'This item is currently unavailable.';

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
  String get appInfoKma => 'Korea Meteorological Administration (KMA)';

  @override
  String get appInfoKmaDescription =>
      'Provides weather and forecast data for South Korea.';

  @override
  String get appInfoAirKorea => 'AirKorea';

  @override
  String get appInfoAirKoreaDescription =>
      'Provides PM10, PM2.5, ozone, and integrated air quality data for South Korea.';

  @override
  String get appInfoOpenWeather => 'OpenWeather';

  @override
  String get appInfoOpenWeatherDescription =>
      'Provides international weather, forecast, and air quality (PM10, PM2.5, O3) data.';

  @override
  String get appInfoNominatim => 'OpenStreetMap Nominatim';

  @override
  String get appInfoNominatimDescription =>
      'Converts coordinates to localized place names. (ODbL license)';

  @override
  String get appInfoNoaa => 'NOAA / National Weather Service';

  @override
  String get appInfoNoaaDescription =>
      'Provides official weather forecasts and hourly data for the United States. (Public domain)';

  @override
  String get appInfoAirNow => 'U.S. EPA AirNow';

  @override
  String get appInfoAirNowDescription =>
      'Provides real-time air quality data (PM2.5, PM10, Ozone) for the United States.';

  @override
  String get appInfoDataSourceNotice =>
      'Some information follows KOGL attribution standards. International data is provided by OpenWeather API.';

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
  String get appReviewTitle => 'Could you spare a moment? 🙏';

  @override
  String get appReviewMessage =>
      'Thank you so much for using Yegamssi. As a small one-person project, a 5-star rating from you would mean the world to us. Would you mind leaving a 5-star review?';

  @override
  String get appReviewAction => 'Rate 5 Stars';

  @override
  String get appReviewLater => 'Maybe Later';

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

  @override
  String get settingsBackgroundRefreshTitle => 'Background refresh';

  @override
  String get settingsBackgroundRefreshDescription =>
      'Updates weather, air quality, outdoor score, and widget data about every 30 minutes. Battery optimization exception improves reliability.';

  @override
  String get settingsBackgroundRefreshStatusEnabled =>
      'Battery exception enabled';

  @override
  String get settingsBackgroundRefreshStatusLimited =>
      'Battery exception needed';

  @override
  String get settingsBackgroundRefreshAction => 'Open settings';

  @override
  String get batteryOptimizationReminderTitle =>
      'Allow stable background refresh';

  @override
  String get batteryOptimizationReminderMessage =>
      'Yegamssi can update weather, air quality, and widgets more reliably every 30 minutes when battery optimization is disabled for this app.';

  @override
  String get batteryOptimizationReminderLater => 'Later';

  @override
  String get batteryOptimizationReminderNever => 'Don\'t show again';

  @override
  String get batteryOptimizationReminderSettings => 'Open settings';

  @override
  String get settingsSupportTitle => 'Support';

  @override
  String get settingsSupportDescription =>
      'Support Yegamssi with a review or a short ad view.';

  @override
  String get settingsSupportSheetDescription =>
      'A small action helps keep Yegamssi improving.';

  @override
  String get settingsSupportReviewAction => 'Write a review';

  @override
  String get settingsSupportAdAction =>
      'Watch an interstitial ad to support the developer';

  @override
  String get settingsSupportReviewFailed =>
      'Could not open the review screen. Please try again later.';

  @override
  String get settingsSupportAdThanks => 'Thank you for supporting Yegamssi.';

  @override
  String get settingsSupportPremiumThanks =>
      'You already supported Yegamssi by removing ads. Thank you.';

  @override
  String get settingsSupportAdFailed =>
      'Could not load an ad. Please try again later.';
}
