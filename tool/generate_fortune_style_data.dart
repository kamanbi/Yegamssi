import 'dart:io';

const _sourcePath = 'etc/supabase_exports/fortune_ko_20260515_202502.csv';
const _outputDir = 'etc/fortune_styles';
const _dedupedBasePath = 'etc/fortune_styles/fortune_ko_base_deduped.csv';

const _styles = <String, String>{
  'humor': '유머',
  'tsundere': '츤데레',
  'cynical': '시니컬',
  'emotional': '감성',
  'historical': '사극',
  'ai': 'AI',
};

Future<void> main() async {
  final source = File(_sourcePath);
  if (!source.existsSync()) {
    throw StateError('기준 파일이 없습니다: $_sourcePath');
  }

  final rows = source
      .readAsLinesSync()
      .where((line) => line.trim().isNotEmpty)
      .toList();
  if (rows.length <= 1) {
    throw StateError('기준 파일에 데이터가 없습니다: $_sourcePath');
  }

  final outputDirectory = Directory(_outputDir)..createSync(recursive: true);
  final parsedRows = rows
      .skip(1)
      .map(_parseCsvLine)
      .where((cols) {
        return cols.length >= 4;
      })
      .map(FortuneRow.fromColumns);

  final uniqueRows = <FortuneRow>[];
  final seen = <String>{};
  for (final row in parsedRows) {
    if (seen.add(row.dedupeKey)) {
      uniqueRows.add(row);
    }
  }

  _writeRows(
    File(_dedupedBasePath),
    uniqueRows,
    (row) => row.text,
    ensureUniqueText: false,
  );
  stdout.writeln(
    '기본 중복 제거: ${rows.length - 1}행 -> ${uniqueRows.length}행 '
    '(삭제 ${rows.length - 1 - uniqueRows.length}행)',
  );

  for (final entry in _styles.entries) {
    final styleKey = entry.key;
    final output = File('${outputDirectory.path}/fortune_ko_$styleKey.csv');
    _writeRows(
      output,
      uniqueRows,
      (row) => _styleText(styleKey, row),
      ensureUniqueText: true,
    );
    stdout.writeln(
      '${entry.value}: ${uniqueRows.length}행 생성 -> ${output.path}',
    );
  }
}

void _writeRows(
  File output,
  List<FortuneRow> rows,
  String Function(FortuneRow row) textBuilder, {
  required bool ensureUniqueText,
}) {
  final lines = <String>['code,type,text,weight'];
  final seenRows = <String>{};
  for (final row in rows) {
    var text = textBuilder(row);
    if (ensureUniqueText) {
      var rowKey = '${row.code}|${row.type}|$text|${row.weight}';
      var conflictIndex = 0;
      while (!seenRows.add(rowKey)) {
        text = _joinSentence(
          textBuilder(row),
          _conflictSuffix(row, conflictIndex),
        );
        rowKey = '${row.code}|${row.type}|$text|${row.weight}';
        conflictIndex++;
      }
    }
    lines.add(
      [
        _escapeCsvValue(row.code),
        _escapeCsvValue(row.type),
        _escapeCsvValue(text),
        _escapeCsvValue(row.weight),
      ].join(','),
    );
  }
  output.writeAsStringSync('${lines.join('\n')}\n');
}

String _conflictSuffix(FortuneRow row, int conflictIndex) {
  final suffixes = switch (row.type) {
    'intro' => [
      '조금 더 편한 쪽으로 받아들이면 좋습니다',
      '첫 느낌보다 흐름을 차분히 보는 편이 낫습니다',
      '오늘의 시작점은 여기서 잡아도 충분합니다',
    ],
    'state' => [
      '다만 마음의 속도는 조금 조절해 주세요',
      '이럴 때일수록 작은 균형이 중요합니다',
      '흐름을 억지로 끌고 가지만 않으면 됩니다',
    ],
    'effect' => [
      '그 여파는 생각보다 부드럽게 이어질 수 있습니다',
      '작은 차이가 뒤에서 조용히 힘을 보탤 수 있습니다',
      '결과는 급하게 드러나지 않아도 천천히 쌓입니다',
    ],
    'action' => [
      '오늘은 한 번 더 확인하고 움직이면 충분합니다',
      '무리하게 넓히기보다 필요한 만큼만 챙기세요',
      '끝까지 붙잡기보다 적당한 선에서 정리하세요',
    ],
    _ => [
      '흐름을 조금 더 여유 있게 보면 좋습니다',
      '오늘은 과하게 힘주지 않는 편이 낫습니다',
      '필요한 만큼만 차분히 챙기세요',
    ],
  };
  return suffixes[conflictIndex % suffixes.length];
}

