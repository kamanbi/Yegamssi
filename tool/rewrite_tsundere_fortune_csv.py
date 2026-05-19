import csv
import shutil
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
STYLE_DIR = ROOT / 'etc' / 'fortune_styles'
BASE = STYLE_DIR / 'fortune_ko_base.csv'
TARGET = STYLE_DIR / 'fortune_ko_tsundere.csv'
BACKUP_DIR = STYLE_DIR / 'backup'

FIELDNAMES = ['code', 'type', 'text', 'weight']
EXPECTED_ROWS = 5976
MAX_FILE_BYTES = 900_000
EXPECTED_TIERS = {'A', 'B', 'B1', 'C', 'C1', 'D'}
EXPECTED_TYPE_COUNTS = {
    'intro': 1512,
    'effect': 1512,
    'action': 1512,
    'state': 1440,
}

CATEGORIES = {
    'overall': {
        'name': '종합운',
        'subject': '하루 흐름은',
        'area_topic': '오늘 하루는',
        'task': {
            'good': ['미뤄둔 일 하나는 해', '중요한 일정부터 정리해'],
            'neutral': ['일정부터 줄여', '평소 루틴이나 지켜'],
            'bad': ['일 크게 벌이지 마', '무리한 약속은 줄여'],
        },
    },
    'money': {
        'name': '재물운',
        'subject': '돈 흐름은',
        'area_topic': '재정은',
        'task': {
            'good': ['미뤄둔 정산부터 해', '쓸 돈과 묶을 돈을 나눠'],
            'neutral': ['지출 기준부터 봐', '잔돈 새는 곳부터 막아'],
            'bad': ['충동 결제는 미뤄', '돈 나갈 일은 줄여'],
        },
    },
    'love': {
        'name': '연애운',
        'subject': '마음은',
        'area_topic': '관계는',
        'task': {
            'good': ['먼저 짧게 말 걸어', '진심은 담백하게 말해'],
            'neutral': ['말의 온도부터 낮춰', '상대 속도에 맞춰'],
            'bad': ['감정적인 말은 아껴', '오해 살 말은 피해'],
        },
    },
    'work': {
        'name': '업무운',
        'subject': '일 흐름은',
        'area_topic': '업무는',
        'task': {
            'good': ['중요한 일부터 처리해', '성과 보이는 일부터 해'],
            'neutral': ['일 순서부터 다시 정해', '속도보다 확인부터 해'],
            'bad': ['새 일은 벌이지 마', '실수할 부분부터 다시 봐'],
        },
    },
    'health': {
        'name': '건강운',
        'subject': '컨디션은',
        'area_topic': '몸 상태는',
        'task': {
            'good': ['가벼운 활동부터 해', '몸을 조금 더 움직여'],
            'neutral': ['몸 상태부터 살펴', '무리 말고 일상만 유지해'],
            'bad': ['휴식부터 챙겨', '무리한 활동은 줄여'],
        },
    },
    'decision': {
        'name': '결정운',
        'subject': '판단은',
        'area_topic': '선택은',
        'task': {
            'good': ['오래 붙잡던 문제를 정리해', '미뤄둔 결정부터 꺼내'],
            'neutral': ['기준부터 다시 세워', '선택지를 줄여'],
            'bad': ['큰 결정은 미뤄', '확신 없는 선택은 피해'],
        },
    },
}

