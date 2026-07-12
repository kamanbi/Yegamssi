import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ro'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Yegamssi'**
  String get appName;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabHome;

  /// No description provided for @tabWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get tabWeather;

  /// No description provided for @tabScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get tabScore;

  /// No description provided for @tabMonthlyYegamssi.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get tabMonthlyYegamssi;

  /// No description provided for @monthlyYegamssiTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Yegamssi'**
  String get monthlyYegamssiTitle;

  /// No description provided for @monthlyYegamssiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See this month\'s good days and days to watch for each category.'**
  String get monthlyYegamssiSubtitle;

  /// No description provided for @monthlyGoodDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Good days'**
  String get monthlyGoodDaysLabel;

  /// No description provided for @monthlyCautionDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Watch out'**
  String get monthlyCautionDaysLabel;

  /// No description provided for @monthlyGeneratingMessage.
  ///
  /// In en, this message translates to:
  /// **'Preparing this month\'s Monthly Yegamssi.'**
  String get monthlyGeneratingMessage;

  /// No description provided for @monthlyFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t prepare this month\'s Monthly Yegamssi. Please restart the app.'**
  String get monthlyFailedMessage;

  /// No description provided for @monthlyDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Monthly Yegamssi is reference content based on Myeongri flow. Please weigh important decisions against real-world conditions.'**
  String get monthlyDisclaimer;

  /// No description provided for @monthlySummaryEarly.
  ///
  /// In en, this message translates to:
  /// **'The flow is strong early this month, so moving ahead sooner works in your favor.'**
  String get monthlySummaryEarly;

  /// No description provided for @monthlySummaryMid.
  ///
  /// In en, this message translates to:
  /// **'The flow improves from mid-month onward, so watching for the right moment beats rushing.'**
  String get monthlySummaryMid;

  /// No description provided for @monthlySummaryLate.
  ///
  /// In en, this message translates to:
  /// **'Push through later in the month and good results will follow.'**
  String get monthlySummaryLate;

  /// No description provided for @monthlyCategoryLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get monthlyCategoryLove;

  /// No description provided for @monthlyCategoryLoveMessage.
  ///
  /// In en, this message translates to:
  /// **'Good days are great for expressing how you feel first. On days to watch, a calm conversation works better.'**
  String get monthlyCategoryLoveMessage;

  /// No description provided for @monthlyCategoryWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get monthlyCategoryWork;

  /// No description provided for @monthlyCategoryWorkMessage.
  ///
  /// In en, this message translates to:
  /// **'Good days are great for starting something new. On days to watch, ease off and focus on wrapping things up.'**
  String get monthlyCategoryWorkMessage;

  /// No description provided for @monthlyCategoryMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get monthlyCategoryMoney;

  /// No description provided for @monthlyCategoryMoneyMessage.
  ///
  /// In en, this message translates to:
  /// **'Good days are great for tidying up your finances. On days to watch, double-check before any big spending.'**
  String get monthlyCategoryMoneyMessage;

  /// No description provided for @monthlyCategoryRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get monthlyCategoryRelationship;

  /// No description provided for @monthlyCategoryRelationshipMessage.
  ///
  /// In en, this message translates to:
  /// **'Good days are great for talking with people. On days to watch, choose your words carefully to avoid misunderstandings.'**
  String get monthlyCategoryRelationshipMessage;

  /// No description provided for @monthlyCategoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get monthlyCategoryHealth;

  /// No description provided for @monthlyCategoryHealthMessage.
  ///
  /// In en, this message translates to:
  /// **'Good days are great for getting your body moving. On days to watch, don\'t overdo it and make room for rest.'**
  String get monthlyCategoryHealthMessage;

  /// No description provided for @monthlyCategoryDecision.
  ///
  /// In en, this message translates to:
  /// **'Decisions'**
  String get monthlyCategoryDecision;

  /// No description provided for @monthlyCategoryDecisionMessage.
  ///
  /// In en, this message translates to:
  /// **'Good days are great for making an important call. On days to watch, hold off and look things over a bit more.'**
  String get monthlyCategoryDecisionMessage;

  /// No description provided for @monthlyCategoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get monthlyCategoryTravel;

  /// No description provided for @monthlyCategoryTravelMessage.
  ///
  /// In en, this message translates to:
  /// **'Good days are great for planning an outing or trip. On days to watch, leave some slack in your schedule.'**
  String get monthlyCategoryTravelMessage;

  /// No description provided for @tabFortune.
  ///
  /// In en, this message translates to:
  /// **'Fortune'**
  String get tabFortune;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Weather and signals for today'**
  String get homeHeadline;

  /// No description provided for @homeWeatherLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading current weather'**
  String get homeWeatherLoadingTitle;

  /// No description provided for @homeWeatherLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Preparing location and weather data.'**
  String get homeWeatherLoadingMessage;

  /// No description provided for @homeWeatherErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load current weather'**
  String get homeWeatherErrorTitle;

  /// No description provided for @homeWeatherErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Open the weather screen and try again.'**
  String get homeWeatherErrorMessage;

  /// No description provided for @homeWeatherAction.
  ///
  /// In en, this message translates to:
  /// **'View Weather'**
  String get homeWeatherAction;

  /// No description provided for @homeFortuneLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing today\'s fortune'**
  String get homeFortuneLoadingTitle;

  /// No description provided for @homeFortuneLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'A short summary will appear soon.'**
  String get homeFortuneLoadingMessage;

  /// No description provided for @homeFortuneErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Fortune is not ready yet'**
  String get homeFortuneErrorTitle;

  /// No description provided for @homeFortuneErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your profile and try again on the fortune screen.'**
  String get homeFortuneErrorMessage;

  /// No description provided for @homeFortuneAction.
  ///
  /// In en, this message translates to:
  /// **'View Fortune'**
  String get homeFortuneAction;

  /// No description provided for @homeFortuneHeadline.
  ///
  /// In en, this message translates to:
  /// **'Today\'s fortune in one line'**
  String get homeFortuneHeadline;

  /// No description provided for @appExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit app'**
  String get appExitTitle;

  /// No description provided for @appExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to close Yegamssi?'**
  String get appExitMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loadingAd.
  ///
  /// In en, this message translates to:
  /// **'Loading ad...'**
  String get loadingAd;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @refreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Refresh failed: {error}'**
  String refreshFailed(String error);

  /// No description provided for @notFoundPage.
  ///
  /// In en, this message translates to:
  /// **'Page not found: {error}'**
  String notFoundPage(String error);

  /// No description provided for @weatherFeelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like {temp}°C'**
  String weatherFeelsLike(String temp);

  /// No description provided for @weatherFeelsLikeShort.
  ///
  /// In en, this message translates to:
  /// **'Feels {temp}℃'**
  String weatherFeelsLikeShort(String temp);

  /// No description provided for @weatherHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity {value}%'**
  String weatherHumidity(int value);

  /// No description provided for @weatherWind.
  ///
  /// In en, this message translates to:
  /// **'Wind {speed}m/s'**
  String weatherWind(String speed);

  /// No description provided for @weatherHumidityLabel.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get weatherHumidityLabel;

  /// No description provided for @weatherWindLabel.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get weatherWindLabel;

  /// No description provided for @weatherWindSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Wind speed'**
  String get weatherWindSpeedLabel;

  /// No description provided for @weatherPrecipitationLabel.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get weatherPrecipitationLabel;

  /// No description provided for @weatherPrecipitationAmount.
  ///
  /// In en, this message translates to:
  /// **'Rainfall {amount}'**
  String weatherPrecipitationAmount(String amount);

  /// No description provided for @weatherDustPm10.
  ///
  /// In en, this message translates to:
  /// **'PM10'**
  String get weatherDustPm10;

  /// No description provided for @weatherDustPm25.
  ///
  /// In en, this message translates to:
  /// **'PM2.5'**
  String get weatherDustPm25;

  /// No description provided for @weatherHourlyForecast.
  ///
  /// In en, this message translates to:
  /// **'Hourly Forecast'**
  String get weatherHourlyForecast;

  /// No description provided for @weatherWeeklyForecast.
  ///
  /// In en, this message translates to:
  /// **'Weekly Forecast'**
  String get weatherWeeklyForecast;

  /// No description provided for @weatherLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading weather...'**
  String get weatherLoading;

  /// No description provided for @weatherErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to get weather data'**
  String get weatherErrorTitle;

  /// No description provided for @weatherReturnCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Returning to current location in {seconds}s'**
  String weatherReturnCurrentLocation(int seconds);

  /// No description provided for @weatherToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get weatherToday;

  /// No description provided for @weatherAm.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get weatherAm;

  /// No description provided for @weatherPm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get weatherPm;

  /// No description provided for @weatherHour.
  ///
  /// In en, this message translates to:
  /// **'{hour}:00'**
  String weatherHour(String hour);

  /// No description provided for @weatherUvVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'{uv} Very high'**
  String weatherUvVeryHigh(int uv);

  /// No description provided for @weatherUvHigh.
  ///
  /// In en, this message translates to:
  /// **'{uv} High'**
  String weatherUvHigh(int uv);

  /// No description provided for @weatherUvModerateHigh.
  ///
  /// In en, this message translates to:
  /// **'{uv} Moderate high'**
  String weatherUvModerateHigh(int uv);

  /// No description provided for @weatherUvModerate.
  ///
  /// In en, this message translates to:
  /// **'{uv} Moderate'**
  String weatherUvModerate(int uv);

  /// No description provided for @weatherUvLow.
  ///
  /// In en, this message translates to:
  /// **'{uv} Low'**
  String weatherUvLow(int uv);

  /// No description provided for @weatherConditionSunny.
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get weatherConditionSunny;

  /// No description provided for @weatherConditionClearNight.
  ///
  /// In en, this message translates to:
  /// **'Clear night'**
  String get weatherConditionClearNight;

  /// No description provided for @weatherConditionPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get weatherConditionPartlyCloudy;

  /// No description provided for @weatherConditionPartlyCloudyNight.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy night'**
  String get weatherConditionPartlyCloudyNight;

  /// No description provided for @weatherConditionCloudy.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get weatherConditionCloudy;

  /// No description provided for @weatherConditionHazy.
  ///
  /// In en, this message translates to:
  /// **'Hazy'**
  String get weatherConditionHazy;

  /// No description provided for @weatherConditionWindy.
  ///
  /// In en, this message translates to:
  /// **'Windy'**
  String get weatherConditionWindy;

  /// No description provided for @weatherConditionSlightRain.
  ///
  /// In en, this message translates to:
  /// **'Light rain'**
  String get weatherConditionSlightRain;

  /// No description provided for @weatherConditionRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get weatherConditionRain;

  /// No description provided for @weatherConditionHeavyRain.
  ///
  /// In en, this message translates to:
  /// **'Heavy rain'**
  String get weatherConditionHeavyRain;

  /// No description provided for @weatherConditionThunderstorm.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get weatherConditionThunderstorm;

  /// No description provided for @weatherConditionRainThunder.
  ///
  /// In en, this message translates to:
  /// **'Rain and thunder'**
  String get weatherConditionRainThunder;

  /// No description provided for @weatherConditionLightSnow.
  ///
  /// In en, this message translates to:
  /// **'Light snow'**
  String get weatherConditionLightSnow;

  /// No description provided for @weatherConditionSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get weatherConditionSnow;

  /// No description provided for @weatherConditionSleet.
  ///
  /// In en, this message translates to:
  /// **'Sleet'**
  String get weatherConditionSleet;

  /// No description provided for @weatherConditionHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get weatherConditionHot;

  /// No description provided for @weatherConditionHotNight.
  ///
  /// In en, this message translates to:
  /// **'Hot night'**
  String get weatherConditionHotNight;

  /// No description provided for @weatherConditionColdWave.
  ///
  /// In en, this message translates to:
  /// **'Cold wave'**
  String get weatherConditionColdWave;

  /// No description provided for @weatherConditionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get weatherConditionUnknown;

  /// No description provided for @locationCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get locationCurrent;

  /// No description provided for @locationSelectClose.
  ///
  /// In en, this message translates to:
  /// **'Close location selector'**
  String get locationSelectClose;

  /// No description provided for @locationAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String locationAdded(String name);

  /// No description provided for @locationFavoriteLimit.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 5 locations.'**
  String get locationFavoriteLimit;

  /// No description provided for @locationFavoriteFull.
  ///
  /// In en, this message translates to:
  /// **'Favorites full'**
  String get locationFavoriteFull;

  /// No description provided for @locationFavoriteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add favorite'**
  String get locationFavoriteAdd;

  /// No description provided for @locationSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Location'**
  String get locationSearchTitle;

  /// No description provided for @locationSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Seoul, Busan, Tokyo'**
  String get locationSearchHint;

  /// No description provided for @locationSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get locationSearchEmpty;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Outdoor Activity Score'**
  String get scoreLabel;

  /// No description provided for @scoreLoading.
  ///
  /// In en, this message translates to:
  /// **'Calculating outdoor activity score...'**
  String get scoreLoading;

  /// No description provided for @scoreErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to calculate score'**
  String get scoreErrorTitle;

  /// No description provided for @scoreBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get scoreBreakdownTitle;

  /// No description provided for @scoreNoDeduction.
  ///
  /// In en, this message translates to:
  /// **'Stable outdoor conditions with almost no deduction factors.'**
  String get scoreNoDeduction;

  /// No description provided for @scoreInfo.
  ///
  /// In en, this message translates to:
  /// **'Outdoor activity score is calculated from rain, wind, feels-like temperature, air quality, and UV data.'**
  String get scoreInfo;

  /// No description provided for @scoreDeductionRain.
  ///
  /// In en, this message translates to:
  /// **'Rain and snow'**
  String get scoreDeductionRain;

  /// No description provided for @scoreDeductionWind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get scoreDeductionWind;

  /// No description provided for @scoreDeductionTemp.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get scoreDeductionTemp;

  /// No description provided for @scoreDeductionAir.
  ///
  /// In en, this message translates to:
  /// **'Air quality'**
  String get scoreDeductionAir;

  /// No description provided for @scoreDeductionUv.
  ///
  /// In en, this message translates to:
  /// **'UV'**
  String get scoreDeductionUv;

  /// No description provided for @scoreDeductionOzone.
  ///
  /// In en, this message translates to:
  /// **'Ozone'**
  String get scoreDeductionOzone;

  /// No description provided for @scoreAdviceExcellent.
  ///
  /// In en, this message translates to:
  /// **'Today is good for outdoor activity.\nStep out lightly and lift your condition.'**
  String get scoreAdviceExcellent;

  /// No description provided for @scoreAdviceGood.
  ///
  /// In en, this message translates to:
  /// **'Outdoor activity is fine, but check wind and UV once more.'**
  String get scoreAdviceGood;

  /// No description provided for @scoreAdviceFair.
  ///
  /// In en, this message translates to:
  /// **'Outdoor activity is possible, and better preparation will make it easier.'**
  String get scoreAdviceFair;

  /// No description provided for @scoreAdvicePoor.
  ///
  /// In en, this message translates to:
  /// **'It is safer to plan around indoor activities today.'**
  String get scoreAdvicePoor;

  /// No description provided for @scoreTierExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get scoreTierExcellent;

  /// No description provided for @scoreTierGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get scoreTierGood;

  /// No description provided for @scoreTierFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get scoreTierFair;

  /// No description provided for @scoreTierPoor.
  ///
  /// In en, this message translates to:
  /// **'Caution'**
  String get scoreTierPoor;

  /// No description provided for @scorePointUnit.
  ///
  /// In en, this message translates to:
  /// **'{score} pts'**
  String scorePointUnit(int score);

  /// No description provided for @activityRecommendOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor activity recommended'**
  String get activityRecommendOutdoor;

  /// No description provided for @activityRecommendLight.
  ///
  /// In en, this message translates to:
  /// **'Light activity fits'**
  String get activityRecommendLight;

  /// No description provided for @activityRecommendCaution.
  ///
  /// In en, this message translates to:
  /// **'Caution needed'**
  String get activityRecommendCaution;

  /// No description provided for @activityRecommendIndoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor activity recommended'**
  String get activityRecommendIndoor;

  /// No description provided for @airQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Air Quality'**
  String get airQualityTitle;

  /// No description provided for @airQualityIntegrated.
  ///
  /// In en, this message translates to:
  /// **'Integrated Air Quality'**
  String get airQualityIntegrated;

  /// No description provided for @airQualityUnknown.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get airQualityUnknown;

  /// No description provided for @airGradeGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get airGradeGood;

  /// No description provided for @airGradeModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get airGradeModerate;

  /// No description provided for @airGradeBad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get airGradeBad;

  /// No description provided for @airGradeVeryBad.
  ///
  /// In en, this message translates to:
  /// **'Very bad'**
  String get airGradeVeryBad;

  /// No description provided for @pointUnit.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get pointUnit;

  /// No description provided for @fortuneTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Daily Fortune'**
  String get fortuneTitle;

  /// No description provided for @fortuneNeedProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Birth information is needed'**
  String get fortuneNeedProfileTitle;

  /// No description provided for @fortuneNeedProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your birth date and time to receive today\'s fortune in a calm tone.'**
  String get fortuneNeedProfileMessage;

  /// No description provided for @fortuneBirthInputAction.
  ///
  /// In en, this message translates to:
  /// **'Enter Birth Info'**
  String get fortuneBirthInputAction;

  /// No description provided for @fortuneHelpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Fortune help'**
  String get fortuneHelpTooltip;

  /// No description provided for @fortuneHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How Yegamssi Reads Fortune'**
  String get fortuneHelpTitle;

  /// No description provided for @fortuneHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Yegamssi reads the flow of today\'s fortune based on Myeongri.'**
  String get fortuneHelpIntro;

  /// No description provided for @fortuneHelpMyeongri.
  ///
  /// In en, this message translates to:
  /// **'Myeongri is an East Asian fortune system that looks at the Four Pillars and the balance of the five elements using your birth date and time. Yegamssi calculates your basic personal energy from your birth date and birth time, compares it with today\'s flow, and guides your overall, money, love, work, health, and decision fortune.'**
  String get fortuneHelpMyeongri;

  /// No description provided for @fortuneHelpBirthTime.
  ///
  /// In en, this message translates to:
  /// **'If you do not know your birth time, you can use noon as the default. Entering the birth time helps produce a more detailed reading.'**
  String get fortuneHelpBirthTime;

  /// No description provided for @fortuneHelpWeather.
  ///
  /// In en, this message translates to:
  /// **'Yegamssi also reflects weather and activity scores, not only fortune. If today\'s energy is good but the weather is poor, the outdoor recommendation can be lower. If fortune and weather are both stable, it can be a better day to act.'**
  String get fortuneHelpWeather;

  /// No description provided for @fortuneHelpReference.
  ///
  /// In en, this message translates to:
  /// **'Fortune is a reference, not a fixed answer. Use it to preview today\'s flow and choose contacts, outings, spending, contracts, and important decisions with a little more care.'**
  String get fortuneHelpReference;

  /// No description provided for @fortuneLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load fortune'**
  String get fortuneLoadFailedTitle;

  /// No description provided for @fortuneLoadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get fortuneLoadFailedMessage;

  /// No description provided for @fortuneCategoryAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Category Analysis'**
  String get fortuneCategoryAnalysis;

  /// No description provided for @fortuneOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall Fortune'**
  String get fortuneOverall;

  /// No description provided for @fortuneCategoryMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get fortuneCategoryMoney;

  /// No description provided for @fortuneCategoryLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get fortuneCategoryLove;

  /// No description provided for @fortuneCategoryWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get fortuneCategoryWork;

  /// No description provided for @fortuneCategoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get fortuneCategoryHealth;

  /// No description provided for @fortuneCategoryDecision.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get fortuneCategoryDecision;

  /// No description provided for @fortuneLuckyColor.
  ///
  /// In en, this message translates to:
  /// **'Lucky Color'**
  String get fortuneLuckyColor;

  /// No description provided for @fortuneLuckyNumber.
  ///
  /// In en, this message translates to:
  /// **'Lucky Number'**
  String get fortuneLuckyNumber;

  /// No description provided for @fortuneOhengBalance.
  ///
  /// In en, this message translates to:
  /// **'Element Balance'**
  String get fortuneOhengBalance;

  /// No description provided for @fortuneOhengDescription.
  ///
  /// In en, this message translates to:
  /// **'A supporting signal for today\'s emotional flow.'**
  String get fortuneOhengDescription;

  /// No description provided for @fortuneCaptureTooltip.
  ///
  /// In en, this message translates to:
  /// **'Capture fortune card'**
  String get fortuneCaptureTooltip;

  /// No description provided for @fortuneCaptureSaved.
  ///
  /// In en, this message translates to:
  /// **'Fortune card capture saved.'**
  String get fortuneCaptureSaved;

  /// No description provided for @fortuneCaptureSaveDone.
  ///
  /// In en, this message translates to:
  /// **'Fortune card capture complete'**
  String get fortuneCaptureSaveDone;

  /// No description provided for @fortuneCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'Capture failed: {error}'**
  String fortuneCaptureFailed(String error);

  /// No description provided for @fortuneOpenFolder.
  ///
  /// In en, this message translates to:
  /// **'Open Folder'**
  String get fortuneOpenFolder;

  /// No description provided for @fortuneAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing.'**
  String get fortuneAnalyzing;

  /// No description provided for @fortuneToneBase.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get fortuneToneBase;

  /// No description provided for @fortuneToneHumor.
  ///
  /// In en, this message translates to:
  /// **'Humor'**
  String get fortuneToneHumor;

  /// No description provided for @fortuneToneTsundere.
  ///
  /// In en, this message translates to:
  /// **'Tsundere'**
  String get fortuneToneTsundere;

  /// No description provided for @fortuneToneCynical.
  ///
  /// In en, this message translates to:
  /// **'Cynical'**
  String get fortuneToneCynical;

  /// No description provided for @fortuneToneEmotional.
  ///
  /// In en, this message translates to:
  /// **'Emotional'**
  String get fortuneToneEmotional;

  /// No description provided for @fortuneToneHistorical.
  ///
  /// In en, this message translates to:
  /// **'Historical'**
  String get fortuneToneHistorical;

  /// No description provided for @fortuneToneAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get fortuneToneAi;

  /// No description provided for @fortuneTimeMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get fortuneTimeMorning;

  /// No description provided for @fortuneTimeAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get fortuneTimeAfternoon;

  /// No description provided for @ohengMok.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get ohengMok;

  /// No description provided for @ohengHwa.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get ohengHwa;

  /// No description provided for @ohengTo.
  ///
  /// In en, this message translates to:
  /// **'Earth'**
  String get ohengTo;

  /// No description provided for @ohengGeum.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get ohengGeum;

  /// No description provided for @ohengSu.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get ohengSu;

  /// No description provided for @luckyColorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get luckyColorGreen;

  /// No description provided for @luckyColorCoral.
  ///
  /// In en, this message translates to:
  /// **'Coral'**
  String get luckyColorCoral;

  /// No description provided for @luckyColorGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get luckyColorGold;

  /// No description provided for @luckyColorSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get luckyColorSilver;

  /// No description provided for @luckyColorSky.
  ///
  /// In en, this message translates to:
  /// **'Sky blue'**
  String get luckyColorSky;

  /// No description provided for @luckyColorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get luckyColorRed;

  /// No description provided for @luckyColorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get luckyColorOrange;

  /// No description provided for @luckyColorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get luckyColorYellow;

  /// No description provided for @luckyColorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get luckyColorTeal;

  /// No description provided for @luckyColorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get luckyColorBlue;

  /// No description provided for @luckyColorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get luckyColorPurple;

  /// No description provided for @luckyColorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get luckyColorPink;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsCountry.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get settingsCountry;

  /// No description provided for @countryKorea.
  ///
  /// In en, this message translates to:
  /// **'Korea'**
  String get countryKorea;

  /// No description provided for @countryUnitedStates.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get countryUnitedStates;

  /// No description provided for @countryJapan.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get countryJapan;

  /// No description provided for @countryChina.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get countryChina;

  /// No description provided for @countryGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get countryGlobal;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Default theme uses the day theme from 6:00 AM to 7:00 PM based on the connected location\'s local time, and the night theme outside that range. Day theme and night theme stay fixed regardless of time.'**
  String get settingsThemeDescription;

  /// No description provided for @settingsThemeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Default theme'**
  String get settingsThemeAutomatic;

  /// No description provided for @settingsThemeAutomaticDescription.
  ///
  /// In en, this message translates to:
  /// **'Uses the day theme from 06:00 to 19:00 at the connected location, then switches to the night theme from 19:00 until before 06:00 the next day.'**
  String get settingsThemeAutomaticDescription;

  /// No description provided for @settingsThemeDay.
  ///
  /// In en, this message translates to:
  /// **'Day theme'**
  String get settingsThemeDay;

  /// No description provided for @settingsThemeDayDescription.
  ///
  /// In en, this message translates to:
  /// **'Always uses the bright day theme regardless of time.'**
  String get settingsThemeDayDescription;

  /// No description provided for @settingsThemeNight.
  ///
  /// In en, this message translates to:
  /// **'Night theme'**
  String get settingsThemeNight;

  /// No description provided for @settingsThemeNightDescription.
  ///
  /// In en, this message translates to:
  /// **'Always uses the existing dark night theme regardless of time.'**
  String get settingsThemeNightDescription;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsBirthTitle.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get settingsBirthTitle;

  /// No description provided for @settingsBirthDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage the birth date and time used for fortune calculation.'**
  String get settingsBirthDescription;

  /// No description provided for @settingsBirthEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not entered'**
  String get settingsBirthEmpty;

  /// No description provided for @settingsBirthEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get settingsBirthEdit;

  /// No description provided for @settingsBirthUnknownHour.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get settingsBirthUnknownHour;

  /// No description provided for @onboardingGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get onboardingGenderLabel;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get genderUnspecified;

  /// No description provided for @settingsGenderTitle.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get settingsGenderTitle;

  /// No description provided for @settingsHourUnit.
  ///
  /// In en, this message translates to:
  /// **'{hour}:00'**
  String settingsHourUnit(int hour);

  /// No description provided for @settingsFortuneToneTitle.
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get settingsFortuneToneTitle;

  /// No description provided for @settingsFortuneToneDescription.
  ///
  /// In en, this message translates to:
  /// **'Fortune messages are shown in the {tone} style.'**
  String settingsFortuneToneDescription(String tone);

  /// No description provided for @settingsFortuneToneSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'Base messages are kept, and the selected style is prioritized.'**
  String get settingsFortuneToneSheetDescription;

  /// No description provided for @settingsAppInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get settingsAppInfoTitle;

  /// No description provided for @settingsAppInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Check homepage, privacy guide, contact email, and links.'**
  String get settingsAppInfoDescription;

  /// No description provided for @settingsPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads (Lifetime)'**
  String get settingsPremiumTitle;

  /// No description provided for @settingsPremiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove banner and interstitial ads.'**
  String get settingsPremiumDescription;

  /// No description provided for @settingsPremiumButton.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get settingsPremiumButton;

  /// No description provided for @settingsPremiumButtonPriced.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads — {price}'**
  String settingsPremiumButtonPriced(String price);

  /// No description provided for @settingsPremiumPurchasedTitle.
  ///
  /// In en, this message translates to:
  /// **'Ads Removed'**
  String get settingsPremiumPurchasedTitle;

  /// No description provided for @settingsPremiumPurchasedDescription.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support.'**
  String get settingsPremiumPurchasedDescription;

  /// No description provided for @premiumMsgSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ads have been removed. Thank you!'**
  String get premiumMsgSuccess;

  /// No description provided for @premiumMsgCanceled.
  ///
  /// In en, this message translates to:
  /// **'Purchase canceled.'**
  String get premiumMsgCanceled;

  /// No description provided for @premiumMsgError.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again later.'**
  String get premiumMsgError;

  /// No description provided for @premiumMsgStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to the store. Please try again later.'**
  String get premiumMsgStoreUnavailable;

  /// No description provided for @premiumMsgProductUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This item is currently unavailable.'**
  String get premiumMsgProductUnavailable;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Yegamssi'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your birth date and time\nto receive today\'s fortune.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingStart;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @birthHour.
  ///
  /// In en, this message translates to:
  /// **'Birth Time'**
  String get birthHour;

  /// No description provided for @birthHourOptional.
  ///
  /// In en, this message translates to:
  /// **'Birth Time (Optional)'**
  String get birthHourOptional;

  /// No description provided for @birthSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get birthSelectDate;

  /// No description provided for @birthUnknownNoon.
  ///
  /// In en, this message translates to:
  /// **'Unknown (calculated at noon)'**
  String get birthUnknownNoon;

  /// No description provided for @birthUnknownNoonShort.
  ///
  /// In en, this message translates to:
  /// **'Unknown (noon)'**
  String get birthUnknownNoonShort;

  /// No description provided for @dateYmd.
  ///
  /// In en, this message translates to:
  /// **'{year}-{month}-{day}'**
  String dateYmd(int year, int month, int day);

  /// No description provided for @hourLabel.
  ///
  /// In en, this message translates to:
  /// **'{hour}:00'**
  String hourLabel(int hour);

  /// No description provided for @appInfoHomepage.
  ///
  /// In en, this message translates to:
  /// **'Homepage'**
  String get appInfoHomepage;

  /// No description provided for @appInfoHomepageDescription.
  ///
  /// In en, this message translates to:
  /// **'Open the Yegamssi introduction page.'**
  String get appInfoHomepageDescription;

  /// No description provided for @appInfoPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get appInfoPrivacy;

  /// No description provided for @appInfoPrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Open the privacy policy page.'**
  String get appInfoPrivacyDescription;

  /// No description provided for @appInfoEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact Email'**
  String get appInfoEmail;

  /// No description provided for @appInfoEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'Open the mail app for inquiries.'**
  String get appInfoEmailDescription;

  /// No description provided for @appInfoShare.
  ///
  /// In en, this message translates to:
  /// **'Share Yegamssi'**
  String get appInfoShare;

  /// No description provided for @appInfoShareDescription.
  ///
  /// In en, this message translates to:
  /// **'Show a QR code linked to the store.'**
  String get appInfoShareDescription;

  /// No description provided for @appInfoShareQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code to open the Yegamssi store page.'**
  String get appInfoShareQrDescription;

  /// No description provided for @appInfoCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get appInfoCopyLink;

  /// No description provided for @appInfoOpenStore.
  ///
  /// In en, this message translates to:
  /// **'Open Store'**
  String get appInfoOpenStore;

  /// No description provided for @appInfoStoreLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Store link copied.'**
  String get appInfoStoreLinkCopied;

  /// No description provided for @appInfoVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appInfoVersionTitle;

  /// No description provided for @appInfoCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version {version}+{buildNumber}'**
  String appInfoCurrentVersion(String version, String buildNumber);

  /// No description provided for @appInfoCheckingVersion.
  ///
  /// In en, this message translates to:
  /// **'Checking version...'**
  String get appInfoCheckingVersion;

  /// No description provided for @appInfoDataSource.
  ///
  /// In en, this message translates to:
  /// **'Data Sources'**
  String get appInfoDataSource;

  /// No description provided for @appInfoKma.
  ///
  /// In en, this message translates to:
  /// **'Korea Meteorological Administration (KMA)'**
  String get appInfoKma;

  /// No description provided for @appInfoKmaDescription.
  ///
  /// In en, this message translates to:
  /// **'Provides weather and forecast data for South Korea.'**
  String get appInfoKmaDescription;

  /// No description provided for @appInfoAirKorea.
  ///
  /// In en, this message translates to:
  /// **'AirKorea'**
  String get appInfoAirKorea;

  /// No description provided for @appInfoAirKoreaDescription.
  ///
  /// In en, this message translates to:
  /// **'Provides PM10, PM2.5, ozone, and integrated air quality data for South Korea.'**
  String get appInfoAirKoreaDescription;

  /// No description provided for @appInfoOpenWeather.
  ///
  /// In en, this message translates to:
  /// **'OpenWeather'**
  String get appInfoOpenWeather;

  /// No description provided for @appInfoOpenWeatherDescription.
  ///
  /// In en, this message translates to:
  /// **'Provides international weather, forecast, and air quality (PM10, PM2.5, O3) data.'**
  String get appInfoOpenWeatherDescription;

  /// No description provided for @appInfoNominatim.
  ///
  /// In en, this message translates to:
  /// **'OpenStreetMap Nominatim'**
  String get appInfoNominatim;

  /// No description provided for @appInfoNominatimDescription.
  ///
  /// In en, this message translates to:
  /// **'Converts coordinates to localized place names. (ODbL license)'**
  String get appInfoNominatimDescription;

  /// No description provided for @appInfoNoaa.
  ///
  /// In en, this message translates to:
  /// **'NOAA / National Weather Service'**
  String get appInfoNoaa;

  /// No description provided for @appInfoNoaaDescription.
  ///
  /// In en, this message translates to:
  /// **'Provides official weather forecasts and hourly data for the United States. (Public domain)'**
  String get appInfoNoaaDescription;

  /// No description provided for @appInfoAirNow.
  ///
  /// In en, this message translates to:
  /// **'U.S. EPA AirNow'**
  String get appInfoAirNow;

  /// No description provided for @appInfoAirNowDescription.
  ///
  /// In en, this message translates to:
  /// **'Provides real-time air quality data (PM2.5, PM10, Ozone) for the United States.'**
  String get appInfoAirNowDescription;

  /// No description provided for @appInfoDataSourceNotice.
  ///
  /// In en, this message translates to:
  /// **'Some information follows KOGL attribution standards. International data is provided by OpenWeather API.'**
  String get appInfoDataSourceNotice;

  /// No description provided for @widgetScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get widgetScoreLabel;

  /// No description provided for @widgetFortuneLabel.
  ///
  /// In en, this message translates to:
  /// **'Fortune'**
  String get widgetFortuneLabel;

  /// No description provided for @widget_description.
  ///
  /// In en, this message translates to:
  /// **'Yegamssi daily summary widget'**
  String get widget_description;

  /// No description provided for @widgetInstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Add the Yegamssi widget'**
  String get widgetInstallTitle;

  /// No description provided for @widgetInstallMessage.
  ///
  /// In en, this message translates to:
  /// **'Check weather, temperature, outdoor score, and fortune directly from your home screen.'**
  String get widgetInstallMessage;

  /// No description provided for @widgetInstallAction.
  ///
  /// In en, this message translates to:
  /// **'Install Widget'**
  String get widgetInstallAction;

  /// No description provided for @widgetInstallManual.
  ///
  /// In en, this message translates to:
  /// **'Long-press the home screen and add the Yegamssi widget.'**
  String get widgetInstallManual;

  /// No description provided for @appReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Could you spare a moment? 🙏'**
  String get appReviewTitle;

  /// No description provided for @appReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you so much for using Yegamssi. As a small one-person project, a 5-star rating from you would mean the world to us. Would you mind leaving a 5-star review?'**
  String get appReviewMessage;

  /// No description provided for @appReviewAction.
  ///
  /// In en, this message translates to:
  /// **'Rate 5 Stars'**
  String get appReviewAction;

  /// No description provided for @appReviewLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get appReviewLater;

  /// No description provided for @updateNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Notice'**
  String get updateNoticeTitle;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Current version {currentVersion} is no longer supported.\nPlease update to version {latestVersion}.'**
  String updateRequiredMessage(String currentVersion, String latestVersion);

  /// No description provided for @updateAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Version {latestVersion} is ready.\nUpdate now?'**
  String updateAvailableMessage(String latestVersion);

  /// No description provided for @updateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAction;

  /// No description provided for @updateNewVersionMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version has been released.\nUpdate now?'**
  String get updateNewVersionMessage;

  /// No description provided for @activityRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get activityRunning;

  /// No description provided for @activityCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get activityCycling;

  /// No description provided for @activityHiking.
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get activityHiking;

  /// No description provided for @activityWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get activityWalking;

  /// No description provided for @activityOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor Work'**
  String get activityOutdoor;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection.'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred.'**
  String get errorServer;

  /// No description provided for @errorLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to get location.'**
  String get errorLocation;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get errorUnknown;

  /// No description provided for @settingsBackgroundRefreshTitle.
  ///
  /// In en, this message translates to:
  /// **'Background refresh'**
  String get settingsBackgroundRefreshTitle;

  /// No description provided for @settingsBackgroundRefreshDescription.
  ///
  /// In en, this message translates to:
  /// **'Updates weather, air quality, outdoor score, and widget data about every 30 minutes. Battery optimization exception improves reliability.'**
  String get settingsBackgroundRefreshDescription;

  /// No description provided for @settingsBackgroundRefreshStatusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Battery exception enabled'**
  String get settingsBackgroundRefreshStatusEnabled;

  /// No description provided for @settingsBackgroundRefreshStatusLimited.
  ///
  /// In en, this message translates to:
  /// **'Battery exception needed'**
  String get settingsBackgroundRefreshStatusLimited;

  /// No description provided for @settingsBackgroundRefreshAction.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get settingsBackgroundRefreshAction;

  /// No description provided for @batteryOptimizationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow stable background refresh'**
  String get batteryOptimizationReminderTitle;

  /// No description provided for @batteryOptimizationReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Yegamssi can update weather, air quality, and widgets more reliably every 30 minutes when battery optimization is disabled for this app.'**
  String get batteryOptimizationReminderMessage;

  /// No description provided for @batteryOptimizationReminderLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get batteryOptimizationReminderLater;

  /// No description provided for @batteryOptimizationReminderNever.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get batteryOptimizationReminderNever;

  /// No description provided for @batteryOptimizationReminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get batteryOptimizationReminderSettings;

  /// No description provided for @settingsSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupportTitle;

  /// No description provided for @settingsSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'Support Yegamssi with a review or a short ad view.'**
  String get settingsSupportDescription;

  /// No description provided for @settingsSupportSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'A small action helps keep Yegamssi improving.'**
  String get settingsSupportSheetDescription;

  /// No description provided for @settingsSupportReviewAction.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get settingsSupportReviewAction;

  /// No description provided for @settingsSupportAdAction.
  ///
  /// In en, this message translates to:
  /// **'Watch an interstitial ad to support the developer'**
  String get settingsSupportAdAction;

  /// No description provided for @settingsSupportReviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the review screen. Please try again later.'**
  String get settingsSupportReviewFailed;

  /// No description provided for @settingsSupportAdThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting Yegamssi.'**
  String get settingsSupportAdThanks;

  /// No description provided for @settingsSupportPremiumThanks.
  ///
  /// In en, this message translates to:
  /// **'You already supported Yegamssi by removing ads. Thank you.'**
  String get settingsSupportPremiumThanks;

  /// No description provided for @settingsSupportAdFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load an ad. Please try again later.'**
  String get settingsSupportAdFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'ko',
    'pt',
    'ro',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
