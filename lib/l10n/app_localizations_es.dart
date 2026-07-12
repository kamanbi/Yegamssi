// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Yegamssi';

  @override
  String get tabHome => 'Hoy';

  @override
  String get tabWeather => 'Tiempo';

  @override
  String get tabScore => 'Puntuación';

  @override
  String get tabMonthlyYegamssi => 'Mensual';

  @override
  String get monthlyYegamssiTitle => 'Yegamssi mensual';

  @override
  String get monthlyYegamssiSubtitle =>
      'Consulta los días buenos y los días para tener cuidado de este mes por categoría.';

  @override
  String get monthlyGoodDaysLabel => 'Días buenos';

  @override
  String get monthlyCautionDaysLabel => 'Con cuidado';

  @override
  String get monthlyGeneratingMessage =>
      'Preparando el Yegamssi mensual de este mes.';

  @override
  String get monthlyFailedMessage =>
      'No pudimos preparar el Yegamssi mensual de este mes. Reinicia la aplicación, por favor.';

  @override
  String get monthlyDisclaimer =>
      'El Yegamssi mensual es contenido de referencia basado en el flujo del Myeongri. Valora las decisiones importantes junto con las condiciones reales.';

  @override
  String get monthlySummaryEarly =>
      'Este mes el flujo es bueno al principio, así que moverte pronto te favorece.';

  @override
  String get monthlySummaryMid =>
      'Este mes el flujo mejora a partir de mediados; conviene más esperar el momento que apresurarse.';

  @override
  String get monthlySummaryLate =>
      'Si te esfuerzas en la recta final del mes, llegarán buenos resultados.';

  @override
  String get monthlyCategoryLove => 'Amor';

  @override
  String get monthlyCategoryLoveMessage =>
      'Los días buenos son ideales para expresar primero lo que sientes. En los días con cuidado, mejor una conversación tranquila.';

  @override
  String get monthlyCategoryWork => 'Trabajo';

  @override
  String get monthlyCategoryWorkMessage =>
      'Los días buenos son ideales para empezar algo nuevo. En los días con cuidado, mejor no forzar y centrarte en cerrar temas.';

  @override
  String get monthlyCategoryMoney => 'Dinero';

  @override
  String get monthlyCategoryMoneyMessage =>
      'Los días buenos son ideales para ordenar tus finanzas. En los días con cuidado, comprueba dos veces antes de un gasto grande.';

  @override
  String get monthlyCategoryRelationship => 'Relaciones';

  @override
  String get monthlyCategoryRelationshipMessage =>
      'Los días buenos son ideales para conversar con la gente. En los días con cuidado, elige bien las palabras para evitar malentendidos.';

  @override
  String get monthlyCategoryHealth => 'Salud';

  @override
  String get monthlyCategoryHealthMessage =>
      'Los días buenos son ideales para mover el cuerpo. En los días con cuidado, no te excedas y reserva tiempo para descansar.';

  @override
  String get monthlyCategoryDecision => 'Decisiones';

  @override
  String get monthlyCategoryDecisionMessage =>
      'Los días buenos son ideales para tomar una decisión importante. En los días con cuidado, mejor esperar y revisarlo un poco más.';

  @override
  String get monthlyCategoryTravel => 'Desplazamientos';

  @override
  String get monthlyCategoryTravelMessage =>
      'Los días buenos son ideales para planear una salida o un viaje. En los días con cuidado, deja algo de margen en tu agenda.';

  @override
  String get tabFortune => 'Fortuna';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get homeHeadline => 'El tiempo y las señales de hoy';

  @override
  String get homeWeatherLoadingTitle => 'Cargando el tiempo actual';

  @override
  String get homeWeatherLoadingMessage =>
      'Preparando datos de ubicación y tiempo.';

  @override
  String get homeWeatherErrorTitle => 'No se pudo cargar el tiempo actual';

  @override
  String get homeWeatherErrorMessage =>
      'Abre la pantalla del tiempo e inténtalo de nuevo.';

  @override
  String get homeWeatherAction => 'Ver tiempo';

  @override
  String get homeFortuneLoadingTitle => 'Preparando la fortuna de hoy';

  @override
  String get homeFortuneLoadingMessage => 'El resumen aparecerá en breve.';

  @override
  String get homeFortuneErrorTitle => 'La fortuna aún no está lista';

  @override
  String get homeFortuneErrorMessage =>
      'Comprueba tu perfil e inténtalo en la pantalla de fortuna.';

  @override
  String get homeFortuneAction => 'Ver fortuna';

  @override
  String get homeFortuneHeadline => 'La fortuna de hoy en una frase';

  @override
  String get appExitTitle => 'Salir de la app';

  @override
  String get appExitMessage => '¿Quieres cerrar Yegamssi?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Aceptar';

  @override
  String get close => 'Cerrar';

  @override
  String get later => 'Después';

  @override
  String get exit => 'Salir';

  @override
  String get search => 'Buscar';

  @override
  String get loadingAd => 'Cargando anuncio...';

  @override
  String get refresh => 'Actualizar';

  @override
  String refreshFailed(String error) {
    return 'Error al actualizar: $error';
  }

  @override
  String notFoundPage(String error) {
    return 'Página no encontrada: $error';
  }

  @override
  String weatherFeelsLike(String temp) {
    return 'Sensación $temp°C';
  }

  @override
  String weatherFeelsLikeShort(String temp) {
    return 'Sens. $temp℃';
  }

  @override
  String weatherHumidity(int value) {
    return 'Humedad $value%';
  }

  @override
  String weatherWind(String speed) {
    return 'Viento ${speed}m/s';
  }

  @override
  String get weatherHumidityLabel => 'Humedad';

  @override
  String get weatherWindLabel => 'Viento';

  @override
  String get weatherWindSpeedLabel => 'Vel. viento';

  @override
  String get weatherPrecipitationLabel => 'Lluvia';

  @override
  String weatherPrecipitationAmount(String amount) {
    return 'Lluvia $amount';
  }

  @override
  String get weatherDustPm10 => 'PM10';

  @override
  String get weatherDustPm25 => 'PM2.5';

  @override
  String get weatherHourlyForecast => 'Pronóstico por hora';

  @override
  String get weatherWeeklyForecast => 'Pronóstico semanal';

  @override
  String get weatherLoading => 'Cargando tiempo...';

  @override
  String get weatherErrorTitle => 'No se pueden obtener datos del tiempo';

  @override
  String weatherReturnCurrentLocation(int seconds) {
    return 'Volviendo a la ubicación actual en ${seconds}s';
  }

  @override
  String get weatherToday => 'Hoy';

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
    return '$uv Muy alto';
  }

  @override
  String weatherUvHigh(int uv) {
    return '$uv Alto';
  }

  @override
  String weatherUvModerateHigh(int uv) {
    return '$uv Moderado-alto';
  }

  @override
  String weatherUvModerate(int uv) {
    return '$uv Moderado';
  }

  @override
  String weatherUvLow(int uv) {
    return '$uv Bajo';
  }

  @override
  String get weatherConditionSunny => 'Soleado';

  @override
  String get weatherConditionClearNight => 'Noche despejada';

  @override
  String get weatherConditionPartlyCloudy => 'Parcialmente nublado';

  @override
  String get weatherConditionPartlyCloudyNight => 'Noche parcialmente nublada';

  @override
  String get weatherConditionCloudy => 'Nublado';

  @override
  String get weatherConditionHazy => 'Brumoso';

  @override
  String get weatherConditionWindy => 'Ventoso';

  @override
  String get weatherConditionSlightRain => 'Lluvia ligera';

  @override
  String get weatherConditionRain => 'Lluvia';

  @override
  String get weatherConditionHeavyRain => 'Lluvia intensa';

  @override
  String get weatherConditionThunderstorm => 'Tormenta';

  @override
  String get weatherConditionRainThunder => 'Lluvia y truenos';

  @override
  String get weatherConditionLightSnow => 'Nevada ligera';

  @override
  String get weatherConditionSnow => 'Nieve';

  @override
  String get weatherConditionSleet => 'Aguanieve';

  @override
  String get weatherConditionHot => 'Calor';

  @override
  String get weatherConditionHotNight => 'Noche calurosa';

  @override
  String get weatherConditionColdWave => 'Ola de frío';

  @override
  String get weatherConditionUnknown => 'Desconocido';

  @override
  String get locationCurrent => 'Ubicación actual';

  @override
  String get locationSelectClose => 'Cerrar selector de ubicación';

  @override
  String locationAdded(String name) {
    return '$name añadido';
  }

  @override
  String get locationFavoriteLimit => 'Puedes añadir hasta 5 ubicaciones.';

  @override
  String get locationFavoriteFull => 'Favoritos llenos';

  @override
  String get locationFavoriteAdd => 'Añadir favorito';

  @override
  String get locationSearchTitle => 'Buscar ubicación';

  @override
  String get locationSearchHint => 'Ejemplo: Seúl, Busan, Tokio';

  @override
  String get locationSearchEmpty => 'No se encontraron resultados';

  @override
  String get scoreLabel => 'Puntuación actividad exterior';

  @override
  String get scoreLoading => 'Calculando puntuación de actividad exterior...';

  @override
  String get scoreErrorTitle => 'No se pudo calcular la puntuación';

  @override
  String get scoreBreakdownTitle => 'Deducciones';

  @override
  String get scoreNoDeduction =>
      'Condiciones exteriores estables, casi sin factores de deducción.';

  @override
  String get scoreInfo =>
      'La puntuación de actividad exterior se calcula con lluvia, viento, sensación térmica, calidad del aire y UV.';

  @override
  String get scoreDeductionRain => 'Lluvia y nieve';

  @override
  String get scoreDeductionWind => 'Viento';

  @override
  String get scoreDeductionTemp => 'Temperatura';

  @override
  String get scoreDeductionAir => 'Calidad del aire';

  @override
  String get scoreDeductionUv => 'UV';

  @override
  String get scoreDeductionOzone => 'Ozono';

  @override
  String get scoreAdviceExcellent =>
      'Hoy es perfecto para actividades al aire libre.\nSal y disfruta.';

  @override
  String get scoreAdviceGood =>
      'Las actividades al aire libre están bien, pero revisa el viento y el UV.';

  @override
  String get scoreAdviceFair =>
      'Es posible salir, pero conviene prepararse bien.';

  @override
  String get scoreAdvicePoor =>
      'Hoy es más seguro planificar actividades en interiores.';

  @override
  String get scoreTierExcellent => 'Excelente';

  @override
  String get scoreTierGood => 'Bueno';

  @override
  String get scoreTierFair => 'Aceptable';

  @override
  String get scoreTierPoor => 'Precaución';

  @override
  String scorePointUnit(int score) {
    return '$score pts';
  }

  @override
  String get activityRecommendOutdoor => 'Actividad exterior recomendada';

  @override
  String get activityRecommendLight => 'Actividad ligera adecuada';

  @override
  String get activityRecommendCaution => 'Se necesita precaución';

  @override
  String get activityRecommendIndoor => 'Actividad interior recomendada';

  @override
  String get airQualityTitle => 'Calidad del aire';

  @override
  String get airQualityIntegrated => 'Calidad del aire integrada';

  @override
  String get airQualityUnknown => 'Sin datos';

  @override
  String get airGradeGood => 'Buena';

  @override
  String get airGradeModerate => 'Moderada';

  @override
  String get airGradeBad => 'Mala';

  @override
  String get airGradeVeryBad => 'Muy mala';

  @override
  String get pointUnit => 'pts';

  @override
  String get fortuneTitle => 'Tu fortuna diaria';

  @override
  String get fortuneNeedProfileTitle => 'Se necesita información de nacimiento';

  @override
  String get fortuneNeedProfileMessage =>
      'Introduce tu fecha y hora de nacimiento para recibir la fortuna de hoy.';

  @override
  String get fortuneBirthInputAction => 'Introducir datos de nacimiento';

  @override
  String get fortuneHelpTooltip => 'Ayuda de fortuna';

  @override
  String get fortuneHelpTitle => 'Cómo Yegamssi lee la fortuna';

  @override
  String get fortuneHelpIntro =>
      'Yegamssi lee el flujo de la fortuna de hoy basándose en Myeongri.';

  @override
  String get fortuneHelpMyeongri =>
      'Myeongri es un sistema tradicional oriental de fortuna que observa los Cuatro Pilares y el equilibrio de los cinco elementos a partir de la fecha y la hora de nacimiento. Yegamssi calcula tu energía básica personal con tu fecha y hora de nacimiento, la compara con el flujo del día y guía tu fortuna general, de dinero, amor, trabajo, salud y decisiones.';

  @override
  String get fortuneHelpBirthTime =>
      'Si no sabes tu hora de nacimiento, puedes usar el mediodía como referencia. Aun así, introducir la hora de nacimiento ayuda a obtener una interpretación más detallada.';

  @override
  String get fortuneHelpWeather =>
      'Yegamssi también refleja el clima y la puntuación de actividad, no solo la fortuna. Por eso, aunque la energía del día sea buena, si el clima no acompaña la recomendación para salir puede bajar. Si la fortuna y el clima están estables, puede ser un buen día para actuar.';

  @override
  String get fortuneHelpReference =>
      'La fortuna no es una respuesta definitiva, sino una referencia. Úsala para revisar el flujo del día y elegir con más cuidado contactos, salidas, gastos, contratos y decisiones importantes.';

  @override
  String get fortuneLoadFailedTitle => 'No se pudo cargar la fortuna';

  @override
  String get fortuneLoadFailedMessage => 'Inténtalo de nuevo más tarde.';

  @override
  String get fortuneCategoryAnalysis => 'Análisis por categoría';

  @override
  String get fortuneOverall => 'Fortuna general';

  @override
  String get fortuneCategoryMoney => 'Dinero';

  @override
  String get fortuneCategoryLove => 'Amor';

  @override
  String get fortuneCategoryWork => 'Trabajo';

  @override
  String get fortuneCategoryHealth => 'Salud';

  @override
  String get fortuneCategoryDecision => 'Decisión';

  @override
  String get fortuneLuckyColor => 'Color de la suerte';

  @override
  String get fortuneLuckyNumber => 'Número de la suerte';

  @override
  String get fortuneOhengBalance => 'Equilibrio elemental';

  @override
  String get fortuneOhengDescription =>
      'Una señal de apoyo para el flujo emocional de hoy.';

  @override
  String get fortuneCaptureTooltip => 'Capturar tarjeta de fortuna';

  @override
  String get fortuneCaptureSaved => 'Captura de tarjeta guardada.';

  @override
  String get fortuneCaptureSaveDone => 'Captura de tarjeta completa';

  @override
  String fortuneCaptureFailed(String error) {
    return 'Error en captura: $error';
  }

  @override
  String get fortuneOpenFolder => 'Abrir carpeta';

  @override
  String get fortuneAnalyzing => 'Analizando.';

  @override
  String get fortuneToneBase => 'Base';

  @override
  String get fortuneToneHumor => 'Humor';

  @override
  String get fortuneToneTsundere => 'Tsundere';

  @override
  String get fortuneToneCynical => 'Cínico';

  @override
  String get fortuneToneEmotional => 'Emocional';

  @override
  String get fortuneToneHistorical => 'Histórico';

  @override
  String get fortuneToneAi => 'IA';

  @override
  String get fortuneTimeMorning => 'Mañana';

  @override
  String get fortuneTimeAfternoon => 'Tarde';

  @override
  String get ohengMok => 'Madera';

  @override
  String get ohengHwa => 'Fuego';

  @override
  String get ohengTo => 'Tierra';

  @override
  String get ohengGeum => 'Metal';

  @override
  String get ohengSu => 'Agua';

  @override
  String get luckyColorGreen => 'Verde';

  @override
  String get luckyColorCoral => 'Coral';

  @override
  String get luckyColorGold => 'Oro';

  @override
  String get luckyColorSilver => 'Plata';

  @override
  String get luckyColorSky => 'Azul cielo';

  @override
  String get luckyColorRed => 'Rojo';

  @override
  String get luckyColorOrange => 'Naranja';

  @override
  String get luckyColorYellow => 'Amarillo';

  @override
  String get luckyColorTeal => 'Turquesa';

  @override
  String get luckyColorBlue => 'Azul';

  @override
  String get luckyColorPurple => 'Morado';

  @override
  String get luckyColorPink => 'Rosa';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsCountry => 'Región';

  @override
  String get countryKorea => 'Corea';

  @override
  String get countryUnitedStates => 'Estados Unidos';

  @override
  String get countryJapan => 'Japón';

  @override
  String get countryChina => 'China';

  @override
  String get countryGlobal => 'Global';

  @override
  String get settingsTheme => 'Apariencia';

  @override
  String get settingsThemeDescription =>
      'El tema predeterminado usa el tema diurno de 06:00 a 19:00 según la hora local de la ubicación conectada, y el tema nocturno fuera de ese horario. Los temas diurno y nocturno quedan fijos sin importar la hora.';

  @override
  String get settingsThemeAutomatic => 'Tema predeterminado';

  @override
  String get settingsThemeAutomaticDescription =>
      'Usa automáticamente el tema diurno de 06:00 a 19:00 en la ubicación conectada, y el tema nocturno desde las 19:00 hasta antes de las 06:00 del día siguiente.';

  @override
  String get settingsThemeDay => 'Tema diurno';

  @override
  String get settingsThemeDayDescription =>
      'Usa siempre el tema diurno claro, sin importar la hora.';

  @override
  String get settingsThemeNight => 'Tema nocturno';

  @override
  String get settingsThemeNightDescription =>
      'Usa siempre el tema nocturno oscuro existente, sin importar la hora.';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsBirthTitle => 'Fecha de nacimiento';

  @override
  String get settingsBirthDescription =>
      'Gestiona la fecha y hora de nacimiento para el cálculo de la fortuna.';

  @override
  String get settingsBirthEmpty => 'No introducido';

  @override
  String get settingsBirthEdit => 'Editar';

  @override
  String get settingsBirthUnknownHour => 'Desconocido';

  @override
  String get onboardingGenderLabel => 'Género';

  @override
  String get genderMale => 'Hombre';

  @override
  String get genderFemale => 'Mujer';

  @override
  String get genderUnspecified => 'Prefiero no decirlo';

  @override
  String get settingsGenderTitle => 'Género';

  @override
  String settingsHourUnit(int hour) {
    return '$hour:00';
  }

  @override
  String get settingsFortuneToneTitle => 'Tono';

  @override
  String settingsFortuneToneDescription(String tone) {
    return 'Los mensajes de fortuna se muestran en estilo $tone.';
  }

  @override
  String get settingsFortuneToneSheetDescription =>
      'Los mensajes base se mantienen y el estilo seleccionado tiene prioridad.';

  @override
  String get settingsAppInfoTitle => 'Información de la app';

  @override
  String get settingsAppInfoDescription =>
      'Consulta la página principal, guía de privacidad, correo de contacto y enlaces.';

  @override
  String get settingsPremiumTitle => 'Eliminar anuncios (de por vida)';

  @override
  String get settingsPremiumDescription =>
      'Elimina permanentemente los anuncios de banner e intersticiales.';

  @override
  String get settingsPremiumButton => 'Eliminar anuncios';

  @override
  String settingsPremiumButtonPriced(String price) {
    return 'Eliminar anuncios — $price';
  }

  @override
  String get settingsPremiumPurchasedTitle => 'Anuncios eliminados';

  @override
  String get settingsPremiumPurchasedDescription => 'Gracias por tu apoyo.';

  @override
  String get premiumMsgSuccess => 'Los anuncios se han eliminado. ¡Gracias!';

  @override
  String get premiumMsgCanceled => 'Compra cancelada.';

  @override
  String get premiumMsgError =>
      'La compra ha fallado. Inténtalo de nuevo más tarde.';

  @override
  String get premiumMsgStoreUnavailable =>
      'No se puede conectar con la tienda. Inténtalo de nuevo más tarde.';

  @override
  String get premiumMsgProductUnavailable =>
      'Este artículo no está disponible actualmente.';

  @override
  String get onboardingTitle => 'Yegamssi';

  @override
  String get onboardingSubtitle =>
      'Introduce tu fecha y hora de nacimiento\npara recibir la fortuna de hoy.';

  @override
  String get onboardingStart => 'Comenzar';

  @override
  String get birthDate => 'Fecha de nacimiento';

  @override
  String get birthHour => 'Hora de nacimiento';

  @override
  String get birthHourOptional => 'Hora de nacimiento (opcional)';

  @override
  String get birthSelectDate => 'Selecciona una fecha';

  @override
  String get birthUnknownNoon => 'Desconocido (calculado al mediodía)';

  @override
  String get birthUnknownNoonShort => 'Desconocido (mediodía)';

  @override
  String dateYmd(int year, int month, int day) {
    return '$day/$month/$year';
  }

  @override
  String hourLabel(int hour) {
    return '$hour:00';
  }

  @override
  String get appInfoHomepage => 'Página principal';

  @override
  String get appInfoHomepageDescription =>
      'Abrir la página de presentación de Yegamssi.';

  @override
  String get appInfoPrivacy => 'Política de privacidad';

  @override
  String get appInfoPrivacyDescription =>
      'Abrir la página de política de privacidad.';

  @override
  String get appInfoEmail => 'Correo de contacto';

  @override
  String get appInfoEmailDescription =>
      'Abrir la app de correo para consultas.';

  @override
  String get appInfoShare => 'Compartir Yegamssi';

  @override
  String get appInfoShareDescription =>
      'Mostrar un código QR vinculado a la tienda.';

  @override
  String get appInfoShareQrDescription =>
      'Escanea el código QR para abrir la página de tienda de Yegamssi.';

  @override
  String get appInfoCopyLink => 'Copiar enlace';

  @override
  String get appInfoOpenStore => 'Abrir tienda';

  @override
  String get appInfoStoreLinkCopied => 'Enlace de tienda copiado.';

  @override
  String get appInfoVersionTitle => 'Versión de la app';

  @override
  String appInfoCurrentVersion(String version, String buildNumber) {
    return 'Versión actual $version+$buildNumber';
  }

  @override
  String get appInfoCheckingVersion => 'Comprobando versión...';

  @override
  String get appInfoDataSource => 'Fuentes de datos';

  @override
  String get appInfoKma => 'Servicio Meteorológico de Corea (KMA)';

  @override
  String get appInfoKmaDescription =>
      'Proporciona datos meteorológicos y de previsión para Corea del Sur.';

  @override
  String get appInfoAirKorea => 'AirKorea';

  @override
  String get appInfoAirKoreaDescription =>
      'Proporciona datos de PM10, PM2.5, ozono y calidad del aire integrada para Corea del Sur.';

  @override
  String get appInfoOpenWeather => 'OpenWeather';

  @override
  String get appInfoOpenWeatherDescription =>
      'Proporciona datos meteorológicos internacionales, previsiones y calidad del aire (PM10, PM2.5, O3).';

  @override
  String get appInfoNominatim => 'OpenStreetMap Nominatim';

  @override
  String get appInfoNominatimDescription =>
      'Convierte coordenadas en nombres de lugares localizados. (Licencia ODbL)';

  @override
  String get appInfoNoaa => 'NOAA / Servicio Meteorológico Nacional de EE. UU.';

  @override
  String get appInfoNoaaDescription =>
      'Proporciona pronósticos meteorológicos oficiales y datos horarios para Estados Unidos. (Dominio público)';

  @override
  String get appInfoAirNow => 'U.S. EPA AirNow';

  @override
  String get appInfoAirNowDescription =>
      'Proporciona datos de calidad del aire en tiempo real (PM2.5, PM10, Ozono) para los Estados Unidos.';

  @override
  String get appInfoDataSourceNotice =>
      'Parte de la información sigue los estándares de atribución KOGL. Los datos internacionales son proporcionados por la API de OpenWeather.';

  @override
  String get widgetScoreLabel => 'Puntuación';

  @override
  String get widgetFortuneLabel => 'Fortuna';

  @override
  String get widget_description => 'Widget de resumen diario de Yegamssi';

  @override
  String get widgetInstallTitle => 'Añadir el widget de Yegamssi';

  @override
  String get widgetInstallMessage =>
      'Consulta el tiempo, temperatura, puntuación exterior y fortuna directamente desde tu pantalla de inicio.';

  @override
  String get widgetInstallAction => 'Instalar widget';

  @override
  String get widgetInstallManual =>
      'Mantén pulsada la pantalla de inicio y añade el widget de Yegamssi.';

  @override
  String get appReviewTitle => '¿Tienes un momento? 🙏';

  @override
  String get appReviewMessage =>
      'Muchas gracias por usar Yegamssi. Es una pequeña app desarrollada por una sola persona, y una valoración de 5 estrellas significaría muchísimo para nosotros. ¿Podrías dejarnos una valoración de 5 estrellas, por favor?';

  @override
  String get appReviewAction => 'Valorar con 5 estrellas';

  @override
  String get appReviewLater => 'Quizás más tarde';

  @override
  String get updateNoticeTitle => 'Aviso de actualización';

  @override
  String get updateRequiredTitle => 'Actualización requerida';

  @override
  String updateRequiredMessage(String currentVersion, String latestVersion) {
    return 'La versión actual $currentVersion ya no es compatible.\nActualiza a la versión $latestVersion.';
  }

  @override
  String updateAvailableMessage(String latestVersion) {
    return 'La versión $latestVersion está lista.\n¿Actualizar ahora?';
  }

  @override
  String get updateAction => 'Actualizar';

  @override
  String get updateNewVersionMessage =>
      'Se ha lanzado una nueva versión.\n¿Actualizar ahora?';

  @override
  String get activityRunning => 'Correr';

  @override
  String get activityCycling => 'Ciclismo';

  @override
  String get activityHiking => 'Senderismo';

  @override
  String get activityWalking => 'Caminar';

  @override
  String get activityOutdoor => 'Trabajo exterior';

  @override
  String get errorNetwork => 'Comprueba tu conexión a internet.';

  @override
  String get errorServer => 'Se ha producido un error en el servidor.';

  @override
  String get errorLocation => 'No se puede obtener la ubicación.';

  @override
  String get errorUnknown => 'Se ha producido un error desconocido.';

  @override
  String get settingsBackgroundRefreshTitle => 'Actualizacion en segundo plano';

  @override
  String get settingsBackgroundRefreshDescription =>
      'Actualiza clima, calidad del aire, puntuacion exterior y widget cada 30 minutos aproximadamente. La excepcion de bateria mejora la fiabilidad.';

  @override
  String get settingsBackgroundRefreshStatusEnabled =>
      'Excepcion de bateria activa';

  @override
  String get settingsBackgroundRefreshStatusLimited =>
      'Se necesita excepcion de bateria';

  @override
  String get settingsBackgroundRefreshAction => 'Abrir ajustes';

  @override
  String get batteryOptimizationReminderTitle =>
      'Permite una actualizacion estable';

  @override
  String get batteryOptimizationReminderMessage =>
      'Yegamssi puede actualizar clima, calidad del aire y widgets cada 30 minutos con mas fiabilidad si desactivas la optimizacion de bateria para esta app.';

  @override
  String get batteryOptimizationReminderLater => 'Mas tarde';

  @override
  String get batteryOptimizationReminderNever => 'No volver a mostrar';

  @override
  String get batteryOptimizationReminderSettings => 'Abrir ajustes';

  @override
  String get settingsSupportTitle => 'Apoyo';

  @override
  String get settingsSupportDescription =>
      'Apoya a Yegamssi con una reseña o viendo un anuncio breve.';

  @override
  String get settingsSupportSheetDescription =>
      'Un pequeño gesto ayuda a que Yegamssi siga mejorando.';

  @override
  String get settingsSupportReviewAction => 'Escribir una reseña';

  @override
  String get settingsSupportAdAction =>
      'Ver un anuncio intersticial para apoyar al desarrollador';

  @override
  String get settingsSupportReviewFailed =>
      'No se pudo abrir la pantalla de reseñas. Inténtalo de nuevo más tarde.';

  @override
  String get settingsSupportAdThanks => 'Gracias por apoyar a Yegamssi.';

  @override
  String get settingsSupportPremiumThanks =>
      'Ya apoyaste a Yegamssi al eliminar los anuncios. Muchas gracias.';

  @override
  String get settingsSupportAdFailed =>
      'No se pudo cargar el anuncio. Inténtalo de nuevo más tarde.';
}
