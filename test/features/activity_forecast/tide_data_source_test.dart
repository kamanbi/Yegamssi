import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/data/marine_station_catalog.dart';
import 'package:yegamssi/features/activity_forecast/data/tide_data_source.dart';
import 'package:yegamssi/features/activity_forecast/domain/activity_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses four tide events into high/low tide entries', () async {
    final source = TideDataSource(
      dio: _fakeDio([
        _item(time: '2026-08-13 01:02', level: '294.0', extrSe: '1'),
        _item(time: '2026-08-13 07:02', level: '60.0', extrSe: '2'),
        _item(time: '2026-08-13 13:04', level: '237.0', extrSe: '3'),
        _item(time: '2026-08-13 18:58', level: '5.0', extrSe: '4'),
      ]),
      stations: _fakeStationCatalog({'가거도': 'SO_0577'}),
    );

    final evidence = await source.fetch(
      requestedAt: DateTime(2026, 8, 13),
      stationName: '가거도',
    );

    expect(evidence, isNotNull);
    expect(evidence!.events, hasLength(4));
    expect(evidence.events[0].type, TideEventType.highTide);
    expect(evidence.events[0].levelCm, 294);
    expect(evidence.events[1].type, TideEventType.lowTide);
    expect(evidence.events[1].levelCm, 60);
    expect(evidence.events[2].type, TideEventType.highTide);
    expect(evidence.events[3].type, TideEventType.lowTide);
  });

  test('returns null when the station name has no known obsCode', () async {
    final source = TideDataSource(
      dio: _fakeDio([_item(time: '2026-08-13 01:02', level: '294.0', extrSe: '1')]),
      stations: _fakeStationCatalog({}),
    );

    final evidence = await source.fetch(
      requestedAt: DateTime(2026, 8, 13),
      stationName: '알수없는곳',
    );

    expect(evidence, isNull);
  });

  test('returns null when the upstream response has no items', () async {
    final source = TideDataSource(
      dio: _fakeDio(const []),
      stations: _fakeStationCatalog({'가거도': 'SO_0577'}),
    );

    final evidence = await source.fetch(
      requestedAt: DateTime(2026, 8, 13),
      stationName: '가거도',
    );

    expect(evidence, isNull);
  });

  test('reuses a cached response for the same station and day', () async {
    var requestCount = 0;
    final source = TideDataSource(
      dio: _fakeDio(
        [_item(time: '2026-08-13 01:02', level: '294.0', extrSe: '1')],
        onRequest: () => requestCount++,
      ),
      stations: _fakeStationCatalog({'가거도': 'SO_0577'}),
    );

    await source.fetch(requestedAt: DateTime(2026, 8, 13), stationName: '가거도');
    await source.fetch(requestedAt: DateTime(2026, 8, 13), stationName: '가거도');

    expect(requestCount, 1);
  });
}

Map<String, dynamic> _item({
  required String time,
  required String level,
  required String extrSe,
}) => {
  'obsvtrNm': '가거도',
  'lot': '125.12888',
  'lat': '34.05083',
  'predcDt': time,
  'predcTdlvVl': level,
  'extrSe': extrSe,
};

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
    final bytes = Uint8List.fromList(utf8.encode(content));
    return ByteData.view(bytes.buffer);
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
