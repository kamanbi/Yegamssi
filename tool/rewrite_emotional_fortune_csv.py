import csv
import shutil
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
STYLE_DIR = ROOT / 'etc' / 'fortune_styles'
BASE = STYLE_DIR / 'fortune_ko_base.csv'
TARGET = STYLE_DIR / 'fortune_ko_emotional.csv'
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
        'subject': '하루의 기운은',
        'area_topic': '오늘 하루는',
        'area_loc': '오늘 하루에는',
        'task': {
            'good': ['미뤄둔 일 하나를 차분히 시작해보세요', '중요한 일정부터 조용히 정리해보세요'],
            'neutral': ['일정을 조금 단순하게 정리해보세요', '평소 루틴을 편안히 지켜보세요'],
            'bad': ['일을 크게 벌이지 말고 오늘 할 만큼만 남겨보세요', '무리한 약속은 줄이고 숨 쉴 틈을 남겨두세요'],
        },
    },
    'money': {
        'name': '재물운',
        'subject': '돈의 흐름은',
        'area_topic': '재정은',
        'area_loc': '재정에서는',
        'task': {
            'good': ['미뤄둔 정산을 편안히 마무리해보세요', '쓸 돈과 묶을 돈을 조용히 나눠보세요'],
            'neutral': ['지출 기준을 다시 살펴보세요', '작은 새는 돈부터 천천히 막아보세요'],
            'bad': ['충동 결제는 잠시 미뤄두세요', '돈 나갈 일은 오늘만큼은 줄여보세요'],
        },
    },
    'love': {
        'name': '연애운',
        'subject': '마음은',
        'area_topic': '관계는',
        'area_loc': '관계에서는',
        'task': {
            'good': ['먼저 짧게 말을 건네보세요', '진심은 길게 꾸미지 말고 담백하게 전해보세요'],
            'neutral': ['말의 온도를 조금 낮춰보세요', '상대의 속도에 맞춰 천천히 다가가보세요'],
            'bad': ['감정적인 말은 잠시 아껴두세요', '오해가 생길 말은 오늘만큼은 피해보세요'],
        },
    },
    'work': {
        'name': '업무운',
        'subject': '일의 흐름은',
        'area_topic': '업무는',
        'area_loc': '업무에서는',
        'task': {
            'good': ['중요한 일부터 차분히 처리해보세요', '성과가 보이는 일에 먼저 마음을 두세요'],
            'neutral': ['일의 순서부터 다시 정해보세요', '속도보다 확인을 먼저 챙겨보세요'],
            'bad': ['새 일은 잠시 미루고 지금 일부터 닫아보세요', '실수하기 쉬운 부분을 한 번 더 살펴보세요'],
        },
    },
    'health': {
        'name': '건강운',
        'subject': '컨디션은',
        'area_topic': '몸 상태는',
        'area_loc': '몸 상태에는',
        'task': {
            'good': ['가벼운 활동부터 시작해보세요', '몸을 조금 더 부드럽게 움직여보세요'],
            'neutral': ['몸 상태를 먼저 살펴보세요', '무리하지 말고 일상을 가볍게 유지해보세요'],
            'bad': ['휴식부터 먼저 챙겨보세요', '무리한 활동은 줄이고 몸의 신호를 들어보세요'],
        },
    },
    'decision': {
        'name': '결정운',
        'subject': '판단은',
        'area_topic': '선택은',
        'area_loc': '선택에서는',
        'task': {
            'good': ['오래 붙잡던 문제를 조용히 정리해보세요', '미뤄둔 결정을 천천히 꺼내보세요'],
            'neutral': ['기준부터 다시 세워보세요', '선택지를 조금 줄여보세요'],
            'bad': ['큰 결정은 잠시 미뤄두세요', '확신 없는 선택은 오늘만큼은 피해주세요'],
        },
    },
}