String _styleText(String styleKey, FortuneRow row) {
  return switch (styleKey) {
    'humor' => _humor(row),
    'tsundere' => _tsundere(row),
    'cynical' => _cynical(row),
    'emotional' => _emotional(row),
    'historical' => _historical(row),
    'ai' => _ai(row),
    _ => row.text,
  };
}

String _humor(FortuneRow row) {
  final mood = _mood(row.tier);
  final scene = _categoryScene(row.category);
  final weather = _weatherPhrase(row.weather);
  final variants = switch (row.type) {
    'intro' => [
      '$scene 쪽으로 오늘은 $mood 흐름이 슬쩍 들어옵니다',
      '오늘 $scene 운은 생각보다 표정이 좋습니다',
      '$weather $scene 일은 너무 심각하게만 보지 않아도 됩니다',
    ],
    'state' => [
      '마음은 바쁜 척하지만 흐름은 꽤 눈치 있게 움직입니다',
      '기운이 완벽하진 않아도 오늘 할 일은 대체로 알아서 줄을 섭니다',
      '예민한 부분만 살짝 내려놓으면 하루가 덜 귀찮게 굴겠습니다',
    ],
    'effect' => [
      '작은 선택 하나가 의외로 괜찮은 반전을 데려올 수 있습니다',
      '가볍게 넘긴 일이 나중에 쓸 만한 힌트가 될 수 있습니다',
      '운이 대놓고 돕진 않아도 뒤에서 살짝 밀어주는 모양입니다',
    ],
    'action' => [
      '너무 폼 잡기보다 일단 해보고 웃으면서 수정하세요',
      '오늘은 완벽한 계획보다 빠른 실행이 체면을 살립니다',
      '괜히 혼자 심각해지지 말고 필요한 말은 짧게 꺼내세요',
    ],
    _ => ['오늘은 너무 무겁게만 보지 않아도 됩니다'],
  };
  return _withScoreContext('humor', row, _pick(variants, row));
}

String _tsundere(FortuneRow row) {
  final scene = _categoryScene(row.category);
  final variants = switch (row.type) {
    'intro' => [
      '$scene 운이 아주 나쁘진 않습니다. 딱히 기대하라는 뜻은 아니고요',
      '오늘 $scene 쪽은 좀 봐줄 만합니다. 방심만 하지 마세요',
      '흐름이 나쁘지 않으니 괜히 삐딱하게 굴 필요는 없습니다',
    ],
    'state' => [
      '기운이 조금 들쭉날쭉해도 못 버틸 정도는 아닙니다',
      '마음이 예민해질 수 있으니 스스로를 너무 몰아붙이지는 마세요',
      '컨디션이 완벽하진 않아도 잘 다루면 충분합니다',
    ],
    'effect' => [
      '괜찮은 결과가 따라올 수 있습니다. 물론 준비한 만큼만요',
      '작은 배려가 생각보다 크게 돌아올 수 있습니다. 그러니 대충하지 마세요',
      '운이 도와줄 여지는 있습니다. 그렇다고 전부 맡기진 말고요',
    ],
    'action' => [
      '할 일은 미루지 말고 챙기세요. 누가 걱정해서 하는 말은 아닙니다',
      '말을 아끼되 필요한 순간엔 제대로 표현하세요',
      '무리하지 말고 페이스를 지키세요. 그래야 덜 피곤합니다',
    ],
    _ => ['참고만 하세요. 그래도 무시하진 말고요'],
  };
  return _withScoreContext('tsundere', row, _pick(variants, row));
}

