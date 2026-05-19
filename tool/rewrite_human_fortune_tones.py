import csv
import re
from collections import Counter, defaultdict
from pathlib import Path


ROOT = Path("etc/fortune_styles")
TARGET_FILES = {
    "emotional": ROOT / "fortune_ko_emotional.csv",
    "tsundere": ROOT / "fortune_ko_tsundere.csv",
    "cynical": ROOT / "fortune_ko_cynical.csv",
    "historical": ROOT / "fortune_ko_historical.csv",
}
EXPECTED_COLUMNS = ["code", "type", "text", "weight"]

ELEMENT_WORDS = {
    "geum": {"focus": "정리", "soft": "기준", "body": "칼끝 같은 판단", "historical": "분별의 기운"},
    "hwa": {"focus": "표현", "soft": "열기", "body": "앞으로 나서는 마음", "historical": "불의 기운"},
    "mok": {"focus": "성장", "soft": "새 길", "body": "뻗어나가려는 힘", "historical": "목의 기운"},
    "su": {"focus": "감정", "soft": "속마음", "body": "안쪽에서 흔들리는 감각", "historical": "물의 기운"},
    "to": {"focus": "안정", "soft": "바탕", "body": "버티는 힘", "historical": "토의 기운"},
    "": {"focus": "기본", "soft": "상황", "body": "평소의 리듬", "historical": "오늘의 기운"},
}

STRENGTH_WORDS = {
    "df": {"soft": "조심스럽게", "plain": "한 박자 늦게", "historical": "차분히"},
    "ex": {"soft": "뚜렷하게", "plain": "조금 빠르게", "historical": "힘 있게"},
    "": {"soft": "무난하게", "plain": "평소처럼", "historical": "평온히"},
}

WEATHER_WORDS = {
    "earth": {"soft": "차분한 공기", "plain": "가라앉은 분위기", "historical": "흙의 기운"},
    "fire": {"soft": "밝은 기세", "plain": "달아오른 분위기", "historical": "불의 기세"},
    "water": {"soft": "촉촉한 여유", "plain": "감정이 흔들리는 분위기", "historical": "물의 기운"},
    "wood": {"soft": "움직이는 기운", "plain": "변화가 빠른 분위기", "historical": "나무의 기운"},
    "": {"soft": "보통의 공기", "plain": "평범한 분위기", "historical": "일상의 기운"},
}

CATEGORIES = {
    "decision": {
        "name": "결정운",
        "subject": "판단",
        "area": "선택",
        "good": ["오래 붙잡던 문제를 정리하기", "마음속 결론을 행동으로 옮기기", "미뤄둔 결정을 꺼내보기"],
        "neutral": ["기준을 다시 세우기", "선택지를 줄이기", "잠깐 멈춰 생각 정리하기"],
        "bad": ["큰 결정을 미루기", "서둘러 답을 내지 않기", "확신 없는 선택을 피하기"],
    },
    "health": {
        "name": "건강운",
        "subject": "컨디션",
        "area": "몸 상태",
        "good": ["가벼운 활동을 시작하기", "몸을 조금 더 움직이기", "미뤄둔 운동을 해보기"],
        "neutral": ["몸 상태를 살피기", "무리하지 않고 일상 유지하기", "잠깐 쉬어가며 움직이기"],
        "bad": ["휴식을 먼저 챙기기", "무리한 활동을 줄이기", "몸의 신호를 넘기지 않기"],
    },
    "love": {
        "name": "애정운",
        "subject": "마음",
        "area": "관계",
        "good": ["먼저 말을 건네기", "진심을 가볍게 표현하기", "상대의 반응을 믿어보기"],
        "neutral": ["말의 온도를 낮추기", "관계를 천천히 살피기", "상대의 속도를 맞추기"],
        "bad": ["감정적인 말을 아끼기", "무리해서 가까워지려 하지 않기", "오해가 생길 말은 피하기"],
    },
    "money": {
        "name": "금전운",
        "subject": "돈의 흐름",
        "area": "재정",
        "good": ["준비한 거래를 검토하기", "작은 수익 기회를 살피기", "미뤄둔 정산을 처리하기"],
        "neutral": ["지출 기준을 다시 보기", "필요한 것과 아닌 것을 나누기", "큰돈보다 작은 관리에 집중하기"],
        "bad": ["충동 지출을 막기", "큰 결제를 미루기", "돈 나갈 일을 최대한 줄이기"],
    },
    "overall": {
        "name": "종합운",
        "subject": "하루의 분위기",
        "area": "오늘 하루",
        "good": ["미뤄둔 일을 하나 처리하기", "평소보다 조금 적극적으로 움직이기", "좋은 기회를 놓치지 않기"],
        "neutral": ["일정을 단순하게 정리하기", "평소 루틴을 유지하기", "욕심내지 않고 하루를 보내기"],
        "bad": ["일을 크게 벌이지 않기", "무리한 약속을 줄이기", "조용히 지나가는 쪽을 택하기"],
    },
    "work": {
        "name": "업무운",
        "subject": "일의 흐름",
        "area": "업무",
        "good": ["중요한 일을 먼저 처리하기", "성과가 보이는 일에 집중하기", "미뤄둔 보고를 마무리하기"],
        "neutral": ["일의 순서를 다시 정하기", "확인할 것을 먼저 챙기기", "속도보다 정확도를 잡기"],
        "bad": ["새 일을 벌이지 않기", "실수하기 쉬운 부분을 다시 보기", "혼자 밀어붙이지 않기"],
    },
}

