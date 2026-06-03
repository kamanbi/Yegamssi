# Research: Yegamssi 언어팩 적용

## 현재 구조
- 앱은 Flutter/Riverpod 기반이며 `MaterialApp.router`는 `lib/app.dart`에 있다.
- `l10n.yaml`은 `l10n/*.arb`를 `lib/l10n/app_localizations*.dart`로 생성하도록 설정되어 있다.
- 현재 ARB 파일은 `ko`, `en`, `ja`, `zh`가 있으나 요구 범위는 한국어, 일본어, 영어 3개다.
- `lib/core/locale/locale_provider.dart`에는 `LocaleNotifier`와 `AppLanguageNotifier`가 있고 `SharedPreferences` 저장 키도 이미 있다.
- `lib/app.dart`는 `locale: const Locale('ko')`로 고정되어 있어 저장된 언어 설정이 앱 전역에 반영되지 않는다.

## 현재 UI 언어 상태
- 홈, 설정, 탭, 날씨 카드, 점수 라벨, 운세 화면 등에 하드코딩 문자열이 남아 있다.
- `HomeScreen`의 하단 탭 라벨은 정적 리스트에 직접 문자열로 들어가 있어 로케일 변경 반응성이 없다.
- `HomeTabScreen`, `SettingsScreen`, `WeatherIconMapper`, `ScoreTierExtension`, `ActivityIconMapper`, `FortuneTone`에 표시 문자열이 직접 들어가 있다.
- `app_ja.arb`는 키 수가 부족하고, `app_ko.arb`/일부 Dart 출력은 인코딩 깨짐이 관찰된다. 실제 적용 전 ARB 파일의 UTF-8 정상 여부와 키 동기화가 필요하다.

## 날씨 데이터 소스 상태
- `weatherRepositoryProvider`는 `resolvedCountryProvider`를 기준으로 국가를 판정한다.
- 한국은 `KmaDataSource`, 미국은 `NoaaDataSource` 후 `OpenWeatherDataSource`, 그 외 국가는 `OpenWeatherDataSource`를 사용한다.
- 이 구조는 “위치 기반으로 한국은 기상청, 나머지 나라는 OpenWeather 계열” 요구와 대부분 맞다.
- 언어 설정은 앱 표시 언어이고, 날씨 API 선택은 GPS/위치 기반 국가이므로 서로 분리해야 한다.
- 현재 위치 판정 실패 시 `CountryCode.kr`로 fallback한다. 글로벌 서비스 관점에서는 위치 실패 시 한국 API로 고정되는 리스크가 있다.

## 운세 언어 상태
- `dailyFortuneProvider`는 `appLanguageNotifierProvider.tableKey`를 읽어 `lang`으로 넘긴다.
- `FortuneTone.tableNameForLang()`은 `lang == 'ko'`가 아니면 강제로 `fortune_ko`를 사용한다.
- Supabase 운세 테이블 SQL은 `fortune_ko`와 한국어 스타일 테이블 중심이다.
- `etc/en.csv`, `etc/en_insert.sql`이 존재하므로 영어 운세 데이터 준비 흔적은 있으나 현재 스타일 테이블과 앱 fallback 정책에는 연결되어 있지 않다.
- 일본어 운세 데이터 파일/테이블은 현재 확인되지 않았다.

## 제약
- 사용자 승인 전에는 구현 파일을 수정하지 않고 `research.md`, `plan.md`만 최신 기준으로 유지한다.
- 앱 언어는 한국어, 일본어, 영어 3개만 노출하는 것이 현재 요구다.
- 날씨 제공자는 앱 언어가 아니라 위치 국가 기준으로 선택해야 한다.
- 운세는 단순 번역보다 국가별 운세 체계 분리가 필요하다는 기존 프로젝트 원칙이 있다.
- 위젯 텍스트도 앱 언어팩과 동기화하려면 Flutter 쪽 snapshot writer와 Android 네이티브 위젯 표시 문자열까지 함께 검토해야 한다.

## 리스크
- ARB 키가 화면 문자열보다 부족하면 일부 UI만 번역되는 반쪽 적용이 된다.
- 앱 언어와 위치 국가를 묶으면 일본에서 한국어를 쓰거나 한국에서 영어를 쓰는 사용자의 날씨/운세 동작이 잘못된다.
- 운세 테이블이 없는 언어에서 무조건 한국어 fallback을 하면 사용자 설정과 표시 결과가 불일치한다.
- 일본어 운세는 사주 문구 번역만으로 처리하면 기존 “일본은 오미쿠지” 원칙과 충돌한다.
- 현재 작업트리에 문서 외 수정사항이 많으므로 구현 단계에서 변경 범위 분리가 필요하다.
