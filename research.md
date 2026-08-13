# 바다낚시 고도화 — 경쟁 앱(어신) 분석 및 현재 구조 점검

## 조사 배경
- 조사일: 2026-08-13
- 목적: 실기기에 설치된 낚시 앱 "어신"(패키지 `io.sgma.uhshin`, 버전 3.30.15, 운영사 SGMA/브랜드 US-IN)을 실행·정적 분석하여 예감씨 활동예감의 바다낚시 고도화 방향을 도출
- 방법: 실기기 UI 조작(온보딩~홈~지도), APK 정적 분석(base.apk + split_config.arm64_v8a.apk 내 classes.dex, libapp.so 문자열 추출), 예감씨 현재 바다낚시 코드 대조

## 어신 앱 구조 요약

### 기술 스택
- **Flutter 기반**(libapp.so에 `docs.flutter.dev`, flutter github 이슈 문자열 존재) — 예감씨와 동일 프레임워크
- Firebase(Analytics, Remote Config, Storage, Installations), Google Mobile Ads/Ad Manager(DFP)
- Datadog APM(`libdatadog-native-lib.so`) — 유료 모니터링, 자체 앱 안정성 관리용(공개 API 아님)
- TensorFlow Lite(`libtensorflowlite_*.so`) — 온디바이스 ML, 추정컨대 "피싱그램"(조과 사진) 관련 이미지 처리
- NICE 본인인증(`nice.checkplus.co.kr`), 토스페이먼츠(`js.tosspayments.com`) — 로그인/결제, 커머스(청약몰) 기능용

### 사용 지도/해양 데이터 소스 (정적 문자열에서 확인)
| 도메인/키워드 | 성격 | 무료 여부 |
|---|---|---|
| `www.khoa.go.kr/oceanmap/...ServiceKey=BEA63B387CE...` | 국립해양조사원 바다지도 WMS/WMTS 타일 | **무료**(공공데이터포털 오픈API, 코드에 서비스키 하드코딩 확인) |
| `api.vworld.kr/req/wmts/...` | 국토교통부 브이월드 배경지도 | **무료**(공공 오픈API) |
| `api.maptiler.com/...` | MapTiler 지도 타일(위성/음영) | **유료**(무료 티어 존재, 배경 디자인용) |
| `tile.openstreetmap.org` | OSM 타일 | 무료(fallback으로 추정) |
| `geo.uhshin.com` | 자체 지오코딩 서버 | 자체 인프라 |
| 문자열 `khoa/now`, `khoaMapRequest`, `khoaVisualMapLayers` | 자체 API 경로 조각 | 자체 백엔드가 KHOA 데이터를 프록시하는 구조로 추정(예감씨 weather-proxy와 동일 패턴) |
| `admin.uhshin.com` | 자체 CMS(공지/게시물) | 자체 인프라 |

핵심 조황/기상 데이터를 반환하는 **메인 API 베이스 도메인은 정적 문자열에서 노출되지 않음**(빌드타임 환경변수 주입 또는 문자열 분할로 추정) — 예감씨의 `weather-proxy` Edge Function처럼 자체 서버가 앞단에서 여러 공공/상용 소스를 조합해 클라이언트에는 자체 API만 노출하는 구조로 판단됨.

### 화면/데이터 항목 (실기기 UI 확인)

**홈**: 오늘의 물때(음력 날짜, 물때 수, 동/서/남해 각각 물때), 즐겨찾기 포인트 바로가기, 사용자 등급(게이미피케이션: "그린피쉬 Lv.7"), 피싱 매거진, 파트너스(선상 예약) 배너

**포인트 상세**(마케팅 프리뷰로 구조 확인, 독도 예시):
- 3시간 간격 타임라인(09/12/15/18/21시): 환경 종합등급(보통/나쁨/위험), 날씨 아이콘, 기온, 강수량, **풍속+풍향(화살표)**, **파고**, **수온**
- 일출/일몰 시각
- **물때**: N물(간만조식), **시:분 단위 만조/간조 4회 시각 + 조위(cm) + 전일 대비 변화(±)**, 조위 변화 그래프(시각화)
- **수심**(평균), **저질**(바위/모래 등 해저 지형)
- 메모, 물때달력 버튼

