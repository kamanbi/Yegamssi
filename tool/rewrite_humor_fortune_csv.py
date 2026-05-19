import csv
import shutil
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / 'etc' / 'fortune_styles' / 'fortune_ko_humor.csv'
BACKUP_DIR = ROOT / 'etc' / 'fortune_styles' / 'backup'

EXPECTED_ROWS = 5976
FIELDNAMES = ['code', 'type', 'text', 'weight']
EXPECTED_TYPE_COUNTS = {
    'intro': 1512,
    'effect': 1512,
    'action': 1512,
    'state': 1440,
}

FORBIDDEN = ['각', '운빨', '★']
SCENARIO_FORBIDDEN = [
    '주연',
    '조연',
    '배우',
    '무대',
    '상황실',
    '축포',
    '출연료',
    '파업',
    '피켓',
    '병가',
    '예능',
    '대체 근무자',
]

CATEGORIES = {
    'overall': {
        'label': '하루',
        'target': '일정',
        'target_subject': '일정이',
        'risk': '잡일',
        'safe': '오늘 할 일은 줄이고 중요한 일만 남기세요',
    },
    'money': {
        'label': '재물',
        'target': '통장',
        'target_subject': '통장이',
        'risk': '결제창',
        'safe': '장바구니는 구경만 하고 결제는 한 번 미루세요',
    },
    'love': {
        'label': '연애',
        'target': '대화',
        'target_subject': '대화가',
        'risk': '카톡 장문',
        'safe': '말을 늘리기보다 답장을 담백하게 보내세요',
    },
    'work': {
        'label': '업무',
        'target': '할 일',
        'target_subject': '할 일이',
        'risk': '회의와 메일',
        'safe': '작은 업무부터 닫고 새 일은 천천히 받으세요',
    },
    'health': {
        'label': '건강',
        'target': '컨디션',
        'target_subject': '컨디션이',
        'risk': '무리한 계획',
        'safe': '물 마시고 스트레칭부터 챙기세요',
    },
    'decision': {
        'label': '결정',
        'target': '선택',
        'target_subject': '선택이',
        'risk': '급한 확인 버튼',
        'safe': '큰 선택은 보류하고 기준부터 다시 보세요',
    },
}

ELEMENTS = {
    'geum': {
        'trait': '정리력',
        'good': '말이 짧아도 핵심은 잘 잡힙니다',
        'bad': '말이 너무 직진해서 상대가 안전거리 찾을 수 있습니다',
    },
    'hwa': {
        'trait': '추진력',
        'good': '시작은 빠른데 브레이크도 같이 챙겨야 합니다',
        'bad': '기분이 앞서면 손이 먼저 나갈 수 있습니다',
    },
    'mok': {
        'trait': '확장성',
        'good': '새 방법이 보이지만 가지를 너무 벌리면 손이 모자랍니다',
        'bad': '할 일을 늘리기 쉬워서 목록이 금방 살찔 수 있습니다',
    },
    'su': {
        'trait': '흐름 감',
        'good': '타이밍을 잘 타면 힘을 덜 쓰고도 지나갑니다',
        'bad': '흐름만 보다가 결론이 늦게 도착할 수 있습니다',
    },
    'to': {
        'trait': '안정감',
        'good': '느리지만 크게 흔들리지는 않습니다',
        'bad': '안전하게 가려다 시작이 너무 늦어질 수 있습니다',
    },
}