TIERS = {
    "A": {"level": "high", "label": "좋은", "soft": "한결 수월한", "score": "높은"},
    "B": {"level": "good", "label": "괜찮은", "soft": "무난히 좋은", "score": "안정적인"},
    "B1": {"level": "good", "label": "괜찮은", "soft": "조금 힘이 붙는", "score": "안정적인"},
    "B2": {"level": "mid", "label": "보통의", "soft": "평범한", "score": "중간"},
    "C": {"level": "low", "label": "조심스러운", "soft": "살짝 흔들리는", "score": "낮아지는"},
    "C1": {"level": "low", "label": "조심스러운", "soft": "힘이 빠지는", "score": "낮아지는"},
    "C2": {"level": "bad", "label": "불안한", "soft": "많이 가라앉는", "score": "낮은"},
    "D": {"level": "bad", "label": "좋지 않은", "soft": "버거운", "score": "매우 낮은"},
}


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        if reader.fieldnames != EXPECTED_COLUMNS:
            raise ValueError(f"{path.name}: unexpected columns {reader.fieldnames}")
        return list(reader)


def write_rows(path: Path, rows: list[dict[str, str]]) -> None:
    # Keep a UTF-8 BOM so Windows spreadsheet tools do not misread Korean CSV as CP949.
    with path.open("w", encoding="utf-8-sig", newline="") as file:
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


def pick(options: list[str], index: int) -> str:
    return options[index % len(options)]


def tier_bucket(tier: str) -> str:
    level = TIERS[tier]["level"]
    if level in {"high", "good"}:
        return "good"
    if level == "mid":
        return "neutral"
    return "bad"


def action_item(category: dict[str, object], tier: str, index: int) -> str:
    return pick(category[tier_bucket(tier)], index)  # type: ignore[index]


def action_sentence(task: str, tone: str) -> str:
    special = {
        "마음속 결론을 행동으로 옮기기": {
            "emotional": "마음속 결론을 행동으로 옮겨보세요",
            "tsundere": "마음속 결론을 행동으로 옮겨",
            "cynical": "마음속 결론을 행동으로 옮겨라",
            "historical": "마음속 결론을 행동으로 옮기시오",
        },
        "평소보다 조금 적극적으로 움직이기": {
            "emotional": "평소보다 조금 적극적으로 움직여보세요",
            "tsundere": "평소보다 조금 적극적으로 움직여",
            "cynical": "평소보다 조금 적극적으로 움직여라",
            "historical": "평소보다 조금 적극적으로 움직이시오",
        },
        "몸 상태를 살피기": {
            "emotional": "몸 상태를 살펴보세요",
            "tsundere": "몸 상태를 살펴",
            "cynical": "몸 상태를 살펴라",
            "historical": "몸 상태를 살피시오",
        },
    }
    if task in special:
        return special[task][tone]
    endings = [
        ("해보기", {"emotional": "해보세요", "tsundere": "해봐", "cynical": "해봐라", "historical": "해보시오"}),
        ("하기", {"emotional": "하세요", "tsundere": "해", "cynical": "해라", "historical": "하시오"}),
        ("보기", {"emotional": "보세요", "tsundere": "봐", "cynical": "봐라", "historical": "보시오"}),
        ("챙기기", {"emotional": "챙기세요", "tsundere": "챙겨", "cynical": "챙겨라", "historical": "챙기시오"}),
        ("피하기", {"emotional": "피하세요", "tsundere": "피해", "cynical": "피해라", "historical": "피하시오"}),
        ("줄이기", {"emotional": "줄이세요", "tsundere": "줄여", "cynical": "줄여라", "historical": "줄이시오"}),
        ("미루기", {"emotional": "미루세요", "tsundere": "미뤄", "cynical": "미뤄라", "historical": "미루시오"}),
        ("않기", {"emotional": "않는 편이 좋습니다", "tsundere": "않는 게 나아", "cynical": "않는 게 낫다", "historical": "않는 편이 좋겠소"}),
    ]
    for ending, replacements in endings:
        if task.endswith(ending):
            return f"{task[:-len(ending)]}{replacements[tone]}"
    if task.endswith("기"):
        replacements = {
            "emotional": "세요",
            "tsundere": "",
            "cynical": "라",
            "historical": "시오",
        }
        return f"{task[:-1]}{replacements[tone]}"
    return task


