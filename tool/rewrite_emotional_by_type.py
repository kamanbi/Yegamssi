import csv
from collections import Counter, defaultdict
from pathlib import Path


TARGET_PATH = Path("etc/fortune_styles/fortune_ko_emotional.csv")
EXPECTED_COLUMNS = ["code", "type", "text", "weight"]

CATEGORY = {
    "decision": {
        "name": "결정운",
        "subject": "판단",
        "area": "선택",
        "good_action": ["오래 붙잡던 문제를 정리해보세요", "미뤄둔 결정을 조용히 꺼내보세요", "마음속 결론을 한 번 행동으로 옮겨보세요"],
        "mid_action": ["기준을 다시 세워보세요", "선택지를 조금 줄여보세요", "잠깐 멈춰 생각을 정리해보세요"],
        "bad_action": ["큰 결정은 잠시 미뤄두세요", "서둘러 답을 내리지 마세요", "확신 없는 선택은 피해주세요"],
    },
    "health": {
        "name": "건강운",
        "subject": "컨디션",
        "area": "몸 상태",
        "good_action": ["가벼운 활동을 시작해보세요", "몸을 조금 더 움직여보세요", "미뤄둔 운동을 짧게 해보세요"],
        "mid_action": ["몸 상태를 먼저 살펴보세요", "무리하지 않고 일상을 유지해보세요", "잠깐 쉬어가며 움직여보세요"],
        "bad_action": ["휴식을 먼저 챙겨주세요", "무리한 활동은 줄여주세요", "몸의 신호를 넘기지 말아주세요"],
    },
    "love": {
        "name": "애정운",
        "subject": "마음",
        "area": "관계",
        "good_action": ["먼저 말을 건네보세요", "진심을 가볍게 표현해보세요", "상대의 반응을 조금 믿어보세요"],
        "mid_action": ["말의 온도를 낮춰보세요", "관계를 천천히 살펴보세요", "상대의 속도에 맞춰보세요"],
        "bad_action": ["감정적인 말은 아껴주세요", "무리해서 가까워지려 하지 마세요", "오해가 생길 말은 피해 주세요"],
    },
    "money": {
        "name": "금전운",
        "subject": "돈의 흐름",
        "area": "재정",
        "good_action": ["준비한 거래를 차분히 검토해보세요", "작은 수익 기회를 살펴보세요", "미뤄둔 정산을 마무리해보세요"],
        "mid_action": ["지출 기준을 다시 봐주세요", "필요한 것과 아닌 것을 나눠보세요", "큰돈보다 작은 관리에 집중해보세요"],
        "bad_action": ["충동 지출은 막아주세요", "큰 결제는 잠시 미뤄주세요", "돈 나갈 일은 최대한 줄여주세요"],
    },
    "overall": {
        "name": "종합운",
        "subject": "하루의 분위기",
        "area": "오늘 하루",
        "good_action": ["미뤄둔 일을 하나 처리해보세요", "평소보다 조금 적극적으로 움직여보세요", "좋은 기회를 조용히 붙잡아보세요"],
        "mid_action": ["일정을 단순하게 정리해보세요", "평소 루틴을 유지해보세요", "욕심내지 않고 하루를 보내보세요"],
        "bad_action": ["일을 크게 벌이지 마세요", "무리한 약속은 줄여주세요", "조용히 지나가는 쪽을 택해보세요"],
    },
    "work": {
        "name": "업무운",
        "subject": "일의 흐름",
        "area": "업무",
        "good_action": ["중요한 일을 먼저 처리해보세요", "성과가 보이는 일에 집중해보세요", "미뤄둔 보고를 마무리해보세요"],
        "mid_action": ["일의 순서를 다시 정해보세요", "확인할 것을 먼저 챙겨보세요", "속도보다 정확도를 잡아보세요"],
        "bad_action": ["새 일을 벌이지 마세요", "실수하기 쉬운 부분을 다시 봐주세요", "혼자 밀어붙이지 말아주세요"],
    },
}

