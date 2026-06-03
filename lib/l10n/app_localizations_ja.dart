// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'イェガムシ';

  @override
  String get tabHome => '今日';

  @override
  String get tabWeather => '天気';

  @override
  String get tabScore => 'スコア';

  @override
  String get tabFortune => '運勢';

  @override
  String get tabSettings => '設定';

  @override
  String get homeHeadline => '今日の天気と予感';

  @override
  String get homeWeatherLoadingTitle => '現在の天気を読み込み中';

  @override
  String get homeWeatherLoadingMessage => '位置情報と天気情報を準備しています。';

  @override
  String get homeWeatherErrorTitle => '現在の天気を読み込めません';

  @override
  String get homeWeatherErrorMessage => '天気画面でもう一度確認してください。';

  @override
  String get homeWeatherAction => '天気を見る';

  @override
  String get homeFortuneLoadingTitle => '今日の運勢を準備中';

  @override
  String get homeFortuneLoadingMessage => 'まもなく一言まとめを表示します。';

  @override
  String get homeFortuneErrorTitle => '運勢をまだ準備できません';

  @override
  String get homeFortuneErrorMessage => 'プロフィールを確認し、運勢画面でもう一度お試しください。';

  @override
  String get homeFortuneAction => '運勢を見る';

  @override
  String get homeFortuneHeadline => '今日の一言運勢';

  @override
  String get appExitTitle => 'アプリ終了';

  @override
  String get appExitMessage => 'イェガムシを終了しますか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get close => '閉じる';

  @override
  String get later => '後で';

  @override
  String get exit => '終了';

  @override
  String get search => '検索';

  @override
  String get loadingAd => '広告を読み込み中...';

  @override
  String get refresh => '更新';

  @override
  String refreshFailed(String error) {
    return '更新に失敗しました: $error';
  }

  @override
  String notFoundPage(String error) {
    return 'ページが見つかりません: $error';
  }

  @override
  String weatherFeelsLike(String temp) {
    return '体感 $temp°C';
  }

  @override
  String weatherFeelsLikeShort(String temp) {
    return '体感 $temp°';
  }

  @override
  String weatherHumidity(int value) {
    return '湿度 $value%';
  }

  @override
  String weatherWind(String speed) {
    return '風 ${speed}m/s';
  }

  @override
  String get weatherHumidityLabel => '湿度';

  @override
  String get weatherWindLabel => '風';

  @override
  String get weatherWindSpeedLabel => '風速';

  @override
  String get weatherPrecipitationLabel => '降水';

  @override
  String weatherPrecipitationAmount(String amount) {
    return '降水量 $amount';
  }

  @override
  String get weatherDustPm10 => 'PM10';

  @override
  String get weatherDustPm25 => 'PM2.5';

  @override
  String get weatherHourlyForecast => '時間別予報';

  @override
  String get weatherWeeklyForecast => '週間予報';

  @override
  String get weatherLoading => '天気情報を読み込み中...';

  @override
  String get weatherErrorTitle => '天気情報を取得できません';

  @override
  String weatherReturnCurrentLocation(int seconds) {
    return '$seconds秒後に現在地へ戻ります';
  }

  @override
  String get weatherToday => '今日';

  @override
  String get weatherAm => '午前';

  @override
  String get weatherPm => '午後';

  @override
  String weatherHour(String hour) {
    return '$hour時';
  }

  @override
  String weatherUvVeryHigh(int uv) {
    return '$uv 非常に高い';
  }

  @override
  String weatherUvHigh(int uv) {
    return '$uv 高い';
  }

  @override
  String weatherUvModerateHigh(int uv) {
    return '$uv やや高い';
  }

  @override
  String weatherUvModerate(int uv) {
    return '$uv 普通';
  }

  @override
  String weatherUvLow(int uv) {
    return '$uv 低い';
  }

  @override
  String get weatherConditionSunny => '晴れ';

  @override
  String get weatherConditionClearNight => '晴れた夜';

  @override
  String get weatherConditionPartlyCloudy => '少し曇り';

  @override
  String get weatherConditionPartlyCloudyNight => '少し曇りの夜';

  @override
  String get weatherConditionCloudy => '曇り';

  @override
  String get weatherConditionHazy => 'もや';

  @override
  String get weatherConditionWindy => '強風';

  @override
  String get weatherConditionSlightRain => '小雨';

  @override
  String get weatherConditionRain => '雨';

  @override
  String get weatherConditionHeavyRain => '強い雨';

  @override
  String get weatherConditionThunderstorm => '雷雨';

  @override
  String get weatherConditionRainThunder => '雨と雷';

  @override
  String get weatherConditionLightSnow => '小雪';

  @override
  String get weatherConditionSnow => '雪';

  @override
  String get weatherConditionSleet => 'みぞれ';

  @override
  String get weatherConditionHot => '暑い';

  @override
  String get weatherConditionHotNight => '暑い夜';

  @override
  String get weatherConditionColdWave => '寒波';

  @override
  String get weatherConditionUnknown => '情報なし';

  @override
  String get locationCurrent => '現在地';

  @override
  String get locationSelectClose => '位置選択を閉じる';

  @override
  String locationAdded(String name) {
    return '$nameを追加しました';
  }

  @override
  String get locationFavoriteLimit => '最大5件まで追加できます。';

  @override
  String get locationFavoriteFull => 'お気に入りが満杯です';

  @override
  String get locationFavoriteAdd => 'お気に入り追加';

  @override
  String get locationSearchTitle => '地域検索';

  @override
  String get locationSearchHint => '例: Seoul, Busan, Tokyo';

  @override
  String get locationSearchEmpty => '検索結果がありません';

  @override
  String get scoreLabel => '屋外活動スコア';

  @override
  String get scoreLoading => '屋外活動スコアを計算中...';

  @override
  String get scoreErrorTitle => 'スコアを計算できません';

  @override
  String get scoreBreakdownTitle => '減点内訳';

  @override
  String get scoreNoDeduction => '減点要因がほとんどない安定した屋外活動の天気です。';

  @override
  String get scoreInfo => '屋外活動スコアは降水、風、体感温度、大気質、紫外線情報をもとに計算します。';

  @override
  String get scoreDeductionRain => '雨雪と降水';

  @override
  String get scoreDeductionWind => '風';

  @override
  String get scoreDeductionTemp => '気温';

  @override
  String get scoreDeductionAir => '大気質';

  @override
  String get scoreDeductionUv => '紫外線';

  @override
  String get scoreDeductionOzone => 'オゾン';

  @override
  String get scoreAdviceExcellent => '今日は屋外活動に良い日です。\n軽く外に出て調子を整えてみましょう。';

  @override
  String get scoreAdviceGood => '屋外活動は無難ですが、風と紫外線をもう一度確認してください。';

  @override
  String get scoreAdviceFair => '屋外活動は可能ですが、準備を整えるほど快適です。';

  @override
  String get scoreAdvicePoor => '今日は屋内活動を中心に計画する方が安全です。';

  @override
  String get scoreTierExcellent => '最適';

  @override
  String get scoreTierGood => '良い';

  @override
  String get scoreTierFair => '普通';

  @override
  String get scoreTierPoor => '注意';

  @override
  String scorePointUnit(int score) {
    return '$score点';
  }

  @override
  String get activityRecommendOutdoor => '屋外活動おすすめ';

  @override
  String get activityRecommendLight => '軽い活動に適合';

  @override
  String get activityRecommendCaution => '注意が必要な日';

  @override
  String get activityRecommendIndoor => '屋内活動おすすめ';

  @override
  String get airQualityTitle => '大気質';

  @override
  String get airQualityIntegrated => '総合大気質';

  @override
  String get airQualityUnknown => '情報なし';

  @override
  String get airGradeGood => '良い';

  @override
  String get airGradeModerate => '普通';

  @override
  String get airGradeBad => '悪い';

  @override
  String get airGradeVeryBad => '非常に悪い';

  @override
  String get pointUnit => '点';

  @override
  String get fortuneTitle => '今日の運勢';

  @override
  String get fortuneNeedProfileTitle => '運勢を見るには出生情報が必要です';

  @override
  String get fortuneNeedProfileMessage =>
      '生年月日と出生時刻を入力すると、今日の運勢を落ち着いたトーンで整理します。';

  @override
  String get fortuneBirthInputAction => '出生情報を入力';

  @override
  String get fortuneLoadFailedTitle => '運勢を読み込めません';

  @override
  String get fortuneLoadFailedMessage => 'しばらくしてからもう一度お試しください。';

  @override
  String get fortuneCategoryAnalysis => 'カテゴリ別解釈';

  @override
  String get fortuneOverall => '総合運勢';

  @override
  String get fortuneCategoryMoney => '金運';

  @override
  String get fortuneCategoryLove => '恋愛運';

  @override
  String get fortuneCategoryWork => '仕事運';

  @override
  String get fortuneCategoryHealth => '健康運';

  @override
  String get fortuneCategoryDecision => '決断運';

  @override
  String get fortuneLuckyColor => 'ラッキーカラー';

  @override
  String get fortuneLuckyNumber => 'ラッキーナンバー';

  @override
  String get fortuneOhengBalance => '五行バランス';

  @override
  String get fortuneOhengDescription => '今日の感情の流れを参考にする補助指標です。';

  @override
  String get fortuneCaptureTooltip => '運勢カードをキャプチャ';

  @override
  String get fortuneCaptureSaved => '運勢カードのキャプチャを保存しました。';

  @override
  String get fortuneCaptureSaveDone => '運勢カードのキャプチャ保存完了';

  @override
  String fortuneCaptureFailed(String error) {
    return 'キャプチャに失敗しました: $error';
  }

  @override
  String get fortuneOpenFolder => 'フォルダを開く';

  @override
  String get fortuneAnalyzing => '分析中です。';

  @override
  String get fortuneToneBase => '基本';

  @override
  String get fortuneToneHumor => 'ユーモア';

  @override
  String get fortuneToneTsundere => 'ツンデレ';

  @override
  String get fortuneToneCynical => 'シニカル';

  @override
  String get fortuneToneEmotional => '感性';

  @override
  String get fortuneToneHistorical => '時代劇';

  @override
  String get fortuneToneAi => 'AI';

  @override
  String get fortuneTimeMorning => '午前';

  @override
  String get fortuneTimeAfternoon => '午後';

  @override
  String get ohengMok => '木';

  @override
  String get ohengHwa => '火';

  @override
  String get ohengTo => '土';

  @override
  String get ohengGeum => '金';

  @override
  String get ohengSu => '水';

  @override
  String get luckyColorGreen => '緑';

  @override
  String get luckyColorCoral => 'コーラル';

  @override
  String get luckyColorGold => 'ゴールド';

  @override
  String get luckyColorSilver => 'シルバー';

  @override
  String get luckyColorSky => '空色';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsCountry => '地域';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get settingsThemeDark => 'ダーク';

  @override
  String get settingsThemeLight => 'ライト';

  @override
  String get settingsBirthTitle => '生年月日';

  @override
  String get settingsBirthDescription => '運勢計算に使う生年月日と出生時刻を管理します。';

  @override
  String get settingsBirthEmpty => '未入力';

  @override
  String get settingsBirthUnknownHour => '不明';

  @override
  String settingsHourUnit(int hour) {
    return '$hour時';
  }

  @override
  String get settingsFortuneToneTitle => 'メッセージトーン';

  @override
  String settingsFortuneToneDescription(String tone) {
    return '運勢メッセージを$toneスタイルで表示します。';
  }

  @override
  String get settingsFortuneToneSheetDescription =>
      '基本文は維持し、選択したスタイル文を優先して使用します。';

  @override
  String get settingsAppInfoTitle => 'アプリ情報';

  @override
  String get settingsAppInfoDescription =>
      'ホームページ、プライバシー案内、問い合わせメール、リンクを確認します。';

  @override
  String get onboardingTitle => 'イェガムシ';

  @override
  String get onboardingSubtitle => '生年月日と出生時刻を入力すると\n今日の運勢をお知らせします。';

  @override
  String get onboardingStart => '始める';

  @override
  String get birthDate => '生年月日';

  @override
  String get birthHour => '出生時刻';

  @override
  String get birthHourOptional => '出生時刻（任意）';

  @override
  String get birthSelectDate => '日付を選択してください';

  @override
  String get birthUnknownNoon => '不明（正午基準で計算）';

  @override
  String get birthUnknownNoonShort => '不明（正午基準）';

  @override
  String dateYmd(int year, int month, int day) {
    return '$year年$month月$day日';
  }

  @override
  String hourLabel(int hour) {
    return '$hour時';
  }

  @override
  String get appInfoHomepage => 'ホームページ';

  @override
  String get appInfoHomepageDescription => 'イェガムシ紹介ページを開きます。';

  @override
  String get appInfoPrivacy => 'プライバシーポリシー';

  @override
  String get appInfoPrivacyDescription => 'プライバシーポリシーページを開きます。';

  @override
  String get appInfoEmail => '問い合わせメール';

  @override
  String get appInfoEmailDescription => '問い合わせ用メールアプリを開きます。';

  @override
  String get appInfoShare => 'イェガムシを共有';

  @override
  String get appInfoShareDescription => 'ストアにつながるQRコードを表示します。';

  @override
  String get appInfoShareQrDescription => 'QRコードをスキャンするとイェガムシのストアページへ移動します。';

  @override
  String get appInfoCopyLink => 'リンクをコピー';

  @override
  String get appInfoOpenStore => 'ストアを開く';

  @override
  String get appInfoStoreLinkCopied => 'ストアリンクをコピーしました。';

  @override
  String get appInfoVersionTitle => 'アプリバージョン';

  @override
  String appInfoCurrentVersion(String version, String buildNumber) {
    return '現在のバージョン $version+$buildNumber';
  }

  @override
  String get appInfoCheckingVersion => 'バージョン確認中...';

  @override
  String get appInfoDataSource => 'データ出典';

  @override
  String get appInfoKma => '韓国気象庁';

  @override
  String get appInfoKmaDescription => '天気と予報データを提供します。';

  @override
  String get appInfoAirKorea => 'AirKorea';

  @override
  String get appInfoAirKoreaDescription => 'PM10、PM2.5、オゾン、総合大気質情報を提供します。';

  @override
  String get appInfoDataSourceNotice => '一部情報は公共データポータルと公共ヌリの出典表示基準に従います。';

  @override
  String get widgetScoreLabel => 'スコア';

  @override
  String get widgetFortuneLabel => '運勢';

  @override
  String get widget_description => 'イェガムシ今日の要約ウィジェット';

  @override
  String get widgetInstallTitle => 'イェガムシのウィジェットを追加しましょう';

  @override
  String get widgetInstallMessage => 'ホーム画面で天気、気温、屋外スコア、運勢をすぐ確認できます。';

  @override
  String get widgetInstallAction => 'ウィジェットを設置';

  @override
  String get widgetInstallManual => 'ホーム画面を長押ししてイェガムシのウィジェットを追加してください。';

  @override
  String get updateNoticeTitle => '更新のお知らせ';

  @override
  String get updateRequiredTitle => '更新が必要です';

  @override
  String updateRequiredMessage(String currentVersion, String latestVersion) {
    return '現在のバージョン $currentVersion はサポートされていません。\n最新バージョン $latestVersion に更新してください。';
  }

  @override
  String updateAvailableMessage(String latestVersion) {
    return '新しいバージョン $latestVersion が準備できました。\n今すぐ更新しますか？';
  }

  @override
  String get updateAction => '更新';

  @override
  String get updateNewVersionMessage => '新しいバージョンがリリースされました。\n今すぐ更新しますか？';

  @override
  String get activityRunning => 'ランニング';

  @override
  String get activityCycling => 'サイクリング';

  @override
  String get activityHiking => 'ハイキング';

  @override
  String get activityWalking => 'ウォーキング';

  @override
  String get activityOutdoor => '屋外作業';

  @override
  String get errorNetwork => 'インターネット接続を確認してください。';

  @override
  String get errorServer => 'サーバーエラーが発生しました。';

  @override
  String get errorLocation => '位置情報を取得できません。';

  @override
  String get errorUnknown => '不明なエラーが発生しました。';
}
