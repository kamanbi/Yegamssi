import 'dart:math';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/geocoding_service.dart';
import '../../domain/entities/weather_entity.dart';
import '../models/weather_response.dart';
import 'air_korea_data_source.dart';
import 'kma_grid_converter.dart';
import 'weather_data_source.dart';

class KmaDataSource implements WeatherDataSource {
  KmaDataSource()
    : _dio = DioClient.create(baseUrl: AppConfig.kmaBaseUrl),
      _airKorea = AirKoreaDataSource();

  final Dio _dio;
  final AirKoreaDataSource _airKorea;
  final Logger _logger = Logger();

  static const _ncstPath =
      '/api/typ02/openApi/VilageFcstInfoService_2.0/getUltraSrtNcst';
  static const _srtPath =
      '/api/typ02/openApi/VilageFcstInfoService_2.0/getUltraSrtFcst';
  static const _fcstPath =
      '/api/typ02/openApi/VilageFcstInfoService_2.0/getVilageFcst';
  static const _midLandPath =
      '/api/typ02/openApi/MidFcstInfoService/getMidLandFcst';
  // 중기기온 (typ01 plain-text API)
  static const _midTaWcPath = '/api/typ01/url/fct_afs_wc.php';

  static const _hourlyCutoffHours = 1;
  static const _maxHourlyForecasts = 24;
  static const _maxDailyForecasts = 7;

  @override
  Future<WeatherResponse> fetchCurrent({
    required double lat,
    required double lon,
  }) async {
    final grid = KmaGridConverter.latLonToGrid(lat, lon);
    final now = DateTime.now();

    try {
      final ncstItems = await _requestItems(
        path: _ncstPath,
        nx: grid.nx,
        ny: grid.ny,
        baseDate: _ncstBaseTime(now).kmaDate,
        baseTime: _ncstBaseTime(now).kmaTime,
      );

      List<Map<String, dynamic>> ultraShortForecastItems = const [];
      try {
        final (baseDate, baseTime) = _srtBaseTime(now);
        ultraShortForecastItems = await _requestItems(
          path: _srtPath,
          nx: grid.nx,
          ny: grid.ny,
          baseDate: baseDate,
          baseTime: baseTime,
          numOfRows: 200,
        );
      } catch (error, stackTrace) {
        _logger.w(
          'KMA ultra short forecast unavailable',
          error: error,
          stackTrace: stackTrace,
        );
      }

      List<Map<String, dynamic>> villageForecastItems = const [];
      try {
        final (baseDate, baseTime) = _fcstBaseTime(now);
        villageForecastItems = await _requestItems(
          path: _fcstPath,
          nx: grid.nx,
          ny: grid.ny,
          baseDate: baseDate,
          baseTime: baseTime,
          numOfRows: 1000,
        );
      } catch (error, stackTrace) {
        _logger.w(
          'KMA village forecast unavailable',
          error: error,
          stackTrace: stackTrace,
        );
      }

      final currentObservedValues = _latestCategoryValues(ncstItems);
      // 단기예보(village) 먼저, 초단기예보가 뒤에서 덮어써 우선 적용
      final hourlyForecasts = _parseHourlyForecasts([
        ...villageForecastItems,
        ...ultraShortForecastItems,
      ], now);
      final villageDailyForecasts = _parseDailyForecasts(
        villageForecastItems,
        now,
      );

      // 중기예보 + 에어코리아 병렬 조회
      final midTermFuture = _fetchMidTermDailyForecasts(
        lat: lat,
        lon: lon,
        now: now,
      ).catchError((_) => (const <DailyForecast>[], ''));
      final airFuture = _airKorea.fetchAirQuality(lat: lat, lon: lon);
      final locationFuture = GeocodingService.reverseGeocode(lat, lon);

      final midTermResult = await midTermFuture;
      final midTermForecasts = midTermResult.$1;
      final (pm10, pm25, o3, khaiValue, khaiGrade) = await airFuture;
      final locationName = await locationFuture;

      // 단기(village) 우선, 이후 날짜는 중기예보로 채움
      final dailyByDate = <String, DailyForecast>{};
      for (final f in villageDailyForecasts) {
        dailyByDate[f.date.yyyyMMdd] = f;
      }
      for (final f in midTermForecasts) {
        dailyByDate.putIfAbsent(f.date.yyyyMMdd, () => f);
      }
      final dailyForecasts =
          (dailyByDate.values.toList()
                ..sort((a, b) => a.date.compareTo(b.date)))
              .take(_maxDailyForecasts)
              .toList(growable: false);
      final nearestForecastValues = _nearestForecastValues(
        ultraShortForecastItems,
        now,
      );
      final villageSnapshotValues = _nearestForecastValues(
        villageForecastItems,
        now,
      );

      final isNight = _isNightByHour(now);

      return _buildResponse(
        currentObservedValues: currentObservedValues,
        nearestForecastValues: nearestForecastValues,
        villageSnapshotValues: villageSnapshotValues,
        hourlyForecasts: hourlyForecasts,
        dailyForecasts: dailyForecasts,
        locationName: locationName,
        pm10: pm10,
        pm25: pm25,
        o3: o3,
        khaiValue: khaiValue,
        khaiGrade: khaiGrade,
        isNight: isNight,
      );
    } on DioException catch (error) {
      throw NetworkException('기상청 API 오류: ${error.message}');
    } catch (error) {
      if (error is AppException) rethrow;
      throw ParseException('기상청 응답 파싱 실패: $error');
    }
  }