BASE_LINES = {
    'A': {
        'intro': [
            '{label} 운은 꽤 좋습니다. 평소라면 미루던 일도 오늘은 덜 밉게 보입니다',
            '{label} 흐름이 좋습니다. 오늘은 일단 해보면 의외로 덜 귀찮습니다',
        ],
        'effect': [
            '{target_subject} 의외로 잘 풀립니다. 평소보다 손이 덜 미끄러지는 날입니다',
            '움직이면 결과가 따라옵니다. 오늘은 노력한 티가 숨지 않습니다',
        ],
        'action': [
            '중요한 일부터 하세요. 지금 미루면 내일의 내가 또 눈으로 욕합니다',
            '하나만 제대로 끝내세요. 오늘은 대충 시작해도 마무리가 꽤 봐줄 만합니다',
        ],
    },
    'B': {
        'intro': [
            '{label} 운은 무난히 좋습니다. 괜히 오버만 안 하면 꽤 쓸 만합니다',
            '{label} 흐름이 나쁘지 않습니다. 오늘은 기본만 해도 본전 이상입니다',
        ],
        'effect': [
            '{target_subject} 크게 꼬이지 않습니다. 이 정도면 하루가 예의는 지킵니다',
            '작은 성과는 챙길 수 있습니다. 너무 큰 기대만 안 얹으면 됩니다',
        ],
        'action': [
            '욕심만 줄이세요. 오늘은 깔끔한 안타가 괜히 홈런보다 낫습니다',
            '순서대로 처리하세요. 새치기하면 일이 바로 표정 나빠집니다',
        ],
    },
    'B1': {
        'intro': [
            '{label} 운은 중간 이상입니다. 다만 감만 믿기엔 오늘의 감이 졸려 보입니다',
            '{label} 흐름은 괜찮습니다. 확인 한 번만 더 하면 체면은 지킵니다',
        ],
        'effect': [
            '{target_subject} 챙겨지지만 방심하면 작은 구멍이 생깁니다',
            '큰 문제는 적지만 디테일이 귀찮게 굴 수 있습니다',
        ],
        'action': [
            '한 번 더 확인하세요. 오늘의 영웅은 용기가 아니라 체크입니다',
            '크게 벌리지 말고 가능한 것부터 하세요. 목록이 많으면 마음도 렉 걸립니다',
        ],
    },
    'C': {
        'intro': [
            '{label} 운은 살짝 삐걱입니다. 되는 일도 한 번씩 비밀번호를 묻습니다',
            '{label} 흐름이 느립니다. 오늘은 빨리하려다 더 오래 걸릴 수 있습니다',
        ],
        'effect': [
            '{target_subject} 뜻대로만 가지 않습니다. 그래도 작게 잡으면 수습은 됩니다',
            '{risk}이 발목을 잡을 수 있습니다. 별일 아닌 게 은근히 귀찮습니다',
        ],
        'action': [
            '새 일은 줄이세요. 열린 창 닫기만 해도 오늘은 충분히 어른입니다',
            '말과 손을 천천히 쓰세요. 급하면 뒤처리만 성실해집니다',
        ],
    },
    'C1': {
        'intro': [
            '{label} 운은 낮은 편입니다. 오늘은 열심히보다 덜 망하기가 더 중요합니다',
            '{label} 흐름이 무겁습니다. 의욕이 출근 도장을 안 찍은 느낌입니다',
        ],
        'effect': [
            '{target_subject} 쉽게 풀리지 않습니다. 애쓰면 피로만 성실하게 쌓입니다',
            '{risk}이 크게 보일 수 있습니다. 오늘은 작은 일도 괜히 덩치가 있습니다',
        ],
        'action': [
            '핵심만 하세요. 나머지는 내일에게 넘기되 너무 티 나게 떠넘기지는 마세요',
            '무리하지 마세요. 오늘의 성과는 조용히 버티는 것일 수 있습니다',
        ],
    },
    'D': {
        'intro': [
            '{label} 운은 낮습니다. 오늘은 큰일보다 조용히 지나가는 게 이득입니다',
            '{label} 흐름이 막혀 있습니다. 억지로 밀면 마음만 야근합니다',
        ],
        'effect': [
            '{target_subject} 잘 안 따라옵니다. 무리하면 일보다 뒤처리가 더 큽니다',
            '{risk}이 문제를 키울 수 있습니다. 오늘은 작은 불씨도 크게 보입니다',
        ],
        'action': [
            '{safe}. 오늘은 이게 제일 현실적인 승리입니다',
            '큰 결정은 미루세요. 오늘의 나를 너무 믿으면 내일의 내가 고생합니다',
        ],
    },
}

