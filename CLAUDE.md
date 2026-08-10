# PROJECT_AGENT_GUIDE.md

## 프로젝트 개요

- **프로젝트명:** 예감씨 (Yegamssi)
- **버전:** 1.0.3+17
- **성격:** Flutter 기반 Android 우선 글로벌 예측 서비스 앱 (행동 판단 앱)
- **최소 SDK:** Dart 3.8.0

### 주요 기능
- 날씨 (다중 API 소스, 국가별 분리)
- 외부활동 점수화 (0~100, 국가별 가중치)
- 운세 (사주 기반, 국가별 로직 분리)
- 위젯 중심 UX (Android Home Widget)
- AdMob 광고 (배너 + 전면)

### 주요 기술 스택
- Flutter / Dart + freezed / json_serializable / Riverpod codegen
- Riverpod 2.6.1 (`@riverpod` 어노테이션 기반)
- go_router 14.6.2
- Supabase 2.8.0 (운세 DB, Phase 2+ 연동)
- home_widget 0.7.0 + workmanager 0.9.0 (위젯 업데이트)
- Dio 5.7.0 + flutter_dotenv (API 키 관리)

---

## 목적

이 문서는 `CLAUDE.md`와 `AGENTS.md`에서 공통으로 사용하는 작업 기준 문서이다.

Claude Code와 Codex를 동시에 사용할 때
**동일한 기준, 동일한 흐름, 동일한 판단 기준**으로 개발하기 위한 가이드이다.

---

## 작업 기본 원칙

- 의미 있는 수정 전 반드시 현재 구조 분석
- 감으로 수정하지 말고 구조 기반 수정
- 글로벌 서비스 기준으로 설계

복잡한 작업은 반드시 아래 순서:

1. 코드 및 구조 분석
2. `research.md` 작성
3. `plan.md` 작성
4. 사용자 승인
5. 구현
6. 검증

---

## 반복 개선 루프

### 1. 계획
- 요구사항 정리
- 리스크 분석
- 검증 방법 정의

### 2. 구현
- 작은 단위로 수정
- 가독성 유지

### 3. 평가 (100점 기준)

- 요구사항 충족: 40
- 구조 일관성: 20
- 가독성: 20
- 안정성: 20

### 4. 재수정
- 90점 미만이면 재수정
- 최대 2회 반복

---

## 현재 아키텍처 (실제 구현 기준)

### Clean Architecture + Feature-based 모듈

```
lib/
├── main.dart               # dotenv 로드, Supabase/AdMob 초기화, ProviderScope
├── app.dart                # MaterialApp.router, 테마, 다국어
│
├── core/                   # 전역 공통 라이브러리
│   ├── config/             # app_config.dart, supabase_config.dart, admob_config.dart
│   ├── constants/          # app_colors.dart, app_text_styles.dart, app_assets.dart
│   ├── design/             # app_radius.dart, app_shadows.dart, app_spacing.dart
│   ├── error/              # app_exception.dart (FortuneNoProfileException 등), failure.dart
│   ├── extensions/         # context_ext.dart, datetime_ext.dart
│   ├── locale/             # country_code.dart, country_resolver.dart, locale_provider.dart
│   ├── network/            # dio_client.dart, api_interceptor.dart
│   ├── router/             # app_router.dart (@riverpod GoRouter), app_routes.dart
│   ├── storage/            # local_storage.dart, location_cache_store.dart,
│   │                       # weather_cache_store.dart, widget_cache.dart
│   ├── theme/              # app_theme.dart, glassmorphism.dart, theme_provider.dart
│   ├── utils/              # date_format_helper.dart, geocoding_service.dart,
│   │                       # location_provider.dart
│   ├── version/            # app_update_service.dart
│   └── widgets/            # app_buttons.dart, premium_card.dart
│
├── features/               # 기능별 모듈 (Clean Architecture 계층)
│   ├── splash/
│   ├── onboarding/         # 생년월일 입력 (첫 실행)
│   ├── home/               # ShellRoute 래퍼 + 대시보드
│   ├── weather/            # 날씨 (data/domain/presentation)
│   ├── score/              # 활동 점수 (data/domain/presentation)
│   ├── fortune/            # 운세 (data/domain/presentation)
│   ├── user/               # 사용자 프로필 (생년월일, 출생시간)
│   ├── settings/           # 언어/테마 설정
│   └── widget_bridge/      # Android 위젯 연동 (widget_snapshot_sync.dart,
│                           # widget_data_writer.dart)
│
└── l10n/                   # 다국어 생성 파일 (ko, en, ja, zh)
```

