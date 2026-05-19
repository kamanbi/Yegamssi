import csv
from collections import Counter, defaultdict
from pathlib import Path


SOURCE_PATH = Path("etc/fortune_styles/fortune_ko_ai.csv")
OUTPUT_PATH = SOURCE_PATH
EXPECTED_COLUMNS = ["code", "type", "text", "weight"]

HUMAN_TONE_BLOCKLIST = [
    "괜히",
    "네가",
    "귀찮아도",
    "폼 잡다",
    "아닌 척",
    "놓치지 마",
    "나중에 딴소리",
    "대충",
    "흘려듣지 마",
    "챙겨",
    "끝까지 확인은 해",
    "그래도 된다",
    "진짜",
    "흥",
]

AI_REQUIRED_TERMS = [
    "AI",
    "분석",
    "데이터",
    "지표",
    "확률",
    "리스크",
    "변수",
    "신호",
    "모델",
    "판정",
    "예측",
    "권장",
    "검증",
    "우선순위",
    "최적",
    "기준",
]

CATEGORY = {
    "overall": {
        "label": "종합운세",
        "metric": "하루 흐름 지표",
        "target": "오늘의 전체 판단",
        "axis": "일정, 컨디션, 관계 변수",
    },
    "money": {
        "label": "금전운",
        "metric": "재무 안정 지표",
        "target": "지출과 수입 판단",
        "axis": "현금 흐름, 충동 지출, 거래 변수",
    },
    "love": {
        "label": "애정운",
        "metric": "관계 반응 지표",
        "target": "대화와 감정 표현",
        "axis": "거리감, 반응 속도, 표현 변수",
    },
    "work": {
        "label": "업무운",
        "metric": "업무 성과 지표",
        "target": "업무 처리와 작업 판단",
        "axis": "집중도, 일정, 작업 변수",
    },
    "health": {
        "label": "건강운",
        "metric": "컨디션 안정 지표",
        "target": "활동량과 휴식 판단",
        "axis": "체력, 회복, 과부하 변수",
    },
    "decision": {
        "label": "결정운",
        "metric": "의사결정 신뢰 지표",
        "target": "선택과 보류 판단",
        "axis": "근거, 직관, 외부 변수",
    },
}

TIER = {
    "A": {
        "band": "최상위",
        "score": "92",
        "intro": "상위 안정 구간",
        "state": "긍정 신호가 우세하고 실행 저항이 낮습니다",
        "effect": "기대값이 높고 결과 변동폭은 관리 가능한 수준입니다",
        "action": "핵심 선택은 오늘 처리하는 편을 권장합니다",
        "guard": "최종 확인 절차만 유지하면 충분합니다",
        "risk": "낮은 리스크",
    },
    "B": {
        "band": "양호",
        "score": "78",
        "intro": "양호한 유지 구간",
        "state": "안정 신호가 유지되지만 일부 보정 변수가 있습니다",
        "effect": "평균 이상의 결과를 기대할 수 있으나 과속은 리스크를 높입니다",
        "action": "기존 계획은 진행하되 확인 단계를 짧게 추가하세요",
        "guard": "새로운 확장은 범위를 제한하는 편이 안전합니다",
        "risk": "관리 가능한 리스크",
    },
    "B1": {
        "band": "보통 이상",
        "score": "64",
        "intro": "보수적 실행 구간",
        "state": "안정 지표와 경계 지표가 동시에 감지됩니다",
        "effect": "무리하지 않으면 손실 확률을 낮출 수 있습니다",
        "action": "작은 단위의 실행과 재확인을 권장합니다",
        "guard": "결정 범위보다 검증 밀도를 높이세요",
        "risk": "중간 이하 리스크",
    },
    "B2": {
        "band": "중립",
        "score": "56",
        "intro": "중립 관찰 구간",
        "state": "확신 지표가 강하지 않아 추가 기준이 필요합니다",
        "effect": "결과 오차가 커질 수 있어 단정 판단은 비효율적입니다",
        "action": "진행하더라도 예비안을 함께 두는 편을 권장합니다",
        "guard": "즉시 판단보다 기준표를 먼저 확인하세요",
        "risk": "중립 리스크",
    },
    "C": {
        "band": "주의",
        "score": "44",
        "intro": "주의 구간",
        "state": "오류 가능성과 변수 민감도가 함께 상승합니다",
        "effect": "작은 누락도 결과 예측을 흔들 수 있습니다",
        "action": "중요한 선택은 한 단계 낮춰 검토하는 편이 좋습니다",
        "guard": "실행보다 점검과 정리를 우선순위로 두세요",
        "risk": "상승 리스크",
    },
    "C1": {
        "band": "낮음",
        "score": "31",
        "intro": "대응률 경계 구간",
        "state": "리스크 신호가 우세하고 회복 지표는 제한적입니다",
        "effect": "성급한 실행은 손실 확률을 높일 수 있습니다",
        "action": "핵심 결정은 보류하고 최소 대응만 권장합니다",
        "guard": "새로운 시도보다 기존 문제 제거가 우선입니다",
        "risk": "높은 리스크",
    },
    "C2": {
        "band": "낮음",
        "score": "26",
        "intro": "대응률 관망 구간",
        "state": "불안정 변수의 영향력이 기준값을 넘어섭니다",
        "effect": "진행 대비 보상값이 낮아질 가능성이 큽니다",
        "action": "일정과 선택지를 줄이고 회복 시간을 확보하세요",
        "guard": "오늘은 확장보다 방어적 관리가 적합합니다",
        "risk": "높은 변동 리스크",
    },
    "D": {
        "band": "최저",
        "score": "18",
        "intro": "최저 안정성 구간",
        "state": "부정 신호가 우세하고 오류 허용 범위가 좁습니다",
        "effect": "무리한 실행은 손실과 연속 부담을 키울 수 있습니다",
        "action": "중요 결정은 다음 주기로 넘기고 최소 대응만 하세요",
        "guard": "회복과 리스크 차단을 최우선 기준으로 두세요",
        "risk": "매우 높은 리스크",
    },
}

