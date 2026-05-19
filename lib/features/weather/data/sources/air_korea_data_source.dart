import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_client.dart';

/// 한국환경공단 에어코리아 실시간 대기오염 정보
/// 출처: 한국환경공단_에어코리아 (공공누리 제0유형)
/// https://apis.data.go.kr/B552584/ArpltnInforInqireSvc
class AirKoreaDataSource {
  AirKoreaDataSource()
      : _dio = DioClient.create(baseUrl: AppConfig.airkoreaBaseUrl);

  final Dio _dio;
  final Logger _logger = Logger();

  static const _path =
      '/B552584/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty';

  /// 위경도 기반으로 해당 시도의 실시간 대기오염 정보 조회
  /// 반환: (pm10 μg/m³, pm25 μg/m³, o3 ppm, khaiValue 통합지수, khaiGrade 1~4)
  Future<(double? pm10, double? pm25, double? o3, double? khaiValue, int? khaiGrade)>
      fetchAirQuality({
    required double lat,
    required double lon,
  }) async {
    try {
      final sidoName = _sidoName(lat, lon);
      final response = await _dio.get(_path, queryParameters: {
        'serviceKey': AppConfig.airkoreaApiKey,
        'returnType': 'json',
        'numOfRows': 100,
        'pageNo': 1,
        'sidoName': sidoName,
        'ver': '1.0',
      });

      final items = response.data?['response']?['body']?['items'];
      if (items is! List || items.isEmpty) return (null, null, null, null, null);

      // 유효한 pm10 값을 가진 첫 번째 측정소 사용
      for (final item in items) {
        final pm10 = _parseValue(item['pm10Value']);
        if (pm10 != null) {
          final pm25 = _parseValue(item['pm25Value']);
          final o3 = _parseValue(item['o3Value']);
          final khaiValue = _parseValue(item['khaiValue']);
          final khaiGrade = int.tryParse(item['khaiGrade']?.toString() ?? '');
          return (pm10, pm25, o3, khaiValue, khaiGrade);
        }
      }
      return (null, null, null, null, null);
    } catch (e, st) {
      _logger.w('에어코리아 대기오염 조회 실패', error: e, stackTrace: st);
      return (null, null, null, null, null);
    }
  }

  double? _parseValue(dynamic raw) {
    final str = raw?.toString() ?? '';
    if (str.isEmpty || str == '-') return null;
    return double.tryParse(str);
  }

  /// 위경도 → 시도명 (에어코리아 API sidoName 파라미터)
  String _sidoName(double lat, double lon) {
    if (lat < 33.6) return '제주';
    if (lat < 34.9) return lon < 127.2 ? '전남' : (lon < 128.5 ? '경남' : '경남');
    if (lat < 35.2) {
      if (lon < 128.6) return '경남';
      return '부산';
    }
    if (lat < 35.6) {
      if (lon < 127.5) return '전남';
      if (lon < 128.6) return '경남';
      return '울산';
    }
    if (lat < 35.9) {
      if (lon < 127.1) return '전북';
      if (lon < 128.3) return '대구';
      return '경북';
    }
    if (lat < 36.2) {
      if (lon < 127.4) return '전북';
      if (lon < 128.0) return '충북';
      return '경북';
    }
    if (lat < 36.6) {
      if (lon < 127.0) return '충남';
      if (lon < 127.9) return '충북';
      return '경북';
    }
    if (lat < 36.8) {
      if (lon < 127.1) return '대전';
      if (lon < 127.5) return '세종';
      if (lon < 128.5) return '충북';
      return '경북';
    }
    if (lat < 37.3) {
      if (lon < 126.8) return '경기';
      if (lon < 127.9) return '경기';
      if (lon < 128.9) return '강원';
      return '강원';
    }
    if (lat < 37.6) {
      if (lon < 126.7) return '인천';
      if (lon < 127.5) return '경기';
      return '강원';
    }
    // 서울 이북
    if (lon < 126.8) return '인천';
    if (lon < 127.2) return '서울';
    return '경기';
  }
}
