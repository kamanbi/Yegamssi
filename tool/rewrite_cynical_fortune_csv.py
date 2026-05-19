import csv
import shutil
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
STYLE_DIR = ROOT / 'etc' / 'fortune_styles'
BASE = STYLE_DIR / 'fortune_ko_base.csv'
TARGET = STYLE_DIR / 'fortune_ko_cynical.csv'
BACKUP_DIR = STYLE_DIR / 'backup'

FIELDNAMES = ['code', 'type', 'text', 'weight']
EXPECTED_ROWS = 5976
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
        'area_loc': '오늘 하루에서',
        'area_object': '오늘 하루를',
        'task': {
            'good': ['미뤄둔 일 하나는 오늘 처리해라', '중요한 일정부터 정리해라'],
            'neutral': ['일정을 단순하게 줄여라', '평소 루틴부터 지켜라'],
            'bad': ['일을 크게 벌이지 마라', '무리한 약속은 줄여라'],
        },
    },
    'money': {
        'name': '재물운',
        'subject': '돈의 흐름은',
        'area_topic': '재정은',
        'area_loc': '재정에서',
        'area_object': '재정을',
        'task': {
            'good': ['미뤄둔 정산부터 처리해라', '쓸 돈과 묶을 돈을 나눠라'],
            'neutral': ['지출 기준부터 다시 봐라', '큰돈보다 잔돈 새는 곳부터 막아라'],
            'bad': ['충동 결제는 미뤄라', '돈 나갈 일은 최대한 줄여라'],
        },
    },
    'love': {
        'name': '연애운',
        'subject': '마음은',
        'area_topic': '관계는',
        'area_loc': '관계에서',
        'area_object': '관계를',
        'task': {
            'good': ['먼저 짧게 말을 건네라', '진심은 짧게 표현해라'],
            'neutral': ['말의 온도부터 낮춰라', '상대 속도에 맞춰라'],
            'bad': ['감정적인 말은 아껴라', '오해가 생길 말은 피하라'],
        },
    },
    'work': {
        'name': '업무운',
        'subject': '일의 흐름은',
        'area_topic': '업무는',
        'area_loc': '업무에서',
        'area_object': '업무를',
        'task': {
            'good': ['중요한 일부터 처리해라', '성과가 보이는 일에 집중해라'],
            'neutral': ['일의 순서부터 다시 정해라', '속도보다 확인을 먼저 해라'],
            'bad': ['새 일은 벌이지 마라', '실수하기 쉬운 부분부터 다시 봐라'],
        },
    },
    'health': {
        'name': '건강운',
        'subject': '컨디션은',
        'area_topic': '몸 상태는',
        'area_loc': '몸 상태에서',
        'area_object': '몸 상태를',
        'task': {
            'good': ['가벼운 활동부터 시작해라', '몸을 조금 더 움직여라'],
            'neutral': ['몸 상태부터 살펴라', '무리하지 말고 일상을 유지해라'],
            'bad': ['휴식부터 챙겨라', '무리한 활동은 줄여라'],
        },
    },
    'decision': {
        'name': '결정운',
        'subject': '판단은',
        'area_topic': '선택은',
        'area_loc': '선택에서',
        'area_object': '선택을',
        'task': {
            'good': ['오래 붙잡던 문제를 정리해라', '미뤄둔 결정을 꺼내라'],
            'neutral': ['기준부터 다시 세워라', '선택지를 줄여라'],
            'bad': ['큰 결정은 미뤄라', '확신 없는 선택은 피하라'],
        },
    },
}