ELEMENT = {
    "mok": "확장 변수",
    "hwa": "속도 변수",
    "to": "안정 변수",
    "geum": "정리 변수",
    "su": "유동 변수",
    "": "기본 변수",
}

STRENGTH = {
    "df": "절제형 패턴",
    "ex": "과열형 패턴",
    "": "기본 패턴",
}

WEATHER = {
    "earth": "중립 환경",
    "fire": "과열 환경",
    "water": "감정 환경",
    "wood": "변화 환경",
    "": "기본 환경",
}

TYPE_VARIANTS = {
    "intro": [
        "AI 분석 기준, {label}의 {metric} 기준값은 {band}로 판정됩니다.",
        "오늘의 예측 모델은 {target}을 {band} 신호로 분류합니다.",
        "{label} 데이터는 {score}점 기준의 {band} 패턴에 가깝습니다.",
        "현재 입력값을 종합하면 {label}은 {intro}입니다.",
    ],
    "state": [
        "{element}와 {weather}이 함께 반영되어 {state}.",
        "{strength}이 작동하면서 {axis}의 민감도가 조정됩니다.",
        "실시간 변수 조합은 {element}, {strength}, {weather} 순서로 가중됩니다.",
        "{axis}를 종합하면 현재 상태는 {state}.",
    ],
    "effect": [
        "예측 결과, {target}에는 다음 판단이 적용됩니다. {effect}.",
        "{metric} 변화가 {target}에 반영됩니다. {effect}.",
        "현재 신호가 유지되면 {target}에서 다음 결과가 예상됩니다. {effect}.",
        "리스크 모델은 {axis}를 기준으로 {target}의 오차 범위를 재계산합니다.",
    ],
    "action": [
        "{action}. {guard}.",
        "{target}은 {action}. {guard}.",
        "우선순위 기준으로는 {action}. {guard}.",
        "오늘의 권장값은 {action}. {guard}.",
    ],
}

CONTEXT_VARIANTS = [
    "분석 기준은 {element}, {strength}, {weather}입니다.",
    "보정값은 {element}와 {weather}을 우선 반영했습니다.",
    "{strength}은 보조 신호로 적용했습니다.",
    "세부 모델은 {label} {band} 구간의 {risk}를 기준으로 계산했습니다.",
]

SECOND_OCCURRENCE_VARIANTS = [
    "동일 조건의 보조 시나리오에서는 검증 단계를 한 번 더 둡니다.",
    "반복 신호가 감지되어 보수 가중치를 소폭 반영했습니다.",
    "동일 점수대의 대체 모델도 같은 방향을 제시합니다.",
    "추가 데이터가 들어와도 기본 판정은 크게 흔들리지 않습니다.",
]


