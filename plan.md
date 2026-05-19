# 계획: 날씨 상세 페이지 원복 및 점검

## 완료한 원복
- `AppRoutes.weatherDetail` 제거
- 상세 날씨 라우트 제거
- 날씨 화면 박스 클릭 이동 제거
- 상세 날씨 화면 파일 제거
- 예특보 provider 제거
- 예특보 데이터 소스 제거
- 예특보 요약 entity 제거

## 점검 목표
- 기존 날씨 화면 동작을 유지한다.
- 불필요한 import, 미사용 라우트, 삭제된 파일 참조가 남지 않게 한다.
- 전체 정적분석 오류를 제거한다.
- 릴리즈 빌드는 사용자 요청 시에만 진행한다.

## 후속 설계 원칙
1. 상세 날씨는 기존 화면에 직접 섞지 않고 별도 화면과 provider로 분리한다.
2. 예특보는 위치별 특보 구역 매칭 방식을 먼저 확정한 뒤 붙인다.
3. 바다낚시지수와 물때는 해양/낚시 기능으로 별도 설계한다.
4. API 실패 시 전체 화면 실패가 아니라 섹션 단위 fallback으로 처리한다.

## 가독성 5칙
- Early Return: API 실패 시 섹션 단위로 빠르게 fallback 처리한다.
- Contextual Naming: `WeatherDetailSnapshot`, `WarningSummary`, `FishingIndexSummary`처럼 기능별 책임을 분리한다.
- Magic Number Hunter: 갱신 주기, 예보 표시 개수, 캐시 TTL은 상수화한다.
- Parameter Object: 좌표, 격자, 위치명, 강제 갱신 여부는 요청 객체로 묶는다.
- Complexity Check: 현재 원복 후 구조 가독성 84/100, 상세/해양 기능 분리 설계 시 목표 90/100.

## 검증 기준
- `dart format` 완료
- `flutter analyze` 통과
- 삭제한 상세 날씨 파일 참조 없음