def task_label(task: str) -> str:
    replacements = [
        ("해보기", "해보기"),
        ("하기", ""),
        ("보기", "보기"),
        ("챙기기", "챙기기"),
        ("피하기", "피하기"),
        ("줄이기", "줄이기"),
        ("미루기", "미루기"),
        ("않기", "않기"),
    ]
    label = task
    for ending, replacement in replacements:
        if task.endswith(ending):
            label = f"{task[:-len(ending)]}{replacement}".strip()
            break
    else:
        if task.endswith("기"):
            label = task[:-1].strip()
    cleanup = {
        "준비한 거래를 검토": "준비한 거래 검토",
        "마음속 결론을 행동으로 옮기": "마음속 결론",
        "가벼운 활동을 시작": "가벼운 활동",
        "몸 상태를 살피": "몸 상태 확인",
        "상대의 반응을 믿어": "상대 반응",
        "좋은 기회를 놓치지 않": "좋은 기회",
        "큰 결정을 미루": "큰 결정 보류",
        "일을 크게 벌이지 않": "일을 크게 벌이지 않는 것",
        "오해가 생길 말을 피하": "오해가 생길 말 피하기",
    }
    return cleanup.get(label, label)


def apply_tone_context(context: dict[str, str | int], tone: str) -> dict[str, str | int]:
    context["task_action"] = action_sentence(str(context["task"]), tone)
    context["task_label"] = task_label(str(context["task"]))
    return context


def build_context(row: dict[str, str], index: int, occurrence: int) -> dict[str, str | int]:
    parsed = parse_code(row["code"])
    category = CATEGORIES[parsed["category"]]
    tier = TIERS[parsed["tier"]]
    element = ELEMENT_WORDS[parsed["element"]]
    strength = STRENGTH_WORDS[parsed["strength"]]
    weather = WEATHER_WORDS[parsed["weather"]]
    return {
        "index": index,
        "occurrence": occurrence,
        "category_key": parsed["category"],
        "tier_key": parsed["tier"],
        "element_key": parsed["element"],
        "strength_key": parsed["strength"],
        "weather_key": parsed["weather"],
        "name": category["name"],
        "subject": category["subject"],
        "area": category["area"],
        "task": action_item(category, parsed["tier"], index + occurrence),
        "task_action": action_sentence(
            action_item(category, parsed["tier"], index + occurrence),
            "emotional",
        ),
        "tier_label": tier["label"],
        "tier_soft": tier["soft"],
        "tier_score": tier["score"],
        "level": tier["level"],
        "element_focus": element["focus"],
        "element_soft": element["soft"],
        "element_body": element["body"],
        "element_historical": element["historical"],
        "strength_soft": strength["soft"],
        "strength_plain": strength["plain"],
        "strength_historical": strength["historical"],
        "weather_soft": weather["soft"],
        "weather_plain": weather["plain"],
        "weather_historical": weather["historical"],
    }


