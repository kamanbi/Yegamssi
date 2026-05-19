import csv
import shutil
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
STYLE_DIR = ROOT / 'etc' / 'fortune_styles'
BASE = STYLE_DIR / 'fortune_ko_base.csv'
TARGET = STYLE_DIR / 'fortune_ko_ai.csv'
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
        'signal': '하루 전체 신호가',
        'area_topic': '오늘 하루는',
        'task': {
            'good': ['중요한 일정부터 처리하세요', '미뤄둔 일을 하나 시작하세요'],
            'neutral': ['일정을 단순하게 정리하세요', '평소 루틴을 유지하세요'],
            'bad': ['새 일을 늘리지 마세요', '무리한 약속은 줄이세요'],
        },
    },
    'money': {
        'name': '재물운',
        'signal': '지출과 수입 신호가',
        'area_topic': '재정 흐름은',
        'task': {
            'good': ['정산과 예산을 먼저 정리하세요', '쓸 돈과 묶을 돈을 나누세요'],
            'neutral': ['지출 기준을 다시 확인하세요', '작은 결제부터 줄이세요'],
            'bad': ['충동 결제는 보류하세요', '돈 나갈 일은 최소화하세요'],
        },
    },
    'love': {
        'name': '연애운',
        'signal': '관계 반응 신호가',
        'area_topic': '관계 흐름은',
        'task': {
            'good': ['먼저 짧게 말을 건네세요', '진심은 담백하게 전하세요'],
            'neutral': ['말의 온도를 낮추세요', '상대의 속도에 맞추세요'],
            'bad': ['감정적인 말은 보류하세요', '오해가 생길 표현은 피하세요'],
        },
    },
    'work': {
        'name': '업무운',
        'signal': '업무 처리 신호가',
        'area_topic': '업무 흐름은',
        'task': {
            'good': ['중요한 일부터 처리하세요', '성과가 보이는 일에 먼저 집중하세요'],
            'neutral': ['업무 순서를 다시 정하세요', '속도보다 확인을 우선하세요'],
            'bad': ['새 업무 확장은 미루세요', '실수 가능성이 큰 부분부터 점검하세요'],
        },
    },
    'health': {
        'name': '건강운',
        'signal': '컨디션 신호가',
        'area_topic': '몸 상태는',
        'task': {
            'good': ['가벼운 활동부터 시작하세요', '몸을 조금 더 움직여도 좋습니다'],
            'neutral': ['컨디션을 먼저 확인하세요', '무리하지 말고 일상을 유지하세요'],
            'bad': ['휴식을 먼저 확보하세요', '무리한 활동은 줄이세요'],
        },
    },
    'decision': {
        'name': '결정운',
        'signal': '판단 신뢰도가',
        'area_topic': '선택 흐름은',
        'task': {
            'good': ['오래 붙잡던 문제를 정리하세요', '미뤄둔 결정을 검토하세요'],
            'neutral': ['판단 기준부터 다시 세우세요', '선택지를 줄이세요'],
            'bad': ['큰 결정은 보류하세요', '확신 없는 선택은 피하세요'],
        },
    },
}

ELEMENTS = {
    'geum': {
        'focus': '판단 기준',
        'focus_subject': '판단 기준이',
        'metric': '정리 변수',
        'good': '기준이 선명해서 판단 오차가 낮습니다',
        'neutral': '기준은 있지만 표현이 단단해질 수 있습니다',
        'bad': '기준이 과해져 반응이 날카로울 수 있습니다',
        'df': '판단 기준이 낮아져 재확인이 필요합니다',
        'ex': '판단 기준이 강해져 유연성이 줄 수 있습니다',
    },
    'hwa': {
        'focus': '실행 에너지',
        'focus_subject': '실행 에너지가',
        'metric': '활성 변수',
        'good': '실행 에너지가 충분해 움직임이 빠릅니다',
        'neutral': '실행력은 있지만 속도 조절이 필요합니다',
        'bad': '실행이 앞서면 변수 대응이 늦을 수 있습니다',
        'df': '실행 에너지가 낮아 시작 반응이 느립니다',
        'ex': '실행 에너지가 높아 행동이 앞설 수 있습니다',
    },
    'mok': {
        'focus': '확장 가능성',
        'focus_subject': '확장 가능성이',
        'metric': '성장 변수',
        'good': '새 선택지를 찾는 능력이 좋습니다',
        'neutral': '가능성은 있지만 범위 관리가 필요합니다',
        'bad': '선택지가 많아져 집중도가 낮아질 수 있습니다',
        'df': '확장 신호가 낮아 새 시도가 부담될 수 있습니다',
        'ex': '확장 신호가 높아 일이 늘어날 수 있습니다',
    },
    'su': {
        'focus': '타이밍 감지',
        'focus_subject': '타이밍 감지가',
        'metric': '흐름 변수',
        'good': '타이밍을 읽는 감도가 좋습니다',
        'neutral': '감지는 되지만 결론이 늦어질 수 있습니다',
        'bad': '변동성이 커져 판단이 밀릴 수 있습니다',
        'df': '타이밍 감지가 낮아 흐름을 놓치기 쉽습니다',
        'ex': '타이밍 감지가 과해 결론을 미루기 쉽습니다',
    },
    'to': {
        'focus': '안정 지표',
        'focus_subject': '안정 지표가',
        'metric': '안정 변수',
        'good': '안정 지표가 좋아 흔들림이 적습니다',
        'neutral': '안정성은 있지만 시작이 늦을 수 있습니다',
        'bad': '안정만 우선하면 움직임이 둔해질 수 있습니다',
        'df': '안정 지표가 낮아 작은 변수에도 흔들릴 수 있습니다',
        'ex': '안정 지표가 높아 움직임이 느려질 수 있습니다',
    },
}

