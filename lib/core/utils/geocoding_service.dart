import 'package:dio/dio.dart';

class GeocodingService {
  GeocodingService._();

  static const String _fallbackLocationName = '현재 위치';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://nominatim.openstreetmap.org',
      headers: {'User-Agent': 'YegamssiApp/1.0', 'Accept-Language': 'ko,en'},
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  static Future<String> reverseGeocode(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'format': 'json',
          'zoom': 18,
          'addressdetails': 1,
        },
      );

      final data = response.data as Map<String, dynamic>?;
      final address = data?['address'] as Map<String, dynamic>?;
      if (address == null) {
        return _fallbackLocationName;
      }

      final locationName = _composeLocationName(address);
      return locationName.isEmpty ? _fallbackLocationName : locationName;
    } catch (_) {
      return _fallbackLocationName;
    }
  }

  static String _composeLocationName(Map<String, dynamic> address) {
    final neighborhood = _firstText(address, const [
      'suburb',
      'quarter',
      'neighbourhood',
      'city_block',
      'village',
      'hamlet',
      'isolated_dwelling',
    ]);
    final district = _firstText(address, const [
      'city_district',
      'borough',
      'district',
      'county',
      'municipality',
    ]);
    final city = _firstText(address, const [
      'city',
      'town',
      'province',
      'state',
      'region',
      'municipality',
      'county',
    ]);

    final segments = _compactLocationSegments([city, district, neighborhood]);
    if (segments.isNotEmpty) {
      return segments.join(' ');
    }

    return _firstText(address, const ['country']);
  }

  static List<String> _compactLocationSegments(List<String> values) {
    final segments = <String>[];
    for (final value in values) {
      if (value.isEmpty || segments.contains(value)) {
        continue;
      }
      segments.add(value);
    }
    return segments;
  }

  static String _firstText(Map<String, dynamic> address, List<String> keys) {
    for (final key in keys) {
      final value = address[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }
}
