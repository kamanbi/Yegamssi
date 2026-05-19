# 예감씨 v1.1.1+30 출시 준비

**출시일:** 2026-05-04  
**버전:** 1.1.1+30  
**플랫폼:** Android (Google Play Store)

---

## 📦 빌드 파일

| 파일명 | 크기 | SHA256 |
|---|---|---|
| app-release.apk | 27.6MB | 091cbd9775fa7ce2d4cb8cd58cffd213b1d117b513bb0ca588d9aebd527b8abd |
| app-release.aab | 48.1MB | 9f23e502ff1e413b35fef398db593153d7f2f36bb55948f9cdc6dbc5a67f169e |

---

## ✨ 주요 변경사항 (v1.1.0 → v1.1.1+30)

### Phase 1 완성
- ✅ 기본 기능: 날씨, 활동 점수, 운세
- ✅ Android 홈 위젯 + WorkManager
- ✅ Supabase 운세 DB 연동

### v1.1.1 업데이트 (최근 누적)

#### 1. 야간 날씨 아이콘 (v1.1.1+23~27)
- night_sunny.svg - 야간 맑음
- night-cloudy.svg - 야간 구름
- night-hazey.svg - 야간 안개
- night-hot.svg - 야간 폭염
- 자동 일출/일몰 기반 적용

#### 2. AlarmManager 기반 위젯 자동 갱신 (v1.1.1+28)
- Doze 모드에서도 30분 주기 정확 실행
- `AlarmManager.setExactAndAllowWhileIdle()` 적용
- 부팅 후 자동 재등록
- 캐시 데이터 즉시 갱신

#### 3. 강수확률 점수 차감 기준 변경 (v1.1.1+28)
```
기존: 70%↑ -40, 40%↑ -20, 20%↑ -10
변경: 90%↑ -70, 80%↑ -60, 70%↑ -50, 60%↑ -40, 미만 -0
```

#### 4. 구글 플레이 인앱 업데이트 (v1.1.1+29~30)
- 앱 시작 시 자동 업데이트 확인
- 신버전 발견 → 다이얼로그 표시
- "업데이트" 클릭 → 구글 플레이 스토어 인앱 업데이트 UI
- 백그라운드 다운로드 후 재시작 시 설치

#### 5. 백그라운드 동기화 디버그 정보 (v1.1.1+28)
- 앱정보 화면에서 확인 가능
  - 마지막 시도: bg_last_attempt
  - 마지막 성공: bg_last_success
  - 마지막 에러: bg_last_error

---

## 🔧 기술 스택

| 구분 | 내용 |
|---|---|
| **Flutter** | 3.8.0+ |
| **Dart** | 3.8.0 |
| **Android SDK** | 36 (컴파일), API 24+ (최소) |
| **핵심 라이브러리** | Riverpod 2.6.1, go_router 14.6.2, Supabase 2.8.0 |
| **위젯/백그라운드** | home_widget 0.7.0, workmanager 0.9.0, in_app_update 4.2.2 |
| **광고** | Google Mobile Ads 5.1.0 |

---

## 📋 출시 체크리스트

### Google Play Console 업로드
- [ ] app-release.aab 업로드
- [ ] 스크린샷 최신화 (필요시)
- [ ] 릴리즈 노트 작성
  ```
  야간 날씨 아이콘 추가
  위젯 자동 갱신 개선 (Doze 모드 대응)
  강수확률 기준 조정
  인앱 업데이트 기능 추가
  ```
- [ ] 타겟 API 레벨: 36 확인
- [ ] 버전: 1.1.1+30 확인

### 테스트 (내부 테스터 트랙)
- [ ] Internal Testing 트랙에 먼저 배포
- [ ] 기기 테스트: 
  - S908N (Android 16, API 36) ✓
  - S928N (Android 14, API 34) — 연결 필요
- [ ] 인앱 업데이트 기능 검증
  - 구글 플레이 Console에서 더 높은 버전으로 새 버전 등록
  - 앱 실행 시 업데이트 다이얼로그 표시 확인
  - "업데이트" 클릭 → 구글 플레이 UI 진행 확인

### 출시 (Production)
- [ ] Internal Testing에서 1주 검증 완료
- [ ] Production 트랙으로 승격
- [ ] Rollout 설정 (예: 25% → 50% → 100%)

---

## 🗂️ 빌드 경로

```
build/app/outputs/
├── flutter-apk/
│   └── app-release.apk          ← 테스트/직접 설치용
└── bundle/release/
    └── app-release.aab          ← Google Play Store 배포용
```

---

## 📝 참고사항

### in_app_update 제한사항
- **프로덕션만 작동**: Google Play Store에 배포된 앱에서만 동작
- **테스트 환경**: APK 직접 설치 시 업데이트 기능 테스트 불가
- **테스트 방법**: Google Play Console 내부 테스터 트랙 사용

### AlarmManager 권한
- AndroidManifest.xml에 `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM` 등록 ✓
- 삼성 기기 배터리 최적화: 사용자가 앱 설정에서 수동 해제 필요

### 다국어 상태
- ✅ 한국어 (ko): 완성


---
---

**빌드 완료:** 2026-05-04 12:13 KST  
**준비 상태:** 🟢 Google Play Console 배포 준비 완료