  Future<List<Map<String, dynamic>>> _requestItems({
    required String path,
    required int nx,
    required int ny,
    required String baseDate,
    required String baseTime,
    int numOfRows = 10,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: {
        'authKey': AppConfig.kmaApiKey,
        'dataType': 'JSON',
        'numOfRows': numOfRows,
        'pageNo': 1,
        'base_date': baseDate,
        'base_time': baseTime,
        'nx': nx,
        'ny': ny,
      },
    );

    final items = response.data?['response']?['body']?['items']?['item'];
    if (items is! List) {
      throw const ParseException('KMA 응답 파싱 실패: items 없음');
    }
    return items
        .whereType<Map>()
        .map((item) {
          return item.map((key, value) => MapEntry(key.toString(), value));
        })
        .toList(growable: false);
  }

  Map<String, String> _latestCategoryValues(List<Map<String, dynamic>> items) {
    final values = <String, String>{};
    for (final item in items) {
      final category = item['category'] as String?;
      final value = item['obsrValue']?.toString();
      if (category == null || value == null || values.containsKey(category)) {
        continue;
      }
      values[category] = value;
    }
    return values;
  }

  Map<String, String> _nearestForecastValues(
    List<Map<String, dynamic>> items,
    DateTime now,
  ) {
    final groupedItems = _groupForecastItems(items);
    if (groupedItems.isEmpty) {
      return const {};
    }

    final orderedKeys = groupedItems.keys.toList()
      ..sort((left, right) => left.compareTo(right));
    final cutoff = now.subtract(const Duration(hours: _hourlyCutoffHours));

    String? selectedKey;
    for (final key in orderedKeys) {
      final parsed = _parseForecastKey(key);
      if (parsed == null) continue;
      if (!parsed.isBefore(cutoff)) {
        selectedKey = key;
        break;
      }
    }
    selectedKey ??= orderedKeys.first;
    return groupedItems[selectedKey] ?? const {};
  }

