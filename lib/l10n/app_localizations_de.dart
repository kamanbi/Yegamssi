// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Yegamssi';

  @override
  String get tabHome => 'Heute';

  @override
  String get tabWeather => 'Wetter';

  @override
  String get tabScore => 'Bewertung';

  @override
  String get tabMonthlyYegamssi => 'Monat';

  @override
  String get monthlyYegamssiTitle => 'Monats-Yegamssi';

  @override
  String get monthlyYegamssiSubtitle =>
      'Sieh dir die guten Tage und die Tage zum Aufpassen dieses Monats je Kategorie an.';

  @override
  String get monthlyGoodDaysLabel => 'Gute Tage';

  @override
  String get monthlyCautionDaysLabel => 'Aufpassen';

  @override
  String get monthlyGeneratingMessage =>
      'Der Monats-Yegamssi wird vorbereitet.';

  @override
  String get monthlyFailedMessage =>
      'Der Monats-Yegamssi konnte nicht vorbereitet werden. Bitte starte die App neu.';

  @override
  String get monthlyDisclaimer =>
      'Der Monats-Yegamssi ist ein Referenzinhalt auf Basis des Myeongri-Verlaufs. Wäge wichtige Entscheidungen bitte mit den realen Umständen ab.';

  @override
  String get monthlySummaryEarly =>
      'Zu Monatsbeginn läuft es rund, deshalb lohnt es sich, früh loszulegen.';

  @override
  String get monthlySummaryMid =>
      'Ab Monatsmitte wird der Verlauf besser, den richtigen Moment abzuwarten bringt mehr als Eile.';

  @override
  String get monthlySummaryLate =>
      'Wenn du im späteren Monatsverlauf Gas gibst, folgen gute Ergebnisse.';

  @override
  String get monthlyCategoryLove => 'Liebe';

  @override
  String get monthlyCategoryLoveMessage =>
      'Gute Tage eignen sich, um zuerst Gefühle zu zeigen. An Tagen zum Aufpassen ist ein ruhiges Gespräch besser.';

  @override
  String get monthlyCategoryWork => 'Arbeit';

  @override
  String get monthlyCategoryWorkMessage =>
      'Gute Tage eignen sich, um Neues zu beginnen. An Tagen zum Aufpassen lieber kürzertreten und Angefangenes abschließen.';

  @override
  String get monthlyCategoryMoney => 'Geld';

  @override
  String get monthlyCategoryMoneyMessage =>
      'Gute Tage eignen sich, um die Finanzen zu ordnen. An Tagen zum Aufpassen vor größeren Ausgaben lieber noch einmal prüfen.';

  @override
  String get monthlyCategoryRelationship => 'Beziehungen';

  @override
  String get monthlyCategoryRelationshipMessage =>
      'Gute Tage eignen sich für Gespräche mit anderen. An Tagen zum Aufpassen die Worte mit Bedacht wählen, um Missverständnisse zu vermeiden.';

  @override
  String get monthlyCategoryHealth => 'Gesundheit';

  @override
  String get monthlyCategoryHealthMessage =>
      'Gute Tage eignen sich, um in Bewegung zu kommen. An Tagen zum Aufpassen nicht übertreiben und Raum für Erholung lassen.';

  @override
  String get monthlyCategoryDecision => 'Entscheidungen';

  @override
  String get monthlyCategoryDecisionMessage =>
      'Gute Tage eignen sich für eine wichtige Entscheidung. An Tagen zum Aufpassen lieber abwarten und noch einmal in Ruhe prüfen.';

  @override
  String get monthlyCategoryTravel => 'Unterwegs';

  @override
  String get monthlyCategoryTravelMessage =>
      'Gute Tage eignen sich, um einen Ausflug oder eine Reise zu planen. An Tagen zum Aufpassen den Zeitplan etwas großzügiger halten.';

  @override
  String get tabFortune => 'Glück';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String get homeHeadline => 'Wetter und Signale für heute';

  @override
  String get homeWeatherLoadingTitle => 'Aktuelles Wetter wird geladen';

  @override
  String get homeWeatherLoadingMessage =>
      'Standort- und Wetterdaten werden vorbereitet.';

  @override
  String get homeWeatherErrorTitle =>
      'Aktuelles Wetter konnte nicht geladen werden';

  @override
  String get homeWeatherErrorMessage =>
      'Öffne den Wetterbildschirm und versuche es erneut.';

  @override
  String get homeWeatherAction => 'Wetter anzeigen';

  @override
  String get homeFortuneLoadingTitle => 'Heutiges Glück wird vorbereitet';

  @override
  String get homeFortuneLoadingMessage =>
      'Eine kurze Zusammenfassung erscheint gleich.';

  @override
  String get homeFortuneErrorTitle => 'Glück ist noch nicht bereit';

  @override
  String get homeFortuneErrorMessage =>
      'Überprüfe dein Profil und versuche es im Glücksbildschirm erneut.';

  @override
  String get homeFortuneAction => 'Glück anzeigen';

  @override
  String get homeFortuneHeadline => 'Heutiges Glück in einem Satz';

  @override
  String get appExitTitle => 'App beenden';

  @override
  String get appExitMessage => 'Möchtest du Yegamssi schließen?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'OK';

  @override
  String get close => 'Schließen';

  @override
  String get later => 'Später';

  @override
  String get exit => 'Beenden';

  @override
  String get search => 'Suchen';

  @override
  String get loadingAd => 'Werbung wird geladen...';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String refreshFailed(String error) {
    return 'Aktualisierung fehlgeschlagen: $error';
  }

  @override
  String notFoundPage(String error) {
    return 'Seite nicht gefunden: $error';
  }

  @override
  String weatherFeelsLike(String temp) {
    return 'Gefühlt $temp°C';
  }

  @override
  String weatherFeelsLikeShort(String temp) {
    return 'Gef. $temp℃';
  }

  @override
  String weatherHumidity(int value) {
    return 'Luftfeuchtigkeit $value%';
  }

  @override
  String weatherWind(String speed) {
    return 'Wind ${speed}m/s';
  }

  @override
  String get weatherHumidityLabel => 'Luftfeucht.';

  @override
  String get weatherWindLabel => 'Wind';

  @override
  String get weatherWindSpeedLabel => 'Windstärke';

  @override
  String get weatherPrecipitationLabel => 'Regen';

  @override
  String weatherPrecipitationAmount(String amount) {
    return 'Niederschlag $amount';
  }

  @override
  String get weatherDustPm10 => 'PM10';

  @override
  String get weatherDustPm25 => 'PM2.5';

  @override
  String get weatherHourlyForecast => 'Stundenvorhersage';

  @override
  String get weatherWeeklyForecast => 'Wochenvorhersage';

  @override
  String get weatherLoading => 'Wetter wird geladen...';

  @override
  String get weatherErrorTitle => 'Wetterdaten konnten nicht abgerufen werden';

  @override
  String weatherReturnCurrentLocation(int seconds) {
    return 'In ${seconds}s zum aktuellen Standort zurückkehren';
  }

  @override
  String get weatherToday => 'Heute';

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
    return '$uv Sehr hoch';
  }

  @override
  String weatherUvHigh(int uv) {
    return '$uv Hoch';
  }

  @override
  String weatherUvModerateHigh(int uv) {
    return '$uv Mäßig hoch';
  }

  @override
  String weatherUvModerate(int uv) {
    return '$uv Mäßig';
  }

  @override
  String weatherUvLow(int uv) {
    return '$uv Niedrig';
  }

  @override
  String get weatherConditionSunny => 'Sonnig';

  @override
  String get weatherConditionClearNight => 'Klare Nacht';

  @override
  String get weatherConditionPartlyCloudy => 'Teilweise bewölkt';

  @override
  String get weatherConditionPartlyCloudyNight => 'Teilweise bewölkte Nacht';

  @override
  String get weatherConditionCloudy => 'Bewölkt';

  @override
  String get weatherConditionHazy => 'Diesig';

  @override
  String get weatherConditionWindy => 'Windig';

  @override
  String get weatherConditionSlightRain => 'Leichter Regen';

  @override
  String get weatherConditionRain => 'Regen';

  @override
  String get weatherConditionHeavyRain => 'Starker Regen';

  @override
  String get weatherConditionThunderstorm => 'Gewitter';

  @override
  String get weatherConditionRainThunder => 'Regen und Donner';

  @override
  String get weatherConditionLightSnow => 'Leichter Schnee';

  @override
  String get weatherConditionSnow => 'Schnee';

  @override
  String get weatherConditionSleet => 'Schneeregen';

  @override
  String get weatherConditionHot => 'Heiß';

  @override
  String get weatherConditionHotNight => 'Heiße Nacht';

  @override
  String get weatherConditionColdWave => 'Kältewelle';

  @override
  String get weatherConditionUnknown => 'Unbekannt';

  @override
  String get locationCurrent => 'Aktueller Standort';

  @override
  String get locationSelectClose => 'Standortauswahl schließen';

  @override
  String locationAdded(String name) {
    return '$name hinzugefügt';
  }

  @override
  String get locationFavoriteLimit =>
      'Du kannst bis zu 5 Standorte hinzufügen.';

  @override
  String get locationFavoriteFull => 'Favoriten voll';

  @override
  String get locationFavoriteAdd => 'Favorit hinzufügen';

  @override
  String get locationSearchTitle => 'Standort suchen';

  @override
  String get locationSearchHint => 'Beispiel: Seoul, Busan, Tokio';

  @override
  String get locationSearchEmpty => 'Keine Ergebnisse gefunden';

  @override
  String get scoreLabel => 'Outdoor-Aktivitätsbewertung';

  @override
  String get scoreLoading => 'Outdoor-Aktivitätsbewertung wird berechnet...';

  @override
  String get scoreErrorTitle => 'Bewertung konnte nicht berechnet werden';

  @override
  String get scoreBreakdownTitle => 'Abzüge';

  @override
  String get scoreNoDeduction =>
      'Stabile Außenbedingungen, kaum Abzugsfaktoren.';

  @override
  String get scoreInfo =>
      'Die Outdoor-Aktivitätsbewertung wird aus Regen, Wind, Gefühlstemperatur, Luftqualität und UV-Daten berechnet.';

  @override
  String get scoreDeductionRain => 'Regen und Schnee';

  @override
  String get scoreDeductionWind => 'Wind';

  @override
  String get scoreDeductionTemp => 'Temperatur';

  @override
  String get scoreDeductionAir => 'Luftqualität';

  @override
  String get scoreDeductionUv => 'UV';

  @override
  String get scoreDeductionOzone => 'Ozon';

  @override
  String get scoreAdviceExcellent =>
      'Heute ist perfekt für Outdoor-Aktivitäten.\nGeh raus und genieße es.';

  @override
  String get scoreAdviceGood =>
      'Outdoor-Aktivitäten sind in Ordnung, aber überprüfe noch einmal Wind und UV.';

  @override
  String get scoreAdviceFair =>
      'Outdoor-Aktivitäten sind möglich, aber gute Vorbereitung hilft.';

  @override
  String get scoreAdvicePoor =>
      'Heute ist es sicherer, Indoor-Aktivitäten zu planen.';

  @override
  String get scoreTierExcellent => 'Ausgezeichnet';

  @override
  String get scoreTierGood => 'Gut';

  @override
  String get scoreTierFair => 'Mäßig';

  @override
  String get scoreTierPoor => 'Vorsicht';

  @override
  String scorePointUnit(int score) {
    return '$score Pkt.';
  }

  @override
  String get activityRecommendOutdoor => 'Outdoor-Aktivität empfohlen';

  @override
  String get activityRecommendLight => 'Leichte Aktivität geeignet';

  @override
  String get activityRecommendCaution => 'Vorsicht erforderlich';

  @override
  String get activityRecommendIndoor => 'Indoor-Aktivität empfohlen';

  @override
  String get airQualityTitle => 'Luftqualität';

  @override
  String get airQualityIntegrated => 'Integrierte Luftqualität';

  @override
  String get airQualityUnknown => 'Keine Daten';

  @override
  String get airGradeGood => 'Gut';

  @override
  String get airGradeModerate => 'Mäßig';

  @override
  String get airGradeBad => 'Schlecht';

  @override
  String get airGradeVeryBad => 'Sehr schlecht';

  @override
  String get pointUnit => 'Pkt.';

  @override
  String get fortuneTitle => 'Dein tägliches Glück';

  @override
  String get fortuneNeedProfileTitle => 'Geburtsinformation benötigt';

  @override
  String get fortuneNeedProfileMessage =>
      'Gib dein Geburtsdatum und deine Geburtszeit ein, um das heutige Glück zu erhalten.';

  @override
  String get fortuneBirthInputAction => 'Geburtsdaten eingeben';

  @override
  String get fortuneHelpTooltip => 'Hilfe zur Glücksdeutung';

  @override
  String get fortuneHelpTitle => 'Wie Yegamssi Glück deutet';

  @override
  String get fortuneHelpIntro =>
      'Yegamssi liest den heutigen Glücksfluss auf Grundlage von Myeongri.';

  @override
  String get fortuneHelpMyeongri =>
      'Myeongri ist ein traditionelles ostasiatisches Deutungssystem, das anhand von Geburtsdatum und Geburtszeit die Vier Säulen und das Gleichgewicht der fünf Elemente betrachtet. Yegamssi berechnet daraus deine persönliche Grundenergie, vergleicht sie mit dem heutigen Tagesfluss und zeigt Gesamtglück, Geld, Liebe, Arbeit, Gesundheit und Entscheidungsenergie.';

  @override
  String get fortuneHelpBirthTime =>
      'Wenn du deine Geburtszeit nicht kennst, kannst du standardmäßig den Mittag verwenden. Eine eingegebene Geburtszeit hilft jedoch bei einer genaueren Deutung.';

  @override
  String get fortuneHelpWeather =>
      'Yegamssi berücksichtigt nicht nur Glück, sondern auch Wetter und Aktivitätswert. Selbst wenn die Tagesenergie gut ist, kann eine schlechte Wetterlage die Empfehlung fürs Rausgehen senken. Sind Glück und Wetter stabil, kann es ein besserer Tag zum Handeln sein.';

  @override
  String get fortuneHelpReference =>
      'Die Glücksdeutung ist keine feste Antwort, sondern eine Orientierung. Nutze sie, um den Tagesfluss vorab zu prüfen und Kontakte, Ausflüge, Ausgaben, Verträge und wichtige Entscheidungen etwas bewusster zu wählen.';

  @override
  String get fortuneLoadFailedTitle => 'Glück konnte nicht geladen werden';

  @override
  String get fortuneLoadFailedMessage => 'Bitte versuche es später erneut.';

  @override
  String get fortuneCategoryAnalysis => 'Kategorieanalyse';

  @override
  String get fortuneOverall => 'Gesamtglück';

  @override
  String get fortuneCategoryMoney => 'Geld';

  @override
  String get fortuneCategoryLove => 'Liebe';

  @override
  String get fortuneCategoryWork => 'Arbeit';

  @override
  String get fortuneCategoryHealth => 'Gesundheit';

  @override
  String get fortuneCategoryDecision => 'Entscheidung';

  @override
  String get fortuneLuckyColor => 'Glücksfarbe';

  @override
  String get fortuneLuckyNumber => 'Glückszahl';

  @override
  String get fortuneOhengBalance => 'Elementgleichgewicht';

  @override
  String get fortuneOhengDescription =>
      'Ein unterstützendes Signal für den emotionalen Fluss von heute.';

  @override
  String get fortuneCaptureTooltip => 'Glückskarte aufnehmen';

  @override
  String get fortuneCaptureSaved => 'Glückskarte gespeichert.';

  @override
  String get fortuneCaptureSaveDone => 'Glückskarte aufgenommen';

  @override
  String fortuneCaptureFailed(String error) {
    return 'Aufnahme fehlgeschlagen: $error';
  }

  @override
  String get fortuneOpenFolder => 'Ordner öffnen';

  @override
  String get fortuneAnalyzing => 'Analysiere.';

  @override
  String get fortuneToneBase => 'Standard';

  @override
  String get fortuneToneHumor => 'Humor';

  @override
  String get fortuneToneTsundere => 'Tsundere';

  @override
  String get fortuneToneCynical => 'Zynisch';

  @override
  String get fortuneToneEmotional => 'Emotional';

  @override
  String get fortuneToneHistorical => 'Historisch';

  @override
  String get fortuneToneAi => 'KI';

  @override
  String get fortuneTimeMorning => 'Morgen';

  @override
  String get fortuneTimeAfternoon => 'Nachmittag';

  @override
  String get ohengMok => 'Holz';

  @override
  String get ohengHwa => 'Feuer';

  @override
  String get ohengTo => 'Erde';

  @override
  String get ohengGeum => 'Metall';

  @override
  String get ohengSu => 'Wasser';

  @override
  String get luckyColorGreen => 'Grün';

  @override
  String get luckyColorCoral => 'Koralle';

  @override
  String get luckyColorGold => 'Gold';

  @override
  String get luckyColorSilver => 'Silber';

  @override
  String get luckyColorSky => 'Himmelblau';

  @override
  String get luckyColorRed => 'Rot';

  @override
  String get luckyColorOrange => 'Orange';

  @override
  String get luckyColorYellow => 'Gelb';

  @override
  String get luckyColorTeal => 'Türkis';

  @override
  String get luckyColorBlue => 'Blau';

  @override
  String get luckyColorPurple => 'Violett';

  @override
  String get luckyColorPink => 'Rosa';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsCountry => 'Region';

  @override
  String get countryKorea => 'Korea';

  @override
  String get countryUnitedStates => 'USA';

  @override
  String get countryJapan => 'Japan';

  @override
  String get countryChina => 'China';

  @override
  String get countryGlobal => 'Global';

  @override
  String get settingsTheme => 'Erscheinungsbild';

  @override
  String get settingsThemeDescription =>
      'Das Standarddesign nutzt von 06:00 bis 19:00 Uhr die Tagesansicht anhand der lokalen Zeit des verbundenen Standorts und außerhalb dieses Zeitraums die Nachtansicht. Tages- und Nachtansicht bleiben unabhängig von der Zeit fest eingestellt.';

  @override
  String get settingsThemeAutomatic => 'Standarddesign';

  @override
  String get settingsThemeAutomaticDescription =>
      'Wendet am verbundenen Standort von 06:00 bis 19:00 Uhr automatisch die Tagesansicht an und von 19:00 Uhr bis vor 06:00 Uhr des nächsten Tages die Nachtansicht.';

  @override
  String get settingsThemeDay => 'Tagesansicht';

  @override
  String get settingsThemeDayDescription =>
      'Verwendet unabhängig von der Uhrzeit immer die helle Tagesansicht.';

  @override
  String get settingsThemeNight => 'Nachtansicht';

  @override
  String get settingsThemeNightDescription =>
      'Verwendet unabhängig von der Uhrzeit immer die bestehende dunkle Nachtansicht.';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsBirthTitle => 'Geburtsdatum';

  @override
  String get settingsBirthDescription =>
      'Verwalte Geburtsdatum und -zeit für die Glücksberechnung.';

  @override
  String get settingsBirthEmpty => 'Nicht eingegeben';

  @override
  String get settingsBirthEdit => 'Bearbeiten';

  @override
  String get settingsBirthUnknownHour => 'Unbekannt';

  @override
  String get onboardingGenderLabel => 'Geschlecht';

  @override
  String get genderMale => 'Männlich';

  @override
  String get genderFemale => 'Weiblich';

  @override
  String get genderUnspecified => 'Keine Angabe';

  @override
  String get settingsGenderTitle => 'Geschlecht';

  @override
  String settingsHourUnit(int hour) {
    return '$hour:00';
  }

  @override
  String get settingsFortuneToneTitle => 'Ton';

  @override
  String settingsFortuneToneDescription(String tone) {
    return 'Glücksmeldungen werden im $tone-Stil angezeigt.';
  }

  @override
  String get settingsFortuneToneSheetDescription =>
      'Basismeldungen bleiben erhalten und der gewählte Stil hat Vorrang.';

  @override
  String get settingsAppInfoTitle => 'App-Informationen';

  @override
  String get settingsAppInfoDescription =>
      'Startseite, Datenschutzleitfaden, Kontakt-E-Mail und Links.';

  @override
  String get settingsPremiumTitle => 'Werbung entfernen (lebenslang)';

  @override
  String get settingsPremiumDescription =>
      'Entfernt Banner- und Vollbildanzeigen dauerhaft.';

  @override
  String get settingsPremiumButton => 'Werbung entfernen';

  @override
  String settingsPremiumButtonPriced(String price) {
    return 'Werbung entfernen — $price';
  }

  @override
  String get settingsPremiumPurchasedTitle => 'Werbung entfernt';

  @override
  String get settingsPremiumPurchasedDescription =>
      'Vielen Dank für deine Unterstützung.';

  @override
  String get premiumMsgSuccess => 'Werbung wurde entfernt. Vielen Dank!';

  @override
  String get premiumMsgCanceled => 'Kauf abgebrochen.';

  @override
  String get premiumMsgError =>
      'Kauf fehlgeschlagen. Bitte versuche es später erneut.';

  @override
  String get premiumMsgStoreUnavailable =>
      'Verbindung zum Store nicht möglich. Bitte versuche es später erneut.';

  @override
  String get premiumMsgProductUnavailable =>
      'Dieser Artikel ist derzeit nicht verfügbar.';

  @override
  String get onboardingTitle => 'Yegamssi';

  @override
  String get onboardingSubtitle =>
      'Gib dein Geburtsdatum und deine Geburtszeit ein,\num das heutige Glück zu erhalten.';

  @override
  String get onboardingStart => 'Loslegen';

  @override
  String get birthDate => 'Geburtsdatum';

  @override
  String get birthHour => 'Geburtszeit';

  @override
  String get birthHourOptional => 'Geburtszeit (optional)';

  @override
  String get birthSelectDate => 'Datum auswählen';

  @override
  String get birthUnknownNoon => 'Unbekannt (Berechnung um Mittag)';

  @override
  String get birthUnknownNoonShort => 'Unbekannt (Mittag)';

  @override
  String dateYmd(int year, int month, int day) {
    return '$day.$month.$year';
  }

  @override
  String hourLabel(int hour) {
    return '$hour:00';
  }

  @override
  String get appInfoHomepage => 'Startseite';

  @override
  String get appInfoHomepageDescription => 'Yegamssi-Vorstellungsseite öffnen.';

  @override
  String get appInfoPrivacy => 'Datenschutzrichtlinie';

  @override
  String get appInfoPrivacyDescription => 'Datenschutzseite öffnen.';

  @override
  String get appInfoEmail => 'Kontakt-E-Mail';

  @override
  String get appInfoEmailDescription => 'Mail-App für Anfragen öffnen.';

  @override
  String get appInfoShare => 'Yegamssi teilen';

  @override
  String get appInfoShareDescription => 'QR-Code zum Store-Link anzeigen.';

  @override
  String get appInfoShareQrDescription =>
      'Scanne den QR-Code, um die Yegamssi-Seite im Store zu öffnen.';

  @override
  String get appInfoCopyLink => 'Link kopieren';

  @override
  String get appInfoOpenStore => 'Store öffnen';

  @override
  String get appInfoStoreLinkCopied => 'Store-Link kopiert.';

  @override
  String get appInfoVersionTitle => 'App-Version';

  @override
  String appInfoCurrentVersion(String version, String buildNumber) {
    return 'Aktuelle Version $version+$buildNumber';
  }

  @override
  String get appInfoCheckingVersion => 'Version wird überprüft...';

  @override
  String get appInfoDataSource => 'Datenquellen';

  @override
  String get appInfoKma => 'Koreanischer Wetterdienst (KMA)';

  @override
  String get appInfoKmaDescription =>
      'Liefert Wetter- und Prognosedaten für Südkorea.';

  @override
  String get appInfoAirKorea => 'AirKorea';

  @override
  String get appInfoAirKoreaDescription =>
      'Liefert PM10, PM2.5, Ozon und integrierte Luftqualitätsdaten für Südkorea.';

  @override
  String get appInfoOpenWeather => 'OpenWeather';

  @override
  String get appInfoOpenWeatherDescription =>
      'Liefert internationale Wetter-, Prognose- und Luftqualitätsdaten (PM10, PM2.5, O3).';

  @override
  String get appInfoNominatim => 'OpenStreetMap Nominatim';

  @override
  String get appInfoNominatimDescription =>
      'Wandelt Koordinaten in lokalisierte Ortsnamen um. (ODbL-Lizenz)';

  @override
  String get appInfoNoaa => 'NOAA / Nationaler Wetterdienst der USA';

  @override
  String get appInfoNoaaDescription =>
      'Liefert offizielle Wettervorhersagen und Stundendaten für die USA. (Gemeinfrei)';

  @override
  String get appInfoAirNow => 'U.S. EPA AirNow';

  @override
  String get appInfoAirNowDescription =>
      'Liefert Echtzeit-Luftqualitätsdaten (PM2.5, PM10, Ozon) für die USA.';

  @override
  String get appInfoDataSourceNotice =>
      'Einige Informationen folgen KOGL-Urheberstandards. Internationale Daten werden von der OpenWeather API bereitgestellt.';

  @override
  String get widgetScoreLabel => 'Bewertung';

  @override
  String get widgetFortuneLabel => 'Glück';

  @override
  String get widget_description => 'Yegamssi tägliches Zusammenfassungs-Widget';

  @override
  String get widgetInstallTitle => 'Yegamssi-Widget hinzufügen';

  @override
  String get widgetInstallMessage =>
      'Sieh Wetter, Temperatur, Outdoor-Bewertung und Glück direkt auf deinem Startbildschirm.';

  @override
  String get widgetInstallAction => 'Widget installieren';

  @override
  String get widgetInstallManual =>
      'Halte den Startbildschirm gedrückt und füge das Yegamssi-Widget hinzu.';

  @override
  String get appReviewTitle => 'Hast du einen Moment Zeit? 🙏';

  @override
  String get appReviewMessage =>
      'Vielen Dank, dass du Yegamssi nutzt. Es ist eine kleine App von einem Ein-Personen-Entwickler, und eine 5-Sterne-Bewertung von dir würde uns unglaublich viel bedeuten. Könntest du uns bitte mit 5 Sternen bewerten?';

  @override
  String get appReviewAction => 'Mit 5 Sternen bewerten';

  @override
  String get appReviewLater => 'Vielleicht später';

  @override
  String get updateNoticeTitle => 'Update-Hinweis';

  @override
  String get updateRequiredTitle => 'Update erforderlich';

  @override
  String updateRequiredMessage(String currentVersion, String latestVersion) {
    return 'Die aktuelle Version $currentVersion wird nicht mehr unterstützt.\nBitte auf Version $latestVersion aktualisieren.';
  }

  @override
  String updateAvailableMessage(String latestVersion) {
    return 'Version $latestVersion ist bereit.\nJetzt aktualisieren?';
  }

  @override
  String get updateAction => 'Aktualisieren';

  @override
  String get updateNewVersionMessage =>
      'Eine neue Version wurde veröffentlicht.\nJetzt aktualisieren?';

  @override
  String get activityRunning => 'Laufen';

  @override
  String get activityCycling => 'Radfahren';

  @override
  String get activityHiking => 'Wandern';

  @override
  String get activityWalking => 'Spazieren';

  @override
  String get activityOutdoor => 'Outdoor-Arbeit';

  @override
  String get errorNetwork => 'Überprüfe deine Internetverbindung.';

  @override
  String get errorServer => 'Serverfehler aufgetreten.';

  @override
  String get errorLocation => 'Standort konnte nicht abgerufen werden.';

  @override
  String get errorUnknown => 'Ein unbekannter Fehler ist aufgetreten.';

  @override
  String get settingsBackgroundRefreshTitle => 'Hintergrundaktualisierung';

  @override
  String get settingsBackgroundRefreshDescription =>
      'Aktualisiert Wetter, Luftqualitaet, Outdoor-Wert und Widget etwa alle 30 Minuten. Eine Akku-Ausnahme erhoeht die Zuverlaessigkeit.';

  @override
  String get settingsBackgroundRefreshStatusEnabled => 'Akku-Ausnahme aktiv';

  @override
  String get settingsBackgroundRefreshStatusLimited =>
      'Akku-Ausnahme erforderlich';

  @override
  String get settingsBackgroundRefreshAction => 'Einstellungen oeffnen';

  @override
  String get batteryOptimizationReminderTitle =>
      'Stabile Aktualisierung erlauben';

  @override
  String get batteryOptimizationReminderMessage =>
      'Yegamssi kann Wetter, Luftqualitaet und Widgets alle 30 Minuten zuverlaessiger aktualisieren, wenn die Akku-Optimierung fuer diese App deaktiviert ist.';

  @override
  String get batteryOptimizationReminderLater => 'Spaeter';

  @override
  String get batteryOptimizationReminderNever => 'Nicht mehr anzeigen';

  @override
  String get batteryOptimizationReminderSettings => 'Einstellungen oeffnen';

  @override
  String get settingsSupportTitle => 'Unterstützung';

  @override
  String get settingsSupportDescription =>
      'Unterstütze Yegamssi mit einer Bewertung oder einem kurzen Werbe-Video.';

  @override
  String get settingsSupportSheetDescription =>
      'Eine kleine Geste hilft dabei, Yegamssi weiter zu verbessern.';

  @override
  String get settingsSupportReviewAction => 'Bewertung schreiben';

  @override
  String get settingsSupportAdAction =>
      'Werbevideo ansehen, um den Entwickler zu unterstützen';

  @override
  String get settingsSupportReviewFailed =>
      'Der Bewertungsbildschirm konnte nicht geöffnet werden. Bitte versuche es später erneut.';

  @override
  String get settingsSupportAdThanks => 'Danke, dass du Yegamssi unterstützt.';

  @override
  String get settingsSupportPremiumThanks =>
      'Du hast Yegamssi bereits durch das Entfernen der Werbung unterstützt. Vielen Dank.';

  @override
  String get settingsSupportAdFailed =>
      'Die Werbung konnte nicht geladen werden. Bitte versuche es später erneut.';
}
