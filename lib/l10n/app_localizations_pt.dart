// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Yegamssi';

  @override
  String get tabHome => 'Hoje';

  @override
  String get tabWeather => 'Clima';

  @override
  String get tabScore => 'Pontuação';

  @override
  String get tabMonthlyYegamssi => 'Mensal';

  @override
  String get monthlyYegamssiTitle => 'Yegamssi mensal';

  @override
  String get monthlyYegamssiSubtitle =>
      'Veja os dias bons e os dias de atenção deste mês por categoria.';

  @override
  String get monthlyGoodDaysLabel => 'Dias bons';

  @override
  String get monthlyCautionDaysLabel => 'Atenção';

  @override
  String get monthlyGeneratingMessage =>
      'Preparando o Yegamssi mensal deste mês.';

  @override
  String get monthlyFailedMessage =>
      'Não foi possível preparar o Yegamssi mensal deste mês. Reinicie o aplicativo.';

  @override
  String get monthlyDisclaimer =>
      'O Yegamssi mensal é um conteúdo de referência baseado no fluxo do Myeongri. Pondere as decisões importantes junto com as condições reais.';

  @override
  String get monthlySummaryEarly =>
      'Neste mês o fluxo é bom no começo, então agir cedo joga a seu favor.';

  @override
  String get monthlySummaryMid =>
      'Neste mês o fluxo melhora a partir da metade; vale mais esperar o momento certo do que ter pressa.';

  @override
  String get monthlySummaryLate =>
      'Neste mês, se você se esforçar na reta final, bons resultados virão.';

  @override
  String get monthlyCategoryLove => 'Amor';

  @override
  String get monthlyCategoryLoveMessage =>
      'Os dias bons são ótimos para expressar primeiro o que sente. Nos dias de atenção, uma conversa tranquila funciona melhor.';

  @override
  String get monthlyCategoryWork => 'Trabalho';

  @override
  String get monthlyCategoryWorkMessage =>
      'Os dias bons são ótimos para começar algo novo. Nos dias de atenção, não force e foque em concluir o que já começou.';

  @override
  String get monthlyCategoryMoney => 'Dinheiro';

  @override
  String get monthlyCategoryMoneyMessage =>
      'Os dias bons são ótimos para organizar as finanças. Nos dias de atenção, confira duas vezes antes de um gasto grande.';

  @override
  String get monthlyCategoryRelationship => 'Relações';

  @override
  String get monthlyCategoryRelationshipMessage =>
      'Os dias bons são ótimos para conversar com as pessoas. Nos dias de atenção, escolha bem as palavras para evitar mal-entendidos.';

  @override
  String get monthlyCategoryHealth => 'Saúde';

  @override
  String get monthlyCategoryHealthMessage =>
      'Os dias bons são ótimos para se movimentar. Nos dias de atenção, não exagere e reserve tempo para descansar.';

  @override
  String get monthlyCategoryDecision => 'Decisões';

  @override
  String get monthlyCategoryDecisionMessage =>
      'Os dias bons são ótimos para tomar uma decisão importante. Nos dias de atenção, é melhor esperar e revisar mais um pouco.';

  @override
  String get monthlyCategoryTravel => 'Deslocamentos';

  @override
  String get monthlyCategoryTravelMessage =>
      'Os dias bons são ótimos para planejar um passeio ou viagem. Nos dias de atenção, deixe uma folga na programação.';

  @override
  String get tabFortune => 'Fortuna';

  @override
  String get tabSettings => 'Configurações';

  @override
  String get homeHeadline => 'O clima e os sinais de hoje';

  @override
  String get homeWeatherLoadingTitle => 'Carregando clima atual';

  @override
  String get homeWeatherLoadingMessage =>
      'Preparando dados de localização e clima.';

  @override
  String get homeWeatherErrorTitle => 'Não foi possível carregar o clima atual';

  @override
  String get homeWeatherErrorMessage =>
      'Abra a tela do clima e tente novamente.';

  @override
  String get homeWeatherAction => 'Ver clima';

  @override
  String get homeFortuneLoadingTitle => 'Preparando a fortuna de hoje';

  @override
  String get homeFortuneLoadingMessage => 'O resumo aparecerá em breve.';

  @override
  String get homeFortuneErrorTitle => 'A fortuna ainda não está pronta';

  @override
  String get homeFortuneErrorMessage =>
      'Verifique seu perfil e tente novamente na tela de fortuna.';

  @override
  String get homeFortuneAction => 'Ver fortuna';

  @override
  String get homeFortuneHeadline => 'A fortuna de hoje em uma frase';

  @override
  String get appExitTitle => 'Sair do aplicativo';

  @override
  String get appExitMessage => 'Deseja fechar o Yegamssi?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'OK';

  @override
  String get close => 'Fechar';

  @override
  String get later => 'Depois';

  @override
  String get exit => 'Sair';

  @override
  String get search => 'Buscar';

  @override
  String get loadingAd => 'Carregando anúncio...';

  @override
  String get refresh => 'Atualizar';

  @override
  String refreshFailed(String error) {
    return 'Falha ao atualizar: $error';
  }

  @override
  String notFoundPage(String error) {
    return 'Página não encontrada: $error';
  }

  @override
  String weatherFeelsLike(String temp) {
    return 'Sensação $temp°C';
  }

  @override
  String weatherFeelsLikeShort(String temp) {
    return 'Sens. $temp℃';
  }

  @override
  String weatherHumidity(int value) {
    return 'Umidade $value%';
  }

  @override
  String weatherWind(String speed) {
    return 'Vento ${speed}m/s';
  }

  @override
  String get weatherHumidityLabel => 'Umidade';

  @override
  String get weatherWindLabel => 'Vento';

  @override
  String get weatherWindSpeedLabel => 'Vel. vento';

  @override
  String get weatherPrecipitationLabel => 'Chuva';

  @override
  String weatherPrecipitationAmount(String amount) {
    return 'Chuva $amount';
  }

  @override
  String get weatherDustPm10 => 'PM10';

  @override
  String get weatherDustPm25 => 'PM2.5';

  @override
  String get weatherHourlyForecast => 'Previsão por hora';

  @override
  String get weatherWeeklyForecast => 'Previsão semanal';

  @override
  String get weatherLoading => 'Carregando clima...';

  @override
  String get weatherErrorTitle => 'Não foi possível obter dados do clima';

  @override
  String weatherReturnCurrentLocation(int seconds) {
    return 'Voltando para a localização atual em ${seconds}s';
  }

  @override
  String get weatherToday => 'Hoje';

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
    return '$uv Muito alto';
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
    return '$uv Baixo';
  }

  @override
  String get weatherConditionSunny => 'Ensolarado';

  @override
  String get weatherConditionClearNight => 'Noite clara';

  @override
  String get weatherConditionPartlyCloudy => 'Parcialmente nublado';

  @override
  String get weatherConditionPartlyCloudyNight => 'Noite parcialmente nublada';

  @override
  String get weatherConditionCloudy => 'Nublado';

  @override
  String get weatherConditionHazy => 'Névoa';

  @override
  String get weatherConditionWindy => 'Ventoso';

  @override
  String get weatherConditionSlightRain => 'Chuva fraca';

  @override
  String get weatherConditionRain => 'Chuva';

  @override
  String get weatherConditionHeavyRain => 'Chuva forte';

  @override
  String get weatherConditionThunderstorm => 'Tempestade';

  @override
  String get weatherConditionRainThunder => 'Chuva com trovões';

  @override
  String get weatherConditionLightSnow => 'Neve fraca';

  @override
  String get weatherConditionSnow => 'Neve';

  @override
  String get weatherConditionSleet => 'Granizo';

  @override
  String get weatherConditionHot => 'Calor';

  @override
  String get weatherConditionHotNight => 'Noite quente';

  @override
  String get weatherConditionColdWave => 'Onda de frio';

  @override
  String get weatherConditionUnknown => 'Desconhecido';

  @override
  String get locationCurrent => 'Localização atual';

  @override
  String get locationSelectClose => 'Fechar seletor de localização';

  @override
  String locationAdded(String name) {
    return '$name adicionado';
  }

  @override
  String get locationFavoriteLimit => 'Você pode adicionar até 5 localizações.';

  @override
  String get locationFavoriteFull => 'Favoritos cheios';

  @override
  String get locationFavoriteAdd => 'Adicionar favorito';

  @override
  String get locationSearchTitle => 'Buscar localização';

  @override
  String get locationSearchHint => 'Exemplo: Seoul, Busan, Tóquio';

  @override
  String get locationSearchEmpty => 'Nenhum resultado encontrado';

  @override
  String get scoreLabel => 'Pontuação atividade ao ar livre';

  @override
  String get scoreLoading => 'Calculando pontuação de atividade ao ar livre...';

  @override
  String get scoreErrorTitle => 'Não foi possível calcular a pontuação';

  @override
  String get scoreBreakdownTitle => 'Deduções';

  @override
  String get scoreNoDeduction =>
      'Condições externas estáveis, quase sem fatores de dedução.';

  @override
  String get scoreInfo =>
      'A pontuação de atividade ao ar livre é calculada com chuva, vento, sensação térmica, qualidade do ar e dados UV.';

  @override
  String get scoreDeductionRain => 'Chuva e neve';

  @override
  String get scoreDeductionWind => 'Vento';

  @override
  String get scoreDeductionTemp => 'Temperatura';

  @override
  String get scoreDeductionAir => 'Qualidade do ar';

  @override
  String get scoreDeductionUv => 'UV';

  @override
  String get scoreDeductionOzone => 'Ozônio';

  @override
  String get scoreAdviceExcellent =>
      'Hoje é ótimo para atividades ao ar livre.\nSaia e aproveite.';

  @override
  String get scoreAdviceGood =>
      'Atividades ao ar livre estão bem, mas verifique o vento e o UV.';

  @override
  String get scoreAdviceFair =>
      'Atividades ao ar livre são possíveis, mas é melhor se preparar.';

  @override
  String get scoreAdvicePoor =>
      'Hoje é mais seguro planejar atividades internas.';

  @override
  String get scoreTierExcellent => 'Excelente';

  @override
  String get scoreTierGood => 'Bom';

  @override
  String get scoreTierFair => 'Regular';

  @override
  String get scoreTierPoor => 'Cuidado';

  @override
  String scorePointUnit(int score) {
    return '$score pts';
  }

  @override
  String get activityRecommendOutdoor => 'Atividade ao ar livre recomendada';

  @override
  String get activityRecommendLight => 'Atividade leve adequada';

  @override
  String get activityRecommendCaution => 'Cuidado necessário';

  @override
  String get activityRecommendIndoor => 'Atividade interna recomendada';

  @override
  String get airQualityTitle => 'Qualidade do ar';

  @override
  String get airQualityIntegrated => 'Qualidade do ar integrada';

  @override
  String get airQualityUnknown => 'Sem dados';

  @override
  String get airGradeGood => 'Boa';

  @override
  String get airGradeModerate => 'Moderada';

  @override
  String get airGradeBad => 'Ruim';

  @override
  String get airGradeVeryBad => 'Muito ruim';

  @override
  String get pointUnit => 'pts';

  @override
  String get fortuneTitle => 'Sua fortuna diária';

  @override
  String get fortuneNeedProfileTitle => 'Informação de nascimento necessária';

  @override
  String get fortuneNeedProfileMessage =>
      'Insira sua data e hora de nascimento para receber a fortuna de hoje.';

  @override
  String get fortuneBirthInputAction => 'Inserir dados de nascimento';

  @override
  String get fortuneHelpTooltip => 'Ajuda da fortuna';

  @override
  String get fortuneHelpTitle => 'Como o Yegamssi lê a fortuna';

  @override
  String get fortuneHelpIntro =>
      'O Yegamssi lê o fluxo da fortuna de hoje com base no Myeongri.';

  @override
  String get fortuneHelpMyeongri =>
      'Myeongri é um sistema tradicional oriental de fortuna que observa os Quatro Pilares e o equilíbrio dos cinco elementos a partir da data e da hora de nascimento. O Yegamssi calcula sua energia pessoal básica usando sua data e hora de nascimento, compara com o fluxo de hoje e orienta a fortuna geral, financeira, amorosa, profissional, de saúde e de decisões.';

  @override
  String get fortuneHelpBirthTime =>
      'Se você não souber a hora de nascimento, pode usar o meio-dia como referência. Ainda assim, informar a hora de nascimento ajuda a obter uma interpretação mais detalhada.';

  @override
  String get fortuneHelpWeather =>
      'O Yegamssi também considera o clima e a pontuação de atividade, não apenas a fortuna. Por isso, mesmo que a energia do dia esteja boa, se o clima estiver ruim a recomendação para sair pode ser menor. Se a fortuna e o clima estiverem estáveis, pode ser um dia melhor para agir.';

  @override
  String get fortuneHelpReference =>
      'A fortuna não é uma resposta definitiva, mas uma referência. Use-a para observar o fluxo do dia e escolher com mais cuidado contatos, saídas, gastos, contratos e decisões importantes.';

  @override
  String get fortuneLoadFailedTitle => 'Não foi possível carregar a fortuna';

  @override
  String get fortuneLoadFailedMessage => 'Tente novamente mais tarde.';

  @override
  String get fortuneCategoryAnalysis => 'Análise por categoria';

  @override
  String get fortuneOverall => 'Fortuna geral';

  @override
  String get fortuneCategoryMoney => 'Dinheiro';

  @override
  String get fortuneCategoryLove => 'Amor';

  @override
  String get fortuneCategoryWork => 'Trabalho';

  @override
  String get fortuneCategoryHealth => 'Saúde';

  @override
  String get fortuneCategoryDecision => 'Decisão';

  @override
  String get fortuneLuckyColor => 'Cor da sorte';

  @override
  String get fortuneLuckyNumber => 'Número da sorte';

  @override
  String get fortuneOhengBalance => 'Equilíbrio elemental';

  @override
  String get fortuneOhengDescription =>
      'Um sinal de apoio para o fluxo emocional de hoje.';

  @override
  String get fortuneCaptureTooltip => 'Capturar cartão de fortuna';

  @override
  String get fortuneCaptureSaved => 'Captura do cartão salva.';

  @override
  String get fortuneCaptureSaveDone => 'Captura do cartão concluída';

  @override
  String fortuneCaptureFailed(String error) {
    return 'Falha na captura: $error';
  }

  @override
  String get fortuneOpenFolder => 'Abrir pasta';

  @override
  String get fortuneAnalyzing => 'Analisando.';

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
  String get fortuneTimeMorning => 'Manhã';

  @override
  String get fortuneTimeAfternoon => 'Tarde';

  @override
  String get ohengMok => 'Madeira';

  @override
  String get ohengHwa => 'Fogo';

  @override
  String get ohengTo => 'Terra';

  @override
  String get ohengGeum => 'Metal';

  @override
  String get ohengSu => 'Água';

  @override
  String get luckyColorGreen => 'Verde';

  @override
  String get luckyColorCoral => 'Coral';

  @override
  String get luckyColorGold => 'Dourado';

  @override
  String get luckyColorSilver => 'Prata';

  @override
  String get luckyColorSky => 'Azul céu';

  @override
  String get luckyColorRed => 'Vermelho';

  @override
  String get luckyColorOrange => 'Laranja';

  @override
  String get luckyColorYellow => 'Amarelo';

  @override
  String get luckyColorTeal => 'Turquesa';

  @override
  String get luckyColorBlue => 'Azul';

  @override
  String get luckyColorPurple => 'Roxo';

  @override
  String get luckyColorPink => 'Rosa';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsCountry => 'Região';

  @override
  String get countryKorea => 'Coreia';

  @override
  String get countryUnitedStates => 'Estados Unidos';

  @override
  String get countryJapan => 'Japão';

  @override
  String get countryChina => 'China';

  @override
  String get countryGlobal => 'Global';

  @override
  String get settingsTheme => 'Aparência';

  @override
  String get settingsThemeDescription =>
      'O tema padrão usa o tema diurno das 06:00 às 19:00 com base na hora local da localização conectada, e o tema noturno fora desse período. Os temas diurno e noturno ficam fixos independentemente da hora.';

  @override
  String get settingsThemeAutomatic => 'Tema padrão';

  @override
  String get settingsThemeAutomaticDescription =>
      'Usa automaticamente o tema diurno das 06:00 às 19:00 na localização conectada, e o tema noturno das 19:00 até antes das 06:00 do dia seguinte.';

  @override
  String get settingsThemeDay => 'Tema diurno';

  @override
  String get settingsThemeDayDescription =>
      'Usa sempre o tema diurno claro, independentemente da hora.';

  @override
  String get settingsThemeNight => 'Tema noturno';

  @override
  String get settingsThemeNightDescription =>
      'Usa sempre o tema noturno escuro existente, independentemente da hora.';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsBirthTitle => 'Data de nascimento';

  @override
  String get settingsBirthDescription =>
      'Gerencie a data e hora de nascimento para o cálculo da fortuna.';

  @override
  String get settingsBirthEmpty => 'Não inserido';

  @override
  String get settingsBirthEdit => 'Editar';

  @override
  String get settingsBirthUnknownHour => 'Desconhecido';

  @override
  String get onboardingGenderLabel => 'Gênero';

  @override
  String get genderMale => 'Masculino';

  @override
  String get genderFemale => 'Feminino';

  @override
  String get genderUnspecified => 'Prefiro não dizer';

  @override
  String get settingsGenderTitle => 'Gênero';

  @override
  String settingsHourUnit(int hour) {
    return '$hour:00';
  }

  @override
  String get settingsFortuneToneTitle => 'Tom';

  @override
  String settingsFortuneToneDescription(String tone) {
    return 'As mensagens de fortuna são mostradas no estilo $tone.';
  }

  @override
  String get settingsFortuneToneSheetDescription =>
      'As mensagens base são mantidas e o estilo selecionado tem prioridade.';

  @override
  String get settingsAppInfoTitle => 'Informações do app';

  @override
  String get settingsAppInfoDescription =>
      'Veja a página inicial, guia de privacidade, e-mail de contato e links.';

  @override
  String get settingsPremiumTitle => 'Remover anúncios (vitalício)';

  @override
  String get settingsPremiumDescription =>
      'Remove permanentemente os anúncios em banner e intersticiais.';

  @override
  String get settingsPremiumButton => 'Remover anúncios';

  @override
  String settingsPremiumButtonPriced(String price) {
    return 'Remover anúncios — $price';
  }

  @override
  String get settingsPremiumPurchasedTitle => 'Anúncios removidos';

  @override
  String get settingsPremiumPurchasedDescription => 'Obrigado pelo seu apoio.';

  @override
  String get premiumMsgSuccess => 'Os anúncios foram removidos. Obrigado!';

  @override
  String get premiumMsgCanceled => 'Compra cancelada.';

  @override
  String get premiumMsgError => 'Falha na compra. Tente novamente mais tarde.';

  @override
  String get premiumMsgStoreUnavailable =>
      'Não foi possível conectar à loja. Tente novamente mais tarde.';

  @override
  String get premiumMsgProductUnavailable =>
      'Este item não está disponível no momento.';

  @override
  String get onboardingTitle => 'Yegamssi';

  @override
  String get onboardingSubtitle =>
      'Insira sua data e hora de nascimento\npara receber a fortuna de hoje.';

  @override
  String get onboardingStart => 'Começar';

  @override
  String get birthDate => 'Data de nascimento';

  @override
  String get birthHour => 'Hora de nascimento';

  @override
  String get birthHourOptional => 'Hora de nascimento (opcional)';

  @override
  String get birthSelectDate => 'Selecione uma data';

  @override
  String get birthUnknownNoon => 'Desconhecido (calculado ao meio-dia)';

  @override
  String get birthUnknownNoonShort => 'Desconhecido (meio-dia)';

  @override
  String dateYmd(int year, int month, int day) {
    return '$day/$month/$year';
  }

  @override
  String hourLabel(int hour) {
    return '$hour:00';
  }

  @override
  String get appInfoHomepage => 'Página inicial';

  @override
  String get appInfoHomepageDescription =>
      'Abrir a página de apresentação do Yegamssi.';

  @override
  String get appInfoPrivacy => 'Política de privacidade';

  @override
  String get appInfoPrivacyDescription =>
      'Abrir a página de política de privacidade.';

  @override
  String get appInfoEmail => 'E-mail de contato';

  @override
  String get appInfoEmailDescription => 'Abrir o app de e-mail para consultas.';

  @override
  String get appInfoShare => 'Compartilhar Yegamssi';

  @override
  String get appInfoShareDescription =>
      'Mostrar um código QR vinculado à loja.';

  @override
  String get appInfoShareQrDescription =>
      'Escaneie o código QR para abrir a página da loja do Yegamssi.';

  @override
  String get appInfoCopyLink => 'Copiar link';

  @override
  String get appInfoOpenStore => 'Abrir loja';

  @override
  String get appInfoStoreLinkCopied => 'Link da loja copiado.';

  @override
  String get appInfoVersionTitle => 'Versão do app';

  @override
  String appInfoCurrentVersion(String version, String buildNumber) {
    return 'Versão atual $version+$buildNumber';
  }

  @override
  String get appInfoCheckingVersion => 'Verificando versão...';

  @override
  String get appInfoDataSource => 'Fontes de dados';

  @override
  String get appInfoKma => 'Serviço Meteorológico da Coreia (KMA)';

  @override
  String get appInfoKmaDescription =>
      'Fornece dados meteorológicos e de previsão para a Coreia do Sul.';

  @override
  String get appInfoAirKorea => 'AirKorea';

  @override
  String get appInfoAirKoreaDescription =>
      'Fornece dados de PM10, PM2.5, ozônio e qualidade do ar integrada para a Coreia do Sul.';

  @override
  String get appInfoOpenWeather => 'OpenWeather';

  @override
  String get appInfoOpenWeatherDescription =>
      'Fornece dados meteorológicos internacionais, previsões e qualidade do ar (PM10, PM2.5, O3).';

  @override
  String get appInfoNominatim => 'OpenStreetMap Nominatim';

  @override
  String get appInfoNominatimDescription =>
      'Converte coordenadas em nomes de lugares localizados. (Licença ODbL)';

  @override
  String get appInfoNoaa => 'NOAA / Serviço Meteorológico Nacional dos EUA';

  @override
  String get appInfoNoaaDescription =>
      'Fornece previsões meteorológicas oficiais e dados horários para os Estados Unidos. (Domínio público)';

  @override
  String get appInfoAirNow => 'U.S. EPA AirNow';

  @override
  String get appInfoAirNowDescription =>
      'Fornece dados de qualidade do ar em tempo real (PM2.5, PM10, Ozônio) para os Estados Unidos.';

  @override
  String get appInfoDataSourceNotice =>
      'Algumas informações seguem os padrões de atribuição KOGL. Dados internacionais são fornecidos pela API OpenWeather.';

  @override
  String get widgetScoreLabel => 'Pontuação';

  @override
  String get widgetFortuneLabel => 'Fortuna';

  @override
  String get widget_description => 'Widget de resumo diário do Yegamssi';

  @override
  String get widgetInstallTitle => 'Adicionar o widget do Yegamssi';

  @override
  String get widgetInstallMessage =>
      'Veja clima, temperatura, pontuação ao ar livre e fortuna diretamente na sua tela inicial.';

  @override
  String get widgetInstallAction => 'Instalar widget';

  @override
  String get widgetInstallManual =>
      'Pressione e segure a tela inicial e adicione o widget do Yegamssi.';

  @override
  String get appReviewTitle => 'Você tem um momento? 🙏';

  @override
  String get appReviewMessage =>
      'Muito obrigado por usar o Yegamssi. É um pequeno app desenvolvido por uma só pessoa, e uma avaliação de 5 estrelas significaria muito para nós. Você poderia deixar uma avaliação de 5 estrelas, por favor?';

  @override
  String get appReviewAction => 'Avaliar com 5 estrelas';

  @override
  String get appReviewLater => 'Talvez depois';

  @override
  String get updateNoticeTitle => 'Aviso de atualização';

  @override
  String get updateRequiredTitle => 'Atualização necessária';

  @override
  String updateRequiredMessage(String currentVersion, String latestVersion) {
    return 'A versão atual $currentVersion não é mais suportada.\nAtualize para a versão $latestVersion.';
  }

  @override
  String updateAvailableMessage(String latestVersion) {
    return 'A versão $latestVersion está pronta.\nAtualizar agora?';
  }

  @override
  String get updateAction => 'Atualizar';

  @override
  String get updateNewVersionMessage =>
      'Uma nova versão foi lançada.\nAtualizar agora?';

  @override
  String get activityRunning => 'Corrida';

  @override
  String get activityCycling => 'Ciclismo';

  @override
  String get activityHiking => 'Caminhada';

  @override
  String get activityWalking => 'Passeio';

  @override
  String get activityOutdoor => 'Trabalho ao ar livre';

  @override
  String get errorNetwork => 'Verifique sua conexão com a internet.';

  @override
  String get errorServer => 'Erro no servidor.';

  @override
  String get errorLocation => 'Não foi possível obter a localização.';

  @override
  String get errorUnknown => 'Ocorreu um erro desconhecido.';

  @override
  String get settingsBackgroundRefreshTitle => 'Atualizacao em segundo plano';

  @override
  String get settingsBackgroundRefreshDescription =>
      'Atualiza clima, qualidade do ar, pontuacao externa e widget a cada cerca de 30 minutos. A excecao de bateria melhora a confiabilidade.';

  @override
  String get settingsBackgroundRefreshStatusEnabled =>
      'Excecao de bateria ativada';

  @override
  String get settingsBackgroundRefreshStatusLimited =>
      'Excecao de bateria necessaria';

  @override
  String get settingsBackgroundRefreshAction => 'Abrir configuracoes';

  @override
  String get batteryOptimizationReminderTitle => 'Permita atualizacao estavel';

  @override
  String get batteryOptimizationReminderMessage =>
      'O Yegamssi atualiza clima, qualidade do ar e widgets com mais estabilidade a cada 30 minutos quando a otimizacao de bateria e desativada para este app.';

  @override
  String get batteryOptimizationReminderLater => 'Depois';

  @override
  String get batteryOptimizationReminderNever => 'Nao mostrar novamente';

  @override
  String get batteryOptimizationReminderSettings => 'Abrir configuracoes';

  @override
  String get settingsSupportTitle => 'Apoio';

  @override
  String get settingsSupportDescription =>
      'Apoie o Yegamssi com uma avaliação ou assistindo a um breve anúncio.';

  @override
  String get settingsSupportSheetDescription =>
      'Um pequeno gesto ajuda o Yegamssi a continuar melhorando.';

  @override
  String get settingsSupportReviewAction => 'Escrever uma avaliação';

  @override
  String get settingsSupportAdAction =>
      'Assistir a um anúncio intersticial para apoiar o desenvolvedor';

  @override
  String get settingsSupportReviewFailed =>
      'Não foi possível abrir a tela de avaliação. Tente novamente mais tarde.';

  @override
  String get settingsSupportAdThanks => 'Obrigado por apoiar o Yegamssi.';

  @override
  String get settingsSupportPremiumThanks =>
      'Você já apoiou o Yegamssi ao remover os anúncios. Muito obrigado.';

  @override
  String get settingsSupportAdFailed =>
      'Não foi possível carregar o anúncio. Tente novamente mais tarde.';
}
