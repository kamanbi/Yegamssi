import 'dart:math';

/// 일출/일몰 시간 기반 주간/야간 판단 (외부 패키지 없이 NOAA 공식 직접 계산)
class SunriseSunsetHelper {
  SunriseSunsetHelper._();

  /// 현재 시간이 야간(일몰~일출)인지 판단
  ///
  /// [lat]: 위도, [lon]: 경도
  /// [now]: 확인할 시간 (기본값: 현재 로컬 시간)
  static bool isNight(double lat, double lon, {DateTime? now}) {
    final dateTime = now ?? DateTime.now();
    try {
      final times = _getSunTimes(lat, lon, dateTime);
      final sunriseHour = times.$1;
      final sunsetHour = times.$2;
      final localHour = dateTime.hour + dateTime.minute / 60.0;
      return localHour < sunriseHour || localHour > sunsetHour;
    } catch (_) {
      return false; // 계산 실패 시 주간으로 처리
    }
  }

  /// Spencer/NOAA 근사 공식으로 로컬 시각 기준 일출·일몰 시간(h) 반환
  static (double sunrise, double sunset) _getSunTimes(
    double lat,
    double lon,
    DateTime date,
  ) {
    final dayOfYear = date.difference(DateTime(date.year)).inDays + 1;

    // 태양 적위 (Spencer 방정식)
    final B = (360.0 / 365.0) * (dayOfYear - 81) * _d2r;
    final declination = 23.45 * sin(B) * _d2r;

    // 균시차 (분)
    final eqT = 9.87 * sin(2 * B) - 7.53 * cos(B) - 1.5 * sin(B);

    // 시간각
    final latRad = lat * _d2r;
    final cosHourAngle = -tan(latRad) * tan(declination);
    if (cosHourAngle > 1) return (12.0, 12.0); // 극야: 해가 안 뜸
    if (cosHourAngle < -1) return (0.0, 24.0); // 백야: 해가 안 짐

    final hourAngle = acos(cosHourAngle) / _d2r; // 도 단위

    // UTC 기준 태양 정오
    final solarNoonUTC = 12.0 - lon / 15.0 - eqT / 60.0;

    // UTC 일출·일몰
    final sunriseUTC = solarNoonUTC - hourAngle / 15.0;
    final sunsetUTC = solarNoonUTC + hourAngle / 15.0;

    // 로컬 시간으로 변환
    final utcOffset = date.timeZoneOffset.inMinutes / 60.0;
    return (sunriseUTC + utcOffset, sunsetUTC + utcOffset);
  }

  static const double _d2r = pi / 180.0;
}
