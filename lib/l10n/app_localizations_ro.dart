// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appName => 'Yegamssi';

  @override
  String get tabHome => 'Astăzi';

  @override
  String get tabWeather => 'Vreme';

  @override
  String get tabScore => 'Scor';

  @override
  String get tabMonthlyYegamssi => 'Lunar';

  @override
  String get monthlyYegamssiTitle => 'Yegamssi lunar';

  @override
  String get monthlyYegamssiSubtitle =>
      'Vezi zilele bune și zilele de atenție din această lună, pe categorii.';

  @override
  String get monthlyGoodDaysLabel => 'Zile bune';

  @override
  String get monthlyCautionDaysLabel => 'Atenție';

  @override
  String get monthlyGeneratingMessage =>
      'Se pregătește Yegamssi lunar pentru luna aceasta.';

  @override
  String get monthlyFailedMessage =>
      'Nu am putut pregăti Yegamssi lunar pentru luna aceasta. Te rugăm să repornești aplicația.';

  @override
  String get monthlyDisclaimer =>
      'Yegamssi lunar este un conținut orientativ bazat pe fluxul Myeongri. Cântărește deciziile importante împreună cu condițiile reale.';

  @override
  String get monthlySummaryEarly =>
      'Luna aceasta fluxul e bun la început, așa că e în avantajul tău să acționezi devreme.';

  @override
  String get monthlySummaryMid =>
      'Luna aceasta fluxul se îmbunătățește de la mijloc; e mai bine să aștepți momentul potrivit decât să te grăbești.';

  @override
  String get monthlySummaryLate =>
      'Luna aceasta, dacă îți dai silința spre final, vor urma rezultate bune.';

  @override
  String get monthlyCategoryLove => 'Dragoste';

  @override
  String get monthlyCategoryLoveMessage =>
      'Zilele bune sunt potrivite să-ți exprimi primul sentimentele. În zilele de atenție, o discuție calmă e mai bună.';

  @override
  String get monthlyCategoryWork => 'Muncă';

  @override
  String get monthlyCategoryWorkMessage =>
      'Zilele bune sunt potrivite să începi ceva nou. În zilele de atenție, nu forța și concentrează-te pe a finaliza.';

  @override
  String get monthlyCategoryMoney => 'Bani';

  @override
  String get monthlyCategoryMoneyMessage =>
      'Zilele bune sunt potrivite să-ți pui finanțele în ordine. În zilele de atenție, verifică de două ori înainte de o cheltuială mare.';

  @override
  String get monthlyCategoryRelationship => 'Relații';

  @override
  String get monthlyCategoryRelationshipMessage =>
      'Zilele bune sunt potrivite pentru discuții cu ceilalți. În zilele de atenție, alege-ți cuvintele cu grijă ca să eviți neînțelegerile.';

  @override
  String get monthlyCategoryHealth => 'Sănătate';

  @override
  String get monthlyCategoryHealthMessage =>
      'Zilele bune sunt potrivite să te miști. În zilele de atenție, nu exagera și fă loc pentru odihnă.';

  @override
  String get monthlyCategoryDecision => 'Decizii';

  @override
  String get monthlyCategoryDecisionMessage =>
      'Zilele bune sunt potrivite pentru o decizie importantă. În zilele de atenție, e mai bine să aștepți și să mai analizezi.';

  @override
  String get monthlyCategoryTravel => 'Deplasări';

  @override
  String get monthlyCategoryTravelMessage =>
      'Zilele bune sunt potrivite să planifici o ieșire sau o călătorie. În zilele de atenție, lasă puțin spațiu liber în program.';

  @override
  String get tabFortune => 'Horoscop';

  @override
  String get tabSettings => 'Setări';

  @override
  String get homeHeadline => 'Vremea și semnalele zilei de azi';

  @override
  String get homeWeatherLoadingTitle => 'Se încarcă vremea curentă';

  @override
  String get homeWeatherLoadingMessage =>
      'Se pregătesc datele de locație și vreme.';

  @override
  String get homeWeatherErrorTitle => 'Vremea curentă nu a putut fi încărcată';

  @override
  String get homeWeatherErrorMessage =>
      'Deschide ecranul Vreme și încearcă din nou.';

  @override
  String get homeWeatherAction => 'Vezi vremea';

  @override
  String get homeFortuneLoadingTitle => 'Se pregătește horoscopul de azi';

  @override
  String get homeFortuneLoadingMessage =>
      'Un scurt rezumat va apărea în curând.';

  @override
  String get homeFortuneErrorTitle => 'Horoscopul nu este încă pregătit';

  @override
  String get homeFortuneErrorMessage =>
      'Verifică-ți profilul și încearcă din nou pe ecranul de horoscop.';

  @override
  String get homeFortuneAction => 'Vezi horoscopul';

  @override
  String get homeFortuneHeadline => 'Horoscopul de azi pe scurt';

  @override
  String get appExitTitle => 'Ieșire din aplicație';

  @override
  String get appExitMessage => 'Vrei să închizi Yegamssi?';

  @override
  String get cancel => 'Anulează';

  @override
  String get confirm => 'OK';

  @override
  String get close => 'Închide';

  @override
  String get later => 'Mai târziu';

  @override
  String get exit => 'Ieșire';

  @override
  String get search => 'Căutare';

  @override
  String get loadingAd => 'Se încarcă reclama...';

  @override
  String get refresh => 'Reîmprospătează';

  @override
  String refreshFailed(String error) {
    return 'Reîmprospătare eșuată: $error';
  }

  @override
  String notFoundPage(String error) {
    return 'Pagină negăsită: $error';
  }

  @override
  String weatherFeelsLike(String temp) {
    return 'Se simte ca $temp°C';
  }

  @override
  String weatherFeelsLikeShort(String temp) {
    return 'Se simte $temp℃';
  }

  @override
  String weatherHumidity(int value) {
    return 'Umiditate $value%';
  }

  @override
  String weatherWind(String speed) {
    return 'Vânt ${speed}m/s';
  }

  @override
  String get weatherHumidityLabel => 'Umiditate';

  @override
  String get weatherWindLabel => 'Vânt';

  @override
  String get weatherWindSpeedLabel => 'Viteza vântului';

  @override
  String get weatherPrecipitationLabel => 'Ploaie';

  @override
  String weatherPrecipitationAmount(String amount) {
    return 'Cantitate de precipitații $amount';
  }

  @override
  String get weatherDustPm10 => 'PM10';

  @override
  String get weatherDustPm25 => 'PM2.5';

  @override
  String get weatherHourlyForecast => 'Prognoză orară';

  @override
  String get weatherWeeklyForecast => 'Prognoză săptămânală';

  @override
  String get weatherLoading => 'Se încarcă vremea...';

  @override
  String get weatherErrorTitle => 'Datele despre vreme nu pot fi obținute';

  @override
  String weatherReturnCurrentLocation(int seconds) {
    return 'Revii la locația curentă în $seconds sec';
  }

  @override
  String get weatherToday => 'Astăzi';

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
    return '$uv Foarte ridicat';
  }

  @override
  String weatherUvHigh(int uv) {
    return '$uv Ridicat';
  }

  @override
  String weatherUvModerateHigh(int uv) {
    return '$uv Moderat-ridicat';
  }

  @override
  String weatherUvModerate(int uv) {
    return '$uv Moderat';
  }

  @override
  String weatherUvLow(int uv) {
    return '$uv Scăzut';
  }

  @override
  String get weatherConditionSunny => 'Însorit';

  @override
  String get weatherConditionClearNight => 'Noapte senină';

  @override
  String get weatherConditionPartlyCloudy => 'Parțial noros';

  @override
  String get weatherConditionPartlyCloudyNight => 'Noapte parțial noroasă';

  @override
  String get weatherConditionCloudy => 'Noros';

  @override
  String get weatherConditionHazy => 'Ceață ușoară';

  @override
  String get weatherConditionWindy => 'Vântos';

  @override
  String get weatherConditionSlightRain => 'Ploaie ușoară';

  @override
  String get weatherConditionRain => 'Ploaie';

  @override
  String get weatherConditionHeavyRain => 'Ploaie torențială';

  @override
  String get weatherConditionThunderstorm => 'Furtună';

  @override
  String get weatherConditionRainThunder => 'Ploaie cu tunete';

  @override
  String get weatherConditionLightSnow => 'Ninsoare ușoară';

  @override
  String get weatherConditionSnow => 'Ninsoare';

  @override
  String get weatherConditionSleet => 'Lapoviță';

  @override
  String get weatherConditionHot => 'Caniculă';

  @override
  String get weatherConditionHotNight => 'Noapte tropicală';

  @override
  String get weatherConditionColdWave => 'Val de frig';

  @override
  String get weatherConditionUnknown => 'Necunoscut';

  @override
  String get locationCurrent => 'Locația curentă';

  @override
  String get locationSelectClose => 'Închide selectorul de locații';

  @override
  String locationAdded(String name) {
    return '$name a fost adăugat';
  }

  @override
  String get locationFavoriteLimit => 'Poți adăuga până la 5 locații.';

  @override
  String get locationFavoriteFull => 'Lista de favorite este plină';

  @override
  String get locationFavoriteAdd => 'Adaugă la favorite';

  @override
  String get locationSearchTitle => 'Caută locație';

  @override
  String get locationSearchHint => 'Exemplu: Seul, Busan, Tokyo';

  @override
  String get locationSearchEmpty => 'Niciun rezultat găsit';

  @override
  String get scoreLabel => 'Scor activitate în aer liber';

  @override
  String get scoreLoading =>
      'Se calculează scorul de activitate în aer liber...';

  @override
  String get scoreErrorTitle => 'Scorul nu poate fi calculat';

  @override
  String get scoreBreakdownTitle => 'Deduceri';

  @override
  String get scoreNoDeduction =>
      'Condiții stabile pentru activități în aer liber, aproape fără factori de deducere.';

  @override
  String get scoreInfo =>
      'Scorul de activitate în aer liber este calculat pe baza ploii, vântului, temperaturii resimțite, calității aerului și indicelui UV.';

  @override
  String get scoreDeductionRain => 'Ploaie și ninsoare';

  @override
  String get scoreDeductionWind => 'Vânt';

  @override
  String get scoreDeductionTemp => 'Temperatură';

  @override
  String get scoreDeductionAir => 'Calitatea aerului';

  @override
  String get scoreDeductionUv => 'UV';

  @override
  String get scoreDeductionOzone => 'Ozon';

  @override
  String get scoreAdviceExcellent =>
      'Astăzi este o zi bună pentru activități în aer liber.\nIeși afară și bucură-te de ea.';

  @override
  String get scoreAdviceGood =>
      'Activitățile în aer liber sunt în regulă, dar mai verifică o dată vântul și indicele UV.';

  @override
  String get scoreAdviceFair =>
      'Activitățile în aer liber sunt posibile, iar o pregătire mai bună le va ușura.';

  @override
  String get scoreAdvicePoor =>
      'Astăzi este mai sigur să planifici activități în interior.';

  @override
  String get scoreTierExcellent => 'Excelent';

  @override
  String get scoreTierGood => 'Bun';

  @override
  String get scoreTierFair => 'Acceptabil';

  @override
  String get scoreTierPoor => 'Atenție';

  @override
  String scorePointUnit(int score) {
    return '$score pct';
  }

  @override
  String get activityRecommendOutdoor => 'Activitate în aer liber recomandată';

  @override
  String get activityRecommendLight => 'O activitate ușoară este potrivită';

  @override
  String get activityRecommendCaution => 'Este nevoie de prudență';

  @override
  String get activityRecommendIndoor => 'Activitate în interior recomandată';

  @override
  String get airQualityTitle => 'Calitatea aerului';

  @override
  String get airQualityIntegrated => 'Calitatea aerului integrată';

  @override
  String get airQualityUnknown => 'Fără date';

  @override
  String get airGradeGood => 'Bună';

  @override
  String get airGradeModerate => 'Moderată';

  @override
  String get airGradeBad => 'Proastă';

  @override
  String get airGradeVeryBad => 'Foarte proastă';

  @override
  String get pointUnit => 'pct';

  @override
  String get fortuneTitle => 'Horoscopul tău zilnic';

  @override
  String get fortuneNeedProfileTitle =>
      'Sunt necesare informații despre naștere';

  @override
  String get fortuneNeedProfileMessage =>
      'Introdu data și ora nașterii pentru a primi horoscopul de azi într-un ton calm.';

  @override
  String get fortuneBirthInputAction => 'Introdu data nașterii';

  @override
  String get fortuneHelpTooltip => 'Ajutor pentru horoscop';

  @override
  String get fortuneHelpTitle => 'Cum citește Yegamssi horoscopul';

  @override
  String get fortuneHelpIntro =>
      'Yegamssi citește fluxul horoscopului de azi pe baza Myeongri.';

  @override
  String get fortuneHelpMyeongri =>
      'Myeongri este un sistem tradițional oriental de interpretare care analizează Cei Patru Stâlpi și echilibrul celor cinci elemente folosind data și ora nașterii. Yegamssi calculează energia personală de bază din data și ora nașterii, o compară cu fluxul zilei și oferă indicații pentru norocul general, bani, dragoste, muncă, sănătate și decizii.';

  @override
  String get fortuneHelpBirthTime =>
      'Dacă nu îți cunoști ora nașterii, poți folosi prânzul ca reper. Totuși, introducerea orei nașterii ajută la o interpretare mai detaliată.';

  @override
  String get fortuneHelpWeather =>
      'Yegamssi ia în calcul și vremea și scorul de activitate, nu doar horoscopul. De aceea, chiar dacă energia zilei este bună, vremea nefavorabilă poate reduce recomandarea de ieșire. Dacă horoscopul și vremea sunt stabile, poate fi o zi mai bună pentru acțiune.';

  @override
  String get fortuneHelpReference =>
      'Horoscopul nu este un răspuns fix, ci un reper. Folosește-l pentru a privi din timp fluxul zilei și pentru a alege mai atent contactele, ieșirile, cheltuielile, contractele și deciziile importante.';

  @override
  String get fortuneLoadFailedTitle => 'Horoscopul nu a putut fi încărcat';

  @override
  String get fortuneLoadFailedMessage =>
      'Te rugăm să încerci din nou mai târziu.';

  @override
  String get fortuneCategoryAnalysis => 'Analiză pe categorii';

  @override
  String get fortuneOverall => 'Horoscop general';

  @override
  String get fortuneCategoryMoney => 'Bani';

  @override
  String get fortuneCategoryLove => 'Dragoste';

  @override
  String get fortuneCategoryWork => 'Muncă';

  @override
  String get fortuneCategoryHealth => 'Sănătate';

  @override
  String get fortuneCategoryDecision => 'Decizii';

  @override
  String get fortuneLuckyColor => 'Culoare norocoasă';

  @override
  String get fortuneLuckyNumber => 'Număr norocos';

  @override
  String get fortuneOhengBalance => 'Echilibrul elementelor';

  @override
  String get fortuneOhengDescription =>
      'Un semnal de sprijin pentru starea ta emoțională din această zi.';

  @override
  String get fortuneCaptureTooltip => 'Capturează cardul de horoscop';

  @override
  String get fortuneCaptureSaved =>
      'Captura cardului de horoscop a fost salvată.';

  @override
  String get fortuneCaptureSaveDone =>
      'Captura cardului de horoscop este completă';

  @override
  String fortuneCaptureFailed(String error) {
    return 'Capturare eșuată: $error';
  }

  @override
  String get fortuneOpenFolder => 'Deschide folderul';

  @override
  String get fortuneAnalyzing => 'Se analizează.';

  @override
  String get fortuneToneBase => 'De bază';

  @override
  String get fortuneToneHumor => 'Umor';

  @override
  String get fortuneToneTsundere => 'Tsundere';

  @override
  String get fortuneToneCynical => 'Cinic';

  @override
  String get fortuneToneEmotional => 'Emoțional';

  @override
  String get fortuneToneHistorical => 'Istoric';

  @override
  String get fortuneToneAi => 'AI';

  @override
  String get fortuneTimeMorning => 'Dimineață';

  @override
  String get fortuneTimeAfternoon => 'După-amiază';

  @override
  String get ohengMok => 'Lemn';

  @override
  String get ohengHwa => 'Foc';

  @override
  String get ohengTo => 'Pământ';

  @override
  String get ohengGeum => 'Metal';

  @override
  String get ohengSu => 'Apă';

  @override
  String get luckyColorGreen => 'Verde';

  @override
  String get luckyColorCoral => 'Coral';

  @override
  String get luckyColorGold => 'Auriu';

  @override
  String get luckyColorSilver => 'Argintiu';

  @override
  String get luckyColorSky => 'Albastru deschis';

  @override
  String get luckyColorRed => 'Roșu';

  @override
  String get luckyColorOrange => 'Portocaliu';

  @override
  String get luckyColorYellow => 'Galben';

  @override
  String get luckyColorTeal => 'Turcoaz';

  @override
  String get luckyColorBlue => 'Albastru';

  @override
  String get luckyColorPurple => 'Mov';

  @override
  String get luckyColorPink => 'Roz';

  @override
  String get settingsLanguage => 'Limbă';

  @override
  String get settingsCountry => 'Regiune';

  @override
  String get countryKorea => 'Coreea';

  @override
  String get countryUnitedStates => 'Statele Unite';

  @override
  String get countryJapan => 'Japonia';

  @override
  String get countryChina => 'China';

  @override
  String get countryGlobal => 'Global';

  @override
  String get settingsTheme => 'Aspect';

  @override
  String get settingsThemeDescription =>
      'Tema implicită folosește tema de zi între 06:00 și 19:00 pe baza orei locale a locației conectate, iar în afara acestui interval folosește tema de noapte. Temele de zi și de noapte rămân fixe indiferent de oră.';

  @override
  String get settingsThemeAutomatic => 'Tema implicită';

  @override
  String get settingsThemeAutomaticDescription =>
      'Aplică automat tema de zi între 06:00 și 19:00 la locația conectată, apoi tema de noapte de la 19:00 până înainte de 06:00 a zilei următoare.';

  @override
  String get settingsThemeDay => 'Tema de zi';

  @override
  String get settingsThemeDayDescription =>
      'Folosește mereu tema luminoasă de zi, indiferent de oră.';

  @override
  String get settingsThemeNight => 'Tema de noapte';

  @override
  String get settingsThemeNightDescription =>
      'Folosește mereu tema întunecată de noapte existentă, indiferent de oră.';

  @override
  String get settingsThemeDark => 'Întunecat';

  @override
  String get settingsThemeLight => 'Luminos';

  @override
  String get settingsBirthTitle => 'Data nașterii';

  @override
  String get settingsBirthDescription =>
      'Gestionează data și ora nașterii folosite pentru calculul horoscopului.';

  @override
  String get settingsBirthEmpty => 'Neintrodusă';

  @override
  String get settingsBirthEdit => 'Editare';

  @override
  String get settingsBirthUnknownHour => 'Necunoscută';

  @override
  String get onboardingGenderLabel => 'Gen';

  @override
  String get genderMale => 'Bărbat';

  @override
  String get genderFemale => 'Femeie';

  @override
  String get genderUnspecified => 'Prefer să nu spun';

  @override
  String get settingsGenderTitle => 'Gen';

  @override
  String settingsHourUnit(int hour) {
    return '$hour:00';
  }

  @override
  String get settingsFortuneToneTitle => 'Ton';

  @override
  String settingsFortuneToneDescription(String tone) {
    return 'Mesajele de horoscop sunt afișate în stilul $tone.';
  }

  @override
  String get settingsFortuneToneSheetDescription =>
      'Mesajele de bază sunt păstrate, iar stilul ales este prioritizat.';

  @override
  String get settingsAppInfoTitle => 'Despre aplicație';

  @override
  String get settingsAppInfoDescription =>
      'Verifică pagina principală, ghidul de confidențialitate, e-mailul de contact și linkurile.';

  @override
  String get settingsPremiumTitle => 'Eliminare reclame (pe viață)';

  @override
  String get settingsPremiumDescription =>
      'Elimină permanent reclamele banner și interstițiale.';

  @override
  String get settingsPremiumButton => 'Elimină reclamele';

  @override
  String settingsPremiumButtonPriced(String price) {
    return 'Elimină reclamele — $price';
  }

  @override
  String get settingsPremiumPurchasedTitle => 'Reclame eliminate';

  @override
  String get settingsPremiumPurchasedDescription =>
      'Îți mulțumim pentru sprijin.';

  @override
  String get premiumMsgSuccess => 'Reclamele au fost eliminate. Mulțumim!';

  @override
  String get premiumMsgCanceled => 'Achiziție anulată.';

  @override
  String get premiumMsgError =>
      'Achiziția a eșuat. Te rugăm să încerci din nou mai târziu.';

  @override
  String get premiumMsgStoreUnavailable =>
      'Nu se poate conecta la magazin. Te rugăm să încerci din nou mai târziu.';

  @override
  String get premiumMsgProductUnavailable =>
      'Acest produs nu este disponibil momentan.';

  @override
  String get onboardingTitle => 'Yegamssi';

  @override
  String get onboardingSubtitle =>
      'Introdu data și ora nașterii\npentru a primi horoscopul de azi.';

  @override
  String get onboardingStart => 'Începe';

  @override
  String get birthDate => 'Data nașterii';

  @override
  String get birthHour => 'Ora nașterii';

  @override
  String get birthHourOptional => 'Ora nașterii (opțional)';

  @override
  String get birthSelectDate => 'Selectează o dată';

  @override
  String get birthUnknownNoon => 'Necunoscută (calculată la prânz)';

  @override
  String get birthUnknownNoonShort => 'Necunoscută (prânz)';

  @override
  String dateYmd(int year, int month, int day) {
    return '$day.$month.$year';
  }

  @override
  String hourLabel(int hour) {
    return '$hour:00';
  }

  @override
  String get appInfoHomepage => 'Pagina principală';

  @override
  String get appInfoHomepageDescription =>
      'Deschide pagina de prezentare Yegamssi.';

  @override
  String get appInfoPrivacy => 'Politica de confidențialitate';

  @override
  String get appInfoPrivacyDescription =>
      'Deschide pagina politicii de confidențialitate.';

  @override
  String get appInfoEmail => 'E-mail de contact';

  @override
  String get appInfoEmailDescription =>
      'Deschide aplicația de e-mail pentru întrebări.';

  @override
  String get appInfoShare => 'Distribuie Yegamssi';

  @override
  String get appInfoShareDescription => 'Afișează un cod QR către magazin.';

  @override
  String get appInfoShareQrDescription =>
      'Scanează codul QR pentru a deschide pagina Yegamssi din magazin.';

  @override
  String get appInfoCopyLink => 'Copiază linkul';

  @override
  String get appInfoOpenStore => 'Deschide magazinul';

  @override
  String get appInfoStoreLinkCopied => 'Linkul magazinului a fost copiat.';

  @override
  String get appInfoVersionTitle => 'Versiunea aplicației';

  @override
  String appInfoCurrentVersion(String version, String buildNumber) {
    return 'Versiunea curentă $version+$buildNumber';
  }

  @override
  String get appInfoCheckingVersion => 'Se verifică versiunea...';

  @override
  String get appInfoDataSource => 'Surse de date';

  @override
  String get appInfoKma => 'Administrația Meteorologică din Coreea (KMA)';

  @override
  String get appInfoKmaDescription =>
      'Furnizează date meteo și de prognoză pentru Coreea de Sud.';

  @override
  String get appInfoAirKorea => 'AirKorea';

  @override
  String get appInfoAirKoreaDescription =>
      'Furnizează date despre PM10, PM2.5, ozon și calitatea integrată a aerului pentru Coreea de Sud.';

  @override
  String get appInfoOpenWeather => 'OpenWeather';

  @override
  String get appInfoOpenWeatherDescription =>
      'Furnizează date meteo internaționale, de prognoză și de calitate a aerului (PM10, PM2.5, O3).';

  @override
  String get appInfoNominatim => 'OpenStreetMap Nominatim';

  @override
  String get appInfoNominatimDescription =>
      'Convertește coordonatele în nume de locuri localizate. (licență ODbL)';

  @override
  String get appInfoNoaa => 'NOAA / Serviciul Meteorologic Național SUA';

  @override
  String get appInfoNoaaDescription =>
      'Furnizează prognoze meteo oficiale și date orare pentru Statele Unite. (Domeniu public)';

  @override
  String get appInfoAirNow => 'U.S. EPA AirNow';

  @override
  String get appInfoAirNowDescription =>
      'Furnizează date în timp real privind calitatea aerului (PM2.5, PM10, Ozon) pentru Statele Unite.';

  @override
  String get appInfoDataSourceNotice =>
      'Unele informații respectă standardele de atribuire KOGL. Datele internaționale sunt furnizate de API-ul OpenWeather.';

  @override
  String get widgetScoreLabel => 'Scor';

  @override
  String get widgetFortuneLabel => 'Horoscop';

  @override
  String get widget_description => 'Widgetul cu rezumatul zilnic Yegamssi';

  @override
  String get widgetInstallTitle => 'Adaugă widgetul Yegamssi';

  @override
  String get widgetInstallMessage =>
      'Verifică vremea, temperatura, scorul de activitate în aer liber și horoscopul direct de pe ecranul de start.';

  @override
  String get widgetInstallAction => 'Instalează widgetul';

  @override
  String get widgetInstallManual =>
      'Apasă lung pe ecranul de start și adaugă widgetul Yegamssi.';

  @override
  String get appReviewTitle => 'Ai un moment, te rog? 🙏';

  @override
  String get appReviewMessage =>
      'Îți mulțumim mult că folosești Yegamssi. Este o aplicație mică, dezvoltată de o singură persoană, iar o recenzie de 5 stele din partea ta ar însemna enorm pentru noi. Ne-ai putea lăsa o recenzie de 5 stele, te rog?';

  @override
  String get appReviewAction => 'Acordă 5 stele';

  @override
  String get appReviewLater => 'Poate mai târziu';

  @override
  String get updateNoticeTitle => 'Notă de actualizare';

  @override
  String get updateRequiredTitle => 'Actualizare necesară';

  @override
  String updateRequiredMessage(String currentVersion, String latestVersion) {
    return 'Versiunea curentă $currentVersion nu mai este acceptată.\nTe rugăm să actualizezi la versiunea $latestVersion.';
  }

  @override
  String updateAvailableMessage(String latestVersion) {
    return 'Versiunea $latestVersion este pregătită.\nActualizezi acum?';
  }

  @override
  String get updateAction => 'Actualizează';

  @override
  String get updateNewVersionMessage =>
      'A apărut o versiune nouă.\nActualizezi acum?';

  @override
  String get activityRunning => 'Alergare';

  @override
  String get activityCycling => 'Ciclism';

  @override
  String get activityHiking => 'Drumeție';

  @override
  String get activityWalking => 'Plimbare';

  @override
  String get activityOutdoor => 'Muncă în aer liber';

  @override
  String get errorNetwork => 'Te rugăm să verifici conexiunea la internet.';

  @override
  String get errorServer => 'A apărut o eroare de server.';

  @override
  String get errorLocation => 'Locația nu a putut fi obținută.';

  @override
  String get errorUnknown => 'A apărut o eroare necunoscută.';

  @override
  String get settingsBackgroundRefreshTitle => 'Actualizare in fundal';

  @override
  String get settingsBackgroundRefreshDescription =>
      'Actualizeaza vremea, calitatea aerului, scorul de exterior si widgetul aproximativ la fiecare 30 de minute. Exceptia de baterie creste fiabilitatea.';

  @override
  String get settingsBackgroundRefreshStatusEnabled =>
      'Exceptie baterie activa';

  @override
  String get settingsBackgroundRefreshStatusLimited =>
      'Este necesara exceptia de baterie';

  @override
  String get settingsBackgroundRefreshAction => 'Deschide setarile';

  @override
  String get batteryOptimizationReminderTitle => 'Permite actualizarea stabila';

  @override
  String get batteryOptimizationReminderMessage =>
      'Yegamssi poate actualiza mai fiabil vremea, calitatea aerului si widgeturile la fiecare 30 de minute daca dezactivezi optimizarea bateriei pentru aceasta aplicatie.';

  @override
  String get batteryOptimizationReminderLater => 'Mai tarziu';

  @override
  String get batteryOptimizationReminderNever => 'Nu mai afisa';

  @override
  String get batteryOptimizationReminderSettings => 'Deschide setarile';

  @override
  String get settingsSupportTitle => 'Susținere';

  @override
  String get settingsSupportDescription =>
      'Susține Yegamssi printr-o recenzie sau vizionarea unei reclame scurte.';

  @override
  String get settingsSupportSheetDescription =>
      'Un gest mic ajută Yegamssi să continue să se îmbunătățească.';

  @override
  String get settingsSupportReviewAction => 'Scrie o recenzie';

  @override
  String get settingsSupportAdAction =>
      'Vizionează o reclamă interstițială pentru a susține dezvoltatorul';

  @override
  String get settingsSupportReviewFailed =>
      'Ecranul de recenzii nu a putut fi deschis. Încearcă din nou mai târziu.';

  @override
  String get settingsSupportAdThanks => 'Îți mulțumim că susții Yegamssi.';

  @override
  String get settingsSupportPremiumThanks =>
      'Ai susținut deja Yegamssi eliminând reclamele. Îți mulțumim.';

  @override
  String get settingsSupportAdFailed =>
      'Reclama nu a putut fi încărcată. Încearcă din nou mai târziu.';
}