String _cynical(FortuneRow row) {
  final scene = _categoryScene(row.category);
  final variants = switch (row.type) {
    'intro' => [
      '오늘 $scene 운은 기대보다 관리가 먼저입니다',
      '$scene 쪽 흐름은 감정적으로 해석할수록 피곤해집니다',
      '좋고 나쁨보다 무엇을 줄일지가 더 중요한 날입니다',
    ],
    'state' => [
      '기운은 괜찮아 보여도 변수는 언제든 생길 수 있습니다',
      '컨디션을 과신하면 사소한 부분에서 시간이 새기 쉽습니다',
      '분위기에 끌려가기보다 기준을 정해두는 편이 낫습니다',
    ],
    'effect' => [
      '작은 실수가 커지지 않게 초반에 정리하는 것이 유리합니다',
      '운보다 확인이 빠릅니다. 확인한 만큼 손해가 줄어듭니다',
      '결과는 결국 준비한 범위 안에서 움직일 가능성이 큽니다',
    ],
    'action' => [
      '말은 줄이고 기록은 남기세요',
      '선택지는 줄이고 가장 덜 후회할 쪽으로 가세요',
      '오늘은 감보다 체크리스트가 더 믿을 만합니다',
    ],
    _ => ['현실적으로 보면 과한 기대는 줄이는 편이 낫습니다'],
  };
  return _withScoreContext('cynical', row, _pick(variants, row));
}

String _emotional(FortuneRow row) {
  final scene = _categoryScene(row.category);
  final variants = switch (row.type) {
    'intro' => [
      '오늘 $scene 흐름은 천천히 마음을 열 때 더 부드러워집니다',
      '서두르지 않으면 $scene 쪽에서 작은 따뜻함을 발견할 수 있습니다',
      '오늘은 스스로를 조금 다정하게 대할수록 운도 편안해집니다',
    ],
    'state' => [
      '마음 한쪽이 흔들려도 중심은 다시 돌아올 수 있습니다',
      '조용히 숨을 고르면 지금 필요한 감각이 선명해집니다',
      '작은 피로를 알아차리는 것만으로도 하루가 한결 가벼워집니다',
    ],
    'effect' => [
      '부드러운 말 한마디가 생각보다 긴 여운을 남길 수 있습니다',
      '천천히 쌓은 마음이 오늘의 선택을 더 편안하게 만들어줍니다',
      '작은 배려가 관계와 하루의 온도를 함께 올릴 수 있습니다',
    ],
    'action' => [
      '오늘은 스스로를 몰아붙이기보다 한 박자 쉬어가세요',
      '마음이 가는 일을 하나쯤은 조용히 챙겨보세요',
      '필요한 말은 부드럽게, 필요한 쉼은 미루지 마세요',
    ],
    _ => ['마음의 속도를 조금 낮춰도 괜찮습니다'],
  };
  return _withScoreContext('emotional', row, _pick(variants, row));
}

String _historical(FortuneRow row) {
  final scene = _historicalScene(row.category);
  final variants = switch (row.type) {
    'intro' => [
      '금일은 $scene 기운이 서서히 문을 여는 날입니다',
      '오늘의 운세를 살피니 $scene 흐름에 눈길을 둘 만합니다',
      '하늘의 결을 보아하니 $scene 일에 작은 움직임이 있겠습니다',
    ],
    'state' => [
      '마음의 기세가 고르지 않아도 중심을 잃을 정도는 아닙니다',
      '기운이 안으로 모이니 서두름보다 절도가 필요합니다',
      '말과 행동을 가다듬으면 흐름이 한결 단정해지겠습니다',
    ],
    'effect' => [
      '작은 정성이 훗날 뜻밖의 도움으로 돌아올 수 있습니다',
      '오늘 쌓은 신중함이 뒤의 근심을 덜어줄 것입니다',
      '흐름을 거스르지 않으면 얻는 것이 작지 않겠습니다',
    ],
    'action' => [
      '경솔한 말은 삼가고 해야 할 일부터 차례로 행하세요',
      '마음을 급히 쓰지 말고 때를 보아 움직이세요',
      '작은 약속이라도 소홀히 하지 않는 것이 이롭습니다',
    ],
    _ => ['금일은 마음을 단정히 하고 흐름을 살피는 것이 좋습니다'],
  };
  return _withScoreContext('historical', row, _pick(variants, row));
}

