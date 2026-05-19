/// CSV → Supabase 직접 삽입 스크립트
/// 실행: dart run tool/import_data.dart

import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  // .env 파싱
  final envVars = <String, String>{};
  for (final line in File('.env').readAsLinesSync()) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final idx = line.indexOf('=');
    if (idx < 0) continue;
    envVars[line.substring(0, idx).trim()] = line.substring(idx + 1).trim();
  }

  final url = envVars['SUPABASE_URL']!;
  final key = envVars['SUPABASE_ANON_KEY']!;
  final client = SupabaseClient(url, key);

  final desktop = r'C:/Users/kaman/OneDrive/바탕 화면';

  await _importCsv(client, '$desktop/ko.csv', 'fortune_ko');
  await _importCsv(client, '$desktop/en.csv', 'fortune_en');

  await client.dispose();
  print('\n✅ 모든 데이터 삽입 완료');
}

Future<void> _importCsv(
  SupabaseClient client,
  String csvPath,
  String table,
) async {
  print('\n📥 $table 삽입 시작...');

  final lines = File(
    csvPath,
  ).readAsLinesSync().map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  final header = _parseCsvLine(
    lines.removeAt(0),
  ).map((value) => value.toLowerCase()).toList();
  final hasNamedColumns = header.contains('code') && header.contains('type');

  final rows = <Map<String, dynamic>>[];
  for (final line in lines) {
    final cols = _parseCsvLine(line);
    final row = hasNamedColumns
        ? _rowFromNamedColumns(header, cols)
        : _rowFromLegacyColumns(cols);
    if (row == null) continue;
    rows.add(row);
  }

  print('  총 ${rows.length}행 처리 중...');

  // 100행씩 나눠 삽입 (Supabase 권장 배치 크기)
  const batchSize = 100;
  int inserted = 0;
  for (int i = 0; i < rows.length; i += batchSize) {
    final batch = rows.sublist(
      i,
      (i + batchSize < rows.length) ? i + batchSize : rows.length,
    );
    try {
      await client.from(table).insert(batch);
      inserted += batch.length;
      stdout.write('\r  진행: $inserted/${rows.length}행');
    } catch (e) {
      print('\n  ⚠️ 배치 오류 (행 $i~${i + batch.length}): $e');
    }
  }
  print('\n  ✅ $table: $inserted행 삽입 완료');
}

Map<String, dynamic>? _rowFromNamedColumns(
  List<String> header,
  List<String> cols,
) {
  String? valueOf(String name) {
    final index = header.indexOf(name);
    if (index < 0 || index >= cols.length) return null;
    return cols[index];
  }

  final code = valueOf('code');
  final type = valueOf('type');
  final text = valueOf('text');
  if (code == null || type == null || text == null) return null;

  return {
    'code': code,
    'type': type,
    'text': text,
    'weight': int.tryParse(valueOf('weight') ?? '') ?? 1,
  };
}

Map<String, dynamic>? _rowFromLegacyColumns(List<String> cols) {
  if (cols.length < 4) return null;
  return {
    'code': cols[0],
    'type': cols[1],
    'text': cols[2],
    'weight': int.tryParse(cols[3]) ?? 1,
  };
}

List<String> _parseCsvLine(String line) {
  final cols = <String>[];
  var cur = StringBuffer();
  var inQuote = false;

  for (int i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      inQuote = !inQuote;
    } else if (ch == ',' && !inQuote) {
      cols.add(cur.toString().trim());
      cur.clear();
    } else {
      cur.write(ch);
    }
  }
  cols.add(cur.toString().trim());
  return cols;
}
