// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '预感氏';

  @override
  String get tabHome => '今天';

  @override
  String get tabWeather => '天气';

  @override
  String get tabScore => '评分';

  @override
  String get tabMonthlyYegamssi => '本月';

  @override
  String get monthlyYegamssiTitle => '本月预感氏';

  @override
  String get monthlyYegamssiSubtitle => '查看本月各类别的宜行日与留意日。';

  @override
  String get monthlyGoodDaysLabel => '宜行日';

  @override
  String get monthlyCautionDaysLabel => '留意日';

  @override
  String get monthlyGeneratingMessage => '正在准备本月预感氏。';

  @override
  String get monthlyFailedMessage => '未能准备本月预感氏，请重新启动应用。';

  @override
  String get monthlyDisclaimer => '本月预感氏是基于命理走势的参考内容。重要决定请结合现实情况一并判断。';

  @override
  String get monthlySummaryEarly => '本月上旬走势较好，提前行动更为有利。';

  @override
  String get monthlySummaryMid => '本月中旬之后走势转好，与其急于求成，不如静待时机。';

  @override
  String get monthlySummaryLate => '本月后段发力，会有不错的结果。';

  @override
  String get monthlyCategoryLove => '恋爱';

  @override
  String get monthlyCategoryLoveMessage => '宜行日适合主动表达心意。留意日则以平和的交流为宜。';

  @override
  String get monthlyCategoryWork => '工作';

  @override
  String get monthlyCategoryWorkMessage => '宜行日适合开启新的事务。留意日不宜勉强，专注于收尾为宜。';

  @override
  String get monthlyCategoryMoney => '金钱';

  @override
  String get monthlyCategoryMoneyMessage => '宜行日适合梳理财务。留意日在大额支出前多确认一次为宜。';

  @override
  String get monthlyCategoryRelationship => '人际';

  @override
  String get monthlyCategoryRelationshipMessage => '宜行日适合与人交流。留意日说话宜谨慎，以免产生误会。';

  @override
  String get monthlyCategoryHealth => '健康';

  @override
  String get monthlyCategoryHealthMessage => '宜行日适合活动身体。留意日不宜过度，注意休息为宜。';

  @override
  String get monthlyCategoryDecision => '决断';

  @override
  String get monthlyCategoryDecisionMessage => '宜行日适合做出重要判断。留意日宜暂缓决定，多加斟酌。';

  @override
  String get monthlyCategoryTravel => '出行';

  @override
  String get monthlyCategoryTravelMessage => '宜行日适合安排外出或出行。留意日的行程宜留有余地。';

  @override
  String get tabFortune => '运势';

  @override
  String get tabSettings => '设置';

  @override
  String get homeHeadline => '今日天气与信号';

  @override
  String get homeWeatherLoadingTitle => '正在加载当前天气';

  @override
  String get homeWeatherLoadingMessage => '正在准备位置和天气数据。';

  @override
  String get homeWeatherErrorTitle => '无法加载当前天气';

  @override
  String get homeWeatherErrorMessage => '请打开天气页面重试。';

  @override
  String get homeWeatherAction => '查看天气';

  @override
  String get homeFortuneLoadingTitle => '正在准备今日运势';

  @override
  String get homeFortuneLoadingMessage => '简短摘要即将显示。';

  @override
  String get homeFortuneErrorTitle => '运势尚未就绪';

  @override
  String get homeFortuneErrorMessage => '请检查个人资料并在运势页面重试。';

  @override
  String get homeFortuneAction => '查看运势';

  @override
  String get homeFortuneHeadline => '一句话今日运势';

  @override
  String get appExitTitle => '退出应用';

  @override
  String get appExitMessage => '确定要关闭预感氏吗？';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get close => '关闭';

  @override
  String get later => '稍后';

  @override
  String get exit => '退出';

  @override
  String get search => '搜索';

  @override
  String get loadingAd => '广告加载中...';

  @override
  String get refresh => '刷新';

  @override
  String refreshFailed(String error) {
    return '刷新失败：$error';
  }

  @override
  String notFoundPage(String error) {
    return '未找到页面：$error';
  }

  @override
  String weatherFeelsLike(String temp) {
    return '体感 $temp°C';
  }

  @override
  String weatherFeelsLikeShort(String temp) {
    return '体感 $temp℃';
  }

  @override
  String weatherHumidity(int value) {
    return '湿度 $value%';
  }

  @override
  String weatherWind(String speed) {
    return '风速 ${speed}m/s';
  }

  @override
  String get weatherHumidityLabel => '湿度';

  @override
  String get weatherWindLabel => '风速';

  @override
  String get weatherWindSpeedLabel => '风速';

  @override
  String get weatherPrecipitationLabel => '降雨';

  @override
  String weatherPrecipitationAmount(String amount) {
    return '降雨量 $amount';
  }

  @override
  String get weatherDustPm10 => 'PM10';

  @override
  String get weatherDustPm25 => 'PM2.5';

  @override
  String get weatherHourlyForecast => '逐时预报';

  @override
  String get weatherWeeklyForecast => '每周预报';

  @override
  String get weatherLoading => '天气加载中...';

  @override
  String get weatherErrorTitle => '无法获取天气数据';

  @override
  String weatherReturnCurrentLocation(int seconds) {
    return '$seconds秒后返回当前位置';
  }

  @override
  String get weatherToday => '今天';

  @override
  String get weatherAm => '上午';

  @override
  String get weatherPm => '下午';

  @override
  String weatherHour(String hour) {
    return '$hour:00';
  }

  @override
  String weatherUvVeryHigh(int uv) {
    return '$uv 极强';
  }

  @override
  String weatherUvHigh(int uv) {
    return '$uv 强';
  }

  @override
  String weatherUvModerateHigh(int uv) {
    return '$uv 中强';
  }

  @override
  String weatherUvModerate(int uv) {
    return '$uv 中等';
  }

  @override
  String weatherUvLow(int uv) {
    return '$uv 弱';
  }

  @override
  String get weatherConditionSunny => '晴天';

  @override
  String get weatherConditionClearNight => '晴夜';

  @override
  String get weatherConditionPartlyCloudy => '局部多云';

  @override
  String get weatherConditionPartlyCloudyNight => '局部多云夜';

  @override
  String get weatherConditionCloudy => '多云';

  @override
  String get weatherConditionHazy => '雾霾';

  @override
  String get weatherConditionWindy => '大风';

  @override
  String get weatherConditionSlightRain => '小雨';

  @override
  String get weatherConditionRain => '雨';

  @override
  String get weatherConditionHeavyRain => '大雨';

  @override
  String get weatherConditionThunderstorm => '雷暴';

  @override
  String get weatherConditionRainThunder => '雷雨';

  @override
  String get weatherConditionLightSnow => '小雪';

  @override
  String get weatherConditionSnow => '雪';

  @override
  String get weatherConditionSleet => '雨夹雪';

  @override
  String get weatherConditionHot => '高温';

  @override
  String get weatherConditionHotNight => '热夜';

  @override
  String get weatherConditionColdWave => '寒流';

  @override
  String get weatherConditionUnknown => '未知';

  @override
  String get locationCurrent => '当前位置';

  @override
  String get locationSelectClose => '关闭位置选择器';

  @override
  String locationAdded(String name) {
    return '已添加 $name';
  }

  @override
  String get locationFavoriteLimit => '最多可添加5个位置。';

  @override
  String get locationFavoriteFull => '收藏已满';

  @override
  String get locationFavoriteAdd => '添加收藏';

  @override
  String get locationSearchTitle => '搜索位置';

  @override
  String get locationSearchHint => '示例：首尔、釜山、东京';

  @override
  String get locationSearchEmpty => '未找到结果';

  @override
  String get scoreLabel => '户外活动评分';

  @override
  String get scoreLoading => '正在计算户外活动评分...';

  @override
  String get scoreErrorTitle => '无法计算评分';

  @override
  String get scoreBreakdownTitle => '扣分项';

  @override
  String get scoreNoDeduction => '户外条件良好，几乎没有扣分因素。';

  @override
  String get scoreInfo => '户外活动评分根据降雨、风速、体感温度、空气质量和紫外线数据计算。';

  @override
  String get scoreDeductionRain => '降雨和积雪';

  @override
  String get scoreDeductionWind => '风速';

  @override
  String get scoreDeductionTemp => '温度';

  @override
  String get scoreDeductionAir => '空气质量';

  @override
  String get scoreDeductionUv => '紫外线';

  @override
  String get scoreDeductionOzone => '臭氧';

  @override
  String get scoreAdviceExcellent => '今天非常适合户外活动。\n轻松出门，提振状态。';

  @override
  String get scoreAdviceGood => '户外活动没问题，但请再确认一下风速和紫外线。';

  @override
  String get scoreAdviceFair => '户外活动可行，做好准备会更轻松。';

  @override
  String get scoreAdvicePoor => '今天建议以室内活动为主。';

  @override
  String get scoreTierExcellent => '优秀';

  @override
  String get scoreTierGood => '良好';

  @override
  String get scoreTierFair => '一般';

  @override
  String get scoreTierPoor => '注意';

  @override
  String scorePointUnit(int score) {
    return '$score分';
  }

  @override
  String get activityRecommendOutdoor => '推荐户外活动';

  @override
  String get activityRecommendLight => '适合轻度活动';

  @override
  String get activityRecommendCaution => '请注意';

  @override
  String get activityRecommendIndoor => '推荐室内活动';

  @override
  String get airQualityTitle => '空气质量';

  @override
  String get airQualityIntegrated => '综合空气质量';

  @override
  String get airQualityUnknown => '无数据';

  @override
  String get airGradeGood => '优';

  @override
  String get airGradeModerate => '良';

  @override
  String get airGradeBad => '差';

  @override
  String get airGradeVeryBad => '极差';

  @override
  String get pointUnit => '分';

  @override
  String get fortuneTitle => '今日运势';

  @override
  String get fortuneNeedProfileTitle => '需要生日信息';

  @override
  String get fortuneNeedProfileMessage => '请输入您的出生日期和时间以获取今日运势。';

  @override
  String get fortuneBirthInputAction => '输入生日信息';

  @override
  String get fortuneHelpTooltip => '运势帮助';

  @override
  String get fortuneHelpTitle => 'Yegamssi 运势说明';

  @override
  String get fortuneHelpIntro => 'Yegamssi 基于命理学解读今天的运势流动。';

  @override
  String get fortuneHelpMyeongri =>
      '命理学是一种东方传统运势体系，会根据出生日期和时间观察四柱八字与五行平衡。Yegamssi 使用你的出生日期和出生时间计算个人的基本气场，并与今天的日期流动进行比较，提供综合运、财运、恋爱运、事业运、健康运和决策运。';

  @override
  String get fortuneHelpBirthTime =>
      '如果不知道出生时间，也可以使用正午作为默认时间。不过，输入出生时间有助于获得更细致的解读。';

  @override
  String get fortuneHelpWeather =>
      'Yegamssi 不只参考运势，也会结合天气和活动分数。因此，即使今天的气场不错，如果天气不好，外出推荐度也可能降低；相反，如果运势和天气都稳定，就可以视为更适合行动的一天。';

  @override
  String get fortuneHelpReference =>
      '运势不是标准答案，而是参考。你可以提前了解今天的流动，在联系、外出、消费、签约和重要决定上做出更谨慎的选择。';

  @override
  String get fortuneLoadFailedTitle => '无法加载运势';

  @override
  String get fortuneLoadFailedMessage => '请稍后重试。';

  @override
  String get fortuneCategoryAnalysis => '分类分析';

  @override
  String get fortuneOverall => '综合运势';

  @override
  String get fortuneCategoryMoney => '财运';

  @override
  String get fortuneCategoryLove => '爱情';

  @override
  String get fortuneCategoryWork => '事业';

  @override
  String get fortuneCategoryHealth => '健康';

  @override
  String get fortuneCategoryDecision => '决断';

  @override
  String get fortuneLuckyColor => '幸运色';

  @override
  String get fortuneLuckyNumber => '幸运数字';

  @override
  String get fortuneOhengBalance => '五行平衡';

  @override
  String get fortuneOhengDescription => '今日情绪流动的辅助信号。';

  @override
  String get fortuneCaptureTooltip => '截取运势卡片';

  @override
  String get fortuneCaptureSaved => '运势卡片截图已保存。';

  @override
  String get fortuneCaptureSaveDone => '运势卡片截图完成';

  @override
  String fortuneCaptureFailed(String error) {
    return '截图失败：$error';
  }

  @override
  String get fortuneOpenFolder => '打开文件夹';

  @override
  String get fortuneAnalyzing => '分析中。';

  @override
  String get fortuneToneBase => '基础';

  @override
  String get fortuneToneHumor => '幽默';

  @override
  String get fortuneToneTsundere => '傲娇';

  @override
  String get fortuneToneCynical => '讽刺';

  @override
  String get fortuneToneEmotional => '感性';

  @override
  String get fortuneToneHistorical => '古风';

  @override
  String get fortuneToneAi => 'AI';

  @override
  String get fortuneTimeMorning => '上午';

  @override
  String get fortuneTimeAfternoon => '下午';

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
  String get luckyColorGreen => '绿色';

  @override
  String get luckyColorCoral => '珊瑚色';

  @override
  String get luckyColorGold => '金色';

  @override
  String get luckyColorSilver => '银色';

  @override
  String get luckyColorSky => '天蓝色';

  @override
  String get luckyColorRed => '红色';

  @override
  String get luckyColorOrange => '橙色';

  @override
  String get luckyColorYellow => '黄色';

  @override
  String get luckyColorTeal => '青绿色';

  @override
  String get luckyColorBlue => '蓝色';

  @override
  String get luckyColorPurple => '紫色';

  @override
  String get luckyColorPink => '粉色';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsCountry => '地区';

  @override
  String get countryKorea => '韩国';

  @override
  String get countryUnitedStates => '美国';

  @override
  String get countryJapan => '日本';

  @override
  String get countryChina => '中国';

  @override
  String get countryGlobal => '全球';

  @override
  String get settingsTheme => '外观';

  @override
  String get settingsThemeDescription =>
      '默认主题会根据连接位置的当地时间，在上午6点到晚上7点使用日间主题，其余时间使用夜间主题。日间主题和夜间主题会不受时间影响而固定显示。';

  @override
  String get settingsThemeAutomatic => '默认主题';

  @override
  String get settingsThemeAutomaticDescription =>
      '连接位置当地时间 06:00-19:00 自动使用日间主题，19:00 后到次日 06:00 前自动使用夜间主题。';

  @override
  String get settingsThemeDay => '日间主题';

  @override
  String get settingsThemeDayDescription => '无论时间如何，始终使用明亮的日间主题。';

  @override
  String get settingsThemeNight => '夜间主题';

  @override
  String get settingsThemeNightDescription => '无论时间如何，始终使用现有的深色夜间主题。';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsBirthTitle => '出生日期';

  @override
  String get settingsBirthDescription => '管理用于运势计算的出生日期和时间。';

  @override
  String get settingsBirthEmpty => '未填写';

  @override
  String get settingsBirthEdit => '修改';

  @override
  String get settingsBirthUnknownHour => '未知';

  @override
  String get onboardingGenderLabel => '性别';

  @override
  String get genderMale => '男';

  @override
  String get genderFemale => '女';

  @override
  String get genderUnspecified => '不愿透露';

  @override
  String get settingsGenderTitle => '性别';

  @override
  String settingsHourUnit(int hour) {
    return '$hour:00';
  }

  @override
  String get settingsFortuneToneTitle => '风格';

  @override
  String settingsFortuneToneDescription(String tone) {
    return '运势以$tone风格显示。';
  }

  @override
  String get settingsFortuneToneSheetDescription => '保留基础内容，优先显示所选风格。';

  @override
  String get settingsAppInfoTitle => '应用信息';

  @override
  String get settingsAppInfoDescription => '查看主页、隐私指南、联系邮箱和相关链接。';

  @override
  String get settingsPremiumTitle => '移除广告（永久）';

  @override
  String get settingsPremiumDescription => '永久移除横幅广告和插页广告。';

  @override
  String get settingsPremiumButton => '移除广告';

  @override
  String settingsPremiumButtonPriced(String price) {
    return '移除广告 — $price';
  }

  @override
  String get settingsPremiumPurchasedTitle => '广告已移除';

  @override
  String get settingsPremiumPurchasedDescription => '感谢您的支持。';

  @override
  String get premiumMsgSuccess => '广告已移除，感谢您的支持！';

  @override
  String get premiumMsgCanceled => '已取消购买。';

  @override
  String get premiumMsgError => '购买失败，请稍后重试。';

  @override
  String get premiumMsgStoreUnavailable => '无法连接到商店，请稍后重试。';

  @override
  String get premiumMsgProductUnavailable => '该商品当前不可用。';

  @override
  String get onboardingTitle => '预感氏';

  @override
  String get onboardingSubtitle => '请输入您的出生日期和时间\n以获取今日运势。';

  @override
  String get onboardingStart => '开始';

  @override
  String get birthDate => '出生日期';

  @override
  String get birthHour => '出生时间';

  @override
  String get birthHourOptional => '出生时间（可选）';

  @override
  String get birthSelectDate => '选择日期';

  @override
  String get birthUnknownNoon => '未知（以中午计算）';

  @override
  String get birthUnknownNoonShort => '未知（中午）';

  @override
  String dateYmd(int year, int month, int day) {
    return '$year年$month月$day日';
  }

  @override
  String hourLabel(int hour) {
    return '$hour:00';
  }

  @override
  String get appInfoHomepage => '主页';

  @override
  String get appInfoHomepageDescription => '打开预感氏介绍页面。';

  @override
  String get appInfoPrivacy => '隐私政策';

  @override
  String get appInfoPrivacyDescription => '打开隐私政策页面。';

  @override
  String get appInfoEmail => '联系邮箱';

  @override
  String get appInfoEmailDescription => '打开邮件应用进行咨询。';

  @override
  String get appInfoShare => '分享预感氏';

  @override
  String get appInfoShareDescription => '显示链接到商店的二维码。';

  @override
  String get appInfoShareQrDescription => '扫描二维码打开预感氏商店页面。';

  @override
  String get appInfoCopyLink => '复制链接';

  @override
  String get appInfoOpenStore => '打开商店';

  @override
  String get appInfoStoreLinkCopied => '商店链接已复制。';

  @override
  String get appInfoVersionTitle => '应用版本';

  @override
  String appInfoCurrentVersion(String version, String buildNumber) {
    return '当前版本 $version+$buildNumber';
  }

  @override
  String get appInfoCheckingVersion => '检查版本中...';

  @override
  String get appInfoDataSource => '数据来源';

  @override
  String get appInfoKma => '韩国气象厅（KMA）';

  @override
  String get appInfoKmaDescription => '提供韩国天气和预报数据。';

  @override
  String get appInfoAirKorea => 'AirKorea';

  @override
  String get appInfoAirKoreaDescription => '提供韩国PM10、PM2.5、臭氧和综合空气质量数据。';

  @override
  String get appInfoOpenWeather => 'OpenWeather';

  @override
  String get appInfoOpenWeatherDescription =>
      '提供国际天气、预报和空气质量（PM10、PM2.5、O3）数据。';

  @override
  String get appInfoNominatim => 'OpenStreetMap Nominatim';

  @override
  String get appInfoNominatimDescription => '将坐标转换为本地化地名。（ODbL许可证）';

  @override
  String get appInfoNoaa => 'NOAA / 美国国家气象局';

  @override
  String get appInfoNoaaDescription => '为美国提供官方天气预报和小时数据。（公共领域）';

  @override
  String get appInfoAirNow => '美国EPA AirNow';

  @override
  String get appInfoAirNowDescription => '为美国提供实时空气质量数据（PM2.5、PM10、臭氧）。';

  @override
  String get appInfoDataSourceNotice =>
      '部分信息遵循KOGL署名标准。国际数据由OpenWeather API提供。';

  @override
  String get widgetScoreLabel => '评分';

  @override
  String get widgetFortuneLabel => '运势';

  @override
  String get widget_description => '预感氏每日摘要小组件';

  @override
  String get widgetInstallTitle => '添加预感氏小组件';

  @override
  String get widgetInstallMessage => '直接在主屏幕查看天气、温度、户外评分和运势。';

  @override
  String get widgetInstallAction => '安装小组件';

  @override
  String get widgetInstallManual => '长按主屏幕并添加预感氏小组件。';

  @override
  String get appReviewTitle => '可以打扰您一下吗? 🙏';

  @override
  String get appReviewMessage =>
      '非常感谢您使用预感氏。这是一款由个人开发者制作的小应用,您的五星好评对我们来说意义重大。方便的话,可以给个五星好评吗?';

  @override
  String get appReviewAction => '给五星好评';

  @override
  String get appReviewLater => '下次吧';

  @override
  String get updateNoticeTitle => '更新通知';

  @override
  String get updateRequiredTitle => '需要更新';

  @override
  String updateRequiredMessage(String currentVersion, String latestVersion) {
    return '当前版本 $currentVersion 不再受支持。\n请更新到 $latestVersion 版本。';
  }

  @override
  String updateAvailableMessage(String latestVersion) {
    return '版本 $latestVersion 已就绪。\n立即更新？';
  }

  @override
  String get updateAction => '更新';

  @override
  String get updateNewVersionMessage => '新版本已发布。\n立即更新？';

  @override
  String get activityRunning => '跑步';

  @override
  String get activityCycling => '骑行';

  @override
  String get activityHiking => '登山';

  @override
  String get activityWalking => '步行';

  @override
  String get activityOutdoor => '户外工作';

  @override
  String get errorNetwork => '请检查您的网络连接。';

  @override
  String get errorServer => '服务器错误。';

  @override
  String get errorLocation => '无法获取位置。';

  @override
  String get errorUnknown => '发生未知错误。';

  @override
  String get settingsBackgroundRefreshTitle => '后台刷新';

  @override
  String get settingsBackgroundRefreshDescription =>
      '约每30分钟刷新天气、空气质量、户外分数和小组件。允许电池优化例外可提升稳定性。';

  @override
  String get settingsBackgroundRefreshStatusEnabled => '已启用电池例外';

  @override
  String get settingsBackgroundRefreshStatusLimited => '需要电池例外';

  @override
  String get settingsBackgroundRefreshAction => '打开设置';

  @override
  String get batteryOptimizationReminderTitle => '让后台刷新更稳定';

  @override
  String get batteryOptimizationReminderMessage =>
      '允许此应用不受电池优化限制后，Yegamssi 可更稳定地刷新天气、空气质量和小组件。';

  @override
  String get batteryOptimizationReminderLater => '稍后';

  @override
  String get batteryOptimizationReminderNever => '不再显示';

  @override
  String get batteryOptimizationReminderSettings => '打开设置';

  @override
  String get settingsSupportTitle => '支持';

  @override
  String get settingsSupportDescription => '通过评价或观看一个短广告来支持Yegamssi。';

  @override
  String get settingsSupportSheetDescription => '一个小小的举动有助于Yegamssi持续改进。';

  @override
  String get settingsSupportReviewAction => '写评价';

  @override
  String get settingsSupportAdAction => '观看插入式广告以支持开发者';

  @override
  String get settingsSupportReviewFailed => '无法打开评价页面，请稍后重试。';

  @override
  String get settingsSupportAdThanks => '感谢您对Yegamssi的支持。';

  @override
  String get settingsSupportPremiumThanks => '您已通过去除广告支持过Yegamssi，谢谢您。';

  @override
  String get settingsSupportAdFailed => '无法加载广告，请稍后重试。';
}