String _ai(FortuneRow row) {
  final scoreBand = switch (row.tier) {
    'A' => '상승 구간',
    'B' || 'B1' => '안정 구간',
    'C' || 'C1' => '주의 구간',
    _ => '보수적 대응 구간',
  };
  final scene = _categoryScene(row.category);
  final variants = switch (row.type) {
    'intro' => [
      '오늘 $scene 지표는 $scoreBand으로 분류됩니다',
      '$scene 관련 패턴은 $scoreBand에 가깝습니다',
      '현재 조건에서 $scene 운은 $scoreBand 신호를 보입니다',
    ],
    'state' => [
      '내부 에너지 편차를 줄이는 것이 우선입니다',
      '현재 흐름은 감정보다 기준값에 맞춰 판단하는 편이 유리합니다',
      '변수 노출을 낮추면 예측 가능성이 올라갑니다',
    ],
    'effect' => [
      '작은 선택의 누적 효과가 결과에 반영될 가능성이 있습니다',
      '초기 대응 품질이 이후 흐름에 영향을 줄 수 있습니다',
      '관계와 행동 데이터가 긍정 방향으로 보정될 수 있습니다',
    ],
    'action' => [
      '오늘은 우선순위를 3개 이하로 제한하세요',
      '중요한 판단은 확인 과정을 거친 뒤 실행하세요',
      '불필요한 변수를 줄이고 실행 가능한 선택부터 처리하세요',
    ],
    _ => ['현재 조건에서는 안정적인 판단이 우선입니다'],
  };
  return _withScoreContext('ai', row, _pick(variants, row));
}

String _withScoreContext(String styleKey, FortuneRow row, String text) {
  final context = switch (styleKey) {
    'humor' => _humorScoreContext(row),
    'tsundere' => _tsundereScoreContext(row),
    'cynical' => _cynicalScoreContext(row),
    'emotional' => _emotionalScoreContext(row),
    'historical' => _historicalScoreContext(row),
    'ai' => _aiScoreContext(row),
    _ => '',
  };
  if (context.isEmpty) return text;
  return _joinSentence(text, context);
}

String _joinSentence(String first, String second) {
  final cleanFirst = first.trim();
  final cleanSecond = second.trim();
  if (cleanFirst.isEmpty) return cleanSecond;
  if (cleanSecond.isEmpty) return cleanFirst;
  final needsPeriod = !RegExp(r'[.!?。]$').hasMatch(cleanFirst);
  return '${needsPeriod ? '$cleanFirst.' : cleanFirst} $cleanSecond';
}

String _humorScoreContext(FortuneRow row) {
  return switch ((_tierBand(row.tier), row.type)) {
    (_ScoreBand.great, 'intro') => '오늘은 자신감 버튼을 눌러도 괜찮겠습니다',
    (_ScoreBand.great, 'state') => '기운이 꽤 잘 차려입고 나왔습니다',
    (_ScoreBand.great, 'effect') => '기회가 보이면 괜히 뒷걸음질치지 마세요',
    (_ScoreBand.great, 'action') => '오늘은 한 발 더 나가도 크게 무리 없습니다',
    (_ScoreBand.good, 'intro') => '큰 욕심만 빼면 흐름이 꽤 협조적입니다',
    (_ScoreBand.good, 'state') => '평소 페이스만 지켜도 손해 볼 일은 적겠습니다',
    (_ScoreBand.good, 'effect') => '작은 이득은 챙기고 큰 무리는 넘기면 됩니다',
    (_ScoreBand.good, 'action') => '가볍게 움직이되 마감은 제대로 챙기세요',
    (_ScoreBand.caution, 'intro') => '오늘은 운도 안전벨트를 매고 가자는 쪽입니다',
    (_ScoreBand.caution, 'state') => '괜히 객기 부리면 하루가 잔소리를 시작합니다',
    (_ScoreBand.caution, 'effect') => '작은 실수가 커지기 전에 얼른 수습하세요',
    (_ScoreBand.caution, 'action') => '무리수는 접어두고 확인부터 하세요',
    (_ScoreBand.low, 'intro') => '오늘은 영웅 모드보다 생존 모드가 어울립니다',
    (_ScoreBand.low, 'state') => '기운이 휴가를 낸 듯하니 억지로 끌고 가지 마세요',
    (_ScoreBand.low, 'effect') => '잃지 않는 쪽이 오늘의 숨은 승리입니다',
    (_ScoreBand.low, 'action') => '큰일은 미루고 작은 것부터 안전하게 처리하세요',
    _ => '',
  };
}

