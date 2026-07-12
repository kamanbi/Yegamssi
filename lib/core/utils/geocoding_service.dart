import 'package:dio/dio.dart';

import '../locale/country_code.dart';

class GeocodingService {
  GeocodingService._();

  static final Map<String, String> _memoryCache = {};

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://nominatim.openstreetmap.org',
      headers: {'User-Agent': 'YegamssiApp/1.0'},
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  static Future<String> reverseGeocode(
    double lat,
    double lon, {
    AppLanguage language = AppLanguage.ko,
    CountryCode? fallbackCountry,
  }) async {
    final cacheKey = _cacheKey(lat, lon, language);
    final cached = _memoryCache[cacheKey];
    if (cached != null) return cached;

    try {
      final response = await _dio.get(
        '/reverse',
        options: Options(
          headers: {'Accept-Language': _acceptLanguage(language)},
        ),
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
        return _fallbackLocationName(language, fallbackCountry);
      }

      final locationName = _composeLocationName(address, language);
      final resolvedName = locationName.isEmpty
          ? _fallbackLocationName(language, fallbackCountry)
          : locationName;
      _memoryCache[cacheKey] = resolvedName;
      return resolvedName;
    } catch (_) {
      return _fallbackLocationName(language, fallbackCountry);
    }
  }

  static String _cacheKey(double lat, double lon, AppLanguage language) {
    return '${lat.toStringAsFixed(4)},${lon.toStringAsFixed(4)},${language.name}';
  }

  static String _acceptLanguage(AppLanguage language) {
    return switch (language) {
      AppLanguage.ko => 'ko,en',
      AppLanguage.ja => 'ja,en',
      AppLanguage.en => 'en',
      AppLanguage.ro => 'ro,en',
      AppLanguage.hi => 'hi,en',
      AppLanguage.zh => 'zh,en',
      AppLanguage.es => 'es,en',
      AppLanguage.pt => 'pt,en',
      AppLanguage.de => 'de,en',
      AppLanguage.fr => 'fr,en',
      AppLanguage.vi => 'vi,en',
    };
  }

