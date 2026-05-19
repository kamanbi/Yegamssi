/// Supabase 연결 + 테이블 진단
/// 실행: dart run tool/check_supabase.dart

import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  // .env 직접 파싱
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ .env 파일 없음');
    return;
  }

  final envVars = <String, String>{};
  for (final line in envFile.readAsLinesSync()) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final idx = line.indexOf('=');
    if (idx < 0) continue;
    envVars[line.substring(0, idx).trim()] = line.substring(idx + 1).trim();
  }

  final url = envVars['SUPABASE_URL'] ?? '';
  final key = envVars['SUPABASE_ANON_KEY'] ?? '';

  if (url.isEmpty || key.isEmpty) {
    print('❌ SUPABASE_URL 또는 SUPABASE_ANON_KEY 없음');
    return;
  }

  print('🔗 Supabase 연결: $url');
  final client = SupabaseClient(url, key);

  for (final table in ['fortune_ko', 'fortune_en']) {
    try {
      final rows = await client
          .from(table)
          .select('code, type, text, weight')
          .limit(3);

      print('\n✅ $table 연결 성공 (샘플 ${rows.length}행):');
      for (final row in rows) {
        final text = (row['text'] as String);
        final preview = text.length > 24 ? '${text.substring(0, 24)}...' : text;
        print('   [${row['code']}/${row['type']}] $preview');
      }
    } catch (e) {
      print('\n❌ $table 오류: $e');
      print('   → create_tables.sql 실행 후 데이터 INSERT 필요');
    }
  }

  await client.dispose();
  print('\n진단 완료.');
}
