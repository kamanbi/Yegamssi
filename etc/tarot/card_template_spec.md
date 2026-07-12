# 타로 카드 표준 스펙 (card_template_spec)

> 기준: `assets/images/tarot/major_00_fool.png` | 확정일: 2026-07-03
> QA 스크립트: `.claude/skills/tarot-card-pipeline/scripts/tarot_qa.py`

## 고정 요소 (구조 — 위반 시 불합격)

| 항목 | 값 |
|---|---|
| 크기 | 1024 x 1536 px (2:3), RGB |
| 카드 형태 | 라운드 사각 카드, 이중 금선 테두리 |
| 모서리 장식 | 한국 전통 매듭/꽃/격자 문양 |
| 상단 메달리온 | 중심 x=0.5w, 영역 y 0.6%~7.2%h 내 원형 장식 |
| 하단 메달리온 | 중심 x=0.5w, 영역 y 92.8%~99.4%h 내 원형 장식 |
| 명판 | 하단 크림 라운드 박스, 검사 영역 x 30~70%w, y 88.5~94%h |
| 제목 | 대문자 세리프 영문 (`THE FOOL` 형식), 명판 중앙 |
| 그림체 | 수채 동양화풍, 치비 비율 캐릭터, 금선, 부드러운 채도 |

## 가변 요소 (카드 맥락별 허용)

- 테두리/외곽 배경 색 (예: Death=미드나잇 블루, Hierophant=옥색/상아)
- 명판·제목 잉크 색
- 메달리온 내부 문양 (예: Fool=물방울, Tower=번개, Hierophant=연꽃)

## 예외

- `card_back.png`: 명판·제목 없음 (QA에서 plaque 검사 면제)

## QA 임계값 (2026-07-03 캘리브레이션)

합격군 13장(표준 9 + 승인 후보 4) 실측 기반. 원본: `build/tarot_qa_calibration.txt`

| 지표 | 임계값 | 합격군 실측 범위 |
|---|---|---|
| medallion detail (휘도 stddev) | ≥ 25.0 | 36.1 ~ 84.1 |
| plaque brightness (휘도 평균) | ≥ 150.0 | 170.7 ~ 216.8 |
| plaque contrast (휘도 stddev) | ≥ 40.0 | 53.3 ~ 83.8 |

임계값 변경 시 이 문서와 `tarot_qa.py`의 `TH` 상수를 함께 갱신할 것.
