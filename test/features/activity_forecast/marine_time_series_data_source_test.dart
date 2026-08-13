import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/data/marine_station_catalog.dart';
import 'package:yegamssi/features/activity_forecast/data/marine_time_series_data_source.dart';
import 'package:yegamssi/features/activity_forecast/domain/activity_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('collects wave height points within the requested window', () async {
    final source = MarineTimeSeriesDataSource(
      dio: _fakeDio([
        _item(time: '2026-08-13 09:00', field: 'wvhgt', value: '0.8'),
        _item(time: '2026-08-13 12:00', field: 'wvhgt', value: '1.4'),
        _item(time: '2026-08-13 15:00', field: 'wvhgt', value: '1.1'),
      ]),
      waveStations: _fakeStationCatalog({'경포대해수욕장': 'TW_0089'}),
      buoyStations: _fakeStationCatalog({}),
    );

    final evidence = await source.fetchWaveHeight(
      requestedAt: DateTime(2026, 8, 13, 8),
      requestedUntil: DateTime(2026, 8, 13, 16),
      stationName: '경포대해수욕장',
    );

    expect(evidence, isNotNull);
    expect(evidence!.kind, MarineTimeSeriesKind.waveHeight);
    expect(evidence.points, hasLength(3));
    expect(evidence.maxValue, 1.4);
  });

  test('collects water temperature points within the requested window', () async {
    final source = MarineTimeSeriesDataSource(
      dio: _fakeDio([
        _item(time: '2026-08-13 09:00', field: 'wtem', value: '24.1'),
        _item(time: '2026-08-13 12:00', field: 'wtem', value: '26.3'),
      ]),
      waveStations: _fakeStationCatalog({}),
      buoyStations: _fakeStationCatalog({'감천항': 'TW_0088'}),
    );

    final evidence = await source.fetchWaterTemperature(
      requestedAt: DateTime(2026, 8, 13, 8),
      requestedUntil: DateTime(2026, 8, 13, 16),
      stationName: '감천항',
    );

    expect(evidence, isNotNull);
    expect(evidence!.kind, MarineTimeSeriesKind.waterTemperature);
    expect(evidence.maxValue, 26.3);
  });

  test('ignores points outside the requested time window', () async {
    final source = MarineTimeSeriesDataSource(
      dio: _fakeDio([
        _item(time: '2026-08-13 01:00', field: 'wvhgt', value: '2.5'),
        _item(time: '2026-08-13 12:00', field: 'wvhgt', value: '1.0'),
      ]),
      waveStations: _fakeStationCatalog({'경포대해수욕장': 'TW_0089'}),
      buoyStations: _fakeStationCatalog({}),
    );

    final evidence = await source.fetchWaveHeight(
      requestedAt: DateTime(2026, 8, 13, 8),
      requestedUntil: DateTime(2026, 8, 13, 16),
      stationName: '경포대해수욕장',
    );

    expect(evidence!.points, hasLength(1));
    expect(evidence.maxValue, 1.0);
  });

  test('returns null when the station name has no known obsCode', () async {
    final source = MarineTimeSeriesDataSource(
      dio: _fakeDio([_item(time: '2026-08-13 09:00', field: 'wvhgt', value: '0.8')]),
      waveStations: _fakeStationCatalog({}),
      buoyStations: _fakeStationCatalog({}),
    );

    final evidence = await source.fetchWaveHeight(
      requestedAt: DateTime(2026, 8, 13, 8),
      requestedUntil: DateTime(2026, 8, 13, 16),
      stationName: '알수없는곳',
    );

    expect(evidence, isNull);
  });

  test('returns null for a reversed request window', () async {
    final source = MarineTimeSeriesDataSource(
      dio: _fakeDio(const []),
      waveStations: _fakeStationCatalog({'경포대해수욕장': 'TW_0089'}),
      buoyStations: _fakeStationCatalog({}),
    );

    final evidence = await source.fetchWaveHeight(
      requestedAt: DateTime(2026, 8, 13, 16),
      requestedUntil: DateTime(2026, 8, 13, 8),
      stationName: '경포대해수욕장',
    );

    expect(evidence, isNull);
  });
}

Map<String, dynamic> _item({
  required String time,
  required String field,
  required String value,
}) => {'obsvtrNm': '경포대해수욕장', 'lot': '128.93', 'lat': '37.80', 'obsrvnDt': time, field: value};

MarineStationCatalog _fakeStationCatalog(Map<String, String> stationsByName) {
  final json = jsonEncode({
    'schemaVersion': 1,
    'catalogVersion': MarineStationCatalog.catalogVersion,
    'source': 'test',
    'stations': stationsByName,
  });
  return MarineStationCatalog(
    assetPath: 'fake/path.json',
    bundle: _FakeBundle({'fake/path.json': json}),
  );
}

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this._jsonByPath);

  final Map<String, String> _jsonByPath;

  @override
  Future<ByteData> load(String key) async {
    final content = _jsonByPath[key] ?? '{}';
    final bytes = utf8.encode(content);
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}

Dio _fakeDio(List<Map<String, dynamic>> items, {void Function()? onRequest}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        onRequest?.call();
        handler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            data: {
              'body': {
                'items': {'item': items},
              },
            },
          ),
        );
      },
    ),
  );
  return dio;
}
