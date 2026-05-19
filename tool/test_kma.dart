/// KMA API 직접 테스트
/// 실행: dart run tool/test_kma.dart

import 'dart:io';
import 'package:dio/dio.dart';

Future<void> main() async {
  final envVars = <String, String>{};
  for (final line in File('.env').readAsLinesSync()) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final idx = line.indexOf('=');
    if (idx < 0) continue;
    envVars[line.substring(0, idx).trim()] = line.substring(idx + 1).trim();
  }

  final apiKey = envVars['KMA_API_KEY'] ?? '';
  print('KMA API Key: ${apiKey.isEmpty ? "없음" : "${apiKey.substring(0, 8)}..."}');

  final dio = Dio(BaseOptions(
    baseUrl: 'https://apihub.kma.go.kr',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final now = DateTime.now();
  // 현재 시각에서 40분 전 (기상청 자료 생성 딜레이 고려)
  final base = now.subtract(const Duration(minutes: 40));
  final baseDate =
      '${base.year}${base.month.toString().padLeft(2, '0')}${base.day.toString().padLeft(2, '0')}';
  final baseTime =
      '${base.hour.toString().padLeft(2, '0')}${(base.minute ~/ 30 * 30).toString().padLeft(2, '0')}';

  // 서울 격자: nx=60, ny=127
  print('\n🔍 초단기실황 테스트 (서울 nx=60, ny=127)');
  print('   baseDate=$baseDate, baseTime=$baseTime');

  final paths = [
    '/api/typ02/obs/af/getUltraSrtNcst',
    '/1360000/VilageFcstInfoService2.0/getUltraSrtNcst',
  ];

  for (final path in paths) {
    try {
      final res = await dio.get(
        path,
        queryParameters: {
          'authKey': apiKey,
          'dataType': 'JSON',
          'numOfRows': 10,
          'pageNo': 1,
          'base_date': baseDate,
          'base_time': baseTime,
          'nx': 60,
          'ny': 127,
        },
      );
      print('✅ $path → 성공 (${res.statusCode})');
      print('   응답: ${res.data.toString().substring(0, 200)}');
      break;
    } on DioException catch (e) {
      print('❌ $path → ${e.response?.statusCode ?? e.type}: ${e.message}');
      if (e.response != null) {
        print('   응답: ${e.response?.data.toString().substring(0, 200)}');
      }
    }
  }
}