String _tsundereScoreContext(FortuneRow row) {
  return switch ((_tierBand(row.tier), row.type)) {
    (_ScoreBand.great, 'intro') => '이 정도면 기대해도 됩니다. 너무 티 내진 말고요',
    (_ScoreBand.great, 'state') => '상태가 괜찮으니 괜히 망치지만 마세요',
    (_ScoreBand.great, 'effect') => '잘하면 꽤 좋은 결과가 따라올 수 있습니다',
    (_ScoreBand.great, 'action') => '망설이지 말고 해보세요. 기회가 매번 오진 않습니다',
    (_ScoreBand.good, 'intro') => '나쁘지 않습니다. 딱 그 정도로 침착하면 됩니다',
    (_ScoreBand.good, 'state') => '평소처럼만 해도 충분하니 오버하지 마세요',
    (_ScoreBand.good, 'effect') => '무난한 선택이 생각보다 쓸모 있을 겁니다',
    (_ScoreBand.good, 'action') => '괜히 튀지 말고 해야 할 것만 정확히 하세요',
    (_ScoreBand.caution, 'intro') => '오늘은 조심하는 게 낫습니다. 괜히 걱정돼서가 아니라요',
    (_ScoreBand.caution, 'state') => '컨디션을 믿고 막 나가면 곤란합니다',
    (_ScoreBand.caution, 'effect') => '작은 빈틈이 거슬릴 수 있으니 대충 넘기지 마세요',
    (_ScoreBand.caution, 'action') => '확인하고 움직이세요. 두 번 말하게 하지 말고요',
    (_ScoreBand.low, 'intro') => '오늘은 무리하지 마세요. 진짜로요',
    (_ScoreBand.low, 'state') => '버티는 것도 능력이니 괜히 센 척하지 마세요',
    (_ScoreBand.low, 'effect') => '손해를 줄이면 그걸로 충분히 잘한 겁니다',
    (_ScoreBand.low, 'action') => '큰소리치지 말고 안전한 선택부터 하세요',
    _ => '',
  };
}

String _cynicalScoreContext(FortuneRow row) {
  return switch ((_tierBand(row.tier), row.type)) {
    (_ScoreBand.great, 'intro') => '조건은 좋지만 방심하면 좋은 운도 낭비됩니다',
    (_ScoreBand.great, 'state') => '좋은 상태일수록 기준을 낮추지 않는 편이 낫습니다',
    (_ScoreBand.great, 'effect') => '기회는 있습니다. 다만 잡는 건 결국 실행입니다',
    (_ScoreBand.great, 'action') => '지금은 미루는 쪽이 더 손해일 수 있습니다',
    (_ScoreBand.good, 'intro') => '나쁘지 않은 날이지만 특별 대우를 기대하긴 이릅니다',
    (_ScoreBand.good, 'state') => '안정적일수록 사소한 관리가 차이를 만듭니다',
    (_ScoreBand.good, 'effect') => '무난한 흐름을 망치지 않는 것이 핵심입니다',
    (_ScoreBand.good, 'action') => '확실한 것부터 처리하면 충분합니다',
    (_ScoreBand.caution, 'intro') => '오늘은 기대보다 리스크 관리가 먼저입니다',
    (_ScoreBand.caution, 'state') => '흔들림을 인정해야 덜 흔들립니다',
    (_ScoreBand.caution, 'effect') => '작은 문제가 커지는 속도는 생각보다 빠릅니다',
    (_ScoreBand.caution, 'action') => '검토 없이 움직이는 건 비용이 큽니다',
    (_ScoreBand.low, 'intro') => '오늘은 이기는 날보다 덜 잃는 날에 가깝습니다',
    (_ScoreBand.low, 'state') => '상태를 과신하면 결과가 바로 반응할 수 있습니다',
    (_ScoreBand.low, 'effect') => '무리한 기대는 실망을 늘릴 뿐입니다',
    (_ScoreBand.low, 'action') => '선택을 줄이고 방어적으로 움직이세요',
    _ => '',
  };
}