  static String _composeLocationName(
    Map<String, dynamic> address,
    AppLanguage language,
  ) {
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
    final country = _firstText(address, const ['country']);
    final countryCode = _firstText(address, const [
      'country_code',
    ]).toUpperCase();
    final segments = _compactLocationSegments([city, district, neighborhood]);

    if (segments.isEmpty) return country;
    final shouldIncludeCountry = country.isNotEmpty && countryCode != 'KR';
    final visibleSegments = [
      if (language == AppLanguage.en && shouldIncludeCountry) ...segments,
      if (language == AppLanguage.en && shouldIncludeCountry) country,
      if (language != AppLanguage.en && shouldIncludeCountry) country,
      if (language != AppLanguage.en || !shouldIncludeCountry) ...segments,
    ];
    return _compactLocationSegments(
      visibleSegments,
    ).join(language == AppLanguage.en ? ', ' : ' ');
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

  static String _fallbackLocationName(
    AppLanguage language,
    CountryCode? country,
  ) {
    if (country != null && country != CountryCode.global) {
      return switch (language) {
        AppLanguage.ko => _countryNameKo(country),
        AppLanguage.ja => _countryNameJa(country),
        AppLanguage.en => country.displayName,
        AppLanguage.ro => _countryNameRo(country),
        AppLanguage.hi => _countryNameHi(country),
        AppLanguage.zh => _countryNameZh(country),
        AppLanguage.es => _countryNameEs(country),
        AppLanguage.pt => _countryNamePt(country),
        AppLanguage.de => _countryNameDe(country),
        AppLanguage.fr => _countryNameFr(country),
        AppLanguage.vi => _countryNameVi(country),
      };
    }
    return switch (language) {
      AppLanguage.ko => '\uD604\uC7AC \uC704\uCE58',
      AppLanguage.ja => '\u73FE\u5728\u5730',
      AppLanguage.en => 'Current location',
      AppLanguage.ro => 'Loca\u021Bia curent\u0103',
      AppLanguage.hi =>
        '\u0935\u0930\u094D\u0924\u092E\u093E\u0928 \u0938\u094D\u0925\u093E\u0928',
      AppLanguage.zh => '\u5F53\u524D\u4F4D\u7F6E',
      AppLanguage.es => 'Ubicaci\u00F3n actual',
      AppLanguage.pt => 'Localiza\u00E7\u00E3o atual',
      AppLanguage.de => 'Aktueller Standort',
      AppLanguage.fr => 'Position actuelle',
      AppLanguage.vi => 'V\u1ECB tr\u00ED hi\u1EC7n t\u1EA1i',
    };
  }

  static String _countryNameKo(CountryCode country) {
    return switch (country) {
      CountryCode.kr => '\uD55C\uAD6D',
      CountryCode.us => '\uBBF8\uAD6D',
      CountryCode.jp => '\uC77C\uBCF8',
      CountryCode.cn => '\uC911\uAD6D',
      CountryCode.global => '\uAE00\uB85C\uBC8C',
    };
  }

  static String _countryNameJa(CountryCode country) {
    return switch (country) {
      CountryCode.kr => '\u97D3\u56FD',
      CountryCode.us => '\u7C73\u56FD',
      CountryCode.jp => '\u65E5\u672C',
      CountryCode.cn => '\u4E2D\u56FD',
      CountryCode.global => '\u30B0\u30ED\u30FC\u30D0\u30EB',
    };
  }

  static String _countryNameRo(CountryCode country) {
    return switch (country) {
      CountryCode.kr => 'Coreea de Sud',
      CountryCode.us => 'Statele Unite',
      CountryCode.jp => 'Japonia',
      CountryCode.cn => 'China',
      CountryCode.global => 'Global',
    };
  }

  static String _countryNameHi(CountryCode country) {
    return switch (country) {
      CountryCode.kr =>
        '\u0926\u0915\u094D\u0937\u093F\u0923 \u0915\u094B\u0930\u093F\u092F\u093E',
      CountryCode.us =>
        '\u0938\u0902\u092F\u0941\u0915\u094D\u0924 \u0930\u093E\u091C\u094D\u092F \u0905\u092E\u0947\u0930\u093F\u0915\u093E',
      CountryCode.jp => '\u091C\u093E\u092A\u093E\u0928',
      CountryCode.cn => '\u091A\u0940\u0928',
      CountryCode.global => '\u0935\u0948\u0936\u094D\u0935\u093F\u0915',
    };
  }

  static String _countryNameZh(CountryCode country) {
    return switch (country) {
      CountryCode.kr => '\u97E9\u56FD',
      CountryCode.us => '\u7F8E\u56FD',
      CountryCode.jp => '\u65E5\u672C',
      CountryCode.cn => '\u4E2D\u56FD',
      CountryCode.global => '\u5168\u7403',
    };
  }

  static String _countryNameEs(CountryCode country) {
    return switch (country) {
      CountryCode.kr => 'Corea del Sur',
      CountryCode.us => 'Estados Unidos',
      CountryCode.jp => 'Jap\u00F3n',
      CountryCode.cn => 'China',
      CountryCode.global => 'Global',
    };
  }

  static String _countryNamePt(CountryCode country) {
    return switch (country) {
      CountryCode.kr => 'Coreia do Sul',
      CountryCode.us => 'Estados Unidos',
      CountryCode.jp => 'Jap\u00E3o',
      CountryCode.cn => 'China',
      CountryCode.global => 'Global',
    };
  }

  static String _countryNameDe(CountryCode country) {
    return switch (country) {
      CountryCode.kr => 'S\u00FCdkorea',
      CountryCode.us => 'USA',
      CountryCode.jp => 'Japan',
      CountryCode.cn => 'China',
      CountryCode.global => 'Global',
    };
  }

  static String _countryNameFr(CountryCode country) {
    return switch (country) {
      CountryCode.kr => 'Cor\u00E9e du Sud',
      CountryCode.us => '\u00C9tats-Unis',
      CountryCode.jp => 'Japon',
      CountryCode.cn => 'Chine',
      CountryCode.global => 'Global',
    };
  }

  static String _countryNameVi(CountryCode country) {
    return switch (country) {
      CountryCode.kr => 'H\u00E0n Qu\u1ED1c',
      CountryCode.us => 'Hoa K\u1EF3',
      CountryCode.jp => 'Nh\u1EADt B\u1EA3n',
      CountryCode.cn => 'Trung Qu\u1ED1c',
      CountryCode.global => 'To\u00E0n c\u1EA7u',
    };
  }
}
