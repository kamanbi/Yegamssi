// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Yegamssi';

  @override
  String get tabHome => 'Aujourd\'hui';

  @override
  String get tabWeather => 'Météo';

  @override
  String get tabScore => 'Score';

  @override
  String get tabMonthlyYegamssi => 'Mois';

  @override
  String get monthlyYegamssiTitle => 'Yegamssi du mois';

  @override
  String get monthlyYegamssiSubtitle =>
      'Découvre les bons jours et les jours à surveiller de ce mois, par catégorie.';

  @override
  String get monthlyGoodDaysLabel => 'Bons jours';

  @override
  String get monthlyCautionDaysLabel => 'À surveiller';

  @override
  String get monthlyGeneratingMessage => 'Préparation du Yegamssi du mois.';

  @override
  String get monthlyFailedMessage =>
      'Impossible de préparer le Yegamssi du mois. Veuillez relancer l\'application.';

  @override
  String get monthlyDisclaimer =>
      'Le Yegamssi du mois est un contenu indicatif fondé sur le flux du Myeongri. Pèse tes décisions importantes en tenant compte des conditions réelles.';

  @override
  String get monthlySummaryEarly =>
      'Ce mois-ci, le flux est bon en début de mois : avancer tôt joue en ta faveur.';

  @override
  String get monthlySummaryMid =>
      'Ce mois-ci, le flux s\'améliore à partir de la mi-mois : mieux vaut guetter le bon moment que se précipiter.';

  @override
  String get monthlySummaryLate =>
      'Ce mois-ci, si tu donnes tout en fin de mois, de bons résultats suivront.';

  @override
  String get monthlyCategoryLove => 'Amour';

  @override
  String get monthlyCategoryLoveMessage =>
      'Les bons jours sont parfaits pour exprimer tes sentiments en premier. Les jours à surveiller, mieux vaut une conversation posée.';

  @override
  String get monthlyCategoryWork => 'Travail';

  @override
  String get monthlyCategoryWorkMessage =>
      'Les bons jours sont parfaits pour lancer quelque chose de nouveau. Les jours à surveiller, ne force pas et concentre-toi sur ce que tu boucles.';

  @override
  String get monthlyCategoryMoney => 'Argent';

  @override
  String get monthlyCategoryMoneyMessage =>
      'Les bons jours sont parfaits pour mettre de l\'ordre dans tes finances. Les jours à surveiller, vérifie deux fois avant une grosse dépense.';

  @override
  String get monthlyCategoryRelationship => 'Relations';

  @override
  String get monthlyCategoryRelationshipMessage =>
      'Les bons jours sont parfaits pour échanger avec les autres. Les jours à surveiller, choisis bien tes mots pour éviter les malentendus.';

  @override
  String get monthlyCategoryHealth => 'Santé';

  @override
  String get monthlyCategoryHealthMessage =>
      'Les bons jours sont parfaits pour bouger. Les jours à surveiller, n\'en fais pas trop et ménage-toi du repos.';

  @override
  String get monthlyCategoryDecision => 'Décisions';

  @override
  String get monthlyCategoryDecisionMessage =>
      'Les bons jours sont parfaits pour trancher une question importante. Les jours à surveiller, mieux vaut attendre et réexaminer un peu.';

  @override
  String get monthlyCategoryTravel => 'Déplacements';

  @override
  String get monthlyCategoryTravelMessage =>
      'Les bons jours sont parfaits pour planifier une sortie ou un voyage. Les jours à surveiller, garde un peu de marge dans ton emploi du temps.';

  @override
  String get tabFortune => 'Fortune';

  @override
  String get tabSettings => 'Paramètres';

  @override
  String get homeHeadline => 'La météo et les signaux d\'aujourd\'hui';

  @override
  String get homeWeatherLoadingTitle => 'Chargement de la météo actuelle';

  @override
  String get homeWeatherLoadingMessage =>
      'Préparation des données de localisation et de météo.';

  @override
  String get homeWeatherErrorTitle => 'Impossible de charger la météo actuelle';

  @override
  String get homeWeatherErrorMessage => 'Ouvre l\'écran météo et réessaie.';

  @override
  String get homeWeatherAction => 'Voir la météo';

  @override
  String get homeFortuneLoadingTitle => 'Préparation de la fortune du jour';

  @override
  String get homeFortuneLoadingMessage => 'Un court résumé apparaîtra bientôt.';

  @override
  String get homeFortuneErrorTitle => 'La fortune n\'est pas encore prête';

  @override
  String get homeFortuneErrorMessage =>
      'Vérifie ton profil et réessaie sur l\'écran fortune.';

  @override
  String get homeFortuneAction => 'Voir la fortune';

  @override
  String get homeFortuneHeadline => 'La fortune du jour en une phrase';

  @override
  String get appExitTitle => 'Quitter l\'application';

  @override
  String get appExitMessage => 'Voulez-vous fermer Yegamssi ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'OK';

  @override
  String get close => 'Fermer';

  @override
  String get later => 'Plus tard';

  @override
  String get exit => 'Quitter';

  @override
  String get search => 'Rechercher';

  @override
  String get loadingAd => 'Chargement de la publicité...';

  @override
  String get refresh => 'Actualiser';

  @override
  String refreshFailed(String error) {
    return 'Échec de l\'actualisation : $error';
  }

  @override
  String notFoundPage(String error) {
    return 'Page introuvable : $error';
  }

  @override
  String weatherFeelsLike(String temp) {
    return 'Ressenti $temp°C';
  }

  @override
  String weatherFeelsLikeShort(String temp) {
    return 'Res. $temp℃';
  }

  @override
  String weatherHumidity(int value) {
    return 'Humidité $value%';
  }

  @override
  String weatherWind(String speed) {
    return 'Vent ${speed}m/s';
  }

  @override
  String get weatherHumidityLabel => 'Humidité';

  @override
  String get weatherWindLabel => 'Vent';

  @override
  String get weatherWindSpeedLabel => 'Vit. vent';

  @override
  String get weatherPrecipitationLabel => 'Pluie';

  @override
  String weatherPrecipitationAmount(String amount) {
    return 'Pluie $amount';
  }

  @override
  String get weatherDustPm10 => 'PM10';

  @override
  String get weatherDustPm25 => 'PM2.5';

  @override
  String get weatherHourlyForecast => 'Prévisions horaires';

  @override
  String get weatherWeeklyForecast => 'Prévisions hebdomadaires';

  @override
  String get weatherLoading => 'Chargement météo...';

  @override
  String get weatherErrorTitle => 'Impossible d\'obtenir les données météo';

  @override
  String weatherReturnCurrentLocation(int seconds) {
    return 'Retour à la localisation actuelle dans ${seconds}s';
  }

  @override
  String get weatherToday => 'Aujourd\'hui';

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
    return '$uv Très élevé';
  }

  @override
  String weatherUvHigh(int uv) {
    return '$uv Élevé';
  }

  @override
  String weatherUvModerateHigh(int uv) {
    return '$uv Modéré-élevé';
  }

  @override
  String weatherUvModerate(int uv) {
    return '$uv Modéré';
  }

  @override
  String weatherUvLow(int uv) {
    return '$uv Faible';
  }

  @override
  String get weatherConditionSunny => 'Ensoleillé';

  @override
  String get weatherConditionClearNight => 'Nuit claire';

  @override
  String get weatherConditionPartlyCloudy => 'Partiellement nuageux';

  @override
  String get weatherConditionPartlyCloudyNight => 'Nuit partiellement nuageuse';

  @override
  String get weatherConditionCloudy => 'Nuageux';

  @override
  String get weatherConditionHazy => 'Brumeux';

  @override
  String get weatherConditionWindy => 'Venteux';

  @override
  String get weatherConditionSlightRain => 'Pluie légère';

  @override
  String get weatherConditionRain => 'Pluie';

  @override
  String get weatherConditionHeavyRain => 'Forte pluie';

  @override
  String get weatherConditionThunderstorm => 'Orage';

  @override
  String get weatherConditionRainThunder => 'Pluie et tonnerre';

  @override
  String get weatherConditionLightSnow => 'Neige légère';

  @override
  String get weatherConditionSnow => 'Neige';

  @override
  String get weatherConditionSleet => 'Grésil';

  @override
  String get weatherConditionHot => 'Chaud';

  @override
  String get weatherConditionHotNight => 'Nuit chaude';

  @override
  String get weatherConditionColdWave => 'Vague de froid';

  @override
  String get weatherConditionUnknown => 'Inconnu';

  @override
  String get locationCurrent => 'Position actuelle';

  @override
  String get locationSelectClose => 'Fermer le sélecteur de position';

  @override
  String locationAdded(String name) {
    return '$name ajouté';
  }

  @override
  String get locationFavoriteLimit =>
      'Vous pouvez ajouter jusqu\'à 5 positions.';

  @override
  String get locationFavoriteFull => 'Favoris pleins';

  @override
  String get locationFavoriteAdd => 'Ajouter aux favoris';

  @override
  String get locationSearchTitle => 'Rechercher une position';

  @override
  String get locationSearchHint => 'Exemple : Séoul, Busan, Tokyo';

  @override
  String get locationSearchEmpty => 'Aucun résultat trouvé';

  @override
  String get scoreLabel => 'Score d\'activité extérieure';

  @override
  String get scoreLoading => 'Calcul du score d\'activité extérieure...';

  @override
  String get scoreErrorTitle => 'Impossible de calculer le score';

  @override
  String get scoreBreakdownTitle => 'Déductions';

  @override
  String get scoreNoDeduction =>
      'Conditions extérieures stables, presque sans facteurs de déduction.';

  @override
  String get scoreInfo =>
      'Le score d\'activité extérieure est calculé à partir de la pluie, du vent, de la sensation thermique, de la qualité de l\'air et des données UV.';

  @override
  String get scoreDeductionRain => 'Pluie et neige';

  @override
  String get scoreDeductionWind => 'Vent';

  @override
  String get scoreDeductionTemp => 'Température';

  @override
  String get scoreDeductionAir => 'Qualité de l\'air';

  @override
  String get scoreDeductionUv => 'UV';

  @override
  String get scoreDeductionOzone => 'Ozone';

  @override
  String get scoreAdviceExcellent =>
      'Aujourd\'hui est parfait pour les activités extérieures.\nSors et profites-en.';

  @override
  String get scoreAdviceGood =>
      'Les activités extérieures sont bonnes, mais vérifie le vent et les UV.';

  @override
  String get scoreAdviceFair =>
      'Les activités extérieures sont possibles, mieux vaut se préparer.';

  @override
  String get scoreAdvicePoor =>
      'Aujourd\'hui, il vaut mieux planifier des activités intérieures.';

  @override
  String get scoreTierExcellent => 'Excellent';

  @override
  String get scoreTierGood => 'Bon';

  @override
  String get scoreTierFair => 'Passable';

  @override
  String get scoreTierPoor => 'Attention';

  @override
  String scorePointUnit(int score) {
    return '$score pts';
  }

  @override
  String get activityRecommendOutdoor => 'Activité extérieure recommandée';

  @override
  String get activityRecommendLight => 'Activité légère adaptée';

  @override
  String get activityRecommendCaution => 'Prudence requise';

  @override
  String get activityRecommendIndoor => 'Activité intérieure recommandée';

  @override
  String get airQualityTitle => 'Qualité de l\'air';

  @override
  String get airQualityIntegrated => 'Qualité de l\'air intégrée';

  @override
  String get airQualityUnknown => 'Pas de données';

  @override
  String get airGradeGood => 'Bonne';

  @override
  String get airGradeModerate => 'Modérée';

  @override
  String get airGradeBad => 'Mauvaise';

  @override
  String get airGradeVeryBad => 'Très mauvaise';

  @override
  String get pointUnit => 'pts';

  @override
  String get fortuneTitle => 'Votre fortune quotidienne';

  @override
  String get fortuneNeedProfileTitle => 'Informations de naissance requises';

  @override
  String get fortuneNeedProfileMessage =>
      'Entrez votre date et heure de naissance pour recevoir la fortune du jour.';

  @override
  String get fortuneBirthInputAction => 'Saisir les informations de naissance';

  @override
  String get fortuneHelpTooltip => 'Aide sur la fortune';

  @override
  String get fortuneHelpTitle => 'Comment Yegamssi lit la fortune';

  @override
  String get fortuneHelpIntro =>
      'Yegamssi lit le flux de la fortune du jour à partir du Myeongri.';

  @override
  String get fortuneHelpMyeongri =>
      'Le Myeongri est un système traditionnel oriental qui observe les Quatre Piliers et l\'équilibre des cinq éléments à partir de la date et de l\'heure de naissance. Yegamssi calcule ton énergie personnelle de base avec ta date et ton heure de naissance, la compare au flux du jour, puis présente la fortune générale, financière, amoureuse, professionnelle, de santé et de décision.';

  @override
  String get fortuneHelpBirthTime =>
      'Si tu ne connais pas ton heure de naissance, tu peux utiliser midi comme référence. Indiquer l\'heure de naissance aide toutefois à obtenir une interprétation plus précise.';

  @override
  String get fortuneHelpWeather =>
      'Yegamssi tient aussi compte de la météo et du score d\'activité, pas seulement de la fortune. Ainsi, même si l\'énergie du jour est bonne, une mauvaise météo peut réduire la recommandation de sortie. Si la fortune et la météo sont stables, la journée peut être plus favorable à l\'action.';

  @override
  String get fortuneHelpReference =>
      'La fortune n\'est pas une réponse définitive, mais un repère. Utilise-la pour observer le flux du jour et choisir avec plus de prudence tes contacts, sorties, dépenses, contrats et décisions importantes.';

  @override
  String get fortuneLoadFailedTitle => 'Impossible de charger la fortune';

  @override
  String get fortuneLoadFailedMessage => 'Veuillez réessayer plus tard.';

  @override
  String get fortuneCategoryAnalysis => 'Analyse par catégorie';

  @override
  String get fortuneOverall => 'Fortune générale';

  @override
  String get fortuneCategoryMoney => 'Argent';

  @override
  String get fortuneCategoryLove => 'Amour';

  @override
  String get fortuneCategoryWork => 'Travail';

  @override
  String get fortuneCategoryHealth => 'Santé';

  @override
  String get fortuneCategoryDecision => 'Décision';

  @override
  String get fortuneLuckyColor => 'Couleur porte-bonheur';

  @override
  String get fortuneLuckyNumber => 'Numéro porte-bonheur';

  @override
  String get fortuneOhengBalance => 'Équilibre élémentaire';

  @override
  String get fortuneOhengDescription =>
      'Un signal de soutien pour le flux émotionnel d\'aujourd\'hui.';

  @override
  String get fortuneCaptureTooltip => 'Capturer la carte de fortune';

  @override
  String get fortuneCaptureSaved => 'Capture de carte sauvegardée.';

  @override
  String get fortuneCaptureSaveDone => 'Capture de carte terminée';

  @override
  String fortuneCaptureFailed(String error) {
    return 'Échec de la capture : $error';
  }

  @override
  String get fortuneOpenFolder => 'Ouvrir le dossier';

  @override
  String get fortuneAnalyzing => 'Analyse en cours.';

  @override
  String get fortuneToneBase => 'Base';

  @override
  String get fortuneToneHumor => 'Humour';

  @override
  String get fortuneToneTsundere => 'Tsundere';

  @override
  String get fortuneToneCynical => 'Cynique';

  @override
  String get fortuneToneEmotional => 'Émotionnel';

  @override
  String get fortuneToneHistorical => 'Historique';

  @override
  String get fortuneToneAi => 'IA';

  @override
  String get fortuneTimeMorning => 'Matin';

  @override
  String get fortuneTimeAfternoon => 'Après-midi';

  @override
  String get ohengMok => 'Bois';

  @override
  String get ohengHwa => 'Feu';

  @override
  String get ohengTo => 'Terre';

  @override
  String get ohengGeum => 'Métal';

  @override
  String get ohengSu => 'Eau';

  @override
  String get luckyColorGreen => 'Vert';

  @override
  String get luckyColorCoral => 'Corail';

  @override
  String get luckyColorGold => 'Or';

  @override
  String get luckyColorSilver => 'Argent';

  @override
  String get luckyColorSky => 'Bleu ciel';

  @override
  String get luckyColorRed => 'Rouge';

  @override
  String get luckyColorOrange => 'Orange';

  @override
  String get luckyColorYellow => 'Jaune';

  @override
  String get luckyColorTeal => 'Turquoise';

  @override
  String get luckyColorBlue => 'Bleu';

  @override
  String get luckyColorPurple => 'Violet';

  @override
  String get luckyColorPink => 'Rose';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsCountry => 'Région';

  @override
  String get countryKorea => 'Corée';

  @override
  String get countryUnitedStates => 'États-Unis';

  @override
  String get countryJapan => 'Japon';

  @override
  String get countryChina => 'Chine';

  @override
  String get countryGlobal => 'Global';

  @override
  String get settingsTheme => 'Apparence';

  @override
  String get settingsThemeDescription =>
      'Le thème par défaut utilise le thème de jour de 06:00 à 19:00 selon l\'heure locale de la position connectée, puis le thème de nuit en dehors de cette plage. Les thèmes de jour et de nuit restent fixes quelle que soit l\'heure.';

  @override
  String get settingsThemeAutomatic => 'Thème par défaut';

  @override
  String get settingsThemeAutomaticDescription =>
      'Utilise automatiquement le thème de jour de 06:00 à 19:00 à la position connectée, puis le thème de nuit de 19:00 jusqu\'avant 06:00 le lendemain.';

  @override
  String get settingsThemeDay => 'Thème de jour';

  @override
  String get settingsThemeDayDescription =>
      'Utilise toujours le thème clair de jour, quelle que soit l\'heure.';

  @override
  String get settingsThemeNight => 'Thème de nuit';

  @override
  String get settingsThemeNightDescription =>
      'Utilise toujours le thème sombre de nuit existant, quelle que soit l\'heure.';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsBirthTitle => 'Date de naissance';

  @override
  String get settingsBirthDescription =>
      'Gérez la date et l\'heure de naissance pour le calcul de la fortune.';

  @override
  String get settingsBirthEmpty => 'Non renseigné';

  @override
  String get settingsBirthEdit => 'Modifier';

  @override
  String get settingsBirthUnknownHour => 'Inconnu';

  @override
  String get onboardingGenderLabel => 'Genre';

  @override
  String get genderMale => 'Homme';

  @override
  String get genderFemale => 'Femme';

  @override
  String get genderUnspecified => 'Je préfère ne pas répondre';

  @override
  String get settingsGenderTitle => 'Genre';

  @override
  String settingsHourUnit(int hour) {
    return '$hour:00';
  }

  @override
  String get settingsFortuneToneTitle => 'Ton';

  @override
  String settingsFortuneToneDescription(String tone) {
    return 'Les messages de fortune sont affichés en style $tone.';
  }

  @override
  String get settingsFortuneToneSheetDescription =>
      'Les messages de base sont conservés et le style sélectionné est prioritaire.';

  @override
  String get settingsAppInfoTitle => 'Informations sur l\'app';

  @override
  String get settingsAppInfoDescription =>
      'Consulter la page d\'accueil, le guide de confidentialité, l\'e-mail de contact et les liens.';

  @override
  String get settingsPremiumTitle => 'Supprimer les publicités (à vie)';

  @override
  String get settingsPremiumDescription =>
      'Supprime définitivement les bannières publicitaires et les publicités interstitielles.';

  @override
  String get settingsPremiumButton => 'Supprimer les publicités';

  @override
  String settingsPremiumButtonPriced(String price) {
    return 'Supprimer les publicités — $price';
  }

  @override
  String get settingsPremiumPurchasedTitle => 'Publicités supprimées';

  @override
  String get settingsPremiumPurchasedDescription => 'Merci pour votre soutien.';

  @override
  String get premiumMsgSuccess => 'Les publicités ont été supprimées. Merci !';

  @override
  String get premiumMsgCanceled => 'Achat annulé.';

  @override
  String get premiumMsgError =>
      'L\'achat a échoué. Veuillez réessayer plus tard.';

  @override
  String get premiumMsgStoreUnavailable =>
      'Impossible de se connecter au magasin. Veuillez réessayer plus tard.';

  @override
  String get premiumMsgProductUnavailable =>
      'Cet article n\'est pas disponible actuellement.';

  @override
  String get onboardingTitle => 'Yegamssi';

  @override
  String get onboardingSubtitle =>
      'Entrez votre date et heure de naissance\npour recevoir la fortune du jour.';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get birthDate => 'Date de naissance';

  @override
  String get birthHour => 'Heure de naissance';

  @override
  String get birthHourOptional => 'Heure de naissance (optionnel)';

  @override
  String get birthSelectDate => 'Sélectionner une date';

  @override
  String get birthUnknownNoon => 'Inconnu (calculé à midi)';

  @override
  String get birthUnknownNoonShort => 'Inconnu (midi)';

  @override
  String dateYmd(int year, int month, int day) {
    return '$day/$month/$year';
  }

  @override
  String hourLabel(int hour) {
    return '$hour:00';
  }

  @override
  String get appInfoHomepage => 'Page d\'accueil';

  @override
  String get appInfoHomepageDescription =>
      'Ouvrir la page de présentation de Yegamssi.';

  @override
  String get appInfoPrivacy => 'Politique de confidentialité';

  @override
  String get appInfoPrivacyDescription =>
      'Ouvrir la page de politique de confidentialité.';

  @override
  String get appInfoEmail => 'E-mail de contact';

  @override
  String get appInfoEmailDescription =>
      'Ouvrir l\'application de messagerie pour les demandes.';

  @override
  String get appInfoShare => 'Partager Yegamssi';

  @override
  String get appInfoShareDescription =>
      'Afficher un QR code lié à la boutique.';

  @override
  String get appInfoShareQrDescription =>
      'Scannez le QR code pour ouvrir la page de la boutique Yegamssi.';

  @override
  String get appInfoCopyLink => 'Copier le lien';

  @override
  String get appInfoOpenStore => 'Ouvrir la boutique';

  @override
  String get appInfoStoreLinkCopied => 'Lien de la boutique copié.';

  @override
  String get appInfoVersionTitle => 'Version de l\'app';

  @override
  String appInfoCurrentVersion(String version, String buildNumber) {
    return 'Version actuelle $version+$buildNumber';
  }

  @override
  String get appInfoCheckingVersion => 'Vérification de la version...';

  @override
  String get appInfoDataSource => 'Sources de données';

  @override
  String get appInfoKma => 'Service météorologique coréen (KMA)';

  @override
  String get appInfoKmaDescription =>
      'Fournit des données météo et des prévisions pour la Corée du Sud.';

  @override
  String get appInfoAirKorea => 'AirKorea';

  @override
  String get appInfoAirKoreaDescription =>
      'Fournit les données PM10, PM2.5, ozone et qualité de l\'air intégrée pour la Corée du Sud.';

  @override
  String get appInfoOpenWeather => 'OpenWeather';

  @override
  String get appInfoOpenWeatherDescription =>
      'Fournit des données météo internationales, des prévisions et la qualité de l\'air (PM10, PM2.5, O3).';

  @override
  String get appInfoNominatim => 'OpenStreetMap Nominatim';

  @override
  String get appInfoNominatimDescription =>
      'Convertit les coordonnées en noms de lieux localisés. (Licence ODbL)';

  @override
  String get appInfoNoaa =>
      'NOAA / Service météorologique national des États-Unis';

  @override
  String get appInfoNoaaDescription =>
      'Fournit des prévisions météo officielles et des données horaires pour les États-Unis. (Domaine public)';

  @override
  String get appInfoAirNow => 'U.S. EPA AirNow';

  @override
  String get appInfoAirNowDescription =>
      'Fournit des données de qualité de l\'air en temps réel (PM2.5, PM10, Ozone) pour les États-Unis.';

  @override
  String get appInfoDataSourceNotice =>
      'Certaines informations suivent les normes d\'attribution KOGL. Les données internationales sont fournies par l\'API OpenWeather.';

  @override
  String get widgetScoreLabel => 'Score';

  @override
  String get widgetFortuneLabel => 'Fortune';

  @override
  String get widget_description => 'Widget de résumé quotidien Yegamssi';

  @override
  String get widgetInstallTitle => 'Ajouter le widget Yegamssi';

  @override
  String get widgetInstallMessage =>
      'Consultez la météo, la température, le score extérieur et la fortune directement depuis votre écran d\'accueil.';

  @override
  String get widgetInstallAction => 'Installer le widget';

  @override
  String get widgetInstallManual =>
      'Appuyez longuement sur l\'écran d\'accueil et ajoutez le widget Yegamssi.';

  @override
  String get appReviewTitle => 'Avez-vous un instant? 🙏';

  @override
  String get appReviewMessage =>
      'Merci beaucoup d\'utiliser Yegamssi. C\'est une petite application développée par une seule personne, et un avis 5 étoiles de votre part compterait énormément pour nous. Pourriez-vous nous laisser un avis 5 étoiles, s\'il vous plaît?';

  @override
  String get appReviewAction => 'Donner 5 étoiles';

  @override
  String get appReviewLater => 'Peut-être plus tard';

  @override
  String get updateNoticeTitle => 'Avis de mise à jour';

  @override
  String get updateRequiredTitle => 'Mise à jour requise';

  @override
  String updateRequiredMessage(String currentVersion, String latestVersion) {
    return 'La version actuelle $currentVersion n\'est plus prise en charge.\nVeuillez mettre à jour vers la version $latestVersion.';
  }

  @override
  String updateAvailableMessage(String latestVersion) {
    return 'La version $latestVersion est prête.\nMettre à jour maintenant ?';
  }

  @override
  String get updateAction => 'Mettre à jour';

  @override
  String get updateNewVersionMessage =>
      'Une nouvelle version a été publiée.\nMettre à jour maintenant ?';

  @override
  String get activityRunning => 'Course';

  @override
  String get activityCycling => 'Vélo';

  @override
  String get activityHiking => 'Randonnée';

  @override
  String get activityWalking => 'Marche';

  @override
  String get activityOutdoor => 'Travail extérieur';

  @override
  String get errorNetwork => 'Vérifiez votre connexion internet.';

  @override
  String get errorServer => 'Une erreur serveur s\'est produite.';

  @override
  String get errorLocation => 'Impossible d\'obtenir la localisation.';

  @override
  String get errorUnknown => 'Une erreur inconnue s\'est produite.';

  @override
  String get settingsBackgroundRefreshTitle => 'Actualisation en arriere-plan';

  @override
  String get settingsBackgroundRefreshDescription =>
      'Actualise la meteo, la qualite de l air, le score exterieur et le widget environ toutes les 30 minutes. L exception de batterie ameliore la fiabilite.';

  @override
  String get settingsBackgroundRefreshStatusEnabled =>
      'Exception batterie activee';

  @override
  String get settingsBackgroundRefreshStatusLimited =>
      'Exception batterie requise';

  @override
  String get settingsBackgroundRefreshAction => 'Ouvrir les reglages';

  @override
  String get batteryOptimizationReminderTitle =>
      'Autoriser une actualisation stable';

  @override
  String get batteryOptimizationReminderMessage =>
      'Yegamssi peut actualiser plus fiablement la meteo, la qualite de l air et les widgets toutes les 30 minutes si l optimisation batterie est desactivee pour cette app.';

  @override
  String get batteryOptimizationReminderLater => 'Plus tard';

  @override
  String get batteryOptimizationReminderNever => 'Ne plus afficher';

  @override
  String get batteryOptimizationReminderSettings => 'Ouvrir les reglages';

  @override
  String get settingsSupportTitle => 'Soutien';

  @override
  String get settingsSupportDescription =>
      'Soutenez Yegamssi en laissant un avis ou en regardant une courte publicité.';

  @override
  String get settingsSupportSheetDescription =>
      'Un petit geste aide Yegamssi à continuer de s\'améliorer.';

  @override
  String get settingsSupportReviewAction => 'Écrire un avis';

  @override
  String get settingsSupportAdAction =>
      'Regarder une publicité interstitielle pour soutenir le développeur';

  @override
  String get settingsSupportReviewFailed =>
      'Impossible d\'ouvrir l\'écran d\'avis. Veuillez réessayer plus tard.';

  @override
  String get settingsSupportAdThanks => 'Merci de soutenir Yegamssi.';

  @override
  String get settingsSupportPremiumThanks =>
      'Vous avez déjà soutenu Yegamssi en supprimant les publicités. Merci.';

  @override
  String get settingsSupportAdFailed =>
      'Impossible de charger la publicité. Veuillez réessayer plus tard.';
}