TIERS = {
    'A': {
        'bucket': 'good',
        'intro': [
            '분석 결과, {name}은 매우 좋은 구간입니다',
            '데이터 기준으로 {signal} 강하게 올라와 있습니다',
        ],
        'effect': [
            '{area_topic} 원하는 쪽으로 움직일 가능성이 높습니다',
            '예측값이 좋고 리스크 변동폭도 낮은 편입니다',
        ],
        'action_tail': ['오늘은 우선순위를 앞당겨도 좋습니다', '검토한 일은 실행해도 괜찮습니다'],
    },
    'B': {
        'bucket': 'good',
        'intro': [
            '분석 결과, {name}은 좋은 편입니다',
            '데이터 기준으로 {signal} 안정권에 있습니다',
        ],
        'effect': [
            '{area_topic} 무난하게 풀릴 가능성이 있습니다',
            '기대값은 양호하고 큰 변수는 적어 보입니다',
        ],
        'action_tail': ['준비된 일부터 진행하세요', '확인만 마치면 움직여도 좋습니다'],
    },
    'B1': {
        'bucket': 'neutral',
        'intro': [
            '분석 결과, {name}은 중간 이상입니다',
            '데이터 기준으로 {signal} 보통보다 조금 좋습니다',
        ],
        'effect': [
            '{area_topic} 점검한 만큼 안정됩니다',
            '예측값은 나쁘지 않지만 확인 절차가 필요합니다',
        ],
        'action_tail': ['한 번 더 확인한 뒤 진행하세요', '순서를 정리하면 무난합니다'],
    },
    'C': {
        'bucket': 'bad',
        'intro': [
            '분석 결과, {name}은 주의 구간입니다',
            '데이터 기준으로 {signal} 흔들립니다',
        ],
        'effect': [
            '{area_topic} 예상보다 늦게 반응할 수 있습니다',
            '리스크 변동폭이 커져 작은 변수도 커질 수 있습니다',
        ],
        'action_tail': ['오늘은 범위를 줄이세요', '무리한 진행은 피하세요'],
    },
    'C1': {
        'bucket': 'bad',
        'intro': [
            '분석 결과, {name}은 낮은 구간입니다',
            '데이터 기준으로 {signal} 약하게 잡힙니다',
        ],
        'effect': [
            '{area_topic} 작은 변수에도 흔들릴 수 있습니다',
            '예측값이 낮아 결과보다 피로가 커질 수 있습니다',
        ],
        'action_tail': ['핵심만 처리하세요', '남길 수 있는 일은 미루세요'],
    },
    'D': {
        'bucket': 'bad',
        'intro': [
            '분석 결과, {name}은 보류 구간입니다',
            '데이터 기준으로 {signal} 크게 낮습니다',
        ],
        'effect': [
            '{area_topic} 의도와 다르게 흘러갈 수 있습니다',
            '리스크가 높아 작은 결정도 부담이 될 수 있습니다',
        ],
        'action_tail': ['오늘은 회복과 정리에 집중하세요', '큰 선택은 내일 이후로 넘기세요'],
    },
}

