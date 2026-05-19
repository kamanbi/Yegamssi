import csv
import shutil
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
STYLE_DIR = ROOT / 'etc' / 'fortune_styles'
BASE = STYLE_DIR / 'fortune_ko_base.csv'
TARGET = STYLE_DIR / 'fortune_ko_historical.csv'
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
        'subject': '하루 기운은',
        'area_topic': '오늘 하루는',
        'task': {
            'good': ['미뤄둔 일 하나를 시작하시오', '중요한 일정부터 정리하시오'],
            'neutral': ['일정을 단순히 정리하시오', '평소의 루틴을 지키시오'],
            'bad': ['일을 크게 벌이지 마시오', '무리한 약속은 줄이시오'],
        },
    },
    'money': {
        'name': '재물운',
        'subject': '재물 기운은',
        'area_topic': '재정은',
        'task': {
            'good': ['미뤄둔 정산을 마치시오', '쓸 돈과 묶을 돈을 나누시오'],
            'neutral': ['지출 기준을 다시 보시오', '작은 지출부터 막으시오'],
            'bad': ['충동 결제는 미루시오', '돈 나갈 일은 줄이시오'],
        },
    },
    'love': {
        'name': '연애운',
        'subject': '마음의 기운은',
        'area_topic': '관계는',
        'task': {
            'good': ['먼저 짧게 말을 건네시오', '진심은 담백히 전하시오'],
            'neutral': ['말의 온도를 낮추시오', '상대의 속도에 맞추시오'],
            'bad': ['감정적인 말은 아끼시오', '오해 살 말은 피하시오'],
        },
    },
    'work': {
        'name': '업무운',
        'subject': '일의 기운은',
        'area_topic': '업무는',
        'task': {
            'good': ['중요한 일부터 처리하시오', '성과가 보이는 일부터 하시오'],
            'neutral': ['일의 순서부터 다시 정하시오', '속도보다 확인을 먼저 하시오'],
            'bad': ['새 일은 벌이지 마시오', '실수할 부분부터 다시 보시오'],
        },
    },
    'health': {
        'name': '건강운',
        'subject': '몸의 기운은',
        'area_topic': '몸 상태는',
        'task': {
            'good': ['가벼운 활동부터 시작하시오', '몸을 조금 더 움직이시오'],
            'neutral': ['몸 상태부터 살피시오', '무리 말고 일상을 지키시오'],
            'bad': ['휴식부터 챙기시오', '무리한 활동은 줄이시오'],
        },
    },
    'decision': {
        'name': '결정운',
        'subject': '판단 기운은',
        'area_topic': '선택은',
        'task': {
            'good': ['오래 붙잡던 문제를 정리하시오', '미뤄둔 결정을 꺼내시오'],
            'neutral': ['기준부터 다시 세우시오', '선택지를 줄이시오'],
            'bad': ['큰 결정은 미루시오', '확신 없는 선택은 피하시오'],
        },
    },
}

ELEMENTS = {
    'geum': {
        'focus': '분별',
        'good': '기준이 서니 길이 보이오',
        'neutral': '기준은 있으나 말이 굳을 수 있소',
        'bad': '분별이 날카로워 말이 앞설 수 있소',
        'df': '분별이 흐려 한 번 더 살펴야 하오',
        'ex': '분별이 강해 말이 차가울 수 있소',
    },
    'hwa': {
        'focus': '불기운',
        'good': '움직일 힘이 살아 있소',
        'neutral': '기운은 있으나 속도를 낮추시오',
        'bad': '열기가 앞서 일이 커질 수 있소',
        'df': '불기운이 약해 시작이 더딜 수 있소',
        'ex': '불기운이 강해 행동이 앞설 수 있소',
    },
    'mok': {
        'focus': '목기운',
        'good': '새 길이 보이오',
        'neutral': '가능성은 있으나 일을 늘리지 마시오',
        'bad': '가지가 퍼져 마음이 흐트러질 수 있소',
        'df': '목기운이 약해 새 시도가 부담스럽소',
        'ex': '목기운이 강해 일이 늘 수 있소',
    },
    'su': {
        'focus': '물기운',
        'good': '때를 읽는 감이 살아 있소',
        'neutral': '감은 있으나 결론은 늦을 수 있소',
        'bad': '마음이 흔들려 결정이 밀릴 수 있소',
        'df': '물기운이 약해 때를 잡기 어렵소',
        'ex': '물기운이 강해 결론을 미루기 쉽소',
    },
    'to': {
        'focus': '토기운',
        'good': '중심이 크게 흔들리지 않소',
        'neutral': '안정은 있으나 시작이 늦을 수 있소',
        'bad': '안전만 찾다 마음이 무거워질 수 있소',
        'df': '토기운이 약해 작은 변수에도 흔들릴 수 있소',
        'ex': '토기운이 강해 움직임이 늦을 수 있소',
    },
}