String _emotionalScoreContext(FortuneRow row) {
  return switch ((_tierBand(row.tier), row.type)) {
    (_ScoreBand.great, 'intro') => '좋은 기운이 곁에 있으니 마음을 조금 더 열어도 됩니다',
    (_ScoreBand.great, 'state') => '오늘의 밝은 기운을 스스로 믿어줘도 좋습니다',
    (_ScoreBand.great, 'effect') => '따뜻한 선택이 더 큰 기쁨으로 이어질 수 있습니다',
    (_ScoreBand.great, 'action') => '마음이 향하는 곳으로 한 걸음 더 다가가 보세요',
    (_ScoreBand.good, 'intro') => '잔잔하지만 안정적인 온기가 하루를 받쳐줍니다',
    (_ScoreBand.good, 'state') => '평온한 리듬을 지키면 충분히 좋은 날이 됩니다',
    (_ScoreBand.good, 'effect') => '작은 선의가 조용히 좋은 방향을 만듭니다',
    (_ScoreBand.good, 'action') => '무리하지 않는 선에서 마음을 표현해 보세요',
    (_ScoreBand.caution, 'intro') => '조금 예민할 수 있으니 마음을 천천히 다뤄주세요',
    (_ScoreBand.caution, 'state') => '흔들리는 마음도 잠시 쉬면 다시 가라앉습니다',
    (_ScoreBand.caution, 'effect') => '상처 주는 말보다 침묵이 나을 때가 있습니다',
    (_ScoreBand.caution, 'action') => '오늘은 자신에게 부드러운 여백을 주세요',
    (_ScoreBand.low, 'intro') => '힘든 흐름일수록 스스로를 더 조심히 안아주세요',
    (_ScoreBand.low, 'state') => '지친 마음을 이겨내려 하기보다 먼저 쉬게 해주세요',
    (_ScoreBand.low, 'effect') => '무리하지 않는 선택이 오늘의 마음을 지켜줍니다',
    (_ScoreBand.low, 'action') => '큰 결정보다 회복을 먼저 챙기는 편이 좋습니다',
    _ => '',
  };
}

String _historicalScoreContext(FortuneRow row) {
  return switch ((_tierBand(row.tier), row.type)) {
    (_ScoreBand.great, 'intro') => '길한 기운이 앞서니 뜻을 펼쳐도 좋겠습니다',
    (_ScoreBand.great, 'state') => '기세가 살아 있으니 마음 또한 곧게 세울 만합니다',
    (_ScoreBand.great, 'effect') => '작은 공이 크게 자랄 수 있는 때입니다',
    (_ScoreBand.great, 'action') => '때를 놓치지 말고 담대히 움직이세요',
    (_ScoreBand.good, 'intro') => '평탄한 운이 따르니 정도를 지키면 이롭습니다',
    (_ScoreBand.good, 'state') => '기운이 고르니 무리하지 않으면 안정됩니다',
    (_ScoreBand.good, 'effect') => '차분히 쌓은 일이 좋은 결실로 이어질 수 있습니다',
    (_ScoreBand.good, 'action') => '순서를 지키고 약속을 가볍게 여기지 마세요',
    (_ScoreBand.caution, 'intro') => '운이 다소 흐리니 경계심을 잃지 말아야 합니다',
    (_ScoreBand.caution, 'state') => '마음이 산란하면 작은 일도 커질 수 있습니다',
    (_ScoreBand.caution, 'effect') => '사소한 빈틈이 뒤의 근심을 부를 수 있습니다',
    (_ScoreBand.caution, 'action') => '서두르지 말고 다시 살핀 뒤 움직이세요',
    (_ScoreBand.low, 'intro') => '금일은 물러서 지키는 것이 나아 보입니다',
    (_ScoreBand.low, 'state') => '기운이 약하니 큰일을 억지로 밀지 마세요',
    (_ScoreBand.low, 'effect') => '욕심을 덜어내야 손실을 피할 수 있습니다',
    (_ScoreBand.low, 'action') => '큰 결단은 미루고 몸과 마음을 보전하세요',
    _ => '',
  };
}

String _aiScoreContext(FortuneRow row) {
  return switch ((_tierBand(row.tier), row.type)) {
    (_ScoreBand.great, 'intro') => '긍정 신호가 강하므로 적극 실행 비중을 높일 수 있습니다',
    (_ScoreBand.great, 'state') => '현재 에너지 값은 평균 대비 우호적입니다',
    (_ScoreBand.great, 'effect') => '성과 전환 가능성이 높아지는 구간입니다',
    (_ScoreBand.great, 'action') => '핵심 과제는 오늘 처리하는 편이 효율적입니다',
    (_ScoreBand.good, 'intro') => '전반 지표는 안정권으로 해석됩니다',
    (_ScoreBand.good, 'state') => '기본 루틴을 유지하면 변동성은 낮게 관리됩니다',
    (_ScoreBand.good, 'effect') => '점진적 개선 가능성이 있는 흐름입니다',
    (_ScoreBand.good, 'action') => '검증된 선택지를 우선 실행하세요',
    (_ScoreBand.caution, 'intro') => '주의 신호가 있으므로 리스크를 먼저 줄여야 합니다',
    (_ScoreBand.caution, 'state') => '컨디션과 판단 편차가 커질 수 있습니다',
    (_ScoreBand.caution, 'effect') => '오류 비용이 커질 수 있어 확인 절차가 필요합니다',
    (_ScoreBand.caution, 'action') => '중요 결정은 재검토 후 진행하세요',
    (_ScoreBand.low, 'intro') => '방어적 운영이 필요한 낮은 지표 구간입니다',
    (_ScoreBand.low, 'state') => '에너지 저하가 판단 품질에 영향을 줄 수 있습니다',
    (_ScoreBand.low, 'effect') => '무리한 확장은 손실 가능성을 높입니다',
    (_ScoreBand.low, 'action') => '신규 실행보다 보류와 회복을 우선하세요',
    _ => '',
  };
}