---

## 라우팅 구조 (GoRouter)

```
/splash → SplashScreen
/onboarding → OnboardingScreen (생년월일 선택)
ShellRoute (HomeScreen: BottomNavBar + AdMob)
  /         → HomeTabScreen (날씨+점수+운세 대시보드)
  /weather  → WeatherScreen
  /score    → ScoreScreen
  /fortune  → FortuneScreen
  /settings → SettingsScreen
  /settings/app-info → AppInfoScreen
```

- ShellRoute 기반: BottomNavigationBar 모든 탭 유지
- PopScope(canPop: false): Android 뒤로가기 처리 (2회 → 전면광고 → 종료)
- onHorizontalDragEnd: 스와이프 탭 이동

---

## 상태관리 (Riverpod)

### keepAlive: true 핵심 Providers

| Provider | 의존 | 역할 |
|---|---|---|
| `currentPositionProvider` | GPS | 위도/경도 (10초 타임아웃, 캐시 fallback, 기본 서울) |
| `currentWeatherProvider` | currentPosition | 날씨 조회 (API 실패 시 캐시 fallback) |
| `currentScoreProvider` | currentWeather | 날씨 기반 활동 점수 계산 |
| `dailyFortuneProvider` | currentWeather + userProfile | 운세 (사주지문×날짜×시간 캐싱) |

### Notifier Providers

| Provider | 역할 |
|---|---|
| `ThemeNotifier` | 다크모드 토글 |
| `AppLanguageNotifier` | 언어 선택 (ko/en/ja/zh) |
| `LocaleNotifier` | Locale 상태 |
| `UserProfileNotifier` | 생년월일/출생시간 저장·조회 |
| `WeatherNotifier` | 수동 날씨 조회 |

### Provider 반응 사이클
```
currentPosition 변경
  → currentWeather 자동 재조회
  → currentScore 자동 재계산
  → dailyFortune 자동 재조회
  → syncWidgetSnapshot() (Android 위젯 갱신)
```

---

## 핵심 로직 상세

### 활동 점수 계산 (한국 기준: kr_score_calculator.dart)

기본 100점에서 감점:

| 항목 | 조건 | 감점 |
|---|---|---|
| 강수확률 | ≥70% | -40 |
| 강수확률 | ≥40% | -20 |
| 강수확률 | ≥20% | -10 |
| 풍속 (m/s) | ≥14 | -20 |
| 풍속 (m/s) | ≥9 | -10 |
| 풍속 (m/s) | ≥5 | -5 |
| 기온 (°C) | ≥35 or ≤-10 | -30 |
| 기온 (°C) | ≥30 or ≤-5 | -15 |
| 기온 (°C) | ≥28 or ≤0 | -5 |
| PM10 (μg/m³) | ≥151 (매우나쁨) | -20 |
| PM10 (μg/m³) | ≥81 (나쁨) | -12 |
| PM10 (μg/m³) | ≥31 (보통) | -5 |
| UV 지수 | ≥11 | -15 |
| UV 지수 | ≥8 | -8 |
| UV 지수 | ≥6 | -3 |

등급: Excellent(80+) / Good(60~79) / Fair(40~59) / Poor(<40)

미국은 `us_score_calculator.dart`, 글로벌은 `global_score_calculator.dart` 별도 적용.

---

### 사주 계산 (saju_calculator.dart)

```
입력: 생년월일 + 출생시간 (모름=12시)

年柱: (year - 4) % 10 → 천간, (year - 4) % 12 → 지지
月柱: 절기 기반 근사 (입기일 평균, 년간 인덱스 기반 천간)
日柱: 1900-01-01(甲子) 기준 일수 차이 % 10/12
時柱: 출생시간 → 지지 (子시=23~1시), 일간 기반 천간

오행 카운트: 8개 간지의 오행(목화토금수) 빈도 집계
```

---

### 운세 점수 계산 (fortune_score_calculator.dart)

6개 카테고리 (0~100 정규화):

| 카테고리 | 핵심 요소 |
|---|---|
| 종합운세 | 년월일시 4간 관계 합산 (동일+10, 상생+20, 상극-20) |
| 재물운 | 금(金) 오행 카운트 강도 |
| 연애운 | 화(火)·수(水) 오행 균형 |
| 직장운 | 목(木)+금(金) 강도 |
| 건강운 | 오행 5개 분포 균형 |
| 결정운 | 일간×2 + 월간 + 년간 관계 |

