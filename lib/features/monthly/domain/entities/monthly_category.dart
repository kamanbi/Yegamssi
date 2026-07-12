// 월간 예감씨 카테고리 — 각 카테고리의 담당 오행/신살 규칙은 monthly_day_scorer에서 분기 처리
enum MonthlyCategory {
  love, // 연애 — 화·목, 도화 가점
  work, // 일 — 금·토
  money, // 돈 — 토·금, 재성 일진 가점
  relationship, // 관계 — 화·목, 도화 미적용(연애와 분리), 합 가점
  health, // 건강 — 수·목, 충 감점
  decision, // 결정 — 금
  travel; // 이동/외출 — 역마 가점 중심, 오행 보조
}
