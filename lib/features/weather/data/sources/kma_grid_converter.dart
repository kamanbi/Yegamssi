import 'dart:math';

/// 위경도 ↔ 기상청 격자 좌표(X, Y) 변환
/// 기상청 Lambert Conformal Conic 투영 기반
class KmaGridConverter {
  KmaGridConverter._();

  static const double _re = 6371.00877; // 지구 반경 (km)
  static const double _grid = 5.0; // 격자 간격 (km)
  static const double _slat1 = 30.0; // 표준위도 1 (도)
  static const double _slat2 = 60.0; // 표준위도 2 (도)
  static const double _olon = 126.0; // 기준점 경도 (도)
  static const double _olat = 38.0; // 기준점 위도 (도)
  static const double _xo = 43; // 기준점 X 격자
  static const double _yo = 136; // 기준점 Y 격자

  static const double _degrad = pi / 180.0;

  static ({int nx, int ny}) latLonToGrid(double lat, double lon) {
    const re = _re / _grid;
    const slat1 = _slat1 * _degrad;
    const slat2 = _slat2 * _degrad;
    const olon = _olon * _degrad;
    const olat = _olat * _degrad;

    var sn = tan(pi * 0.25 + slat2 * 0.5) / tan(pi * 0.25 + slat1 * 0.5);
    sn = log(cos(slat1) / cos(slat2)) / log(sn);
    var sf = tan(pi * 0.25 + slat1 * 0.5);
    sf = pow(sf, sn) * cos(slat1) / sn;
    var ro = tan(pi * 0.25 + olat * 0.5);
    ro = re * sf / pow(ro, sn);

    var ra = tan(pi * 0.25 + lat * _degrad * 0.5);
    ra = re * sf / pow(ra, sn);
    var theta = lon * _degrad - olon;
    if (theta > pi) theta -= 2.0 * pi;
    if (theta < -pi) theta += 2.0 * pi;
    theta *= sn;

    final nx = (ra * sin(theta) + _xo + 0.5).floor();
    final ny = (ro - ra * cos(theta) + _yo + 0.5).floor();

    return (nx: nx, ny: ny);
  }
}
