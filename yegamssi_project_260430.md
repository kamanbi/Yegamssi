# 예감씨 (Yegamssi) 개발 보고서
> 작성일: 2026-04-30 | 현재 버전: 1.1.1+26

---

## 1. 프로젝트 개요

| 항목 | 내용 |
|---|---|
| 앱 이름 | 예감씨 (Yegamssi) |
| 성격 | 날씨·활동점수·운세 기반 **행동 판단 앱** |
| 플랫폼 | Android 우선 (Flutter) |
| 최소 SDK | Dart 3.8.0 / Android API 21+ |
| 현재 버전 | 1.1.1+26 |
| 개발 도구 | Flutter / Dart + Riverpod 2.6.1 + GoRouter 14.6.2 |

### 앱 컨셉
- **정보 앱이 아닌 판단 앱** — 날씨(참고) + 점수(핵심) + 운세(보조)
- 디자인 키워드: **하늘 + 물방울 + 글래스모피즘 + 고급 미니멀**
- 위젯이 핵심 UX, 앱은 상세 정보 역할

---

## 2. 화면 구성

```
/splash          → SplashScreen
/onboarding      → OnboardingScreen (생년월일 입력, 첫 실행)
ShellRoute (BottomNavBar + AdMob 배너)
  /              → HomeTabScreen  ← 대시보드 (날씨+점수+운세 요약)
  /weather       → WeatherScreen
  /score         → ScoreScreen
  /fortune       → FortuneScreen
  /settings      → SettingsScreen
  /settings/app-info → AppInfoScreen
```

### 화면별 주요 구성 요소

#### HomeTabScreen (대시보드)
- 현재 날씨 아이콘 (84px SVG) + 기온
- 활동 점수 (0~100) + 등급 텍스트
- 운세 한줄 요약 + 방향 심볼 (⬆ / ➡ / ⬇)
- 위치명 + 갱신 시간

#### WeatherScreen (날씨 상세)
- 현재 날씨 박스: 아이콘(86px) + 기온(72px) + 날씨 레이블 + 체감온도
- 시간별 예보 (가로 스크롤): 시간 + 아이콘(34px) + 기온
- 일별 예보: 날짜 + 요일 + 오전/오후 날씨 칩(아이콘 22px) + 최저/최고
- 대기질 카드: PM10, PM2.5, O3, KHAI 등급
- 바람·습도·UV 정보 카드

#### ScoreScreen (활동 점수)
- 대형 점수 숫자 + 등급 (Excellent / Good / Fair / Poor)
- 차감 항목별 breakdown (강수/풍속/기온/미세먼지/UV/오존)

#### FortuneScreen (운세)
- 6개 카테고리 카드: 종합/재물/연애/직장/건강/결정
- 각 카테고리별 0~100 점수 + 한줄 설명

#### SettingsScreen
- 언어 선택 (한국어/English/日本語/中文)
- 다크모드 토글
- 앱 정보

---

## 3. 디자인 시스템

### 색상 팔레트 (app_colors.dart)

#### 브랜드 컬러
| 이름 | HEX | 용도 |
|---|---|---|
| primaryBlue | `#4B68F2` | 주요 강조 |
| secondaryPurple | `#6B58D8` | 보조 강조 |
| accentGold | `#D6B168` | 운세·포인트 |
| goldLight | `#E6CA8E` | 밝은 골드 |
| goldDark | `#9D7A37` | 어두운 골드 |

#### 하늘 컬러 (배경·그라디언트)
| 이름 | HEX | 용도 |
|---|---|---|
| skyDeep | `#0B1730` | 다크 배경 깊은 톤 |
| skyMid | `#1A2C55` | 다크 배경 중간 톤 |
| skyLight | `#6E8CFF` | 밝은 하늘 강조 |
| skyGlow | `#B6C7FF` | 하늘 글로우 |
| waterMist | `#DCEBFF` | 물안개 효과 |
| waterSurface | `#663C6BFF` (38%) | 수면 반투명 |