ELEMENTS = {
    'geum': {
        'focus': '판단',
        'good': '필요한 것과 아닌 것이 조금 더 선명하게 보입니다',
        'neutral': '기준은 보이지만 말이 조금 단단해질 수 있습니다',
        'bad': '판단이 예민해져 마음보다 말이 먼저 나갈 수 있습니다',
        'df': '판단 기준이 흐려져 천천히 살필 필요가 있습니다',
        'ex': '판단이 단단해져 말이 차갑게 느껴질 수 있습니다',
    },
    'hwa': {
        'focus': '활력',
        'good': '움직이려는 힘이 살아나 시작이 한결 가벼워집니다',
        'neutral': '활력은 있지만 속도를 조금 낮추는 편이 편합니다',
        'bad': '마음이 앞서면 작은 말도 크게 번질 수 있습니다',
        'df': '활력이 낮아 시작까지 시간이 걸릴 수 있습니다',
        'ex': '활력이 강해 판단보다 행동이 앞설 수 있습니다',
    },
    'mok': {
        'focus': '가능성',
        'good': '새로운 방법이 보여 막힌 마음이 조금 풀립니다',
        'neutral': '가능성은 보이지만 할 일을 늘리지는 않는 편이 좋습니다',
        'bad': '하고 싶은 일이 많아져 마음이 쉽게 흩어질 수 있습니다',
        'df': '새 시도가 부담스러워 마음이 작아질 수 있습니다',
        'ex': '가능성이 많아 보여 일이 쉽게 늘어날 수 있습니다',
    },
    'su': {
        'focus': '타이밍',
        'good': '말하지 않아도 알게 되는 순간이 생길 수 있습니다',
        'neutral': '느낌은 오지만 결론은 조금 늦게 잡히는 편입니다',
        'bad': '마음이 흔들려 결정이 뒤로 밀릴 수 있습니다',
        'df': '타이밍을 잡기 어려워 늦게 느껴질 수 있습니다',
        'ex': '느낌이 많아져 결론을 미루기 쉽습니다',
    },
    'to': {
        'focus': '안정감',
        'good': '느리더라도 중심을 잃지 않고 이어갈 수 있습니다',
        'neutral': '안정은 되지만 시작이 조금 늦어질 수 있습니다',
        'bad': '안전한 길만 찾다가 마음이 더 무거워질 수 있습니다',
        'df': '중심이 약해 작은 변수에도 흔들릴 수 있습니다',
        'ex': '안정감을 찾다 움직임이 느려질 수 있습니다',
    },
}

TIERS = {
    'A': {
        'bucket': 'good',
        'intro': [
            '{name}은 편안하게 열려 있습니다. 오늘은 마음을 조금 더 내봐도 괜찮겠습니다',
            '{subject} 평소보다 가볍습니다. 조심스럽게 시작해도 좋은 날입니다',
        ],
        'effect': [
            '{area_loc} 기대보다 부드러운 결과가 생길 수 있습니다',
            '작은 시도가 생각보다 좋은 방향으로 이어질 수 있습니다',
        ],
        'action_tail': [
            '그 정도 용기는 괜찮습니다',
            '너무 오래 미루지 않아도 됩니다',
        ],
    },
    'B': {
        'bucket': 'good',
        'intro': [
            '{name}은 무난하게 좋습니다. 큰 욕심만 내려두면 편안히 이어집니다',
            '{subject} 안정적으로 유지됩니다. 차분히 움직이기 좋은 날입니다',
        ],
        'effect': [
            '{area_topic} 크게 흔들리지 않고 필요한 만큼 따라와 줍니다',
            '기대한 만큼은 아니어도 마음이 놓이는 결과가 보입니다',
        ],
        'action_tail': [
            '천천히 해도 괜찮습니다',
            '작게 시작하면 마음이 가벼워집니다',
        ],
    },
    'B1': {
        'bucket': 'neutral',
        'intro': [
            '{name}은 나쁘지 않습니다. 다만 한 번 더 살피면 더 편해집니다',
            '{subject} 조용히 버티고 있습니다. 서두르지 않으면 괜찮습니다',
        ],
        'effect': [
            '{area_topic} 확인한 만큼 안정됩니다. 작은 점검이 마음을 덜어줍니다',
            '큰 변화보다 작은 정리가 더 도움이 되는 날입니다',
        ],
        'action_tail': [
            '한 번 더 살피면 편해집니다',
            '속도보다 편안한 순서가 중요합니다',
        ],
    },
    'C': {
        'bucket': 'bad',
        'intro': [
            '{name}은 조금 조심스럽습니다. 오늘은 마음을 몰아붙이지 않는 편이 좋겠습니다',
            '{subject} 쉽게 가벼워지지 않습니다. 천천히 걸어가도 괜찮습니다',
        ],
        'effect': [
            '{area_loc} 기대보다 반응이 늦을 수 있습니다',
            '작은 일이 마음을 건드릴 수 있으니 여유를 남겨두세요',
        ],
        'action_tail': [
            '무리하지 않는 쪽이 안전합니다',
            '할 수 있는 만큼만 해도 됩니다',
        ],
    },
    'C1': {
        'bucket': 'bad',
        'intro': [
            '{name}은 낮게 가라앉아 있습니다. 오늘은 자신에게 조금 너그러워도 됩니다',
            '{subject} 흔들릴 수 있습니다. 중요한 일일수록 천천히 보세요',
        ],
        'effect': [
            '{area_topic} 작은 변수에도 마음이 쉽게 지칠 수 있습니다',
            '무리하면 결과보다 피로가 더 오래 남을 수 있습니다',
        ],
        'action_tail': [
            '쉬운 선택을 먼저 두세요',
            '남겨둘 일은 내일로 보내도 됩니다',
        ],
    },
    'D': {
        'bucket': 'bad',
        'intro': [
            '{name}은 많이 무겁습니다. 오늘은 잘하려 하기보다 버티는 것으로 충분합니다',
            '{subject} 막힌 듯 느껴질 수 있습니다. 억지로 밀지 않아도 됩니다',
        ],
        'effect': [
            '{area_topic} 뜻대로 움직이지 않아 마음이 지칠 수 있습니다',
            '작은 일도 크게 느껴질 수 있으니 자신을 너무 몰아세우지 마세요',
        ],
        'action_tail': [
            '조용히 지나가도 괜찮습니다',
            '회복할 자리를 남겨두세요',
        ],
    },
}