ELEMENTS = {
    'geum': {
        'focus': '판단',
        'good': '기준이 보여서 덜 헤매겠네',
        'neutral': '기준은 있는데 말이 좀 딱딱할 수 있어',
        'bad': '예민해져서 말이 먼저 나갈 수 있어',
        'df': '판단 기준이 흐려져 한 번 더 봐야 해',
        'ex': '판단이 단단해져 말이 차갑게 들릴 수 있어',
    },
    'hwa': {
        'focus': '활력',
        'good': '움직일 힘은 있어 보여',
        'neutral': '힘은 있는데 속도 조절은 해',
        'bad': '기분이 앞서면 일이 커질 수 있어',
        'df': '활력이 낮아서 시작이 느릴 수 있어',
        'ex': '활력이 강해서 행동이 앞설 수 있어',
    },
    'mok': {
        'focus': '가능성',
        'good': '새 방법은 보여',
        'neutral': '가능성은 있는데 일을 늘리진 마',
        'bad': '하고 싶은 게 많아져 산만해질 수 있어',
        'df': '새 시도가 부담스러울 수 있어',
        'ex': '가능성이 많아 보여 일이 늘 수 있어',
    },
    'su': {
        'focus': '타이밍',
        'good': '감은 나쁘지 않아',
        'neutral': '느낌은 오는데 결론은 늦을 수 있어',
        'bad': '마음이 흔들려 결정이 밀릴 수 있어',
        'df': '타이밍 잡기가 조금 어려워',
        'ex': '느낌이 많아져 결론을 미루기 쉬워',
    },
    'to': {
        'focus': '안정감',
        'good': '느려도 크게 흔들리진 않아',
        'neutral': '안정은 되는데 시작이 늦을 수 있어',
        'bad': '안전한 길만 찾다 더 무거워질 수 있어',
        'df': '중심이 약해 작은 변수에도 흔들릴 수 있어',
        'ex': '안정만 찾다 움직임이 늦어질 수 있어',
    },
}

TIERS = {
    'A': {
        'bucket': 'good',
        'intro': [
            '{name}은 좋아. 이런 날까지 망설이면 좀 아깝지',
            '{subject} 꽤 잘 살아 있어. 오늘은 믿어도 되겠네',
        ],
        'effect': [
            '{area_topic} 원하는 쪽으로 잘 풀릴 가능성이 높아',
            '움직이면 결과가 따라올 것 같아. 이번엔 꽤 괜찮네',
        ],
        'action_tail': ['이번엔 자신 있게 해도 돼', '좋을 때 움직여, 괜히 아끼지 말고'],
    },
    'B': {
        'bucket': 'good',
        'intro': [
            '{name}은 좋은 편이야. 티는 안 내도 써먹을 만해',
            '{subject} 안정적이야. 오늘은 꽤 편하게 가도 돼',
        ],
        'effect': [
            '{area_topic} 안정적으로 풀릴 가능성이 있어',
            '기대보다 괜찮은 결과가 나올 수 있어',
        ],
        'action_tail': ['망설이지 말고 해봐', '이 정도면 해볼 만하지'],
    },
    'B1': {
        'bucket': 'neutral',
        'intro': [
            '{name}은 중간은 넘어. 방심만 하지 마',
            '{subject} 나쁘진 않은데 너무 믿진 마',
        ],
        'effect': [
            '{area_topic} 확인한 만큼만 안정돼',
            '작은 점검 하나가 피곤함을 줄여',
        ],
        'action_tail': ['한 번 더 보고 움직여', '대충 넘기면 티 나'],
    },
    'C': {
        'bucket': 'bad',
        'intro': [
            '{name}은 조심해야 해. 괜히 센 척하지 마',
            '{subject} 쉽게 풀리진 않아. 천천히 가',
        ],
        'effect': [
            '{area_topic} 기대보다 늦게 반응할 수 있어',
            '작은 일도 귀찮게 번질 수 있어',
        ],
        'action_tail': ['오늘은 줄이는 게 나아', '무리하면 바로 피곤해져'],
    },
    'C1': {
        'bucket': 'bad',
        'intro': [
            '{name}은 낮아. 오늘은 욕심부터 내려',
            '{subject} 흔들릴 수 있어. 감만 믿지 마',
        ],
        'effect': [
            '{area_topic} 작은 변수에도 흔들릴 수 있어',
            '무리하면 결과보다 피로가 남아',
        ],
        'action_tail': ['쉬운 것부터 해', '남길 건 내일로 넘겨'],
    },
    'D': {
        'bucket': 'bad',
        'intro': [
            '{name}은 별로야. 포장해도 달라지진 않아',
            '{subject} 막혀 있어. 억지로 밀지 마',
        ],
        'effect': [
            '{area_topic} 뜻대로 안 갈 수 있어',
            '작은 일도 크게 느껴질 수 있어',
        ],
        'action_tail': ['오늘은 조용히 넘어가', '회복할 틈은 남겨'],
    },
}

