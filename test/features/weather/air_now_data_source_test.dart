import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/weather/data/sources/air_now_data_source.dart';

void main() {
  test(
    'parses the new /aq/observation/current/ziplatLong/ response schema',
    () async {
      // 2026-09-30 폐지되는 /aq/observation/latLong/current/의 후속 서비스.
      // 아래 payload는 실제 API를 직접 호출해 확인한 응답 형태를 그대로 사용한다.
      final source = AirNowDataSource(
        dio: _fakeDio([
          _item(parameterName: 'PM2.5', nowcastAQI: 11, category: 'Good'),
          _item(parameterName: 'OZONE', nowcastAQI: 27, category: 'Good'),
          _item(parameterName: 'PM10', nowcastAQI: 9, category: 'Good'),
        ]),
      );

      final (pm10, pm25, o3, aqiValue, aqiGrade) = await source
          .fetchAirQuality(lat: 38.3191, lon: -122.2998);

      expect(pm25, isNotNull);
      expect(pm10, isNotNull);
      expect(o3, isNotNull);
      expect(aqiValue, 27); // 세 파라미터 중 가장 높은 nowcastAQI
      expect(aqiGrade, 1); // Good → grade 1
    },
  );

  test('maps aqiCategoryName strings to grade 1~4', () async {
    final source = AirNowDataSource(
      dio: _fakeDio([
        _item(parameterName: 'PM2.5', nowcastAQI: 160, category: 'Unhealthy'),
      ]),
    );

    final (_, _, _, _, aqiGrade) = await source.fetchAirQuality(
      lat: 38.3191,
      lon: -122.2998,
    );

    expect(aqiGrade, 3);
  });

  test('returns all-null when the upstream list is empty', () async {
    final source = AirNowDataSource(dio: _fakeDio(const []));

    final result = await source.fetchAirQuality(lat: 38.3191, lon: -122.2998);

    expect(result, (null, null, null, null, null));
  });
}

Map<String, dynamic> _item({
  required String parameterName,
  required int nowcastAQI,
  required String category,
}) => {
  'dateObserved': '2026-09-01',
  'hourObserved': '16:00',
  'localTimeZone': 'PDT',
  'reportingAreaName': 'Napa',
  'siteID': '060950004',
  'siteName': 'Vallejo',
  'parameterName': parameterName,
  'nowcastAQI': nowcastAQI,
  'aqiCategoryName': category,
  'reportingAgency': 'Bay Area Air District',
  'lookupBehavior': 'Closest Reading By Pollutant',
  'consideredMonitors': 'All',
  'lookupBoundary': '50 Miles',
};

Dio _fakeDio(List<Map<String, dynamic>> items) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(Response<List<dynamic>>(requestOptions: options, data: items));
      },
    ),
  );
  return dio;
}