ELEMENTS = {
    'geum': {
        'focus': '정리력',
        'good': '기준이 선명해서 쓸데없는 고민은 덜하다',
        'neutral': '기준은 보이지만 말이 딱딱해질 수 있다',
        'bad': '판단이 날카로운 척하다가 괜히 상처를 낼 수 있다',
        'df': '정리력이 약해 기준이 조금 흐리다',
        'ex': '정리력이 과해 말과 선택이 딱딱해질 수 있다',
    },
    'hwa': {
        'focus': '추진력',
        'good': '속도가 붙어 미루던 일을 밀어내기 좋다',
        'neutral': '속도는 있는데 브레이크가 같이 필요하다',
        'bad': '기분이 앞서면 말보다 사고가 먼저 도착할 수 있다',
        'df': '추진력이 약해 시작까지 시간이 걸린다',
        'ex': '추진력이 강해 판단보다 속도가 앞설 수 있다',
    },
    'mok': {
        'focus': '확장성',
        'good': '새 방법이 보여 막힌 길을 돌아갈 수 있다',
        'neutral': '가능성은 보이지만 일을 늘리기 쉽다',
        'bad': '가지가 너무 뻗어 할 일이 괜히 늘어날 수 있다',
        'df': '확장 기운이 약해 새 시도가 부담스럽다',
        'ex': '확장 기운이 강해 일을 너무 많이 벌릴 수 있다',
    },
    'su': {
        'focus': '흐름 감',
        'good': '타이밍을 잡으면 힘을 덜 쓰고 넘어간다',
        'neutral': '흐름은 보이지만 결론이 늦어질 수 있다',
        'bad': '흐름만 보다가 정작 결정은 뒤로 밀릴 수 있다',
        'df': '흐름 감이 약해 타이밍을 놓치기 쉽다',
        'ex': '흐름 감이 강해 결론을 미루기 쉽다',
    },
    'to': {
        'focus': '안정감',
        'good': '속도는 느려도 크게 흔들리지는 않는다',
        'neutral': '안정은 되지만 움직임이 굼뜰 수 있다',
        'bad': '안전하게 가려다 시작 자체가 늦어질 수 있다',
        'df': '안정감이 약해 작은 변수에도 흔들릴 수 있다',
        'ex': '안정감이 강해 움직임이 느려질 수 있다',
    },
}

TIERS = {
    'A': {
        'bucket': 'good',
        'intro': [
            '{name}은 꽤 좋다. 이런 날은 드물다, 써먹는 편이 낫다',
            '{subject} 평소보다 덜 삐걱거린다. 이 정도면 쓸 만하다',
        ],
        'effect': [
            '{area_loc} 기대보다 나은 결과가 나온다. 인생이 바뀌진 않아도 도움은 된다',
            '손해 볼 확률은 낮다. 오늘은 드물게 조건이 편을 든다',
        ],
        'action_tail': [
            '좋을 때 처리하는 게 덜 귀찮다',
            '미뤄도 결국 다시 돌아온다',
        ],
    },
    'B': {
        'bucket': 'good',
        'intro': [
            '{name}은 괜찮은 편이다. 대단하진 않아도 쓸모는 있다',
            '{subject} 무난하게 버틴다. 오늘은 그 정도면 충분하다',
        ],
        'effect': [
            '{area_topic} 크게 꼬이지 않는다. 괜히 욕심만 얹지 않으면 된다',
            '작은 성과는 챙길 수 있다. 기대치를 조금만 낮추면 꽤 괜찮다',
        ],
        'action_tail': [
            '지금 하는 편이 나중의 너에게 덜 미안하다',
            '괜히 멋 부리지 말고 처리해라',
        ],
    },
    'B1': {
        'bucket': 'neutral',
        'intro': [
            '{name}은 중간은 넘는다. 방심하지 않으면 체면은 지킨다',
            '{subject} 나쁘지 않지만 믿고 맡길 정도는 아니다',
        ],
        'effect': [
            '{area_topic} 확인한 만큼만 안전하다. 대충 넘기면 대충 돌아온다',
            '큰 문제는 적지만 디테일이 귀찮게 굴 수 있다',
        ],
        'action_tail': [
            '한 번 더 보는 게 결국 싸게 먹힌다',
            '큰 의미를 붙이지 말고 현실적으로 처리해라',
        ],
    },
    'C': {
        'bucket': 'bad',
        'intro': [
            '{name}은 조심스럽다. 뭘 해도 한 번씩 걸리는 날이다',
            '{subject} 기대하지 않는 편이 낫다. 기대는 자주 비용이 든다',
        ],
        'effect': [
            '{area_loc} 수습할 일이 생길 수 있다. 별일 아닌 게 제일 귀찮다',
            '계획대로 안 될 가능성이 있다. 특별한 일은 아니고 그냥 오늘이 그렇다',
        ],
        'action_tail': [
            '덜 망치는 게 오늘의 현실적인 목표다',
            '새로 벌이면 정리할 일만 늘어난다',
        ],
    },
    'C1': {
        'bucket': 'bad',
        'intro': [
            '{name}은 낮은 편이다. 오늘은 이기는 것보다 덜 꼬이는 게 목표다',
            '{subject} 흔들린다. 네 감을 과대평가할 타이밍은 아니다',
        ],
        'effect': [
            '{area_topic} 작은 변수도 크게 귀찮아질 수 있다',
            '무리하면 얻는 것보다 뒤처리가 커질 수 있다',
        ],
        'action_tail': [
            '오늘은 손해를 줄이는 쪽이 이기는 쪽이다',
            '굳이 어려운 길을 고를 필요는 없다',
        ],
    },
    'D': {
        'bucket': 'bad',
        'intro': [
            '{name}은 좋지 않다. 굳이 포장하면 시간 낭비다',
            '{subject} 막혀 있다. 억지로 밀면 피곤만 성실해진다',
        ],
        'effect': [
            '{area_topic} 뜻대로 움직이지 않는다. 오늘은 그런 날도 있다',
            '작은 일도 크게 번질 수 있다. 불씨 관리는 원래 재미없다',
        ],
        'action_tail': [
            '오늘은 조용히 지나가는 게 실속 있다',
            '사람 일이라는 게 원래 계획대로만 되진 않는다',
        ],
    },
}

