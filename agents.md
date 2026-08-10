# PROJECT_AGENT_GUIDE.md

## 프로젝트 개요
- 프로젝트명: 예감씨 (Yegamssi)
- 성격: Flutter 기반 Android 우선 글로벌 예측 서비스 앱
- 주요 기능:
  - 날씨
  - 외부활동 점수화
  - 운세
  - 위젯 중심 UX

- 주요 기술 스택:
  - Flutter / Dart
  - Riverpod
  - go_router
  - Supabase (확장 고려)
  - Background / WorkManager (위젯 업데이트)

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

---

### 4. 재수정
- 90점 미만이면 재수정
- 최대 2회 반복

---

## 핵심 설계 원칙 (예감씨 전용)

### 1. 글로벌 구조 우선
- 국가별 API 분리
- 국가별 운세 분리
- 다국어 구조 필수

---

### 2. 행동 판단 중심
이 앱은 정보 앱이 아니다.

👉 판단 앱이다

- 날씨 → 참고
- 점수 → 핵심
- 운세 → 보조 판단

---

### 3. 위젯 중심 설계
- 위젯 = 핵심 UX
- 앱 = 상세 정보

---

## 다국어 원칙

- 모든 텍스트는 i18n 구조 사용
- 단순 번역 금지

특히 운세:

- 한국 → 사주
- 미국 → Horoscope
- 일본 → 오미쿠지

👉 국가별 로직 분리 필수

---

## Flutter 작업 원칙

- 기존 구조 유지
- 위젯 UI 최적화
- 성능 우선

주의:
- 백그라운드 업데이트 고려
- 배터리 최적화 고려

---

## 릴리즈 빌드 규칙 (필수)

**릴리즈 APK/AAB는 반드시 `tool/build_release.ps1`로 빌드한다. `flutter build apk/appbundle --release`를 직접 실행하지 않는다.**

- 이유: Supabase URL/anon key는 `.env`에서 `--dart-define`으로 주입되는 컴파일타임 상수(`AppConfig.supabaseUrl/supabaseAnonKey`)다. 일반 `flutter build` 명령은 이 값을 주입하지 않아 빈 문자열로 컴파일되고, 그러면 `SupabaseConfig.initialize()`가 조용히 스킵되어 **운세 등 Supabase 의존 기능이 전부 실패**한다(날씨는 캐시가 있으면 겉보기엔 정상으로 보여 발견이 늦어짐 — 실제로 이 문제로 릴리즈 빌드가 한 번 배포된 적 있음).
- 사용법: `.\tool\build_release.ps1 -Target apk -BuildName <버전> -BuildNumber <빌드번호>` (`-Target appbundle`은 AAB)
- Flutter SDK 경로가 기본값(`C:\dev\flutter`)과 다르면 `$env:YEGRAMSSI_FLUTTER_BIN`으로 override
- 빌드 후 실기기 설치 시 운세 탭이 실제 데이터로 뜨는지(에러 문구가 아니라) 확인하는 것이 이 문제의 가장 빠른 검증 방법이다

---

## 디자인 원칙

- 하늘 + 물방울 컨셉 유지
- 글래스모피즘
- 고급 미니멀

금지:
- 과한 캐릭터
- 싸보이는 색상
- 복잡한 UI

---

## 아이콘 시스템

별도 제작 대상:

- 날씨 아이콘
- 운세 아이콘
- 활동 아이콘

조건:
- 통일된 스타일
- 글로벌 사용 가능
- 단순 + 직관

---

## 점수 로직 원칙

- 단순 계산 → 확장 가능 구조
- 국가별 기준 다르게 적용 가능

---

## 금지 사항

- 사용자 승인 없이 구조 변경 금지
- 글로벌 구조 무시 금지
- 임의 번역 금지
- 감성 위주 UI 변경 금지

---

## 완료 보고

항상 포함:

- 변경 내용
- 변경 파일
- 검증 여부
- 리스크

---

## CLAUDE.md / AGENTS.md 연결

### CLAUDE.md

```
이 프로젝트는 PROJECT_AGENT_GUIDE.md 기준을 따른다.
예감씨의 글로벌 구조, 점수 중심 설계, 위젯 중심 UX를 반드시 유지한다.
```

---

### AGENTS.md

```
Follow PROJECT_AGENT_GUIDE.md.

This project is not a simple weather app.
It is a decision-support app based on weather, activity scoring, and localized fortune systems.
Maintain global architecture and widget-first UX.
```