ELEM_LINES = {
    'A': {
        'intro': '{label} 운이 좋고 {trait}도 잘 살아납니다. 오늘은 평소보다 덜 헤매도 됩니다',
        'effect': '{good}. {target}도 의외로 순하게 따라옵니다',
        'action': '{target}에서 중요한 것 하나를 먼저 처리하세요. 오늘 미루면 아깝습니다',
    },
    'B': {
        'intro': '{label} 운이 괜찮고 {trait}도 무난합니다. 큰 욕심만 빼면 쓸 만합니다',
        'effect': '{good}. 결과도 본전 이상은 기대할 수 있습니다',
        'action': '{target}은 순서대로 처리하세요. 괜히 멋 부리면 일이 바로 삐집니다',
    },
    'B1': {
        'intro': '{label} 운은 괜찮지만 {trait}을 너무 믿으면 살짝 민망해질 수 있습니다',
        'effect': '{bad}. 그래도 한 번 더 확인하면 크게 흔들리진 않습니다',
        'action': '{target}은 작게 나눠서 보세요. 한 번에 다 잡으려면 손이 부족합니다',
    },
    'C': {
        'intro': '{label} 운이 조금 낮고 {trait}도 매끄럽지는 않습니다',
        'effect': '{bad}. 작은 변수도 괜히 존재감을 키울 수 있습니다',
        'action': '{target}에서 새 일을 늘리지 마세요. 오늘은 줄이는 사람이 이깁니다',
    },
    'C1': {
        'intro': '{label} 운이 낮습니다. {trait}도 오늘은 몸을 사리는 쪽입니다',
        'effect': '{bad}. 무리하면 피로만 꼼꼼하게 남습니다',
        'action': '{target}은 핵심만 처리하세요. 나머지는 내일의 나와 협상하세요',
    },
    'D': {
        'intro': '{label} 운이 많이 낮습니다. {trait}도 오늘은 큰 도움을 주기 어렵습니다',
        'effect': '{bad}. 억지로 밀면 수습할 일이 더 생깁니다',
        'action': '{safe}. 오늘은 조용히 지나가는 게 제일 실속 있습니다',
    },
}

STATE_ELEMENT = {
    'geum': {
        'df': '정리력이 부족해 기준이 조금 흐립니다',
        'ex': '정리력이 과해 말과 선택이 딱딱해질 수 있습니다',
    },
    'hwa': {
        'df': '추진력이 약해 시작까지 시간이 걸립니다',
        'ex': '추진력이 강해 속도가 판단보다 앞설 수 있습니다',
    },
    'mok': {
        'df': '확장 기운이 약해 새 시도가 부담스럽게 느껴집니다',
        'ex': '확장 기운이 강해 일을 너무 많이 벌릴 수 있습니다',
    },
    'su': {
        'df': '흐름 감이 약해 타이밍을 놓치기 쉽습니다',
        'ex': '흐름 감이 강해 결론을 미루기 쉽습니다',
    },
    'to': {
        'df': '안정감이 약해 작은 변수에도 흔들릴 수 있습니다',
        'ex': '안정감이 강해 움직임이 느려질 수 있습니다',
    },
}

STATE_WEATHER = {
    'earth': {
        'A': '차분한 기운이 받쳐줘서 실수는 줄고 진행은 안정적입니다',
        'B': '차분한 기운이 과속을 막아줘서 무난하게 이어집니다',
        'B1': '차분한 기운이 속도를 낮추니 확인하기에는 좋습니다',
        'C': '묵직한 기운이 있어 진행이 더디게 느껴질 수 있습니다',
        'C1': '묵직한 기운 때문에 시작이 늦어질 수 있습니다',
        'D': '묵직한 기운이 강해 쉬어 가는 쪽이 낫습니다',
    },
    'fire': {
        'A': '활력이 붙어 빠르게 움직이기 좋습니다',
        'B': '활력이 적당해 분위기를 끌어올리기 좋습니다',
        'B1': '활력이 조금 앞서가니 속도 조절이 필요합니다',
        'C': '활력이 급해져 말이나 행동이 빨라질 수 있습니다',
        'C1': '활력이 부담으로 바뀌면 실수가 늘 수 있습니다',
        'D': '활력이 과하면 오늘은 피로로 바로 돌아올 수 있습니다',
    },
    'water': {
        'A': '부드러운 기운이 타이밍을 살려줍니다',
        'B': '부드러운 기운이 대화와 조율에 도움을 줍니다',
        'B1': '부드러운 기운은 좋지만 결론이 늦어질 수 있습니다',
        'C': '흐름이 늘어져 속도가 느려질 수 있습니다',
        'C1': '흐름이 무거워져 의욕이 처질 수 있습니다',
        'D': '흐름이 막혀 쉬어 가는 편이 현실적입니다',
    },
    'wood': {
        'A': '새 가능성이 잘 보여 움직이기 좋습니다',
        'B': '새 가능성이 보이지만 범위를 정하면 더 좋습니다',
        'B1': '가능성은 있으나 일을 늘리면 부담이 됩니다',
        'C': '방향이 퍼질 수 있어 집중이 필요합니다',
        'C1': '욕심이 커지면 감당할 일이 늘어납니다',
        'D': '새 시도보다 기존 일을 줄이는 편이 낫습니다',
    },
}