### 자체 정적 자산(공공데이터 가공, API 호출 없음)
`flutter_assets/assets/json/`에 번들:
- `bait_rate_fishes.json` — 어종별 **해역코드(EAST01~03/SOUTH01~03 등) × 시기(월 2구간, 24구간) 활동성 매트릭스**(0/1/2 등급). 자체 편집·통계 데이터로 추정(공공API 아님)
- `inhibition_fish.json` — 어종별 **포획금지기간**(수산자원관리법 시행령 근거로 추정)
- `release_fish.json` — 어종별 **금지체장(방류 크기)**(동법 근거)
- `forbidden_words.json` — 커뮤니티 금칙어

이 세 자산은 **정적 JSON을 앱에 번들**하는 방식으로, API 호출 없이 무료로 제공 가능한 정보다.

## 예감씨 현재 바다낚시 구현 현황

- 계산 버전: `activity-v5`([activity_judgment_calculator.dart:8](lib/features/activity_forecast/domain/activity_judgment_calculator.dart))
- 사용 API: **`fcstFishingv2`(국립수산과학원 바다낚시지수) 단 1개**([sea_fishing_data_source.dart:10](lib/features/activity_forecast/data/sea_fishing_data_source.dart))만 실제로 호출됨. 응답 필드(officialIndex, maxWaveHeightM, maxWindSpeedMs, maxWaterTemperatureC, tideDescription 문자열)만으로 채점
- weather-proxy `allowedPaths`에는 조석(`tideFcstHghLw`), 조류(`crntFcstFldEbb`), ROMS 수온/염분(`roms`), 실시간 부이(`twRecent`), 파고(`noonWave`) 등 **5개 KHOA API가 이미 등록되어 있으나, Dart 클라이언트 코드 어디에서도 호출되지 않음**(그렙 결과 0건) — 인프라만 준비되고 미통합 상태
- `tideDescription`은 `fcstFishingv2` 응답의 `tdlvHrCn` 문자열 필드를 그대로 표시하는 수준으로, 어신처럼 **시:분 단위 만조/간조 시각 + 조위(cm) 그래프**는 없음
- 풍향, 저질(해저지형), 수심 정보 없음
- 어종별 금어기/금지체장/조황 활성도 같은 정적 참고자료 없음

## 갭 분석 요약

| 항목 | 어신 | 예감씨 현재 | 격차 |
|---|---|---|---|
| 조석(물때) | 시:분 단위 만조/간조 4회 + 조위(cm) + 그래프 | 텍스트 요약(`tdlvHrCn`) | 큼 — API는 이미 프록시에 등록됨(`tideFcstHghLw`), 미사용 |
| 파고/풍속/풍향 | 3시간 간격 시계열 + 풍향 화살표 | 일 최댓값만 | 중 — `noonWave` 프록시 등록, 미사용. 풍향은 원천 API에 없을 수 있어 확인 필요 |
| 수온 | 3시간 간격 시계열 | 일 최고값(문자열) | 중 — `roms`/`twRecent` 프록시 등록, 미사용 |
| 조류(유속/유향) | 불명(미확인) | 없음 | `crntFcstFldEbb` 프록시 등록, 미사용 |
| 저질(해저지형)/수심 | 있음 | 없음 | 공공API에서 확보 어려움(별도 조사 필요) — 후순위 |
| 어종별 금어기/금지체장 | 정적 자산 번들 | 없음 | 작음 — 무료, 정적 자산만으로 구현 가능 |
| 어종별 조황 활성도(계절) | 정적 자산 번들(자체 통계) | 없음 | 자체 데이터 큐레이션 필요, API 불필요 |
| 지도 기반 포인트 탐색 | KHOA/VWorld 무료 타일 + MapTiler 유료 배경 | 목록/검색 UI만(지도 없음) | 큼 — 별도 스코프 판단 필요 |

## 참고 근거
- 국립수산과학원 바다낚시지수 API: 예감씨 이미 사용 중(`fcstFishingv2`)
- 국립해양조사원(KHOA) 픚수 데이터: `tideFcstHghLw`(조석예보), `crntFcstFldEbb`(조류예보), `roms`(해양예측모델), `twRecent`(실시간 수온), `noonWave`(파고) — 공공데이터포털(data.go.kr) 오픈API, 무료, 예감씨 weather-proxy에 이미 등록·TTL 설정됨
- 해양수산부 수산자원관리법 시행령 — 포획금지기간/금지체장 별표(공공정보, 무료)
- 어신 KHOA 바다지도 오픈API(`www.khoa.go.kr/oceanmap`) — 무료, ServiceKey 발급 필요(코드 내 노출된 키는 어신 소유이므로 재사용 불가, 예감씨는 별도 발급 필요)