def sentence_case(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def with_prefix(prefix: str, text: str) -> str:
    cleaned = text
    for starter in ("오늘은 ", "지금은 ", "이럴 때는 ", "이럴 땐 "):
        if cleaned.startswith(starter):
            cleaned = cleaned[len(starter):]
            break
    return sentence_case(f"{prefix} {cleaned}")


EMOTIONAL = {
    "intro": {
        "good": [
            "{name}이 오늘은 꽤 편안하게 열려 있어요",
            "{subject}에 힘이 붙는 날입니다",
            "{area} 쪽으로 작은 여유가 생길 수 있어요",
            "오늘은 {task_label}에 마음을 내봐도 괜찮습니다",
        ],
        "neutral": [
            "{name}은 무난하지만 서두를 필요는 없어요",
            "{subject}이 평소처럼 흘러가는 날입니다",
            "{area}에서는 큰 욕심보다 정리가 편합니다",
            "오늘은 {task_label} 정도가 알맞아요",
        ],
        "bad": [
            "{name}이 조금 무겁게 느껴질 수 있어요",
            "{subject}이 생각보다 쉽게 풀리지 않을 수 있습니다",
            "{area}에서는 한 걸음 늦추는 편이 편안합니다",
            "오늘은 {task_label}부터 챙기는 게 좋겠어요",
        ],
    },
    "state": {
        "good": [
            "{element_soft}이 {strength_soft} 살아나고 {weather_soft}도 부담을 덜어줍니다",
            "{element_body}이 차분하게 자리 잡아 {subject}을 도와줍니다",
            "{weather_soft} 속에서 {element_focus}의 감각이 조금 더 또렷해집니다",
            "{strength_plain} 움직여도 크게 흔들리지 않는 상태입니다",
        ],
        "neutral": [
            "{element_soft}은 남아 있지만 속도를 내기보다는 살피는 쪽이 낫습니다",
            "{weather_soft}이 지나가며 {subject}을 잠시 멈춰 세웁니다",
            "{element_body}이 약하게 움직여서 작은 확인이 필요합니다",
            "{strength_plain} 움직이면 무리 없이 지나갈 수 있습니다",
        ],
        "bad": [
            "{weather_soft}이 무겁게 깔려 {subject}이 쉽게 흔들릴 수 있습니다",
            "{element_body}이 지친 듯해 {area}에 부담이 생길 수 있어요",
            "{element_soft}이 약해져서 마음처럼 속도가 나지 않습니다",
            "{strength_plain} 쉬어가야 불필요한 소모를 줄일 수 있습니다",
        ],
    },
    "effect": {
        "good": [
            "너무 애쓰지 않아도 {area}에서 자연스럽게 풀리는 일이 생길 수 있습니다",
            "작은 선택이 생각보다 좋은 결과로 이어질 수 있어요",
            "기대했던 만큼은 아니어도 만족할 만한 변화가 보입니다",
            "{subject}을 믿고 움직이면 마음이 한결 가벼워질 수 있습니다",
        ],
        "neutral": [
            "큰 변화는 없어도 하루를 안정적으로 정리할 수 있습니다",
            "답을 빨리 정하지 않으면 오히려 편해질 수 있어요",
            "무리하지 않는 선에서는 괜찮게 지나갑니다",
            "{area}의 속도를 낮추면 작은 실수를 줄일 수 있습니다",
        ],
        "bad": [
            "서두르면 마음만 더 바빠질 수 있으니 여유가 필요합니다",
            "기대한 만큼 반응이 오지 않아도 너무 크게 받아들이지 마세요",
            "오늘은 결과보다 소모를 줄이는 쪽이 더 중요합니다",
            "{area}에서 생기는 작은 불편을 크게 키우지 않는 게 좋습니다",
        ],
    },
    "action": {
        "good": [
            "{task_action}. 생각보다 편하게 풀릴 수 있어요",
            "마음이 가는 쪽으로 한 번 움직여보세요",
            "오늘은 조금 용기 내도 괜찮습니다",
            "{task_action}. 거기에 시간을 써보면 좋겠습니다",
        ],
        "neutral": [
            "{task_action}. 그 정도면 충분합니다",
            "답을 급히 정하기보다 하루를 가볍게 정리해보세요",
            "무리해서 잘하려 하기보다 편한 속도를 지켜보세요",
            "{task_action}. 천천히 해보는 편이 좋습니다",
        ],
        "bad": [
            "{task_action}. 오늘은 쉬운 선택이 더 안전합니다",
            "조금 천천히 움직여도 괜찮아요",
            "괜찮은 척 밀어붙이기보다 쉬어갈 자리를 남겨두세요",
            "{task_action}. 나머지는 내려놓아도 됩니다",
        ],
    },
}

TSUNDERE = {
    "intro": {
        "good": [
            "{name}이 괜찮네. 이런 날은 흔하지 않으니까 알아서 잘 써",
            "오늘 {subject}은 꽤 멀쩡해 보여",
            "{area} 쪽은 네가 생각한 것보다 나쁘지 않아",
            "{task_action}. 이번엔 말릴 이유가 별로 없네",
        ],
        "neutral": [
            "{name}은 그냥 평범해. 너무 기대하진 말고",
            "오늘 {subject}은 딱 보통 정도야",
            "{area} 쪽은 무난해. 잘난 척만 안 하면 돼",
            "{task_label} 정도면 괜찮겠네",
        ],
        "bad": [
            "{name}이 별로야. 좋게 말해줄 상황은 아니네",
            "오늘 {subject}은 좀 삐걱거려",
            "{area} 쪽은 조심해. 괜히 큰소리치지 말고",
            "{task_action}. 무리하면 피곤해져",
        ],
    },
    "state": {
        "good": [
            "{element_focus} 쪽 감이 살아 있고 {weather_plain}도 생각보다 도와줘",
            "{element_body}이 제대로 돌아가서 네가 덜 헤맬 것 같아",
            "{strength_plain} 움직여도 {subject}이 크게 흔들리진 않겠네",
            "{weather_plain}인데도 {area}은 꽤 버텨줘",
        ],
        "neutral": [
            "{element_focus}은 애매하지만 못 쓸 정도는 아니야",
            "{weather_plain}이라서 속도 내면 좀 피곤할 수 있어",
            "{element_body}이 반쯤은 버텨주고 있어",
            "{strength_plain} 움직이면 크게 문제는 없겠네",
        ],
        "bad": [
            "{element_focus} 쪽이 흔들려. 괜히 모른 척하지 마",
            "{weather_plain} 때문에 {subject}이 쉽게 꼬일 수 있어",
            "{element_body}이 힘이 빠져서 버티는 게 먼저야",
            "{strength_plain} 넘기면 괜찮을 일을 네가 키울 수 있어",
        ],
    },
    "effect": {
        "good": [
            "잘하면 {area}에서 꽤 괜찮은 결과가 나올 거야",
            "네가 실수만 안 하면 생각보다 잘 풀려",
            "{subject}이 맞아떨어져서 후회는 적을 것 같아",
            "이번엔 네 감을 믿어봐도 될 것 같네",
        ],
        "neutral": [
            "큰일은 안 생기겠지만 대충 넘기면 티는 날 거야",
            "평범하게 가면 평범하게 괜찮아져",
            "{area}에서 욕심내지만 않으면 무난해",
            "조금만 확인하면 굳이 꼬일 일은 없어",
        ],
        "bad": [
            "막 밀어붙이면 결과가 귀찮아질 수 있어",
            "{area}에서 괜한 말이나 행동이 문제를 만들 수 있어",
            "지금은 네 감만 믿기엔 좀 불안해",
            "괜찮은 척하다가 뒤에서 피곤해질 수 있거든",
        ],
    },
    "action": {
        "good": [
            "{task_action}. 이번엔 그냥 네 판단 믿어봐",
            "해볼 거면 오늘 해. 타이밍은 나쁘지 않아",
            "망설이다가 놓치지 말고 움직여",
            "{task_action}. 괜찮을 때 괜찮다고 해주는 거야",
        ],
        "neutral": [
            "{task_action}. 괜히 크게 벌이지만 마",
            "적당히 해. 그게 제일 덜 피곤해",
            "확인할 건 확인하고 움직여",
            "{task_action}. 무리하면 바로 티 난다",
        ],
        "bad": [
            "{task_action}. 지금 괜히 센 척하지 말고",
            "오늘은 물러나는 게 낫다. 손해 보는 거 아니야",
            "큰소리치지 말고 조용히 정리해",
            "{task_action}. 나중에 후회하기 싫으면",
        ],
    },
}

CYNICAL = {
    "intro": {
        "good": [
            "{name}이 괜찮은 편이다. 드문 일이니 써먹을 수는 있겠다",
            "오늘 {subject}은 평소보다 덜 삐걱거린다",
            "{area} 쪽은 기대치를 조금 올려도 크게 민망하진 않다",
            "{task_label}에는 나쁘지 않은 날이다",
        ],
        "neutral": [
            "{name}은 보통이다. 보통이면 충분한 날도 있다",
            "오늘 {subject}은 특별히 좋지도 나쁘지도 않다",
            "{area} 쪽은 욕심을 줄이면 지나간다",
            "{task_label} 정도가 현실적인 선택이다",
        ],
        "bad": [
            "{name}이 좋지 않다. 굳이 포장할 필요는 없다",
            "오늘 {subject}은 기대하지 않는 편이 낫다",
            "{area} 쪽은 삐끗하기 쉬운 날이다",
            "{task_label} 쪽이 그나마 덜 피곤한 선택이다",
        ],
    },
    "state": {
        "good": [
            "{element_focus} 쪽 조건이 맞아떨어지고 {weather_plain}도 크게 방해하지 않는다",
            "{element_body}이 생각보다 잘 버텨서 상황이 덜 꼬인다",
            "{strength_plain} 움직여도 {subject}이 무너지진 않는다",
            "{weather_plain} 속에서도 {area}은 제법 정리된다",
        ],
        "neutral": [
            "{element_focus}은 애매하고 {weather_plain}도 딱히 편을 들진 않는다",
            "{element_body}이 적당히 버티지만 믿고 맡길 정도는 아니다",
            "{strength_plain} 가면 큰 문제는 피할 수 있다",
            "{area}은 결국 확인한 만큼만 안전해진다",
        ],
        "bad": [
            "{element_focus} 쪽이 흔들리고 {weather_plain}까지 겹친다",
            "{element_body}이 약해서 작은 변수에도 흔들릴 수 있다",
            "{strength_plain} 넘기면 문제가 커지는 건 늘 그렇다",
            "{area}은 오늘 별로 관대하지 않다",
        ],
    },
    "effect": {
        "good": [
            "큰 기대만 안 하면 {area}에서 꽤 쓸 만한 결과가 나온다",
            "잘 풀려도 인생이 바뀌진 않겠지만 오늘은 도움이 된다",
            "{subject}이 받쳐주니 평소보다 손해 볼 확률은 낮다",
            "처리할 일은 처리된다. 그 정도면 충분하다",
        ],
        "neutral": [
            "대단한 일은 없겠지만 크게 망할 일도 적다",
            "{area}은 결국 한 만큼만 돌아온다",
            "무난함을 과소평가하지 않는 편이 낫다",
            "기대치를 낮추면 생각보다 괜찮게 지나간다",
        ],
        "bad": [
            "괜히 욕심내면 {area}에서 수습할 일이 늘어난다",
            "오늘은 손해를 줄이는 쪽이 이기는 쪽이다",
            "{subject}이 흔들리면 작은 일도 피곤해진다",
            "계획대로 안 되는 건 특별한 일이 아니다. 오늘은 더 그렇다",
        ],
    },
    "action": {
        "good": [
            "{task_action}. 어차피 해야 할 일이라면 오늘 처리하는 편이 낫다",
            "좋은 기회가 오면 잡아라. 늘 오는 건 아니다",
            "지금 할 수 있는 건 지금 하는 게 덜 귀찮다",
            "{task_action}. 미뤄도 결국 다시 돌아온다",
        ],
        "neutral": [
            "{task_action}. 큰 기대만 안 하면 된다",
            "할 일만 하고 과한 의미 부여는 하지 마라",
            "평범하게 처리해라. 평범함도 전략이다",
            "{task_action}. 무리해서 멋있어질 필요는 없다",
        ],
        "bad": [
            "{task_action}. 오늘은 덜 망치는 게 목표다",
            "큰 결심은 나중에 해라. 지금은 수습이 먼저다",
            "괜한 모험은 하지 마라. 모험은 보통 비용이 든다",
            "{task_action}. 사람 일이라는 게 원래 계획대로만 되진 않는다",
        ],
    },
}

HISTORICAL = {
    "intro": {
        "good": [
            "{name}이 맑으니 오늘은 움직여볼 만하오",
            "{subject}의 기운이 단단하니 좋은 징조라 하겠소",
            "{area}에 길한 기미가 보이니 너무 물러서지 마시오",
            "{task_label}에 나서도 무리가 없겠소",
        ],
        "neutral": [
            "{name}은 평이하니 큰 욕심은 거두는 게 좋겠소",
            "{subject}의 기운이 고르나 빠르지는 않소",
            "{area}은 차분히 살필 때라 하겠소",
            "{task_label} 정도가 오늘의 알맞은 길이오",
        ],
        "bad": [
            "{name}이 흐리니 섣부른 움직임은 삼가시오",
            "{subject}의 기운이 약하니 오늘은 조심해야 하오",
            "{area}에 걸림이 있으니 한발 물러서 보시오",
            "{task_label}이 오늘은 이로운 길이겠소",
        ],
    },
    "state": {
        "good": [
            "{element_historical}이 {strength_historical} 일어나고 {weather_historical}도 길을 돕소",
            "{element_body}이 바로 서니 {subject}이 흔들리지 않소",
            "{weather_historical} 아래 {element_focus}의 뜻이 제법 선명하오",
            "{strength_historical} 움직여도 크게 어긋나지 않겠소",
        ],
        "neutral": [
            "{element_historical}이 남아 있으나 서두를 때는 아니오",
            "{weather_historical}이 머무르니 {subject}을 한 번 더 살피시오",
            "{element_body}이 약하게 버티니 작은 확인이 필요하오",
            "{strength_historical} 가면 큰 탈은 피하겠소",
        ],
        "bad": [
            "{element_historical}이 흐트러져 {subject}이 흔들리기 쉽소",
            "{weather_historical}이 무거워 {area}에 막힘이 생길 수 있소",
            "{element_body}이 약하니 버티는 일을 먼저 하시오",
            "{strength_historical} 넘기면 작은 일도 크게 번질 수 있소",
        ],
    },
    "effect": {
        "good": [
            "{area}에서 바라던 답이 가까워질 수 있겠소",
            "노력한 만큼 보람이 따를 기미가 있소",
            "{subject}이 바르게 서니 결과도 나쁘지 않겠소",
            "좋은 소식이 아주 멀지는 않소",
        ],
        "neutral": [
            "큰 변화는 없으나 하루를 무사히 넘기기엔 충분하오",
            "{area}은 천천히 다루면 별 탈이 없겠소",
            "기다릴 것은 기다리고 잡을 것은 작게 잡으시오",
            "무리하지 않으면 손실은 줄일 수 있겠소",
        ],
        "bad": [
            "{area}에서 뜻밖의 번거로움이 생길 수 있소",
            "욕심을 내면 얻는 것보다 잃는 것이 커질 수 있소",
            "{subject}이 흔들리니 말과 행동을 아끼는 편이 낫겠소",
            "오늘은 이기는 날보다 지키는 날에 가깝소",
        ],
    },
    "action": {
        "good": [
            "{task_action}. 오늘은 그 길이 나쁘지 않소",
            "뜻을 세웠다면 조용히 밀고 가보시오",
            "망설임을 줄이고 한 걸음 내딛어도 되겠소",
            "{task_action}. 다만 끝맺음은 살피시오",
        ],
        "neutral": [
            "{task_action}. 무리만 피하면 되겠소",
            "서둘지 말고 순서를 지키시오",
            "작게 움직이고 크게 벌이지 마시오",
            "{task_action}. 오늘은 그 정도면 족하오",
        ],
        "bad": [
            "{task_action}. 섣부른 결정을 삼가시오",
            "말을 줄이고 일을 키우지 마시오",
            "오늘은 나아가기보다 지키는 편이 이롭겠소",
            "{task_action}. 훗날을 위해 힘을 아끼시오",
        ],
    },
}

TONE_TABLES = {
    "emotional": EMOTIONAL,
    "tsundere": TSUNDERE,
    "cynical": CYNICAL,
    "historical": HISTORICAL,
}

START_PREFIXES = {
    "emotional": [
        "오늘은",
        "이럴 때는",
        "조금 편하게 보면",
        "{area}에서는",
        "마음이 급해질수록",
        "한 번 숨을 고르면",
        "{subject}을 살필 때는",
        "지금은",
        "무리하지 않으려면",
        "하루를 길게 보면",
    ],
    "tsundere": [
        "오늘은",
        "이럴 땐",
        "{area}에서는",
        "괜히 버티지 말고",
        "네가 알아서 하겠지만",
        "지금은",
        "{subject} 쪽은",
        "쓸데없이 힘주지 말고",
        "한 번만 더 보면",
        "솔직히 말하면",
    ],
    "cynical": [
        "오늘은",
        "현실적으로",
        "{area}에서는",
        "기대치를 낮추면",
        "따지고 보면",
        "지금은",
        "{subject} 쪽은",
        "굳이 말하자면",
        "손해를 줄이려면",
        "어차피 해야 한다면",
    ],
    "historical": [
        "오늘은",
        "이럴 때는",
        "{area}에서는",
        "기운을 보아하니",
        "섣불리 굴지 말고",
        "지금은",
        "{subject}의 기미로는",
        "한 번 더 살피면",
        "길흉을 따져보면",
        "마음을 낮추면",
    ],
}

FORBIDDEN = {
    "emotional": ["마음의 결", "작은 빛", "흐름을 믿으세요", "온기를 느껴보세요", "별이 머뭅니다"],
    "tsundere": ["딱히", "걱정해서", "착각하지 마", "뭐,"],
    "cynical": ["절망", "다 망", "답이 없다"],
    "historical": ["하시옵소서", "옳사옵니다", "도모하심", "하옵니다", "옳소이다"],
}


def bucket_for_context(context: dict[str, str | int]) -> str:
    return tier_bucket(str(context["tier_key"]))


def render_text(tone: str, row: dict[str, str], index: int, occurrence: int) -> str:
    context = apply_tone_context(build_context(row, index, occurrence), tone)
    table = TONE_TABLES[tone]
    text_type = row["type"]
    bucket = bucket_for_context(context)
    variants = table[text_type][bucket]
    # Category, element and occurrence are intentionally mixed to avoid visible cycles.
    variant_index = (
        index
        + occurrence * 7
        + len(str(context["category_key"])) * 3
        + len(str(context["element_key"])) * 5
        + len(str(context["weather_key"])) * 2
    )
    return sentence_case(pick(variants, variant_index).format(**context))


def rewrite_tone(tone: str, rows: list[dict[str, str]]) -> list[dict[str, str]]:
    occurrences: defaultdict[tuple[str, str], int] = defaultdict(int)
    rewritten: list[dict[str, str]] = []
    used: Counter[str] = Counter()
    start_counts: Counter[str] = Counter()
    for index, row in enumerate(rows):
        key = (row["code"], row["type"])
        occurrence = occurrences[key]
        occurrences[key] += 1
        text = render_text(tone, row, index, occurrence)
        # Duplicate safeguard: use a natural qualifier based on code context, not a generic suffix.
        if used[text]:
            context = apply_tone_context(build_context(row, index, occurrence), tone)
            extras = [
                f"{context['area']}에서는 조금 더 천천히 살피면 좋겠습니다",
                f"처음 든 생각만으로 정하지 않아도 됩니다",
                f"지금은 여지를 남겨두는 편이 편안합니다",
                f"작은 확인 하나가 마음을 덜어줄 거예요",
                f"오늘은 {context['task_action']}",
                f"{context['subject']}을 다시 살피면 마음이 조금 놓입니다",
            ]
            if tone == "tsundere":
                extras = [
                    f"{context['area']} 쪽은 한 번 더 봐",
                    f"괜히 넘기지 말고 확인은 해",
                    f"지금은 힘 빼고 가는 게 낫겠네",
                    f"{context['area']}에 너무 힘주지 마",
                    f"이번엔 {context['task_action']}",
                    f"{context['subject']}은 한 번 더 확인해",
                ]
            elif tone == "cynical":
                extras = [
                    f"{context['area']} 쪽은 확인하는 게 덜 귀찮다",
                    f"무시하면 결국 처리할 일이 늘어난다",
                    f"지금은 현실적인 쪽만 고르는 게 낫다",
                    f"{context['area']}에 큰 의미를 붙이지 마라",
                    f"조건이 겹친 만큼 기대치는 낮춰라",
                    f"{context['subject']}을 두 번 보는 편이 결국 싸게 먹힌다",
                ]
            elif tone == "historical":
                extras = [
                    f"{context['area']}의 기미를 한 번 더 살피시오",
                    f"서두르지 않으면 길이 보이겠소",
                    f"오늘은 작게 다루는 편이 좋겠소",
                    f"{context['area']}의 순서를 낮추시오",
                    f"눈앞의 이익보다 균형을 보시오",
                    f"{context['subject']}은 거듭 살피는 편이 이롭소",
                ]
            extra_index = used[text] + index
            candidate = sentence_case(f"{text} {pick(extras, extra_index)}")
            while used[candidate]:
                extra_index += 1
                candidate = sentence_case(f"{text} {pick(extras, extra_index)}")
                if extra_index > used[text] + index + len(extras) + 2:
                    occurrence_label = pick(["첫 판단", "다시 본 판단", "마지막 확인"], int(context["occurrence"]))
                    detail = (
                        f"{context['element_focus']}, {context['strength_plain']}, "
                        f"{context['weather_plain']}을 함께 보고 {occurrence_label}은 {context['task']}에 둡니다"
                    )
                    if tone == "tsundere":
                        detail = (
                            f"{context['element_focus']}이랑 {context['strength_plain']}, "
                            f"{context['weather_plain']}까지 같이 보고 {context['task']} 쪽으로 봐"
                        )
                    elif tone == "cynical":
                        detail = (
                        f"{context['element_focus']}, {context['strength_plain']}, "
                        f"{context['weather_plain']}까지 보면 {context['task_label']} 쪽이 그나마 현실적이다"
                        )
                    elif tone == "historical":
                        detail = (
                            f"{context['element_focus']}, {context['strength_historical']}, "
                            f"{context['weather_historical']}까지 헤아려 {context['task_label']}에 뜻을 두시오"
                        )
                    candidate = sentence_case(
                        f"{candidate} {detail}"
                    )
                    if used[candidate]:
                        candidate = sentence_case(f"{candidate} 세부 순서는 {index + 1}번째로 보겠습니다")
                    break
            text = candidate
        start_key = text[:18]
        if start_counts[start_key] >= 24:
            context = apply_tone_context(build_context(row, index, occurrence), tone)
            prefix_template = pick(START_PREFIXES[tone], index + occurrence + start_counts[start_key])
            prefix = prefix_template.format(**context)
            if not text.startswith(prefix):
                text = with_prefix(prefix, text)
            retry = 0
            while used[text]:
                retry += 1
                prefix_template = pick(
                    START_PREFIXES[tone],
                    index + occurrence + start_counts[start_key] + used[text] + 1,
                )
                prefix = prefix_template.format(**context)
                text = with_prefix(prefix, render_text(tone, row, index + used[text] + 1, occurrence))
                if retry > 12 and used[text]:
                    text = sentence_case(
                        f"{text} 이번 {context['name']}은 {context['area']}, {context['element_focus']}, "
                        f"{context['strength_plain']}, {context['weather_plain']}을 보고 방향을 정리합니다"
                    )
                    break
        start_counts[text[:18]] += 1
        used[text] += 1
        rewritten.append({**row, "text": text})
    return rewritten


def validate_original_shape(before: list[dict[str, str]], after: list[dict[str, str]], path: Path) -> None:
    if len(before) != len(after):
        raise ValueError(f"{path.name}: row count changed")
    for idx, (old, new) in enumerate(zip(before, after)):
        for column in ("code", "type", "weight"):
            if old[column] != new[column]:
                raise ValueError(f"{path.name}: {column} changed at row {idx}")


def validate_tone(tone: str, rows: list[dict[str, str]], path: Path) -> None:
    texts = [row["text"] for row in rows]
    duplicate_count = sum(1 for count in Counter(texts).values() if count > 1)
    if duplicate_count:
        raise ValueError(f"{path.name}: duplicate texts {duplicate_count}")
    blocked = [term for term in FORBIDDEN[tone] if any(term in text for text in texts)]
    if blocked:
        raise ValueError(f"{path.name}: forbidden terms {blocked}")
    empty = [row for row in rows if not row["text"].strip()]
    if empty:
        raise ValueError(f"{path.name}: empty text rows {len(empty)}")

    starts = Counter(text[:18] for text in texts)
    most_common_start, most_common_count = starts.most_common(1)[0]
    if most_common_count > 90:
        raise ValueError(
            f"{path.name}: repeated start too high {most_common_count} '{most_common_start}'"
        )


def main() -> None:
    for tone, path in TARGET_FILES.items():
        before = read_rows(path)
        after = rewrite_tone(tone, before)
        validate_original_shape(before, after, path)
        validate_tone(tone, after, path)
        write_rows(path, after)
        print(f"{path.name}: rewritten rows={len(after)}")


if __name__ == "__main__":
    main()
