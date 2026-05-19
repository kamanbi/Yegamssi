import 'dart:io';

const _basePath = 'etc/fortune_styles/fortune_ko_base.csv';
const _styleDir = 'etc/fortune_styles';

const _styleFiles = <String>[
  'fortune_ko_humor.csv',
  'fortune_ko_tsundere.csv',
  'fortune_ko_cynical.csv',
  'fortune_ko_emotional.csv',
  'fortune_ko_historical.csv',
  'fortune_ko_ai.csv',
];

Future<void> main(List<String> args) async {
  final requestedFiles = args.where((arg) => arg.endsWith('.csv')).toSet();
  final targetFiles = requestedFiles.isEmpty ? _styleFiles : requestedFiles;

  final baseKeys = _readRowKeys(File(_basePath));
  final baseUniqueRows = _readUniqueRows(File(_basePath));
  stdout.writeln('중복 제거 기준: ${baseKeys.length}행');
  stdout.writeln(
    '기준 중복 여부: ${baseKeys.length == baseUniqueRows.length ? 'OK' : 'FAIL'}',
  );

  var hasMismatch = false;
  for (final fileName in targetFiles) {
    final file = File('$_styleDir/$fileName');
    final styleKeys = _readRowKeys(file);
    final styleUniqueRows = _readUniqueRows(file);
    final missing = baseKeys.difference(styleKeys);
    final extra = styleKeys.difference(baseKeys);
    final duplicatedRows = styleKeys.length - styleUniqueRows.length;
    final ok =
        missing.isEmpty &&
        extra.isEmpty &&
        styleKeys.length == baseKeys.length &&
        duplicatedRows == 0;

    stdout.writeln(
      '$fileName: ${styleKeys.length}행, '
      '누락 ${missing.length}, 초과 ${extra.length}, '
      '중복 $duplicatedRows, ${ok ? 'OK' : 'FAIL'}',
    );

    if (!ok) {
      hasMismatch = true;
      if (missing.isNotEmpty) {
        stdout.writeln('  누락 예시: ${missing.take(5).join(', ')}');
      }
      if (extra.isNotEmpty) {
        stdout.writeln('  초과 예시: ${extra.take(5).join(', ')}');
      }
    }
  }

  if (hasMismatch) {
    exitCode = 1;
  }
}

Set<String> _readRowKeys(File file) {
  if (!file.existsSync()) {
    throw StateError('파일이 없습니다: ${file.path}');
  }

  final keys = <String>{};
  var rowIndex = 1;
  for (final line
      in file
          .readAsLinesSync()
          .where((line) => line.trim().isNotEmpty)
          .skip(1)) {
    rowIndex++;
    final cols = _parseCsvLine(line);
    if (cols.length < 4) {
      throw FormatException('CSV 컬럼 부족: ${file.path}:$rowIndex');
    }
    keys.add('${cols[0]}|${cols[1]}|$rowIndex');
  }
  return keys;
}

Set<String> _readUniqueRows(File file) {
  final keys = <String>{};
  for (final line
      in file
          .readAsLinesSync()
          .where((line) => line.trim().isNotEmpty)
          .skip(1)) {
    final cols = _parseCsvLine(line);
    if (cols.length < 4) continue;
    keys.add('${cols[0]}|${cols[1]}|${cols[2]}|${cols[3]}');
  }
  return keys;
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