WEATHERS = {
    'earth': '차분한 기운이 속도를 낮춰',
    'fire': '밝은 기운에 말이 빨라질 수 있어',
    'water': '감정이 깊어져 결론이 늦을 수 있어',
    'wood': '변화가 많아 생각이 퍼질 수 있어',
}

SUSPICIOUS_PATTERNS = [
    '은은',
    '는는',
    '을을',
    '를를',
    '관계을',
    '분위기을',
    '기운를',
    '흐름가',
    '반응가',
    '구간',
    '단계',
    '같은 흐름',
    '방향을 정리합니다',
    '피 쪽',
    '택 쪽',
]
FORBIDDEN = ['딱히', '걱정해서', '착각하지 마', '뭐,', '응원', '힘내']


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open('r', encoding='utf-8-sig', newline='') as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != FIELDNAMES:
            raise ValueError(f'{path.name}: fieldnames mismatch {reader.fieldnames}')
        return list(reader)


def write_rows(path: Path, rows: list[dict[str, str]]) -> None:
    with path.open('w', encoding='utf-8-sig', newline='') as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDNAMES)
        writer.writeheader()
        writer.writerows(rows)


def parse_code(code: str) -> dict[str, str | bool]:
    parts = code.split('_')
    if len(parts) == 2:
        return {
            'category': parts[0],
            'tier': parts[1],
            'element': '',
            'strength': '',
            'weather': '',
            'is_base': True,
        }
    if len(parts) == 5:
        return {
            'category': parts[0],
            'tier': parts[1],
            'element': parts[2],
            'strength': parts[3],
            'weather': parts[4],
            'is_base': False,
        }
    raise ValueError(f'unsupported code: {code}')


def context(meta: dict[str, str | bool]) -> dict[str, str]:
    category = CATEGORIES[str(meta['category'])]
    tier = TIERS[str(meta['tier'])]
    element_key = str(meta['element'])
    element = ELEMENTS.get(element_key, {})
    return {
        **category,
        **element,
        'tier': str(meta['tier']),
        'bucket': str(tier['bucket']),
    }


def pick(items: list[str], index: int) -> str:
    return items[index % len(items)]


def base_text(meta: dict[str, str | bool], text_type: str, occurrence: int) -> str:
    ctx = context(meta)
    tier = TIERS[str(meta['tier'])]
    if text_type in {'intro', 'effect'}:
        return pick(tier[text_type], occurrence).format(**ctx)
    if text_type == 'action':
        actions = ctx['task'][ctx['bucket']]
        action = pick(actions, occurrence)
        tail = pick(tier['action_tail'], occurrence)
        return f'{action}. {tail}'
    raise ValueError(f'base rows do not support type={text_type}')


def elem_text(meta: dict[str, str | bool], text_type: str) -> str:
    ctx = context(meta)
    tier = TIERS[str(meta['tier'])]
    bucket = ctx['bucket']
    if text_type == 'intro':
        if bucket == 'good':
            return f"{ctx['name']}은 {ctx['focus']}이 잘 살아 있어. 이번엔 믿어봐"
        if bucket == 'neutral':
            return f"{ctx['name']}은 {ctx['focus']}을 한 번 더 봐. 넘기면 귀찮아져"
        return f"{ctx['name']}은 {ctx['focus']}이 흔들려. 오늘은 낮춰 잡아"
    if text_type == 'effect':
        if bucket == 'good':
            return f"{ctx['area_topic']} 좋은 쪽으로 풀릴 수 있어. {ctx['good']}"
        if bucket == 'neutral':
            return f"{ctx['area_topic']} 확인한 만큼 안정돼. {ctx['neutral']}"
        return f"{ctx['area_topic']} 작은 일도 신경 쓰일 수 있어. {ctx['bad']}"
    if text_type == 'action':
        actions = ctx['task'][bucket]
        action = pick(actions, len(str(meta['element'])) + len(str(meta['category'])))
        tail = pick(tier['action_tail'], len(str(meta['element'])))
        return f'{action}. {tail}'
    raise ValueError(f'unsupported elem type={text_type}')