#### 배경 / 서피스
| 이름 | HEX | 용도 |
|---|---|---|
| lightBackground | `#F4F7FC` | 라이트 배경 |
| lightSurface | `#FFFFFF` | 라이트 카드 |
| darkBackground | `#07111F` | 다크 배경 |
| darkSurface | `#111D35` | 다크 카드 |
| darkSurfaceMuted | `#182744` | 다크 서브 카드 |

#### 글래스모피즘
| 이름 | HEX/투명도 | 용도 |
|---|---|---|
| glassWhite | `rgba(255,255,255,0.10)` | 글래스 배경 |
| glassBorder | `rgba(255,255,255,0.20)` | 글래스 테두리 |
| glassShadow | `rgba(0,0,0,0.15)` | 글래스 그림자 |
| glassHighlight | `rgba(255,255,255,0.60)` | 글래스 하이라이트 |

#### 텍스트 (다크 배경 기준)
| 이름 | HEX/투명도 | 용도 |
|---|---|---|
| textPrimary | `#F8FAFF` | 본문 |
| textSecondary | `rgba(248,250,255,0.70)` | 보조 텍스트 |
| textMuted | `rgba(248,250,255,0.50)` | 흐린 텍스트 |

#### 점수 등급 컬러
| 등급 | HEX | 기준 |
|---|---|---|
| Excellent | `#5FC98A` | 80점 이상 |
| Good | `#85CF8A` | 60~79점 |
| Fair | `#F0C46B` | 40~59점 |
| Poor | `#E78C7D` | 40점 미만 |

### 타이포그래피 (app_text_styles.dart)

| 스타일 | 크기 | 굵기 | 용도 |
|---|---|---|---|
| displayLarge | 48px | W700 | 메인 숫자 |
| displayMedium | 32px | W700 | 섹션 제목 |
| headlineLarge | 24px | W700 | 카드 제목 |
| headlineMedium | 20px | W600 | 서브 제목 |
| titleLarge | 18px | W600 | 리스트 제목 |
| titleMedium | 16px | W600 | 카드 내 제목 |
| bodyLarge | 16px | W400 | 본문 |
| bodyMedium | 14px | W400 | 보조 본문 |
| labelLarge | 13px | W600 | 레이블 |
| labelMedium | 12px | W500 | 소 레이블 |
| labelSmall | 11px | W500 | 최소 레이블 |
| **temperature** | **72px** | **W300** | 기온 표시 |
| **scoreDisplay** | **40px** | **W700** | 점수 표시 |
| fortuneLine | 15px | W500 | 운세 본문 |

---

## 4. 날씨 아이콘 시스템

### 앱 내 아이콘 (SVG, assets/icons/weather/)

총 **20종** (기본 16종 + 야간 4종)

| 파일명 | 조건 | 야간 파일 |
|---|---|---|
| sunny.svg | 맑음 | night_sunny.svg |
| partly_cloudy.svg | 구름 조금 | night-cloudy.svg |
| cloudy.svg | 흐림 | — |
| hazy.svg | 안개 | night-hazey.svg |
| windy.svg | 바람 | — |
| slight_rain.svg | 약한 비 | — |
| rain.svg | 비 | — |
| heavy_rain.svg | 강한 비 | — |
| thunderstorm.svg | 뇌우 | — |
| rain_thunder.svg | 비+천둥 | — |
| light_snow.svg | 약한 눈 | — |
| snow.svg | 눈 | — |
| sleet.svg | 진눈깨비 | — |
| hot.svg | 폭염 (33°C↑) | night-hot.svg (열대야) |
| cold_wave.svg | 한파 (-10°C↓) | — |
| unknown.svg | 정보없음 | — |

**야간 아이콘 적용 기준:** NOAA 공식 기반 일출/일몰 시간 계산 (위도·경도·로컬 시간)