WEATHERS = {
    'earth': '차분한 기운이 속도를 낮춘다',
    'fire': '열기가 올라 판단보다 말이 앞설 수 있다',
    'water': '흐름이 늘어져 결론이 늦을 수 있다',
    'wood': '변화가 많아 일이 쉽게 퍼질 수 있다',
}

STATE_ENDINGS = {
    'A': '그래도 오늘은 버틸 여지가 있다',
    'B': '큰 문제는 아니지만 확인은 필요하다',
    'B1': '무난하게 넘기려면 속도를 낮춰야 한다',
    'C': '작은 변수도 귀찮아질 수 있다',
    'C1': '무리하면 뒤처리가 더 커진다',
    'D': '오늘은 쉬어 가는 쪽이 덜 손해다',
}

SUSPICIOUS_PATTERNS = [
    '은은',
    '는는',
    '이이',
    '가가',
    '을을',
    '를를',
    '분위기을',
    '흐름은은',
    '업무은',
    '관계은',
    '선택은은',
    '몸 상태는은',
    '재정은은',
    '막라',
    '피 쪽',
    '택 쪽',
    '처리에는',
    '기에는',
    '정리합니다',
]
FORBIDDEN = ['절망', '다 망', '답이 없다', '희망을 가져', '응원']


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
            return (
                f"{ctx['name']}은 {ctx['focus']}이 버텨줘서 생각보다 괜찮다. "
                '큰 의미까진 필요 없다'
            )
        if bucket == 'neutral':
            return (
                f"{ctx['name']}은 {ctx['focus']}이 애매하다. "
                '확인 없이 밀기엔 좀 귀찮다'
            )
        return (
            f"{ctx['name']}은 {ctx['focus']}이 흔들린다. "
            '오늘은 감을 과대평가하지 마라'
        )
    if text_type == 'effect':
        if bucket == 'good':
            return f"{ctx['area_topic']} 예상보다 덜 꼬인다. {ctx['good']}"
        if bucket == 'neutral':
            return f"{ctx['area_topic']} 확인한 만큼만 안전하다. {ctx['neutral']}"
        return f"{ctx['area_topic']} 작은 변수도 귀찮아질 수 있다. {ctx['bad']}"
    if text_type == 'action':
        actions = ctx['task'][bucket]
        action = pick(actions, len(str(meta['element'])) + len(str(meta['category'])))
        tail = pick(tier['action_tail'], len(str(meta['element'])))
        return f'{action}. {tail}'
    raise ValueError(f'unsupported elem type={text_type}')


def state_text(meta: dict[str, str | bool]) -> str:
    ctx = context(meta)
    element = ELEMENTS[str(meta['element'])]
    strength = str(meta['strength'])
    weather = str(meta['weather'])
    tier = str(meta['tier'])
    element_state = element[strength]
    weather_state = WEATHERS[weather]
    ending = STATE_ENDINGS[tier]
    return f'{element_state}. {weather_state}. {ending}'


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
        if len(text) > 110:
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
    backup = BACKUP_DIR / f'fortune_ko_cynical_before_rewrite_{stamp}.csv'
    shutil.copy2(TARGET, backup)

    next_rows = build_rows(base_rows)
    validate(base_rows, next_rows)
    write_rows(TARGET, next_rows)
    print(f'backup={backup}')
    print(f'rows={len(next_rows)} unique_texts={len({row["text"] for row in next_rows})}')


if __name__ == '__main__':
    main()