String _categoryScene(String category) {
  return switch (category) {
    'overall' => '전체 흐름',
    'money' => '재물',
    'love' => '마음과 관계',
    'work' => '일과 역할',
    'health' => '컨디션',
    'decision' => '선택',
    _ => '오늘의 흐름',
  };
}

String _historicalScene(String category) {
  return switch (category) {
    'overall' => '하루 전체의',
    'money' => '재물의',
    'love' => '인연의',
    'work' => '일의',
    'health' => '몸과 마음의',
    'decision' => '결단의',
    _ => '오늘의',
  };
}

String _mood(String tier) {
  return switch (_tierBand(tier)) {
    _ScoreBand.great => '제법 산뜻한',
    _ScoreBand.good => '무난하게 괜찮은',
    _ScoreBand.caution => '조금 조심스러운',
    _ScoreBand.low => '천천히 다뤄야 할',
  };
}

_ScoreBand _tierBand(String tier) {
  return switch (tier) {
    'A' => _ScoreBand.great,
    'B' || 'B1' || 'B2' => _ScoreBand.good,
    'C' || 'C1' || 'C2' => _ScoreBand.caution,
    _ => _ScoreBand.low,
  };
}

enum _ScoreBand { great, good, caution, low }

String _weatherPhrase(String weather) {
  return switch (weather) {
    'fire' => '햇살이 힘을 보태는 듯하니',
    'water' => '물기가 많은 날처럼 감정이 출렁일 수 있으니',
    'wood' => '바람이 방향을 바꾸듯',
    'earth' => '구름이 천천히 움직이듯',
    _ => '오늘 흐름을 보니',
  };
}

String _pick(List<String> variants, FortuneRow row) {
  final hash = row.dedupeKey.codeUnits.fold<int>(0, (sum, unit) {
    return (sum + unit * 31) & 0x7fffffff;
  });
  return variants[hash % variants.length];
}

class FortuneRow {
  const FortuneRow({
    required this.code,
    required this.type,
    required this.text,
    required this.weight,
  });

  factory FortuneRow.fromColumns(List<String> columns) {
    return FortuneRow(
      code: columns[0].trim(),
      type: columns[1].trim(),
      text: columns[2].trim().replaceAll(RegExp(r'\s+'), ' '),
      weight: columns[3].trim(),
    );
  }

  final String code;
  final String type;
  final String text;
  final String weight;

  String get dedupeKey => '$code|$type|$text|$weight';

  String get category => codeParts.isNotEmpty ? codeParts[0] : 'overall';

  String get tier => codeParts.length > 1 ? codeParts[1] : 'B';

  String get weather => codeParts.length > 4 ? codeParts[4] : 'earth';

  List<String> get codeParts => code.split('_');
}

List<String> _parseCsvLine(String line) {
  final cols = <String>[];
  final buffer = StringBuffer();
  var inQuote = false;

  for (var index = 0; index < line.length; index++) {
    final char = line[index];
    if (char == '"') {
      if (inQuote && index + 1 < line.length && line[index + 1] == '"') {
        buffer.write('"');
        index++;
      } else {
        inQuote = !inQuote;
      }
    } else if (char == ',' && !inQuote) {
      cols.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }
  cols.add(buffer.toString());
  return cols;
}

String _escapeCsvValue(Object? value) {
  final text = value?.toString() ?? '';
  if (text.contains('"') ||
      text.contains(',') ||
      text.contains('\n') ||
      text.contains('\r')) {
    return '"${text.replaceAll('"', '""')}"';
  }
  return text;
}