WEATHERS = {
    'earth': '환경 신호는 안정적이지만 반응 속도는 낮습니다',
    'fire': '환경 신호가 활발해 말과 행동이 빨라질 수 있습니다',
    'water': '환경 신호의 변동성이 커 결론이 늦어질 수 있습니다',
    'wood': '환경 신호가 확장되어 선택지가 늘어날 수 있습니다',
}

POSITIVE_WEATHERS = {
    'earth': '환경 신호가 안정적으로 작동합니다',
    'fire': '환경 신호가 실행력을 보태고 있습니다',
    'water': '환경 신호가 타이밍을 맞춰줍니다',
    'wood': '환경 신호가 가능성을 넓혀줍니다',
}

SUSPICIOUS_PATTERNS = [
    '은은',
    '는는',
    '을을',
    '를를',
    '구간의',
    '기준값은',
    '동일 점수대',
    '대체 모델',
    '기본 변수',
    '기본 패턴',
    '기본 환경',
    '[',
    ']',
]
FORBIDDEN = ['ㄹㅇ', '갓생', '딱히', '하시오', '하오.', '하오 ', '옵니다', '마땅하오']


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
            return f"분석 결과, {ctx['name']}은 {ctx['focus_subject']} 강점으로 잡힙니다"
        if bucket == 'neutral':
            return f"분석 결과, {ctx['name']}은 {ctx['focus']} 확인이 필요합니다"
        return f"분석 결과, {ctx['name']}은 {ctx['focus']} 리스크가 있습니다"
    if text_type == 'effect':
        if bucket == 'good':
            return f"{ctx['area_topic']} 좋은 쪽으로 움직일 수 있습니다. {ctx['good']}"
        if bucket == 'neutral':
            return f"{ctx['area_topic']} 확인한 만큼 안정됩니다. {ctx['neutral']}"
        return f"{ctx['area_topic']} 작은 변수도 커질 수 있습니다. {ctx['bad']}"
    if text_type == 'action':
        actions = ctx['task'][bucket]
        action = pick(actions, len(str(meta['element'])) + len(str(meta['category'])))
        tail = pick(tier['action_tail'], len(str(meta['element'])))
        return f'{action}. {tail}'
    raise ValueError(f'unsupported elem type={text_type}')


def state_text(meta: dict[str, str | bool]) -> str:
    element_key = str(meta['element'])
    element = ELEMENTS[element_key]
    focus_subject = element['focus_subject']
    tier = str(meta['tier'])
    strength = str(meta['strength'])
    weather = str(meta['weather'])
    if tier in {'A', 'B'}:
        if strength == 'df':
            element_state = f'{focus_subject} 낮아도 보정 가능한 수준입니다'
        else:
            element_state = f'{focus_subject} 강하게 작동해 예측값을 높입니다'
        return f'{element_state}. {POSITIVE_WEATHERS[weather]}'
    if tier == 'B1':
        return f"{element[strength]}. {WEATHERS[weather]}"
    if strength == 'df':
        element_state = f'{focus_subject} 낮아 재확인이 필요합니다'
    else:
        element_state = f'{focus_subject} 과해 조정이 필요합니다'
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
    for base_row, next_row in zip(base_rows, next_rows):
        if (
            base_row['code'] != next_row['code']
            or base_row['type'] != next_row['type']
            or base_row['weight'] != next_row['weight']
        ):
            raise ValueError(f"key mismatch: {base_row['code']} / {next_row['code']}")
        tier = next_row['code'].split('_')[1]
        if tier not in EXPECTED_TIERS:
            raise ValueError(f"bad tier: {next_row['code']}")
        text = next_row['text']
        for pattern in SUSPICIOUS_PATTERNS:
            if pattern in text:
                raise ValueError(f"suspicious pattern {pattern}: {next_row['code']} {text}")
        for word in FORBIDDEN:
            if word in text:
                raise ValueError(f"forbidden word {word}: {next_row['code']} {text}")


def main() -> None:
    base_rows = read_rows(BASE)
    next_rows = build_rows(base_rows)
    validate(base_rows, next_rows)

    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    if TARGET.exists():
        stamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup = BACKUP_DIR / f'fortune_ko_ai_before_rewrite_{stamp}.csv'
        shutil.copy2(TARGET, backup)
        print(f'backup={backup}')

    write_rows(TARGET, next_rows)
    size = TARGET.stat().st_size
    if size > MAX_FILE_BYTES:
        raise ValueError(f'file too large: {size} bytes')
    print(f'rows={len(next_rows)} unique_texts={len({row["text"] for row in next_rows})}')
    print(f'bytes={size}')


if __name__ == '__main__':
    main()