TIERS = {
    'A': {
        'bucket': 'good',
        'intro': [
            '{name}이 좋소. 오늘은 물러서기보다 나설 때요',
            '{subject} 맑게 열려 있소. 뜻을 세워도 좋겠소',
        ],
        'effect': [
            '{area_topic} 좋은 쪽으로 풀릴 가능성이 크오',
            '움직이면 결과가 따를 기운이 있소',
        ],
        'action_tail': ['오늘은 과감히 움직이시오', '좋은 때를 그냥 보내지 마시오'],
    },
    'B': {
        'bucket': 'good',
        'intro': [
            '{name}이 괜찮소. 큰 욕심만 덜면 길이 보이오',
            '{subject} 안정되어 있소. 차분히 나아가시오',
        ],
        'effect': [
            '{area_topic} 무난히 풀릴 수 있소',
            '기대한 것보다 괜찮은 답이 올 수 있소',
        ],
        'action_tail': ['망설이지 말고 해보시오', '이 정도면 움직일 만하오'],
    },
    'B1': {
        'bucket': 'neutral',
        'intro': [
            '{name}은 중간 이상이오. 방심만 삼가시오',
            '{subject} 나쁘지 않으나 다시 살피시오',
        ],
        'effect': [
            '{area_topic} 확인한 만큼 안정되오',
            '작은 점검이 뒤탈을 줄여줄 것이오',
        ],
        'action_tail': ['한 번 더 살피고 움직이시오', '순서를 지키면 무난하오'],
    },
    'C': {
        'bucket': 'bad',
        'intro': [
            '{name}은 조심해야 하오. 섣불리 나서지 마시오',
            '{subject} 쉽게 풀리지 않소. 천천히 가시오',
        ],
        'effect': [
            '{area_topic} 기대보다 늦게 반응할 수 있소',
            '작은 일도 번거롭게 번질 수 있소',
        ],
        'action_tail': ['오늘은 줄이는 편이 이롭소', '무리하면 피로가 따르오'],
    },
    'C1': {
        'bucket': 'bad',
        'intro': [
            '{name}이 낮소. 욕심을 먼저 거두시오',
            '{subject} 흔들릴 수 있소. 감만 믿지 마시오',
        ],
        'effect': [
            '{area_topic} 작은 변수에도 흔들릴 수 있소',
            '무리하면 결과보다 피로가 남겠소',
        ],
        'action_tail': ['쉬운 것부터 다루시오', '남길 것은 내일로 넘기시오'],
    },
    'D': {
        'bucket': 'bad',
        'intro': [
            '{name}이 흐리오. 억지로 좋게 볼 일은 아니오',
            '{subject} 막혀 있소. 밀어붙이지 마시오',
        ],
        'effect': [
            '{area_topic} 뜻대로 가지 않을 수 있소',
            '작은 일도 크게 느껴질 수 있소',
        ],
        'action_tail': ['오늘은 조용히 넘기시오', '회복할 틈을 남기시오'],
    },
}

WEATHERS = {
    'earth': '차분한 기운이 속도를 낮추오',
    'fire': '밝은 기운에 말이 빨라질 수 있소',
    'water': '물기운이 깊어 결론이 늦을 수 있소',
    'wood': '변화가 많아 생각이 퍼질 수 있소',
}

SUSPICIOUS_PATTERNS = [
    '은은',
    '는는',
    '을을',
    '를를',
    '기세이',
    '분위기은',
    '관계을',
    '기운를',
    '택이',
    '피에',
    '구간',
    '단계',
    '같은 흐름',
    '까지 헤아려',
    '뜻을 두시오',
    '방향을 정리합니다',
]
FORBIDDEN = ['하시옵소서', '옳사옵니다', '도모하심', '하옵니다', '옳소이다']


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
            return f"{ctx['name']}은 {ctx['focus']}이 살아 있소. 나서도 좋겠소"
        if bucket == 'neutral':
            return f"{ctx['name']}은 {ctx['focus']}을 다시 살피시오. 서두르진 마시오"
        return f"{ctx['name']}은 {ctx['focus']}이 흔들리오. 욕심을 낮추시오"
    if text_type == 'effect':
        if bucket == 'good':
            return f"{ctx['area_topic']} 좋은 쪽으로 풀릴 수 있소. {ctx['good']}"
        if bucket == 'neutral':
            return f"{ctx['area_topic']} 확인한 만큼 안정되오. {ctx['neutral']}"
        return f"{ctx['area_topic']} 작은 일도 번거로울 수 있소. {ctx['bad']}"
    if text_type == 'action':
        actions = ctx['task'][bucket]
        action = pick(actions, len(str(meta['element'])) + len(str(meta['category'])))
        tail = pick(tier['action_tail'], len(str(meta['element'])))
        return f'{action}. {tail}'
    raise ValueError(f'unsupported elem type={text_type}')


def state_text(meta: dict[str, str | bool]) -> str:
    element_key = str(meta['element'])
    element = ELEMENTS[element_key]
    focus = element['focus']
    tier = str(meta['tier'])
    strength = str(meta['strength'])
    weather = str(meta['weather'])
    if tier in {'A', 'B'}:
        if strength == 'df':
            element_state = f'{focus}이 조금 흐려도 오늘은 바로잡을 수 있소'
        else:
            element_state = f'{focus}이 강하게 살아 길을 돕소'
        weather_state = {
            'earth': '차분한 기운도 길을 돕소',
            'fire': '밝은 기운이 힘을 보태오',
            'water': '물기운도 때를 맞추오',
            'wood': '변화도 좋은 쪽으로 움직이오',
        }[weather]
        return f'{element_state}. {weather_state}'
    if tier == 'B1':
        return f"{element[strength]}. {WEATHERS[weather]}"
    if strength == 'df':
        element_state = f'{focus}이 약해 한 번 더 살펴야 하오'
    else:
        element_state = f'{focus}이 과해 조절이 필요하오'
    return f'{element_state}. {WEATHERS[weather]}'


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
    backup = BACKUP_DIR / f'fortune_ko_historical_before_rewrite_{stamp}.csv'
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