TIER = {
    "A": {"bucket": "good", "intro": "부드럽게 열려", "tone": "한결 가벼운", "effect": "기대보다 편안한 결과"},
    "B": {"bucket": "good", "intro": "무난히 좋은 쪽으로 기울어", "tone": "안정적인", "effect": "작지만 반가운 변화"},
    "B1": {"bucket": "good", "intro": "조금씩 힘이 붙어", "tone": "차분히 살아나는", "effect": "부담을 덜어주는 변화"},
    "B2": {"bucket": "mid", "intro": "평소와 크게 다르지 않아", "tone": "보통의", "effect": "무리 없는 마무리"},
    "C": {"bucket": "bad", "intro": "조금 흔들릴 수 있어", "tone": "조심스러운", "effect": "작은 불편"},
    "C1": {"bucket": "bad", "intro": "힘이 빠질 수 있어", "tone": "느슨해지는", "effect": "예상보다 느린 반응"},
    "C2": {"bucket": "bad", "intro": "무겁게 가라앉을 수 있어", "tone": "가라앉은", "effect": "불필요한 소모"},
    "D": {"bucket": "bad", "intro": "쉽게 풀리지 않을 수 있어", "tone": "버거운", "effect": "피로한 흐름"},
}

ELEMENT = {
    "geum": {"state": "정리하려는 감각", "detail": "기준을 세우는 마음"},
    "hwa": {"state": "표현하려는 마음", "detail": "밖으로 향하는 온도"},
    "mok": {"state": "자라나려는 힘", "detail": "새롭게 뻗는 생각"},
    "su": {"state": "속마음을 살피는 감각", "detail": "안쪽에서 올라오는 느낌"},
    "to": {"state": "버티는 힘", "detail": "흔들림을 붙잡는 바탕"},
    "": {"state": "평소의 감각", "detail": "오늘의 기본 리듬"},
}

STRENGTH = {
    "df": "조심스럽게",
    "ex": "뚜렷하게",
    "": "천천히",
}

WEATHER = {
    "earth": "차분한 공기",
    "fire": "밝은 기세",
    "water": "감정의 여유",
    "wood": "움직이는 기운",
    "": "보통의 공기",
}

INTRO_TEMPLATES = [
    "오늘 {name}은 {tier_intro} 있어요.",
    "{area} 쪽 분위기가 {tier_tone} 결로 다가오는 날입니다.",
    "{subject}에 {tier_tone} 숨이 들어오는 하루예요.",
    "오늘은 {area}을 너무 급히 몰아붙이지 않아도 되는 날입니다.",
]

STATE_TEMPLATES = [
    "{element_state}이 {strength} 살아나고 {weather}도 곁을 받쳐줍니다.",
    "{element_detail}이 {strength} 자리 잡아 {subject}의 리듬을 만듭니다.",
    "{weather} 속에서 {element_state}이 천천히 방향을 잡고 있습니다.",
    "{element_detail}, {weather}도 함께 놓이며 {area}의 온도가 조금 달라집니다.",
]

EFFECT_TEMPLATES = {
    "good": [
        "{area}에서는 {tier_effect}가 생길 수 있습니다.",
        "너무 애쓰지 않아도 {subject}이 조금 편하게 풀릴 수 있어요.",
        "작은 선택이 마음을 가볍게 해주는 쪽으로 이어질 수 있습니다.",
        "기대했던 만큼은 아니어도 만족할 만한 변화가 보입니다.",
    ],
    "mid": [
        "{area}에서는 큰 변화보다 {tier_effect}가 더 잘 맞습니다.",
        "답을 빨리 정하지 않으면 오히려 마음이 편해질 수 있어요.",
        "무리하지 않는 선에서는 하루가 안정적으로 지나갑니다.",
        "{subject}의 속도를 낮추면 작은 실수를 줄일 수 있습니다.",
    ],
    "bad": [
        "{area}에서는 {tier_effect}가 생기기 쉬우니 마음의 여유가 필요합니다.",
        "서두르면 마음만 더 바빠질 수 있습니다.",
        "기대한 만큼 반응이 오지 않아도 너무 크게 받아들이지 마세요.",
        "오늘은 결과보다 소모를 줄이는 쪽이 더 중요합니다.",
    ],
}