def state_text(meta: dict[str, str | bool]) -> str:
    element_key = str(meta['element'])
    element = ELEMENTS[element_key]
    strength = str(meta['strength'])
    weather = str(meta['weather'])
    tier = str(meta['tier'])
    focus = element['focus']
    if tier in {'A', 'B'}:
        if strength == 'df':
            element_state = f'{focus}이 조금 흔들려도 오늘은 금방 잡을 수 있어'
        else:
            element_state = f'{focus}이 강하게 살아 있어. 잘 쓰면 꽤 도움 돼'
        weather_state = {
            'earth': '차분한 기운도 받쳐줘',
            'fire': '밝은 기운이 힘을 보태',
            'water': '감정 흐름도 나쁘지 않아',
            'wood': '변화도 좋은 쪽으로 움직여',
        }[weather]
        return f'{element_state}. {weather_state}'
    if tier == 'B1':
        return f"{element[strength]}. {WEATHERS[weather]}"
    if strength == 'df':
        element_state = f'{focus}이 약해서 한 번 더 봐야 해'
    else:
        element_state = f'{focus}이 과해서 조절이 필요해'
    return f"{element_state}. {WEATHERS[weather]}"


def build_rows(base_rows: list[dict[str, str]]) -> list[dict[str, str]]:
    base_occurrences: defaultdict[tuple[str, str], int] = defaultdict(int)
    element_cache: dict[tuple[str, str, str, str], str] = {}
    next_rows = []
    for row in base_rows:
        meta = parse_code(row['code'])
        text_type = row['type']
        if meta['is_base']:
            key = (row['code'], text_type)
            text = base_text(meta, text_type, base_occurrences[key])
            base_occurrences[key] += 1
        elif text_type == 'state':
            text = state_text(meta)
        else:
            cache_key = (
                str(meta['category']),
                str(meta['tier']),
                str(meta['element']),
                text_type,
            )
            text = element_cache.setdefault(cache_key, elem_text(meta, text_type))
        next_rows.append(
            {
                'code': row['code'],
                'type': text_type,
                'text': text,
                'weight': row['weight'],
            }
        )
    return next_rows


def validate(base_rows: list[dict[str, str]], next_rows: list[dict[str, str]]) -> None:
    if len(next_rows) != EXPECTED_ROWS:
        raise ValueError(f'row count mismatch: {len(next_rows)}')
    if len(base_rows) != len(next_rows):
        raise ValueError('base and target row counts differ')
    type_counts = Counter(row['type'] for row in next_rows)
    if type_counts != EXPECTED_TYPE_COUNTS:
        raise ValueError(f'type counts mismatch: {type_counts}')
    tiers = {row['code'].split('_')[1] for row in next_rows}
    if tiers != EXPECTED_TIERS:
        raise ValueError(f'tier mismatch: {tiers}')
    for index, (base, row) in enumerate(zip(base_rows, next_rows), start=2):
        for field in ('code', 'type', 'weight'):
            if base[field] != row[field]:
                raise ValueError(f'{field} changed at csv row {index}')
        text = row['text']
        if not text.strip():
            raise ValueError(f'empty text at csv row {index}')
        if len(text) > 95:
            raise ValueError(f'text too long at csv row {index}: {text}')
        for token in FORBIDDEN:
            if token in text:
                raise ValueError(f'forbidden token {token!r} at csv row {index}: {text}')
        for pattern in SUSPICIOUS_PATTERNS:
            if pattern in text:
                raise ValueError(
                    f'suspicious pattern {pattern!r} at csv row {index}: {text}'
                )


def main() -> None:
    base_rows = read_rows(BASE)
    old_rows = read_rows(TARGET)
    if len(old_rows) != EXPECTED_ROWS:
        raise ValueError(f'current target row count mismatch: {len(old_rows)}')

    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup = BACKUP_DIR / f'fortune_ko_tsundere_before_rewrite_{stamp}.csv'
    shutil.copy2(TARGET, backup)

    next_rows = build_rows(base_rows)
    validate(base_rows, next_rows)
    write_rows(TARGET, next_rows)
    size = TARGET.stat().st_size
    if size > MAX_FILE_BYTES:
        raise ValueError(f'file too large: {size} bytes')
    print(f'backup={backup}')
    print(f'rows={len(next_rows)} unique_texts={len({row["text"] for row in next_rows})}')
    print(f'bytes={size}')


if __name__ == '__main__':
    main()