  List<HourlyForecast> _parseHourlyForecasts(
    List<Map<String, dynamic>> items,
    DateTime now,
  ) {
    final groupedItems = _groupForecastItems(items);
    if (groupedItems.isEmpty) {
      _logger.w('KMA hourly forecast parsing returned empty groups');
      return const [];
    }

    final cutoff = now.subtract(const Duration(hours: _hourlyCutoffHours));
    final forecasts = <HourlyForecast>[];

    final orderedEntries = groupedItems.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));

    for (final entry in orderedEntries) {
      final forecastTime = _parseForecastKey(entry.key);
      if (forecastTime == null || forecastTime.isBefore(cutoff)) {
        continue;
      }

      final temperature = _double(entry.value['T1H'] ?? entry.value['TMP']);
      if (temperature == null) {
        continue;
      }

      forecasts.add(
        HourlyForecast(
          time: forecastTime,
          tempCelsius: temperature,
          condition: _mapCondition(
            entry.value['PTY'] ?? '0',
            entry.value['SKY'] ?? '1',
            _precipAmount(entry.value['RN1'] ?? entry.value['PCP']),
          ),
        ),
      );

      if (forecasts.length >= _maxHourlyForecasts) {
        break;
      }
    }

    return forecasts;
  }

  List<DailyForecast> _parseDailyForecasts(
    List<Map<String, dynamic>> items,
    DateTime now,
  ) {
    if (items.isEmpty) {
      _logger.w('KMA daily forecast source is empty');
      return const [];
    }

    final groupedItems = _groupForecastItems(items);
    final dailyByDate = <String, _DailyAccumulator>{};

    for (final entry in groupedItems.entries) {
      final forecastTime = _parseForecastKey(entry.key);
      if (forecastTime == null) {
        continue;
      }
      final dateKey = forecastTime.yyyyMMdd;
      final accumulator = dailyByDate.putIfAbsent(
        dateKey,
        () => _DailyAccumulator(
          date: DateTime(
            forecastTime.year,
            forecastTime.month,
            forecastTime.day,
          ),
        ),
      );
      accumulator.add(time: forecastTime, values: entry.value);
    }

    final today = DateTime(now.year, now.month, now.day);
    final forecasts =
        dailyByDate.values
            .where((daily) => !daily.date.isBefore(today))
            .toList(growable: false)
          ..sort((left, right) => left.date.compareTo(right.date));

    return forecasts
        .take(_maxDailyForecasts)
        .map((daily) => daily.toForecast(_mapCondition))
        .toList(growable: false);
  }

  Map<String, Map<String, String>> _groupForecastItems(
    List<Map<String, dynamic>> items,
  ) {
    final grouped = <String, Map<String, String>>{};
    for (final item in items) {
      final forecastDate = item['fcstDate']?.toString();
      final forecastTime = item['fcstTime']?.toString();
      final category = item['category']?.toString();
      final value = item['fcstValue']?.toString();
      if (forecastDate == null ||
          forecastTime == null ||
          category == null ||
          value == null) {
        continue;
      }
      final key = '$forecastDate$forecastTime';
      grouped.putIfAbsent(key, () => <String, String>{})[category] = value;
    }
    return grouped;
  }

  DateTime? _parseForecastKey(String key) {
    if (key.length != 12) {
      return null;
    }

    final year = int.tryParse(key.substring(0, 4));
    final month = int.tryParse(key.substring(4, 6));
    final day = int.tryParse(key.substring(6, 8));
    final hour = int.tryParse(key.substring(8, 10));
    final minute = int.tryParse(key.substring(10, 12));
    if (year == null ||
        month == null ||
        day == null ||
        hour == null ||
        minute == null) {
      return null;
    }
    return DateTime(year, month, day, hour, minute);
  }

  WeatherResponse _buildResponse({
    required Map<String, String> currentObservedValues,
    required Map<String, String> nearestForecastValues,
    required Map<String, String> villageSnapshotValues,
    required List<HourlyForecast> hourlyForecasts,
    required List<DailyForecast> dailyForecasts,
    required String locationName,
    double? pm10,
    double? pm25,
    double? o3,
    double? khaiValue,
    int? khaiGrade,
    bool isNight = false,
  }) {
    final currentTemperature =
        _double(currentObservedValues['T1H']) ??
        _double(nearestForecastValues['T1H']) ??
        _double(villageSnapshotValues['TMP']) ??
        0.0;

    final humidity =
        _int(currentObservedValues['REH']) ??
        _int(nearestForecastValues['REH']) ??
        _int(villageSnapshotValues['REH']) ??
        50;

    final windSpeed =
        _double(currentObservedValues['WSD']) ??
        _double(nearestForecastValues['WSD']) ??
        _double(villageSnapshotValues['WSD']) ??
        0.0;

    final precipitationType =
        currentObservedValues['PTY'] ??
        nearestForecastValues['PTY'] ??
        villageSnapshotValues['PTY'] ??
        '0';

    final sky =
        nearestForecastValues['SKY'] ?? villageSnapshotValues['SKY'] ?? '1';

    final precipitationProbability =
        ((_double(villageSnapshotValues['POP']) ??
                    _double(nearestForecastValues['POP']) ??
                    0) /
                100)
            .clamp(0.0, 1.0);

    final uvIndex = _int(villageSnapshotValues['UVI']) ?? 0;
    final precipitationAmount = _precipAmount(
      currentObservedValues['RN1'] ??
          nearestForecastValues['RN1'] ??
          villageSnapshotValues['PCP'],
    );

    return WeatherResponse(
      tempCelsius: currentTemperature,
      feelsLikeCelsius: _feelsLike(currentTemperature, windSpeed, humidity),
      condition: _mapCondition(precipitationType, sky, precipitationAmount),
      windSpeedMs: windSpeed,
      precipProbability: precipitationProbability,
      precipitationAmountMm: precipitationAmount,
      uvIndex: uvIndex,
      humidity: humidity,
      locationName: locationName,
      pm10: pm10,
      pm25: pm25,
      o3: o3,
      khaiValue: khaiValue,
      khaiGrade: khaiGrade,
      isNight: isNight,
      hourlyForecasts: hourlyForecasts,
      dailyForecasts: dailyForecasts,
    );
  }

  WeatherCondition _mapCondition(
    String pty,
    String sky,
    double precipitationAmount,
  ) {
    switch (pty) {
      case '1':
        if (precipitationAmount >= 15) return WeatherCondition.heavyRain;
        if (precipitationAmount >= 3) return WeatherCondition.rainy;
        return WeatherCondition.slightRain;
      case '2':
      case '6':
        return WeatherCondition.sleet;
      case '3':
        return precipitationAmount >= 5
            ? WeatherCondition.snowy
            : WeatherCondition.lightSnow;
      case '4':
        return precipitationAmount >= 10
            ? WeatherCondition.heavyRain
            : WeatherCondition.rainy;
      case '5':
        return WeatherCondition.slightRain;
      case '7':
        return WeatherCondition.lightSnow;
    }

    return switch (sky) {
      '1' => WeatherCondition.sunny,
      '3' => WeatherCondition.partlyCloudy,
      '4' => WeatherCondition.cloudy,
      _ => WeatherCondition.unknown,
    };
  }

  double _feelsLike(double temp, double windMs, int humidity) {
    if (temp >= 27) {
      return temp + 0.33 * (humidity / 100 * 6.105) - 4.0;
    } else if (windMs >= 1.3 && temp <= 10) {
      final windFactor = pow(windMs * 3.6, 0.16).toDouble();
      return 13.12 +
          0.6215 * temp -
          11.37 * windFactor +
          0.3965 * temp * windFactor;
    }
    return temp;
  }

  bool _isNightByHour(DateTime time) {
    return time.hour < 6 || time.hour >= 20;
  }

  DateTime _ncstBaseTime(DateTime now) {
    final base = now.minute < 10 ? now.subtract(const Duration(hours: 1)) : now;
    return DateTime(base.year, base.month, base.day, base.hour);
  }

  (String, String) _srtBaseTime(DateTime now) {
    final target = now.minute < 45
        ? now.subtract(const Duration(hours: 1))
        : now;
    final base = DateTime(
      target.year,
      target.month,
      target.day,
      target.hour,
      30,
    );
    return (base.kmaDate, base.kmaTime);
  }

  static const _fcstHours = [2, 5, 8, 11, 14, 17, 20, 23];

  (String, String) _fcstBaseTime(DateTime now) {
    final adjustedHour = now.minute < 30 ? now.hour - 1 : now.hour;
    var baseHour = _fcstHours.last;
    for (var index = _fcstHours.length - 1; index >= 0; index--) {
      if (adjustedHour >= _fcstHours[index]) {
        baseHour = _fcstHours[index];
        break;
      }
    }

    final baseDate = adjustedHour < _fcstHours.first
        ? now.subtract(const Duration(days: 1)).kmaDate
        : now.kmaDate;
    return (baseDate, '${baseHour.toString().padLeft(2, '0')}00');
  }

  // 최신 유효 tmFc 우선 조회, 데이터 부족 시 직전 발표시각으로 fallback
  Future<(List<DailyForecast>, String)> _fetchMidTermDailyForecasts({
    required double lat,
    required double lon,
    required DateTime now,
  }) async {
    final landId = _landRegId(lat, lon);
    final tmFcs = _validTmFcs(now);
    String lastDebug = 'no-tmFc';

    for (int i = 0; i < tmFcs.length; i++) {
      final tmFc = tmFcs[i];
      try {
        final (entries, debug) = await _fetchMidTermForTmFc(
          tmFc: tmFc,
          landId: landId,
        );
        lastDebug = debug.isEmpty ? 'ok:$tmFc' : debug;
        if (entries.length > 2) return (entries, '');
        if (i < tmFcs.length - 1) {
          _logger.w(
            '중기예보 tmFc=$tmFc: ${entries.length}일치 ($debug), 직전 발표로 fallback',
          );
        }
      } catch (e) {
        lastDebug =
            'exc:${e.toString().substring(0, e.toString().length.clamp(0, 50))}';
        if (i < tmFcs.length - 1) {
          _logger.w('중기예보 tmFc=$tmFc 실패, 직전 발표로 fallback: $e');
        }
      }
    }
    return (const <DailyForecast>[], lastDebug);
  }

  Future<(List<DailyForecast>, String)> _fetchMidTermForTmFc({
    required String tmFc, // YYYYMMDDHHMM (12자리)
    required String landId,
  }) async {
    // 1. 날씨 상태 + 강수확률: getMidLandFcst (JSON)
    final landRes = await _dio.get(
      _midLandPath,
      queryParameters: {
        'authKey': AppConfig.kmaApiKey,
        'dataType': 'JSON',
        'numOfRows': 999,
        'pageNo': 1,
        'tmFc': tmFc,
        'regId': landId,
      },
    );
    final land = _extractFirstItem(landRes.data);
    if (land == null) return (const <DailyForecast>[], 'land=null');

    final baseDate = DateTime(
      int.parse(tmFc.substring(0, 4)),
      int.parse(tmFc.substring(4, 6)),
      int.parse(tmFc.substring(6, 8)),
    );

    // 2. 기온 min/max: fct_afs_wc.php (plain text)
    final cityId = _tempCityFor(landId);
    final tmfc10 = tmFc.substring(0, 10); // YYYYMMDDHH
    final tmef1 = _fmt8(baseDate.add(const Duration(days: 3)));
    final tmef2 = _fmt8(baseDate.add(const Duration(days: 10)));
    Map<String, (int, int)> tempsByDate = {};
    try {
      final taRes = await _dio.get(
        _midTaWcPath,
        queryParameters: {
          'authKey': AppConfig.kmaApiKey,
          'reg': cityId,
          'tmfc1': tmfc10,
          'tmfc2': tmfc10,
          'tmef1': tmef1,
          'tmef2': tmef2,
          'disp': 0,
          'help': 0,
        },
        options: Options(responseType: ResponseType.plain),
      );
      tempsByDate = _parseTaWcText(taRes.data?.toString() ?? '', cityId);
    } catch (_) {}

    final result = <DailyForecast>[];
    for (int d = 3; d <= 10; d++) {
      final wfAm = (land['wf${d}Am'] ?? land['wf$d'] ?? '').toString();
      final wfPm = (land['wf${d}Pm'] ?? land['wf$d'] ?? '').toString();
      if (wfAm.isEmpty && wfPm.isEmpty) continue;
      final date = baseDate.add(Duration(days: d));
      final temps = tempsByDate[_fmt8(date)];
      final rnStAm =
          _double(land['rnSt${d}Am']?.toString()) ??
          _double(land['rnSt$d']?.toString()) ??
          0.0;
      final rnStPm = _double(land['rnSt${d}Pm']?.toString()) ?? 0.0;
      result.add(
        DailyForecast(
          date: date,
          tempMin: temps?.$1.toDouble() ?? 0.0,
          tempMax: temps?.$2.toDouble() ?? 0.0,
          condition: _mapMidTermCondition(wfAm, wfPm),
          precipProbability: ((rnStAm + rnStPm) / 2 / 100).clamp(0.0, 1.0),
          amCondition: _mapMidTermSingleCondition(wfAm),
          pmCondition: _mapMidTermSingleCondition(wfPm.isEmpty ? wfAm : wfPm),
          amTempCelsius: _estimateDayPartTemperature(
            temps?.$1.toDouble(),
            temps?.$2.toDouble(),
            isMorning: true,
          ),
          pmTempCelsius: _estimateDayPartTemperature(
            temps?.$1.toDouble(),
            temps?.$2.toDouble(),
            isMorning: false,
          ),
        ),
      );
    }
    if (result.isEmpty) return (const <DailyForecast>[], 'empty');
    return (result, '');
  }

  // fct_afs_wc.php plain text 파싱 → {YYYYMMDD: (min, max)}
  Map<String, (int, int)> _parseTaWcText(String text, String regId) {
    final result = <String, (int, int)>{};
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('#') || trimmed.isEmpty) continue;
      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length < 8 || parts[0] != regId) continue;
      final tmEf = parts[2]; // YYYYMMDDHHMM
      if (tmEf.length < 8) continue;
      final dateKey = tmEf.substring(0, 8);
      final min = int.tryParse(parts[6]);
      final max = int.tryParse(parts[7]);
      if (min != null && max != null && !result.containsKey(dateKey)) {
        result[dateKey] = (min, max);
      }
    }
    return result;
  }

  // landId → fct_afs_wc.php city regId 매핑
  String _tempCityFor(String landId) => switch (landId) {
    '11B00000' => '11B20201', // 서울/인천/경기
    '11C10000' => '11C10301', // 충청북도
    '11C20000' => '11C20101', // 충청남도/대전/세종
    '11D10000' => '11D10101', // 강원영서
    '11D20000' => '11D20501', // 강원영동
    '11F10000' || '11F00000' => '11F10201', // 경상북도/대구
    '11F20000' => '11F20401', // 경상남도
    '11G00000' => '11G00401', // 전라남도/광주
    '11H00000' || '11H10000' => '11H10201', // 전라북도
    '11H20000' => '11H20101', // 경상남도 남부
    '11J10000' => '11J10001', // 제주 북부
    _ => '11B20201',
  };

  static String _fmt8(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  // KMA API는 단일 결과를 Map으로, 복수를 List로 반환하므로 양쪽 처리
  Map<String, dynamic>? _extractFirstItem(dynamic data) {
    final raw = data?['response']?['body']?['items']?['item'];
    return switch (raw) {
      final List l when l.isNotEmpty => (l.first as Map).map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      final Map m => m.map((k, v) => MapEntry(k.toString(), v)),
      _ => null,
    };
  }

  // 유효한 tmFc 목록: 최신 발표 → 직전 발표 순
  List<String> _validTmFcs(DateTime now) {
    String fmt(DateTime d, int h) =>
        '${d.year}${d.month.toString().padLeft(2, '0')}'
        '${d.day.toString().padLeft(2, '0')}${h.toString().padLeft(2, '0')}00';

    final t = DateTime(now.year, now.month, now.day);
    final y = t.subtract(const Duration(days: 1));

    if (now.hour >= 18) return [fmt(t, 18), fmt(t, 6), fmt(y, 18)];
    if (now.hour >= 6) return [fmt(t, 6), fmt(y, 18), fmt(y, 6)];
    return [fmt(y, 18), fmt(y, 6)];
  }

  String _landRegId(double lat, double lon) {
    if (lat < 33.6) return '11J10000'; // 제주
    if (lat < 35.0) {
      return lon < 127.5 ? '11G00000' : '11H20000'; // 전남·광주 / 경남·부산·울산
    }
    if (lat < 35.8) {
      return lon < 127.5 ? '11G00000' : '11H20000'; // 전남·광주 / 경남·부산·울산
    }
    if (lat < 36.2) {
      if (lon < 127.5) return '11F10000'; // 전북
      return '11H10000'; // 경북
    }
    if (lat < 36.8) {
      if (lon < 127.0) return '11C20000'; // 충남·대전·세종
      if (lon < 128.5) return '11C10000'; // 충북
      return '11H10000'; // 경북
    }
    if (lat < 37.8) {
      if (lon < 127.5) return '11B00000'; // 서울·인천·경기
      if (lon < 128.8) return '11D10000'; // 강원영서
      return '11D20000'; // 강원영동
    }
    return lon < 128.8 ? '11D10000' : '11D20000';
  }

  WeatherCondition _mapMidTermCondition(String wfAm, String wfPm) {
    final text = '$wfAm$wfPm';
    if (text.contains('눈') && text.contains('비')) return WeatherCondition.sleet;
    if (text.contains('눈')) return WeatherCondition.snowy;
    if (text.contains('비')) return WeatherCondition.rainy;
    if (text.contains('흐림')) return WeatherCondition.cloudy;
    if (text.contains('구름많')) return WeatherCondition.partlyCloudy;
    if (text.contains('맑')) return WeatherCondition.sunny;
    return WeatherCondition.unknown;
  }

  WeatherCondition _mapMidTermSingleCondition(String text) {
    if (text.contains('눈') && text.contains('비')) return WeatherCondition.sleet;
    if (text.contains('소나기') || text.contains('천둥') || text.contains('번개')) {
      return WeatherCondition.thunderstorm;
    }
    if (text.contains('눈')) return WeatherCondition.snowy;
    if (text.contains('비')) return WeatherCondition.rainy;
    if (text.contains('흐')) return WeatherCondition.cloudy;
    if (text.contains('구름많')) return WeatherCondition.partlyCloudy;
    if (text.contains('맑')) return WeatherCondition.sunny;
    return WeatherCondition.unknown;
  }

  double? _estimateDayPartTemperature(
    double? minTemp,
    double? maxTemp, {
    required bool isMorning,
  }) {
    if (minTemp == null || maxTemp == null) {
      return maxTemp ?? minTemp;
    }
    final range = maxTemp - minTemp;
    if (isMorning) {
      return minTemp + range * 0.35;
    }
    return minTemp + range * 0.8;
  }

  double? _double(String? value) =>
      value == null ? null : double.tryParse(value);
  int? _int(String? value) => value == null ? null : int.tryParse(value);

  double _precipAmount(String? raw) {
    if (raw == null || raw.isEmpty) {
      return 0.0;
    }
    final normalized = raw
        .replaceAll('mm', '')
        .replaceAll('MM', '')
        .replaceAll('cm', '')
        .replaceAll('CM', '')
        .replaceAll('강수없음', '0')
        .replaceAll('적설없음', '0')
        .replaceAll('미만', '')
        .replaceAll('이상', '')
        .replaceAll('~', '')
        .replaceAll(' ', '');
    return double.tryParse(normalized) ?? 0.0;
  }
}