### 위젯 아이콘 (PNG, android/res/drawable-nodpi/)

총 **12종**

| 파일명 | 해당 날씨 |
|---|---|
| widget_weather_sunny.png | 맑음, 폭염 |
| widget_weather_sunny_night.png | 맑은 밤, 열대야 |
| widget_weather_partly_cloudy.png | 구름 조금 |
| widget_weather_partly_cloudy_night.png | 구름 조금 밤 |
| widget_weather_cloudy.png | 흐림, 정보없음 |
| widget_weather_hazy.png | 안개 |
| widget_weather_hazy_night.png | 안개 밤 |
| widget_weather_rain.png | 약한비/비/강한비/진눈깨비 |
| widget_weather_snow.png | 약한눈/눈/한파 |
| widget_weather_thunderstorm.png | 뇌우, 비+천둥 |
| widget_weather_windy.png | 바람 |
| widget_weather_hot_night.png | 열대야 |

### 날씨 상태별 색상 (WeatherIconMapper)

| 날씨 | primaryColor | accentColor |
|---|---|---|
| 맑음 | `#F6F8FF` | Gold `#D6B168` |
| 맑은 밤 | `#DFE8FF` | `#9DB5FF` |
| 구름 조금 | `#F4F7FF` | Gold |
| 구름 조금 밤 | `#E5EFF9` | `#8FA3C6` |
| 흐림 | `#F2F5FC` | `#B9C7E3` |
| 안개 | `#F3F5F8` | `#D5DFEE` |
| 안개 밤 | `#E8EEF7` | `#B0BDD4` |
| 바람 | `#F0F5FA` | `#B4D1E8` |
| 약한 비 | `#F4F8FF` | `#9EC6FF` |
| 비 | `#F4F8FF` | `#89B8FF` |
| 강한 비 | `#F3F7FF` | `#5E8DFF` |
| 뇌우 | `#F6F8FF` | Gold |
| 비+천둥 | `#F5F8FF` | `#7CA0FF` |
| 약한 눈 | `#F8FBFF` | `#DAE9FF` |
| 눈 | `#F8FBFF` | `#C9E2FF` |
| 진눈깨비 | `#F4F8FC` | `#B8D5F0` |
| 폭염 | `#FFF6E8` | `#FFB84A` |
| 열대야 | `#FFEEDD` | `#FFB84A` |
| 한파 | `#F0F7FF` | `#7AAFFF` |
| 정보없음 | `#E7EDF7` | `#B6C1D8` |

---

## 5. Android 홈 위젯

### 위젯 스펙
| 항목 | 내용 |
|---|---|
| 최소 크기 | 280dp × 56dp |
| 권장 셀 | 5열 × 1행 |
| 리사이즈 | 가로만 가능 |
| 갱신 방식 | WorkManager 30분 주기 |

### 위젯 표시 데이터
| 항목 | 설명 |
|---|---|
| 날씨 아이콘 | PNG drawable (야간 구분) |
| 기온 | 현재 기온 °C |
| 체감 온도 | 체감 기온 °C |
| 운세 심볼 | ⬆ (상승) / ➡ (보통) / ⬇ (하락) |
| 운세 색상 | 상승 `#7EDB9C` / 보통 `#FFD76A` / 하락 `#F29A8B` |
| 점수 | 0~100 활동 점수 |
| 날짜 / 시간 | 마지막 갱신 기준 |

### 위젯 갱신 구조
```
앱 실행 시 → WorkManager 등록 (30분 주기)
백그라운드 → 마지막 저장 위치 읽기 → 날씨 API 호출 → 점수 계산 → 위젯 갱신
앱 포그라운드 → 날씨·점수·운세 모두 갱신 → 위젯 동기화
```

---

## 6. 핵심 로직 요약

### 활동 점수 계산 (한국 기준)
기본 100점에서 차감:

**강수 (최대 -90)**

