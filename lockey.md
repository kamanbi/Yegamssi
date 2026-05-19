# 📌 프로젝트명
Weather-Based Fortune App

---

# 1. 개요

본 서비스는 사용자의 생년월일 기반 명리학 분석과 기상청 날씨 데이터를 결합하여
개인 맞춤형 운세를 생성하는 시스템이다.

핵심 구조:

개인 사주 + 오늘 운 + 날씨 = 최종 운세

---

# 2. 핵심 기능

## 2.1 입력
- 생년월일
- 출생 시간 (옵션)
- 언어 (ko / en)

---

## 2.2 출력

- 종합 운세 (1개)
- 개별 운세 (5개)
  - 재물운
  - 연애운
  - 직장운
  - 컨디션
  - 결정운

---

# 3. 시스템 구조

[사주 계산]
→ [오늘 간지 계산]
→ [기본 점수 계산]
→ [날씨 API]
→ [점수 보정]
→ [멘트 생성]

---

# 4. 점수 시스템

## 4.1 기본 점수

- 상생: +20
- 동일: +10
- 중립: 0
- 상극: -20
- 충돌: -40

---

## 4.2 날씨 보정

- 맑음 → 화
- 비 → 수
- 흐림 → 토

보정 규칙:
- 부족 오행 보완 → +점수
- 과다 오행 강화 → -점수

---

# 5. 데이터베이스 구조

## 테이블: fortune_fragments

| 컬럼 | 설명 |
|------|------|
| id | PK |
| type | intro / state / effect / action |
| category | overall / love / money / work / health / decision |
| condition | water_high 등 |
| weather | rain 등 |
| score_min | 최소 점수 |
| score_max | 최대 점수 |
| lang | ko / en |
| text | 멘트 |
| weight | 가중치 |

---

# 6. 멘트 생성 구조

문장은 조각 기반으로 생성한다.

구조:

intro + state + weather + effect + action

---

# 7. 데이터 조회 전략

각 요소를 개별 조회 후 조합한다.

- 상태 → condition 기반
- 날씨 → weather 기반
- 점수 → score_range 기반
- 행동 → category 기반

---

# 8. API 응답 구조

```json
{
  "score": 55,
  "overall": "...",
  "money": "...",
  "love": "...",
  "work": "...",
  "health": "...",
  "decision": "..."
}