class _DailyAccumulator {
  _DailyAccumulator({required this.date});

  final DateTime date;
  double? _minTemp;
  double? _maxTemp;
  double _maxPrecipProbability = 0;
  double? _maxPrecipitationAmountMm;
  DateTime? _conditionTime;
  WeatherCondition _condition = WeatherCondition.unknown;
  DateTime? _morningTime;
  WeatherCondition? _morningCondition;
  double? _morningTemp;
  DateTime? _afternoonTime;
  WeatherCondition? _afternoonCondition;
  double? _afternoonTemp;

  void add({required DateTime time, required Map<String, String> values}) {
    final temperature = _parseDouble(values['TMP']);
    final minCandidate = _parseDouble(values['TMN']) ?? temperature;
    final maxCandidate = _parseDouble(values['TMX']) ?? temperature;
    if (minCandidate != null) {
      _minTemp = _minTemp == null ? minCandidate : min(_minTemp!, minCandidate);
    }
    if (maxCandidate != null) {
      _maxTemp = _maxTemp == null ? maxCandidate : max(_maxTemp!, maxCandidate);
    }

    final pop = (_parseDouble(values['POP']) ?? 0) / 100;
    if (pop > _maxPrecipProbability) {
      _maxPrecipProbability = pop;
    }

    final precipitationAmount = _precipAmountStatic(values['PCP']);
    if (precipitationAmount > 0) {
      _maxPrecipitationAmountMm = _maxPrecipitationAmountMm == null
          ? precipitationAmount
          : max(_maxPrecipitationAmountMm!, precipitationAmount);
    }

    final distanceFromMidday = (time.hour - 12).abs();
    final currentDistance = _conditionTime == null
        ? 99
        : (_conditionTime!.hour - 12).abs();
    if (_conditionTime == null || distanceFromMidday < currentDistance) {
      _conditionTime = time;
      _condition = _mapConditionStatic(
        values['PTY'] ?? '0',
        values['SKY'] ?? '1',
        _precipAmountStatic(values['PCP']),
      );
    }

    final isMorning = time.hour < 12;
    final targetHour = isMorning ? 9 : 15;
    final candidateDistance = (time.hour - targetHour).abs();
    final currentTargetDistance = isMorning
        ? (_morningTime == null ? 99 : (_morningTime!.hour - targetHour).abs())
        : (_afternoonTime == null
              ? 99
              : (_afternoonTime!.hour - targetHour).abs());
    final candidateCondition = _mapConditionStatic(
      values['PTY'] ?? '0',
      values['SKY'] ?? '1',
      _precipAmountStatic(values['PCP']),
    );
    if (isMorning) {
      if (_morningTime == null || candidateDistance < currentTargetDistance) {
        _morningTime = time;
        _morningCondition = candidateCondition;
        _morningTemp = temperature;
      }
    } else {
      if (_afternoonTime == null || candidateDistance < currentTargetDistance) {
        _afternoonTime = time;
        _afternoonCondition = candidateCondition;
        _afternoonTemp = temperature;
      }
    }
  }