정규화: `((rawScore + 80) / 160 * 100).clamp(0, 100)`
날씨 오행 보정: 오행 카운트 0→+20, 1→+10, 2→0, 3→-10, 4+→-20

---

### 날씨 API 소스 우선순위

| 국가 | 1순위 | 2순위 | 3순위 |
|---|---|---|---|
| KR | KMA (기상청, PM10/PM25 제공) | OpenWeather | OpenMeteo |
| US | NOAA | OpenWeather | OpenMeteo |
| GLOBAL | OpenWeather | OpenMeteo | - |

모든 소스는 WeatherEntity로 정규화 (온도: °C, 풍속: m/s, 강수확률: 0.0~1.0)

---

### 캐싱 전략

| 대상 | 저장소 | 키 / 기준 |
|---|---|---|
| GPS 위치 | LocationCacheStore (SharedPrefs) | 5분 유효 |
| 날씨 | WeatherCacheStore (SharedPrefs) | 시간별 예보 보존 |
| 운세 | SharedPreferences | `fortune_{언어}_{날짜}_{시간슬롯}_{사주지문}` |
| 위젯 | home_widget SharedPrefs | 11개 키 실시간 동기화 |

---

### Android 위젯 데이터 키 (widget_cache.dart)

```
weatherCondition, weatherSymbol, temperature, feelsLikeTemperature,
fortuneSymbol (⬆/➡/⬇), score, date, time, latitude, longitude, updatedAt
```

중복 업데이트 방지: condition+온도+운세심볼+점수 서명(signature) 비교

---

## Supabase 연동

- 초기화: `supabase_config.dart` (.env에서 URL/ANON_KEY 로드, 없으면 스킵)
- 운세 테이블: `fortune_ko`, `fortune_en`, `fortune_ja`, `fortune_zh`
- Phase 1: 로컬 계산 완료 / Phase 2+: Supabase 메시지 조회

---

## 다국어(i18n)

- ARB 템플릿: `l10n/app_en.arb`, 생성 클래스: `AppLocalizations`
- 지원 언어: ko(완료), en(완료), ja(스텁), zh(스텁)
- 런타임 변경: `AppLanguageNotifier` + `LocaleNotifier`

운세 국가별 로직 분리 필수:
- 한국 → 사주 (saju_calculator.dart)
- 미국 → Horoscope (Phase 2)
- 일본 → 오미쿠지 (Phase 3)

---

## 핵심 설계 원칙 (예감씨 전용)

### 1. 글로벌 구조 우선
- 국가별 API 분리 (이미 구현: KrScoreCalculator / UsScoreCalculator / GlobalScoreCalculator)
- 국가별 운세 분리 (DB 테이블 분리 완료)
- 다국어 구조 필수

### 2. 행동 판단 중심

이 앱은 정보 앱이 아니다. **판단 앱이다.**

- 날씨 → 참고
- 점수 → 핵심
- 운세 → 보조 판단

### 3. 위젯 중심 설계
- 위젯 = 핵심 UX
- 앱 = 상세 정보

---

## Flutter 작업 원칙

- 기존 구조 유지 (Clean Architecture 계층 엄수)
- `@riverpod` 어노테이션 사용 → 수정 후 `build_runner` 실행 필수
- 위젯 UI 최적화, 성능 우선
- 백그라운드 업데이트 / 배터리 최적화 고려
- `*.g.dart`, `*.freezed.dart` 파일은 직접 수정 금지 (생성 파일)

코드 생성:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 릴리즈 빌드 규칙 (필수)

**릴리즈 APK/AAB는 반드시 `tool/build_release.ps1`로 빌드한다. `flutter build apk/appbundle --release`를 직접 실행하지 않는다.**

- 이유: Supabase URL/anon key는 `.env`에서 `--dart-define`으로 주입되는 컴파일타임 상수(`AppConfig.supabaseUrl/supabaseAnonKey`)다. 일반 `flutter build` 명령은 이 값을 주입하지 않아 빈 문자열로 컴파일되고, 그러면 `SupabaseConfig.initialize()`가 조용히 스킵되어 **운세 등 Supabase 의존 기능이 전부 실패**한다(날씨는 캐시가 있으면 겉보기엔 정상으로 보여 발견이 늦어짐).
- 사용법: `.\tool\build_release.ps1 -Target apk -BuildName <버전> -BuildNumber <빌드번호>` (`-Target appbundle`은 AAB)
- Flutter SDK 경로가 기본값(`C:\dev\flutter`)과 다르면 `$env:YEGRAMSSI_FLUTTER_BIN`으로 override
- 빌드 후 실기기 설치 시 운세 탭이 실제 데이터로 뜨는지(에러 문구가 아니라) 확인하는 것이 이 문제의 가장 빠른 검증 방법이다