ACTION_TEMPLATES = {
    "good": [
        "{action}, 생각보다 편하게 풀릴 수 있어요.",
        "{action}, 오늘은 조금 용기 내도 괜찮습니다.",
        "{action}, 마음이 가는 쪽으로 한 번 움직여보세요.",
        "{action}, 작은 확인만 곁들이면 충분합니다.",
    ],
    "mid": [
        "{action}, 그 정도면 충분합니다.",
        "{action}, 천천히 해도 늦지 않아요.",
        "{action}, 무리해서 잘하려 하지 않아도 됩니다.",
        "{action}, 편한 속도를 지키는 게 좋겠습니다.",
    ],
    "bad": [
        "{action}, 오늘은 쉬운 선택이 더 안전합니다.",
        "{action}, 조금 천천히 움직여도 괜찮아요.",
        "{action}, 괜찮은 척 밀어붙이지 않아도 됩니다.",
        "{action}, 나머지는 잠시 내려놓아도 됩니다.",
    ],
}


def as_sentence(text: str) -> str:
    return f"{text.rstrip(' .')}."


def merge_clause(sentence: str, clause: str) -> str:
    return as_sentence(f"{sentence.rstrip(' .')}, {clause.rstrip(' .')}")


def read_rows() -> list[dict[str, str]]:
    with TARGET_PATH.open(encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        if reader.fieldnames != EXPECTED_COLUMNS:
            raise ValueError(f"unexpected columns: {reader.fieldnames}")
        return list(reader)


def write_rows(rows: list[dict[str, str]]) -> None:
    with TARGET_PATH.open("w", encoding="utf-8-sig", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=EXPECTED_COLUMNS)
        writer.writeheader()
        writer.writerows(rows)


def parse_code(code: str) -> dict[str, str]:
    parts = code.split("_")
    return {
        "category": parts[0],
        "tier": parts[1] if len(parts) > 1 else "C",
        "element": parts[2] if len(parts) > 2 else "",
        "strength": parts[3] if len(parts) > 3 else "",
        "weather": parts[4] if len(parts) > 4 else "",
    }


def pick(values: list[str], index: int) -> str:
    return values[index % len(values)]


def context_for(row: dict[str, str], row_index: int, occurrence: int) -> dict[str, str]:
    parsed = parse_code(row["code"])
    category = CATEGORY[parsed["category"]]
    tier = TIER[parsed["tier"]]
    action_pool = category[f"{tier['bucket']}_action"]
    return {
        "name": category["name"],
        "subject": category["subject"],
        "area": category["area"],
        "tier_key": parsed["tier"],
        "tier_bucket": tier["bucket"],
        "tier_intro": tier["intro"],
        "tier_tone": tier["tone"],
        "tier_effect": tier["effect"],
        "element_state": ELEMENT[parsed["element"]]["state"],
        "element_detail": ELEMENT[parsed["element"]]["detail"],
        "strength": STRENGTH[parsed["strength"]],
        "weather": WEATHER[parsed["weather"]],
        "action": pick(action_pool, row_index + occurrence),
    }


def render(row: dict[str, str], row_index: int, occurrence: int) -> str:
    context = context_for(row, row_index, occurrence)
    text_type = row["type"]
    variant_index = row_index + occurrence * 11 + len(row["code"])
    if text_type == "intro":
        template = pick(INTRO_TEMPLATES, variant_index)
    elif text_type == "state":
        template = pick(STATE_TEMPLATES, variant_index)
    elif text_type == "effect":
        template = pick(EFFECT_TEMPLATES[context["tier_bucket"]], variant_index)
    elif text_type == "action":
        template = pick(ACTION_TEMPLATES[context["tier_bucket"]], variant_index)
    else:
        raise ValueError(f"unknown type: {text_type}")
    return template.format(**context).strip()


def rewrite(rows: list[dict[str, str]]) -> list[dict[str, str]]:
    occurrences: defaultdict[tuple[str, str], int] = defaultdict(int)
    used: Counter[str] = Counter()
    result: list[dict[str, str]] = []
    for index, row in enumerate(rows):
        key = (row["code"], row["type"])
        occurrence = occurrences[key]
        occurrences[key] += 1
        text = render(row, index, occurrence)
        if used[text]:
            context = context_for(row, index, occurrence)
            detail_templates = {
                "intro": [
                    "{name}의 {tier_key} 구간에서 {element_detail}이 중심인 흐름입니다",
                    "{area}에서 {weather}도 함께 살피면 좋은 흐름입니다",
                    "{subject}을 {strength} 살피는 편이 편안한 흐름입니다",
                ],
                "state": [
                    "{element_detail}이 {weather}와 함께 이어지는 상태입니다",
                    "{strength} 움직이는 감각이 {subject}을 붙잡아주는 상태입니다",
                    "{area} 안에서 {element_state}이 중심을 잡는 상태입니다",
                ],
                "effect": [
                    "{name}의 {tier_key} 구간에서는 이 변화가 조금 더 분명해집니다",
                    "{area} 안에서 같은 흐름이 한 번 더 확인될 수 있습니다",
                    "{subject}에는 {weather}도 영향을 줍니다",
                ],
                "action": [
                    "{area}에서는 이 선택을 먼저 두면 좋겠습니다",
                    "{subject}이 흔들리지 않게 작은 확인만 더해주세요",
                    "{element_detail}을 떠올리며 천천히 움직여보세요",
                ],
            }
            candidate = text
            retry = 0
            while used[candidate]:
                detail = pick(detail_templates[row["type"]], index + used[text] + retry)
                candidate = merge_clause(text, detail.format(**context))
                retry += 1
                if retry > len(detail_templates[row["type"]]) + 2 and used[candidate]:
                    candidate = merge_clause(
                        candidate,
                        (
                            f"{context['name']} {context['tier_key']} 단계의 "
                            f"{context['element_state']}과 {context['weather']}를 함께 보는 흐름입니다"
                        ),
                    )
                    if used[candidate]:
                        candidate = merge_clause(
                            candidate,
                            (
                                f"{context['area']}의 {context['subject']}을 "
                                f"{context['strength']} 살피는 조합입니다"
                            ),
                        )
                    break
            text = candidate
        used[text] += 1
        result.append({**row, "text": text})
    return result


def validate(before: list[dict[str, str]], after: list[dict[str, str]]) -> None:
    if len(before) != len(after):
        raise ValueError("row count changed")
    for index, (old, new) in enumerate(zip(before, after)):
        for column in ("code", "type", "weight"):
            if old[column] != new[column]:
                raise ValueError(f"{column} changed at row {index}")
    texts = [row["text"] for row in after]
    duplicates = [text for text, count in Counter(texts).items() if count > 1]
    if duplicates:
        raise ValueError(f"duplicate texts: {len(duplicates)}")
    multi_sentence = [text for text in texts if text.count(".") != 1]
    if multi_sentence:
        raise ValueError(f"multi sentence rows: {len(multi_sentence)}")
    forbidden = [
        "마음의 결",
        "작은 빛",
        "흐름을 믿으세요",
        "온기를 느껴보세요",
        "별이 머뭅니다",
        " 쪽으로 가볍게",
        "하기.",
        "검토에 마음",
        "기세이",
    ]
    found = [term for term in forbidden if any(term in text for text in texts)]
    if found:
        raise ValueError(f"forbidden terms: {found}")


def main() -> None:
    before = read_rows()
    after = rewrite(before)
    validate(before, after)
    write_rows(after)
    print(f"{TARGET_PATH.name}: rewritten rows={len(after)}")


if __name__ == "__main__":
    main()