WEATHERS = {
    'earth': '차분한 기운이 속도를 낮춥니다',
    'fire': '밝은 기운에 말과 행동이 빨라질 수 있습니다',
    'water': '감정이 깊어져 결론이 늦어질 수 있습니다',
    'wood': '변화의 기운에 생각이 여러 방향으로 뻗습니다',
}

STATE_ENDINGS = {
    'A': '전체적으로는 부드럽게 이어질 여지가 있습니다',
    'B': '크게 흔들리지는 않지만 작은 확인이 도움이 됩니다',
    'B1': '천천히 살피면 무난하게 지나갈 수 있습니다',
    'C': '작은 일에도 마음이 예민해질 수 있습니다',
    'C1': '무리하면 피로가 오래 남을 수 있습니다',
    'D': '오늘은 쉬어 갈 공간을 남겨두는 편이 좋습니다',
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
    '있어 있어요',
    '구간',
    '단계',
    '같은 흐름',
    '마음의 결',
    '작은 빛',
    '흐름을 믿',
    '온기를',
    '별이',
]
FORBIDDEN = ['AI', '분석 결과', '데이터 기준', '갓생', 'ㄹㅇ', '운빨', '★']


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
                f"{ctx['name']}은 {ctx['focus']}이 부드럽게 살아납니다. "
                '편안히 움직여도 됩니다'
            )
        if bucket == 'neutral':
            return (
                f"{ctx['name']}은 {ctx['focus']}을 한 번 더 살피면 좋겠습니다. "
                '서두르지 않아도 됩니다'
            )
        return (
            f"{ctx['name']}은 {ctx['focus']}이 흔들릴 수 있습니다. "
                '마음을 낮춰 잡아도 됩니다'
        )
    if text_type == 'effect':
        if bucket == 'good':
            return f"{ctx['area_topic']} 편안히 이어질 수 있습니다. {ctx['good']}"
        if bucket == 'neutral':
            return f"{ctx['area_topic']} 확인한 만큼 안정됩니다. {ctx['neutral']}"
        return f"{ctx['area_topic']} 작은 일에도 마음이 쓰입니다. {ctx['bad']}"
    if text_type == 'action':
        actions = ctx['task'][bucket]
        action = pick(actions, len(str(meta['element'])) + len(str(meta['category'])))
        tail = pick(tier['action_tail'], len(str(meta['element'])))
        return f'{action}. {tail}'
    raise ValueError(f'unsupported elem type={text_type}')


def state_text(meta: dict[str, str | bool]) -> str:
    element = ELEMENTS[str(meta['element'])]
    strength = str(meta['strength'])
    weather = str(meta['weather'])
    element_state = element[strength]
    weather_state = WEATHERS[weather]
    return f'{element_state}. {weather_state}'


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
        if len(text) > 120:
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
    backup = BACKUP_DIR / f'fortune_ko_emotional_before_rewrite_{stamp}.csv'
    shutil.copy2(TARGET, backup)

    next_rows = build_rows(base_rows)
    validate(base_rows, next_rows)
    write_rows(TARGET, next_rows)
    print(f'backup={backup}')
    print(f'rows={len(next_rows)} unique_texts={len({row["text"] for row in next_rows})}')


if __name__ == '__main__':
    main()
