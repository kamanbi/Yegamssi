import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
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
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Yegamssi'**
  String get appName;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabHome;

  /// Weather tab label
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get tabWeather;

  /// Score tab label
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get tabScore;

  /// Fortune tab label
  ///
  /// In en, this message translates to:
  /// **'Fortune'**
  String get tabFortune;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// Feels-like temperature label
  ///
  /// In en, this message translates to:
  /// **'Feels like {temp}°'**
  String weatherFeelsLike(String temp);

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

  /// Activity score section label
  ///
  /// In en, this message translates to:
  /// **'Activity Score'**
  String get scoreLabel;

  /// No description provided for @scoreTierExcellent.
  ///
  /// In en, this message translates to:
  /// **'Perfect conditions'**
  String get scoreTierExcellent;

  /// No description provided for @scoreTierGood.
  ///
  /// In en, this message translates to:
  /// **'Good conditions'**
  String get scoreTierGood;

  /// No description provided for @scoreTierFair.
  ///
  /// In en, this message translates to:
  /// **'Manageable'**
  String get scoreTierFair;

  /// No description provided for @scoreTierPoor.
  ///
  /// In en, this message translates to:
  /// **'Stay indoors'**
  String get scoreTierPoor;

  /// Fortune section header
  ///
  /// In en, this message translates to:
  /// **'Your Daily Fortune'**
  String get fortuneTitle;

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

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsTheme;

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

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Yegamssi'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weather · Score · Fortune'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingStart;

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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
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
