// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '예감씨';

  @override
  String get tabHome => '오늘';

  @override
  String get tabWeather => '날씨';

  @override
  String get tabScore => '점수';

  @override
  String get tabFortune => '운세';

  @override
  String get tabSettings => '설정';

  @override
  String get homeHeadline => '오늘의 날씨와 예감';

  @override
  String get homeWeatherLoadingTitle => '현재 날씨를 불러오는 중';

  @override
  String get homeWeatherLoadingMessage => '위치와 날씨 정보를 준비하고 있습니다.';

  @override
  String get homeWeatherErrorTitle => '현재 날씨를 불러오지 못했습니다';

  @override
  String get homeWeatherErrorMessage => '날씨 화면으로 이동해 다시 확인해 주세요.';

  @override
  String get homeWeatherAction => '날씨 보기';

  @override
  String get homeFortuneLoadingTitle => '오늘의 운세를 준비하는 중';

  @override
  String get homeFortuneLoadingMessage => '한 줄 요약을 곧 보여드릴게요.';

  @override
  String get homeFortuneErrorTitle => '운세를 아직 준비하지 못했습니다';

  @override
  String get homeFortuneErrorMessage => '프로필을 확인하고 운세 화면에서 다시 확인해 주세요.';

  @override
  String get homeFortuneAction => '운세 보기';

  @override
  String get homeFortuneHeadline => '오늘의 한 줄 운세';

  @override
  String get appExitTitle => '앱 종료';

  @override
  String get appExitMessage => '예감씨를 종료하시겠습니까?';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get close => '닫기';

  @override
  String get later => '나중에';

  @override
  String get exit => '종료';

  @override
  String get search => '검색';

  @override
  String get loadingAd => '광고 로딩 중...';

  @override
  String get refresh => '새로고침';

  @override
  String refreshFailed(String error) {
    return '새로고침에 실패했습니다: $error';
  }

  @override
  String notFoundPage(String error) {
    return '페이지를 찾을 수 없습니다: $error';
  }

  @override
  String weatherFeelsLike(String temp) {
    return '체감 $temp°C';
  }

  @override
  String weatherFeelsLikeShort(String temp) {
    return '체감 $temp°';
  }

  @override
  String weatherHumidity(int value) {
    return '습도 $value%';
  }

  @override
  String weatherWind(String speed) {
    return '바람 ${speed}m/s';
  }

  @override
  String get weatherHumidityLabel => '습도';

  @override
  String get weatherWindLabel => '바람';

  @override
  String get weatherWindSpeedLabel => '풍속';

  @override
  String get weatherPrecipitationLabel => '강수';

  @override
  String weatherPrecipitationAmount(String amount) {
    return '강수량 $amount';
  }

  @override
  String get weatherDustPm10 => '미세먼지';

  @override
  String get weatherDustPm25 => '초미세먼지';

  @override
  String get weatherHourlyForecast => '시간별 예보';

  @override
  String get weatherWeeklyForecast => '주간 예보';

  @override
  String get weatherLoading => '날씨 정보를 불러오는 중...';

  @override
  String get weatherErrorTitle => '날씨 정보를 가져올 수 없습니다';

  @override
  String weatherReturnCurrentLocation(int seconds) {
    return '$seconds초 후 현재 위치로 돌아갑니다';
  }

  @override
  String get weatherToday => '오늘';

  @override
  String get weatherAm => '오전';

  @override
  String get weatherPm => '오후';

  @override
  String weatherHour(String hour) {
    return '$hour시';
  }

  @override
  String weatherUvVeryHigh(int uv) {
    return '$uv 매우높음';
  }

  @override
  String weatherUvHigh(int uv) {
    return '$uv 높음';
  }

  @override
  String weatherUvModerateHigh(int uv) {
    return '$uv 약간높음';
  }

  @override
  String weatherUvModerate(int uv) {
    return '$uv 보통';
  }

  @override
  String weatherUvLow(int uv) {
    return '$uv 낮음';
  }

  @override
  String get weatherConditionSunny => '맑음';

  @override
  String get weatherConditionClearNight => '맑은 밤';

  @override
  String get weatherConditionPartlyCloudy => '구름 조금';

  @override
  String get weatherConditionPartlyCloudyNight => '구름 조금 밤';

  @override
  String get weatherConditionCloudy => '흐림';

  @override
  String get weatherConditionHazy => '안개';

  @override
  String get weatherConditionWindy => '바람';

  @override
  String get weatherConditionSlightRain => '약한 비';

  @override
  String get weatherConditionRain => '비';

  @override
  String get weatherConditionHeavyRain => '강한 비';

  @override
  String get weatherConditionThunderstorm => '뇌우';

  @override
  String get weatherConditionRainThunder => '비와 천둥';

  @override
  String get weatherConditionLightSnow => '약한 눈';

  @override
  String get weatherConditionSnow => '눈';

  @override
  String get weatherConditionSleet => '진눈깨비';

  @override
  String get weatherConditionHot => '더움';

  @override
  String get weatherConditionHotNight => '더운 밤';

  @override
  String get weatherConditionColdWave => '한파';

  @override
  String get weatherConditionUnknown => '정보 없음';

  @override
  String get locationCurrent => '현재 위치';

  @override
  String get locationSelectClose => '위치 선택 닫기';

  @override
  String locationAdded(String name) {
    return '$name 추가했습니다';
  }

  @override
  String get locationFavoriteLimit => '최대 5개까지 추가할 수 있습니다.';

  @override
  String get locationFavoriteFull => '즐겨찾기가 가득 찼습니다';

  @override
  String get locationFavoriteAdd => '즐겨찾기 추가';

  @override
  String get locationSearchTitle => '지역 검색';

  @override
  String get locationSearchHint => '예: Seoul, Busan, Tokyo';

  @override
  String get locationSearchEmpty => '검색 결과가 없습니다';

  @override
  String get scoreLabel => '야외활동 점수';

  @override
  String get scoreLoading => '야외활동 점수를 계산하는 중...';

  @override
  String get scoreErrorTitle => '점수를 계산할 수 없습니다';

  @override
  String get scoreBreakdownTitle => '감점 내역';

  @override
  String get scoreNoDeduction => '감점 요인이 거의 없는 안정적인 야외활동 날씨입니다.';

  @override
  String get scoreInfo => '야외활동 점수는 강수, 바람, 체감 기온, 대기질, 자외선 정보를 바탕으로 계산합니다.';

  @override
  String get scoreDeductionRain => '비눈과 강수';

  @override
  String get scoreDeductionWind => '바람';

  @override
  String get scoreDeductionTemp => '기온';

  @override
  String get scoreDeductionAir => '대기질';

  @override
  String get scoreDeductionUv => '자외선';

  @override
  String get scoreDeductionOzone => '오존';

  @override
  String get scoreAdviceExcellent => '오늘은 야외활동하기 좋은 날입니다.\n가볍게 나가 컨디션을 올려보세요.';

  @override
  String get scoreAdviceGood => '야외활동은 무난하지만, 바람과 자외선을 한 번 더 확인해 보세요.';

  @override
  String get scoreAdviceFair => '야외활동은 가능하지만, 준비를 더 할수록 편안합니다.';

  @override
  String get scoreAdvicePoor => '오늘은 실내 활동 중심으로 계획하는 편이 안전합니다.';

  @override
  String get scoreTierExcellent => '최적';

  @override
  String get scoreTierGood => '좋음';

  @override
  String get scoreTierFair => '보통';

  @override
  String get scoreTierPoor => '주의';

  @override
  String scorePointUnit(int score) {
    return '$score점';
  }

  @override
  String get activityRecommendOutdoor => '야외활동 추천';

  @override
  String get activityRecommendLight => '가벼운 활동 적합';

  @override
  String get activityRecommendCaution => '주의가 필요한 날';

  @override
  String get activityRecommendIndoor => '실내 활동 권장';

  @override
  String get airQualityTitle => '대기질';

  @override
  String get airQualityIntegrated => '통합 대기질';

  @override
  String get airQualityUnknown => '정보 없음';

  @override
  String get airGradeGood => '좋음';

  @override
  String get airGradeModerate => '보통';

  @override
  String get airGradeBad => '나쁨';

  @override
  String get airGradeVeryBad => '매우 나쁨';

  @override
  String get pointUnit => '점';

  @override
  String get fortuneTitle => '오늘의 운세';

  @override
  String get fortuneNeedProfileTitle => '운세를 보려면 출생 정보가 필요합니다';

  @override
  String get fortuneNeedProfileMessage =>
      '생년월일과 출생시를 입력하면 오늘의 운세를 조용한 톤으로 정리해 드립니다.';

  @override
  String get fortuneBirthInputAction => '출생 정보 입력하기';

  @override
  String get fortuneLoadFailedTitle => '운세를 불러오지 못했습니다';

  @override
  String get fortuneLoadFailedMessage => '잠시 후 다시 시도해 주세요.';

  @override
  String get fortuneCategoryAnalysis => '카테고리별 해석';

  @override
  String get fortuneOverall => '종합 운세';

  @override
  String get fortuneCategoryMoney => '재물운';

  @override
  String get fortuneCategoryLove => '애정운';

  @override
  String get fortuneCategoryWork => '직장운';

  @override
  String get fortuneCategoryHealth => '건강운';

  @override
  String get fortuneCategoryDecision => '결정운';

  @override
  String get fortuneLuckyColor => '행운 색상';

  @override
  String get fortuneLuckyNumber => '행운 숫자';

  @override
  String get fortuneOhengBalance => '오행 균형';

  @override
  String get fortuneOhengDescription => '오늘의 감정 흐름을 참고하는 보조 지표입니다.';

  @override
  String get fortuneCaptureTooltip => '운세 카드 캡처';

  @override
  String get fortuneCaptureSaved => '운세 카드 캡처를 저장했습니다.';

  @override
  String get fortuneCaptureSaveDone => '운세 카드 캡처 저장 완료';

  @override
  String fortuneCaptureFailed(String error) {
    return '캡처에 실패했습니다: $error';
  }

  @override
  String get fortuneOpenFolder => '폴더 열기';

  @override
  String get fortuneAnalyzing => '분석 중입니다.';

  @override
  String get fortuneToneBase => '기본';

  @override
  String get fortuneToneHumor => '유머';

  @override
  String get fortuneToneTsundere => '츤데레';

  @override
  String get fortuneToneCynical => '시니컬';

  @override
  String get fortuneToneEmotional => '감성';

  @override
  String get fortuneToneHistorical => '사극';

  @override
  String get fortuneToneAi => 'AI';

  @override
  String get fortuneTimeMorning => '오전';

  @override
  String get fortuneTimeAfternoon => '오후';

  @override
  String get ohengMok => '목';

  @override
  String get ohengHwa => '화';

  @override
  String get ohengTo => '토';

  @override
  String get ohengGeum => '금';

  @override
  String get ohengSu => '수';

  @override
  String get luckyColorGreen => '초록';

  @override
  String get luckyColorCoral => '코랄';

  @override
  String get luckyColorGold => '골드';

  @override
  String get luckyColorSilver => '실버';

  @override
  String get luckyColorSky => '하늘색';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsCountry => '지역';

  @override
  String get settingsTheme => '테마';

  @override
  String get settingsThemeDark => '다크';

  @override
  String get settingsThemeLight => '라이트';

  @override
  String get settingsBirthTitle => '생년월일';

  @override
  String get settingsBirthDescription => '운세 계산에 사용하는 생년월일과 출생시를 관리합니다.';

  @override
  String get settingsBirthEmpty => '입력하지 않음';

  @override
  String get settingsBirthUnknownHour => '미상';

  @override
  String settingsHourUnit(int hour) {
    return '$hour시';
  }

  @override
  String get settingsFortuneToneTitle => '멘트 톤';

  @override
  String settingsFortuneToneDescription(String tone) {
    return '운세 문구를 $tone 스타일로 표시합니다.';
  }

  @override
  String get settingsFortuneToneSheetDescription =>
      '기본 문구는 유지하고 선택한 스타일 문구를 우선 사용합니다.';

  @override
  String get settingsAppInfoTitle => '앱 정보';

  @override
  String get settingsAppInfoDescription =>
      '홈페이지, 개인정보 처리 안내, 문의 이메일, 링크를 확인합니다.';

  @override
  String get onboardingTitle => '예감씨';

  @override
  String get onboardingSubtitle => '생년월일과 출생시를 입력하면\n오늘의 운세를 알려드릴게요.';

  @override
  String get onboardingStart => '시작하기';

  @override
  String get birthDate => '생년월일';

  @override
  String get birthHour => '출생시';

  @override
  String get birthHourOptional => '출생시 (선택)';

  @override
  String get birthSelectDate => '날짜를 선택하세요';

  @override
  String get birthUnknownNoon => '모름 (정오 기준 계산)';

  @override
  String get birthUnknownNoonShort => '모름 (정오 기준)';

  @override
  String dateYmd(int year, int month, int day) {
    return '$year년 $month월 $day일';
  }

  @override
  String hourLabel(int hour) {
    return '$hour시';
  }

  @override
  String get appInfoHomepage => '홈페이지';

  @override
  String get appInfoHomepageDescription => '예감씨 소개 페이지를 엽니다.';

  @override
  String get appInfoPrivacy => '개인정보 처리방침';

  @override
  String get appInfoPrivacyDescription => '개인정보 처리방침 페이지를 엽니다.';

  @override
  String get appInfoEmail => '문의 이메일';

  @override
  String get appInfoEmailDescription => '문의 메일 앱을 엽니다.';

  @override
  String get appInfoShare => '예감씨 공유하기';

  @override
  String get appInfoShareDescription => '스토어로 연결되는 QR 코드를 보여줍니다.';

  @override
  String get appInfoShareQrDescription => 'QR 코드를 스캔하면 예감씨 스토어 페이지로 이동합니다.';

  @override
  String get appInfoCopyLink => '링크 복사';

  @override
  String get appInfoOpenStore => '스토어 열기';

  @override
  String get appInfoStoreLinkCopied => '스토어 링크를 복사했습니다.';

  @override
  String get appInfoVersionTitle => '앱 버전';

  @override
  String appInfoCurrentVersion(String version, String buildNumber) {
    return '현재 버전 $version+$buildNumber';
  }

  @override
  String get appInfoCheckingVersion => '버전 확인 중...';

  @override
  String get appInfoDataSource => '데이터 출처';

  @override
  String get appInfoKma => '기상청';

  @override
  String get appInfoKmaDescription => '날씨와 예보 데이터를 제공합니다.';

  @override
  String get appInfoAirKorea => '에어코리아';

  @override
  String get appInfoAirKoreaDescription => '미세먼지, 초미세먼지, 오존, 통합 대기질 정보를 제공합니다.';

  @override
  String get appInfoDataSourceNotice => '일부 정보는 공공데이터포털과 공공누리 출처 표시 기준을 따릅니다.';

  @override
  String get widgetScoreLabel => '점수';

  @override
  String get widgetFortuneLabel => '운세';

  @override
  String get widget_description => '예감씨 오늘 요약 위젯';

  @override
  String get widgetInstallTitle => '예감씨 위젯을 추가해보세요';

  @override
  String get widgetInstallMessage => '홈 화면에서 날씨, 기온, 야외 점수, 운세를 바로 확인할 수 있습니다.';

  @override
  String get widgetInstallAction => '위젯 설치';

  @override
  String get widgetInstallManual => '홈 화면을 길게 눌러 예감씨 위젯을 추가해 주세요.';

  @override
  String get updateNoticeTitle => '업데이트 안내';

  @override
  String get updateRequiredTitle => '업데이트 필요';

  @override
  String updateRequiredMessage(String currentVersion, String latestVersion) {
    return '현재 버전 $currentVersion은 더 이상 지원되지 않습니다.\n최신 버전 $latestVersion으로 업데이트해 주세요.';
  }

  @override
  String updateAvailableMessage(String latestVersion) {
    return '새 버전 $latestVersion이 준비되었습니다.\n지금 업데이트하시겠어요?';
  }

  @override
  String get updateAction => '업데이트';

  @override
  String get updateNewVersionMessage => '새 버전이 출시되었습니다.\n지금 업데이트하시겠어요?';

  @override
  String get activityRunning => '러닝';

  @override
  String get activityCycling => '자전거';

  @override
  String get activityHiking => '등산';

  @override
  String get activityWalking => '걷기';

  @override
  String get activityOutdoor => '야외 작업';

  @override
  String get errorNetwork => '인터넷 연결을 확인해 주세요.';

  @override
  String get errorServer => '서버 오류가 발생했습니다.';

  @override
  String get errorLocation => '위치 정보를 가져올 수 없습니다.';

  @override
  String get errorUnknown => '알 수 없는 오류가 발생했습니다.';
}