def read_rows() -> list[dict[str, str]]:
    with SOURCE_PATH.open(encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        if reader.fieldnames != EXPECTED_COLUMNS:
            raise ValueError(f"unexpected columns: {reader.fieldnames}")
        return list(reader)


def parse_code(code: str) -> dict[str, str]:
    parts = code.split("_")
    return {
        "category": parts[0],
        "tier": parts[1] if len(parts) > 1 else "C",
        "element": parts[2] if len(parts) > 2 else "",
        "strength": parts[3] if len(parts) > 3 else "",
        "weather": parts[4] if len(parts) > 4 else "",
    }


def text_for(row: dict[str, str], occurrence: int, row_index: int) -> str:
    info = parse_code(row["code"])
    category = CATEGORY[info["category"]]
    tier = TIER[info["tier"]]
    text_type = row["type"]
    context = {
        **category,
        **tier,
        "element": ELEMENT.get(info["element"], "복합 변수"),
        "strength": STRENGTH.get(info["strength"], "복합 패턴"),
        "weather": WEATHER.get(info["weather"], "복합 환경"),
        "axis": category["axis"],
    }

    main_template = TYPE_VARIANTS[text_type][(row_index + occurrence) % len(TYPE_VARIANTS[text_type])]
    context_template = CONTEXT_VARIANTS[(row_index + len(row["code"])) % len(CONTEXT_VARIANTS)]
    parts = [
        main_template.format(**context),
        context_template.format(**context),
        (
            f"기준값은 {category['label']}/{tier['band']}/"
            f"{context['element']}/{context['strength']}/{context['weather']}입니다."
        ),
    ]
    if occurrence:
        parts.append(SECOND_OCCURRENCE_VARIANTS[(row_index + occurrence) % len(SECOND_OCCURRENCE_VARIANTS)])
    return " ".join(parts)


def regenerate_rows(rows: list[dict[str, str]]) -> list[dict[str, str]]:
    occurrences: defaultdict[tuple[str, str], int] = defaultdict(int)
    regenerated: list[dict[str, str]] = []
    for row_index, row in enumerate(rows):
        key = (row["code"], row["type"])
        occurrence = occurrences[key]
        occurrences[key] += 1
        regenerated.append({**row, "text": text_for(row, occurrence, row_index)})
    return regenerated


def validate_rows(rows: list[dict[str, str]]) -> None:
    texts = [row["text"] for row in rows]
    duplicate_texts = [text for text, count in Counter(texts).items() if count > 1]
    if duplicate_texts:
        raise ValueError(f"duplicate texts: {len(duplicate_texts)}")

    blocked_rows = [
        row
        for row in rows
        if any(blocked in row["text"] for blocked in HUMAN_TONE_BLOCKLIST)
    ]
    if blocked_rows:
        examples = [row["text"] for row in blocked_rows[:5]]
        raise ValueError(f"human tone fragments found: {len(blocked_rows)} {examples}")

    non_ai_rows = [
        row
        for row in rows
        if not any(term in row["text"] for term in AI_REQUIRED_TERMS)
    ]
    if non_ai_rows:
        examples = [row["text"] for row in non_ai_rows[:5]]
        raise ValueError(f"missing AI terms: {len(non_ai_rows)} {examples}")

    low_tiers = {"C", "C1", "C2", "D"}
    high_tiers = {"A", "B", "B1"}
    low_with_high_phrase = [
        row for row in rows
        if parse_code(row["code"])["tier"] in low_tiers
        and any(phrase in row["text"] for phrase in ["최상위", "기대값이 높고", "양호"])
    ]
    high_with_low_phrase = [
        row for row in rows
        if parse_code(row["code"])["tier"] in high_tiers
        and any(phrase in row["text"] for phrase in ["최저", "매우 높은 리스크", "최소 대응만"])
    ]
    if low_with_high_phrase or high_with_low_phrase:
        raise ValueError(
            f"tier mismatch: low={len(low_with_high_phrase)} high={len(high_with_low_phrase)}"
        )


def write_rows(rows: list[dict[str, str]]) -> None:
    with OUTPUT_PATH.open("w", encoding="utf-8", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=EXPECTED_COLUMNS)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    rows = read_rows()
    regenerated = regenerate_rows(rows)
    validate_rows(regenerated)
    write_rows(regenerated)

    tier_counts = Counter(parse_code(row["code"])["tier"] for row in regenerated)
    type_counts = Counter(row["type"] for row in regenerated)
    print(f"regenerated rows={len(regenerated)} unique_texts={len(set(row['text'] for row in regenerated))}")
    print(f"tier_counts={dict(sorted(tier_counts.items()))}")
    print(f"type_counts={dict(sorted(type_counts.items()))}")


if __name__ == "__main__":
    main()
