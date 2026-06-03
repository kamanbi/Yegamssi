# Plan: Yegamssi 언어팩 적용 방법

## 구현 목표
- 앱 언어 설정을 한국어, 일본어, 영어 3개로 제한한다.
- 메인 페이지에서 현재 언어를 보고 즉시 변경할 수 있게 한다.
- 전체 앱 UI 문자열을 선택 언어의 ARB 언어팩 기준으로 표시한다.
- 날씨 API 선택은 앱 언어가 아니라 위치 국가 기준으로 유지한다.
- 운세 문구는 언어별 데이터 파일/테이블을 명확한 fallback 정책으로 연결한다.

## 권장 설계
- 앱 표시 언어: `AppLanguage`와 `LocaleNotifier`를 하나의 책임으로 통합하거나 동기화한다.
- 국가/날씨 기준: `resolvedCountryProvider`를 유지하고 `WeatherDataSourceSelector` 역할을 분리한다.
- UI 언어팩: 모든 화면 표시 문자열은 `AppLocalizations.of(context)`에서 가져온다.
- 메인 페이지 언어 설정: 홈 헤더 우측 또는 설정 진입 전 영역에 작은 language segmented control을 둔다.
- 운세 언어: `fortune_ko`, `fortune_en`, `fortune_ja`를 기본 테이블 규칙으로 둔다.
- 운세 스타일: 언어별 스타일 데이터가 없으면 “해당 언어 base 테이블”로 fallback하고, 그것도 없을 때만 한국어 fallback을 허용한다.

## 작업 순서
1. 승인 직후 Git 변경사항을 다시 확인하고 문서 외 변경과 분리한다.
2. `app_ko.arb`, `app_en.arb`, `app_ja.arb`의 키를 동일하게 맞추고 UTF-8 인코딩을 정상화한다.
3. `AppLanguage`를 `ko`, `ja`, `en` 3개로 정리하고 `zh`는 노출하지 않는다.
4. `MaterialApp.router.locale`을 저장된 언어 provider와 연결한다.
5. 홈 메인 페이지에 언어 설정 UI를 추가하고 선택 시 provider를 갱신한다.
6. 탭, 홈, 설정, 날씨, 점수, 운세 화면의 하드코딩 문자열을 ARB 키로 이동한다.
7. `WeatherIconMapper`, `ScoreTier`, `ActivityIconMapper`, `FortuneTone`의 표시 라벨을 enum 내부 문자열이 아니라 localization helper에서 가져오게 바꾼다.
8. 날씨 provider는 현재 구조를 유지하되 위치 실패 fallback 정책을 재검토한다.
9. 운세 테이블 선택 로직을 `fortune_{lang}`와 `fortune_{lang}_{tone}` 규칙으로 확장한다.
10. 일본어 운세 데이터가 준비되기 전에는 일본어 UI + 운세 준비중/fallback 문구를 명시적으로 처리한다.

## 운세파일 적용 제안
- 1단계: 한국어는 기존 `fortune_ko`, `fortune_ko_{tone}` 유지.
- 2단계: 영어는 `fortune_en`을 우선 연결하고, 스타일 테이블은 데이터가 있을 때만 `fortune_en_{tone}`을 사용한다.
- 3단계: 일본어는 임시 번역 테이블보다 별도 `fortune_ja` 구조를 만들고, 장기적으로 오미쿠지 도메인 모델을 분리한다.
- 4단계: 테이블 조회 순서는 `selected language + tone` -> `selected language base` -> `ko base` -> hardcoded localized fallback으로 둔다.
- 5단계: 캐시 키에는 언어, 톤, 운세 체계 버전을 포함해 언어 변경 후 이전 문구가 재사용되지 않게 한다.

## 완료 기준
- 앱 재실행 후 저장된 언어가 유지된다.
- 홈에서 언어를 바꾸면 탭과 현재 화면 주요 텍스트가 즉시 바뀐다.
- 한국 위치에서는 기상청, 미국은 NOAA 후 OpenWeather, 그 외는 OpenWeather를 사용한다.
- 앱 언어를 영어/일본어로 바꿔도 한국 위치에서는 KMA가 유지된다.
- 운세 결과는 선택 언어의 테이블을 우선 사용하고 fallback 경로가 로그로 확인된다.
- `flutter gen-l10n`, `dart format`, `flutter analyze`, 관련 테스트를 통과한다.

## 가독성 5칙 적용
- Early Return: 언어/테이블 미지원 시 조기에 base/fallback으로 빠지고 중첩 분기를 줄인다.
- Contextual Naming: `selectedAppLanguage`, `weatherCountry`, `fortuneLanguage`, `FortuneTableResolver`처럼 책임이 드러나는 이름을 사용한다.
- Magic Number Hunter: 날씨 갱신 주기 15분, 운세 날씨 대기 2초, 예보 표시 개수는 상수 이름을 유지하거나 정리한다.
- Parameter Object: 언어, 국가, 톤, 생년월일, 날씨 오행을 함께 넘기는 운세 요청은 `FortuneRequest` 후보로 본다.
- Complexity Check: 현재 언어 구조 가독성은 58/100, 1차 적용 목표는 86/100이다.