| 강수확률 | 차감 |
|---|---|
| 90%↑ | -70 |
| 80%↑ | -60 |
| 70%↑ | -50 |
| 60%↑ | -40 |
| 60% 미만 | 0 |

**날씨 상태 추가 차감**

| 상태 | 추가 |
|---|---|
| 약한 비 | -5 |
| 비 | -10 |
| 강한 비 | -20 |
| 뇌우/비+천둥 | -20 |
| 약한 눈 | -10 |
| 눈 | -12 |
| 진눈깨비 | -5 |

**풍속**

| 조건 | 차감 |
|---|---|
| 14m/s↑ | -30 |
| 9m/s↑ | -18 |
| 5m/s↑ | -8 |

**기온**

| 조건 | 차감 |
|---|---|
| 35°C↑ / -10°C↓ | -35 |
| 30°C↑ / -5°C↓ | -18 |
| 28°C↑ / 0°C↓ | -8 |

**미세먼지 PM10 (최대 -35, PM2.5 합산)**

| PM10 | 차감 |
|---|---|
| 151↑ (매우나쁨) | -30 |
| 81↑ (나쁨) | -18 |
| 31↑ (보통) | -8 |

**UV 지수**

| UV | 차감 |
|---|---|
| 11↑ | -18 |
| 8↑ | -10 |
| 6↑ | -5 |

**오존 O3**

| O3 | 차감 |
|---|---|
| 0.150↑ | -25 |
| 0.090↑ | -15 |
| 0.030↑ | -5 |

### 날씨 API 우선순위 (한국)
```
KMA 기상청 (PM10/PM25 제공) → OpenWeather → OpenMeteo
```

### 운세 계산
- 사주 (年月日時 四柱) 기반
- 6개 카테고리: 종합/재물/연애/직장/건강/결정
- 0~100 정규화 점수
- Supabase DB (fortune_ko/en/ja/zh) 4056행

---

## 7. 다국어 지원

| 언어 | 코드 | 상태 |
|---|---|---|
| 한국어 | ko | 완료 |
| English | en | 완료 |
| 日本語 | ja | 스텁 (Phase 3) |
| 中文 | zh | 스텁 (Phase 3) |

---

## 8. 개발 Phase 현황

| Phase | 내용 | 상태 |
|---|---|---|
| Phase 1 | 날씨/점수/운세/위젯 + Supabase 운세 DB | **완료** |
| Phase 2 | 미국 런칭 (NOAA + Horoscope) | 준비 중 |
| Phase 3 | 일본 (오미쿠지) / 중국 런칭 | 예정 |

---

## 9. 최근 작업 이력 (2026-04-30 기준)

| 버전 | 주요 작업 |
|---|---|
| +24 | 야간 날씨 아이콘 4종 적용 (앱), 백그라운드 갱신(workmanager) 구현 |
| +25 | 강수 점수 차감 기준 전면 개편 (60% 미만 -0, 90% 이상 -70) |
| +26 | 위젯 야간 PNG 아이콘 적용, DartPluginRegistrant 누락 수정 |

---

## 10. 디자인 작업 요청 사항 (현재 기준)

### 완료된 아이콘
- 날씨 SVG 16종 (앱용)
- 날씨 야간 SVG 4종 (맑음/구름조금/안개/폭염)
- 위젯 PNG 12종

### 미완성 / 추가 필요
- 운세 아이콘 (assets/icons/fortune/) — 현재 PNG 4종 (great/good/normal/bad), 스타일 통일 필요
- 활동 아이콘 (assets/icons/activity/) — 현재 PNG 5종 (running/cycling/hiking/walking/outdoor)
- 스플래시 배경 (assets/images/splash_bg.png)
- 위젯 미리보기 레이아웃 디자인

### 디자인 원칙
- 통일된 아이콘 스타일 (글로벌 사용 가능, 단순·직관)
- 과한 캐릭터 금지
- 싸 보이는 색상 금지
- 복잡한 UI 금지
- 하늘·물방울 컨셉 유지