  DailyForecast toForecast(
    WeatherCondition Function(
      String pty,
      String sky,
      double precipitationAmount,
    )
    mapCondition,
  ) {
    final minTemp = _minTemp ?? 0;
    final maxTemp = _maxTemp ?? minTemp;
    return DailyForecast(
      date: date,
      tempMin: minTemp,
      tempMax: maxTemp,
      condition: _condition,
      precipProbability: _maxPrecipProbability,
      expectedPrecipitationMm: _maxPrecipitationAmountMm,
      amCondition: _morningCondition ?? _condition,
      pmCondition: _afternoonCondition ?? _condition,
      amTempCelsius:
          _morningTemp ?? _estimateDayPartTemp(minTemp, maxTemp, true),
      pmTempCelsius:
          _afternoonTemp ?? _estimateDayPartTemp(minTemp, maxTemp, false),
    );
  }

  double _estimateDayPartTemp(double minTemp, double maxTemp, bool isMorning) {
    final range = maxTemp - minTemp;
    return isMorning ? minTemp + range * 0.35 : minTemp + range * 0.8;
  }

  static double? _parseDouble(String? value) {
    if (value == null) return null;
    return double.tryParse(value);
  }

  static double _precipAmountStatic(String? value) {
    if (value == null || value.isEmpty) return 0.0;
    return double.tryParse(
          value
              .replaceAll('mm', '')
              .replaceAll('MM', '')
              .replaceAll('강수없음', '0')
              .replaceAll('미만', '')
              .replaceAll('이상', '')
              .replaceAll('~', '')
              .replaceAll(' ', ''),
        ) ??
        0.0;
  }

  static WeatherCondition _mapConditionStatic(
    String pty,
    String sky,
    double precipitationAmount,
  ) {
    switch (pty) {
      case '1':
        if (precipitationAmount >= 15) return WeatherCondition.heavyRain;
        if (precipitationAmount >= 3) return WeatherCondition.rainy;
        return WeatherCondition.slightRain;
      case '2':
      case '6':
        return WeatherCondition.sleet;
      case '3':
        return precipitationAmount >= 5
            ? WeatherCondition.snowy
            : WeatherCondition.lightSnow;
      case '4':
        return precipitationAmount >= 10
            ? WeatherCondition.heavyRain
            : WeatherCondition.rainy;
      case '5':
        return WeatherCondition.slightRain;
      case '7':
        return WeatherCondition.lightSnow;
      default:
        return switch (sky) {
          '1' => WeatherCondition.sunny,
          '3' => WeatherCondition.partlyCloudy,
          '4' => WeatherCondition.cloudy,
          _ => WeatherCondition.unknown,
        };
    }
  }
}
