import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/network/weather_proxy_dio.dart';

/// EPA AirNow API — 미국 대기질 (무료, API 키 필요)
/// https://docs.airnowapi.org/aq101
///
/// 기존 "/aq/observation/latLong/current/"는 2026-09-30 폐지 예정이라
/// 후속 서비스 "Current Observations by Latitude/Longitude or ZIP Code"
/// (/aq/observation/current/ziplatLong/)로 이전했다. 응답 스키마가 달라져
/// AQI→categoryNumber(1~6) 조합 대신 aqiCategoryName(문자열)만 내려온다.
class AirNowDataSource {
  AirNowDataSource({Dio? dio})
    : _dio = dio ?? WeatherProxyDio.create(WeatherProxyProvider.airNow);

  final Dio _dio;
  final Logger _logger = Logger();

  static const _path = '/aq/observation/current/ziplatLong/';

  /// 위경도 기반 현재 대기질 조회
  /// 반환: (pm10 μg/m³, pm25 μg/m³, o3 ppm, aqiValue, aqiGrade 1~4)
  Future<
    (double? pm10, double? pm25, double? o3, double? aqiValue, int? aqiGrade)
  >
  fetchAirQuality({required double lat, required double lon}) async {
    try {
      final response = await _dio.get(
        _path,
        queryParameters: {
          'format': 'application/json',
          'latitude': lat.toStringAsFixed(4),
          'longitude': lon.toStringAsFixed(4),
        },
      );

      final items = response.data;
      if (items is! List || items.isEmpty) {
        return (null, null, null, null, null);
      }

      double? pm10;
      double? pm25;
      double? o3;
      int highestAqi = 0;
      int? highestCategory;

      for (final item in items) {
        final param = (item['parameterName'] as String? ?? '').toUpperCase();
        final aqi = (item['nowcastAQI'] as num?)?.toInt() ?? 0;
        final category = _categoryNumberFor(
          item['aqiCategoryName'] as String?,
        );

        if (aqi > highestAqi) {
          highestAqi = aqi;
          highestCategory = category;
        }

        switch (param) {
          case 'PM2.5':
            pm25 = _aqiToConcentrationPm25(aqi);
          case 'PM10':
            pm10 = _aqiToConcentrationPm10(aqi);
          case 'OZONE':
            o3 = _aqiToConcentrationO3(aqi);
        }
      }

      return (
        pm10,
        pm25,
        o3,
        highestAqi > 0 ? highestAqi.toDouble() : null,
        highestCategory != null ? _mapGrade(highestCategory) : null,
      );
    } catch (e, st) {
      _logger.w('AirNow 대기질 조회 실패', error: e, stackTrace: st);
      return (null, null, null, null, null);
    }
  }

  /// aqiCategoryName(문자열) → AirNow Category Number(1~6)
  /// https://docs.airnowapi.org/ObservationsByZipCodeLatLon/docs
  int? _categoryNumberFor(String? name) {
    return switch (name) {
      'Good' => 1,
      'Moderate' => 2,
      'Unhealthy for Sensitive Groups' => 3,
      'Unhealthy' => 4,
      'Very Unhealthy' => 5,
      'Hazardous' => 6,
      _ => null,
    };
  }

  /// AQI → khaiGrade(1~4) 변환
  /// AirNow Category: 1=Good, 2=Moderate, 3=USG, 4=Unhealthy, 5=VeryUnhealthy, 6=Hazardous
  int _mapGrade(int category) {
    return switch (category) {
      1 => 1,
      2 => 2,
      3 || 4 => 3,
      _ => 4,
    };
  }

  /// EPA PM2.5 AQI → μg/m³ (piecewise linear)
  double _aqiToConcentrationPm25(int aqi) {
    return _aqiToConc(aqi, const [
      (0, 50, 0.0, 12.0),
      (51, 100, 12.1, 35.4),
      (101, 150, 35.5, 55.4),
      (151, 200, 55.5, 150.4),
      (201, 300, 150.5, 250.4),
      (301, 400, 250.5, 350.4),
      (401, 500, 350.5, 500.4),
    ]);
  }

  /// EPA PM10 AQI → μg/m³ (piecewise linear)
  double _aqiToConcentrationPm10(int aqi) {
    return _aqiToConc(aqi, const [
      (0, 50, 0.0, 54.0),
      (51, 100, 55.0, 154.0),
      (101, 150, 155.0, 254.0),
      (151, 200, 255.0, 354.0),
      (201, 300, 355.0, 424.0),
      (301, 400, 425.0, 504.0),
      (401, 500, 505.0, 604.0),
    ]);
  }

  /// EPA Ozone 8h AQI → ppm (piecewise linear)
  double _aqiToConcentrationO3(int aqi) {
    return _aqiToConc(aqi, const [
      (0, 50, 0.000, 0.054),
      (51, 100, 0.055, 0.070),
      (101, 150, 0.071, 0.085),
      (151, 200, 0.086, 0.105),
      (201, 300, 0.106, 0.200),
    ]);
  }

  double _aqiToConc(int aqi, List<(int, int, double, double)> breakpoints) {
    for (final (aqiLo, aqiHi, concLo, concHi) in breakpoints) {
      if (aqi >= aqiLo && aqi <= aqiHi) {
        return (concHi - concLo) / (aqiHi - aqiLo) * (aqi - aqiLo) + concLo;
      }
    }
    // 범위 초과 시 최대값 반환
    return breakpoints.last.$4;
  }
}