---

## 디자인 원칙

- 하늘 + 물방울 컨셉 유지
- 글래스모피즘 (glassmorphism.dart)
- 고급 미니멀

금지:
- 과한 캐릭터
- 싸보이는 색상
- 복잡한 UI

---

## 아이콘 시스템

별도 제작 대상:
- 날씨 아이콘 (weather_icon_mapper.dart, premium_weather_icon.dart)
- 운세 아이콘
- 활동 아이콘 (activity_icon_mapper.dart)

조건: 통일된 스타일, 글로벌 사용 가능, 단순 + 직관

---

## 점수 로직 원칙

- 단순 계산 → 확장 가능 구조 (ScoreCalculator 추상 인터페이스)
- 국가별 기준 다르게 적용 가능 (KR/US/Global 분리 완료)

---

## 금지 사항

- 사용자 승인 없이 구조 변경 금지
- 글로벌 구조 무시 금지
- 임의 번역 금지
- 감성 위주 UI 변경 금지
- `*.g.dart` / `*.freezed.dart` 직접 수정 금지

---

## 완료 보고

항상 포함:

- 변경 내용
- 변경 파일
- 검증 여부
- 리스크

---

## 개발 단계 현황

| Phase | 내용 | 상태 |
|---|---|---|
| Phase 1 | 핵심 기능 (날씨/점수/운세/위젯) + Supabase 운세 DB (4056행) | 완료 |
| Phase 2 | 미국 런칭 (NOAA + Horoscope) | 준비 중 |
| Phase 3 | 일본 (오미쿠지) / 중국 런칭 | 예정 |

---

## 하네스: 예감씨 진단

**목표:** 백그라운드 갱신·위젯 갱신·운세 캐시·날씨 불일치 문제를 진단하고 수정한다.

**트리거:** "백그라운드 갱신", "위젯 갱신", "운세 로딩", "날씨 불일치", "위젯 날씨 달라" 등 시스템 동작 점검 요청 시 `yegamssi-diagnostic` 스킬을 사용하라. 단순 질문은 직접 응답 가능.

**진단 보고서:** `.claude/_workspace/diagnostic_summary.md` — 수정 우선순위 포함.

**변경 이력:**
| 날짜 | 변경 내용 | 대상 | 사유 |
|------|----------|------|------|
| 2026-05-30 | 초기 구성 | 전체 | 백그라운드·위젯·운세·날씨 불일치 4영역 진단 |

---

## 하네스: 예감씨 비용 최적화

**목표:** 날씨 API 호출량을 격자 캐싱으로 억제해 사용자 수에 비례하던 서버 비용을 지리 기반 상수로 전환하고, 배포 후 캐시 효율을 상시 측정한다.

**트리거:** "격자 캐싱", "API 호출량", "캐시 히트율", "프록시 비용", "TTL 조정", "서버 비용 점검", "단위경제 확인" 등 날씨 프록시 비용·캐시 작업 요청 시 `weather-proxy-cache` 스킬을 사용하라. 앱 내부 캐시(WeatherCacheStore) 문제는 `yegamssi-diagnostic` 대상.

**변경 이력:**
| 날짜 | 변경 내용 | 대상 | 사유 |
|------|----------|------|------|
| 2026-07-12 | 초기 구성 | 에이전트 3 + 스킬 1 | 프록시 무캐싱으로 해외 사용자 단위경제 적자 확인 |
| 2026-08-10 | 설계→구현→검증 1차 실행, 검증 FAIL 1건(F-1)·개선 2건 직접 반영 | weather-proxy/index.ts | fct_afs_wc.php E6 누락, L2 장애 시 L1 미기록, nocache가 일반 요청과 single-flight 공유 |

---

## CLAUDE.md / AGENTS.md 연결

### CLAUDE.md

```
이 프로젝트는 PROJECT_AGENT_GUIDE.md 기준을 따른다.
예감씨의 글로벌 구조, 점수 중심 설계, 위젯 중심 UX를 반드시 유지한다.
```

### AGENTS.md

```
Follow PROJECT_AGENT_GUIDE.md.

This project is not a simple weather app.
It is a decision-support app based on weather, activity scoring, and localized fortune systems.
Maintain global architecture and widget-first UX.
```