WEATHERS = set(STATE_WEATHER)
SUSPICIOUS_PATTERNS = [
    '을을',
    '를를',
    '이이',
    '가가',
    '은은',
    '는는',
    '표이',
    '표을',
    '버튼를',
    '멘트을',
    '스위치을',
    '칼날를',
    '관리자이',
    '계기판가',
    '메뉴판가',
    '알림창가',
]


def parse_code(code):
    parts = code.split('_')
    if len(parts) == 2:
        return {
            'category': parts[0],
            'tier': parts[1],
            'oheng': None,
            'strength': None,
            'weather': None,
            'is_base': True,
        }
    if len(parts) == 5:
        return {
            'category': parts[0],
            'tier': parts[1],
            'oheng': parts[2],
            'strength': parts[3],
            'weather': parts[4],
            'is_base': False,
        }
    raise ValueError(f'unsupported code format: {code}')


def build_context(meta):
    category = CATEGORIES[meta['category']]
    element = ELEMENTS.get(meta['oheng'], {})
    return {**category, **element}


def base_text(meta, row_type, index):
    lines = BASE_LINES[meta['tier']][row_type]
    return lines[index % len(lines)].format(**build_context(meta))


def elem_text(meta, row_type):
    return ELEM_LINES[meta['tier']][row_type].format(**build_context(meta))


def state_text(meta):
    weather = meta['weather'] if meta['weather'] in WEATHERS else 'earth'
    return f"{STATE_ELEMENT[meta['oheng']][meta['strength']]}. {STATE_WEATHER[weather][meta['tier']]}"


def validate(original_rows, next_rows):
    if len(next_rows) != EXPECTED_ROWS:
        raise ValueError(f'row count mismatch: {len(next_rows)}')
    type_counts = Counter(row['type'] for row in next_rows)
    if type_counts != EXPECTED_TYPE_COUNTS:
        raise ValueError(f'type counts mismatch: {type_counts}')

    for index, (old, new) in enumerate(zip(original_rows, next_rows), start=1):
        for field in ('code', 'type', 'weight'):
            if old[field] != new[field]:
                raise ValueError(f'{field} changed at row {index}')
        text = new['text']
        if not text.strip():
            raise ValueError(f'empty text at row {index}')
        if '\n' in text or '\r' in text:
            raise ValueError(f'newline in row {index}')
        for token in FORBIDDEN:
            if token in text:
                raise ValueError(f'forbidden token {token!r} at row {index}: {text}')
        for token in SCENARIO_FORBIDDEN:
            if token in text:
                raise ValueError(f'scenario token {token!r} at row {index}: {text}')
        for pattern in SUSPICIOUS_PATTERNS:
            if pattern in text:
                raise ValueError(f'suspicious pattern {pattern!r} at row {index}: {text}')

    unique_texts = len({row['text'] for row in next_rows})
    if unique_texts < 600:
        raise ValueError(f'unique texts too low: {unique_texts}')


def main():
    with TARGET.open('r', encoding='utf-8-sig', newline='') as handle:
        reader = csv.DictReader(handle)
        original_rows = list(reader)
        if reader.fieldnames != FIELDNAMES:
            raise ValueError(f'fieldnames mismatch: {reader.fieldnames}')

    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup = BACKUP_DIR / f'fortune_ko_humor_before_realistic_rewrite_{stamp}.csv'
    shutil.copy2(TARGET, backup)

    base_indexes = defaultdict(int)
    next_rows = []
    for row in original_rows:
        meta = parse_code(row['code'])
        row_type = row['type']
        if meta['is_base']:
            key = (row['code'], row_type)
            text = base_text(meta, row_type, base_indexes[key])
            base_indexes[key] += 1
        elif row_type == 'state':
            text = state_text(meta)
        else:
            text = elem_text(meta, row_type)
        next_rows.append(
            {
                'code': row['code'],
                'type': row_type,
                'text': text,
                'weight': row['weight'],
            }
        )

    validate(original_rows, next_rows)

    with TARGET.open('w', encoding='utf-8-sig', newline='') as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDNAMES)
        writer.writeheader()
        writer.writerows(next_rows)

    print(f'backup={backup}')
    print(f'rows={len(next_rows)} unique_texts={len({row["text"] for row in next_rows})}')


if __name__ == '__main__':
    main()
