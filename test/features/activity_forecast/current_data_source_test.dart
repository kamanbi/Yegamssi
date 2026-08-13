import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/data/current_data_source.dart';
import 'package:yegamssi/features/activity_forecast/data/marine_station_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('picks the strongest current sample within the requested window', () async {
    final source = CurrentDataSource(
      dio: _fakeDio([
        _item(time: '2026-08-13 00:00', speed: '84.55', direction: '동'),
        _item(time: '2026-08-13 06:00', speed: '9.81', direction: '북동'),
        _item(time: '2026-08-13 12:00', speed: '95.20', direction: '서'),
      ]),
      stations: _fakeStationCatalog({'여수해만': '15LTC10'}),
    );

    final evidence = await source.fetch(
      requestedAt: DateTime(2026, 8, 13),
      requestedUntil: DateTime(2026, 8, 13, 23, 59),
      stationName: '여수해만',
    );

    expect(evidence, isNotNull);
    expect(evidence!.maxSpeedCms, 95.20);
    expect(evidence.direction, '서');
    expect(evidence.maxFloodAt, isNull);
  });

  test('ignores samples outside the requested time window', () async {
    final source = CurrentDataSource(
      dio: _fakeDio([
        _item(time: '2026-08-13 00:00', speed: '84.55', direction: '동'),
        _item(time: '2026-08-13 23:00', speed: '99.99', direction: '서'),
      ]),
      stations: _fakeStationCatalog({'여수해만': '15LTC10'}),
    );

    final evidence = await source.fetch(
      requestedAt: DateTime(2026, 8, 13),
      requestedUntil: DateTime(2026, 8, 13, 6),
      stationName: '여수해만',
    );

    expect(evidence!.maxSpeedCms, 84.55);
  });

  test('returns null for an empty or reversed request window', () async {
    final source = CurrentDataSource(
      dio: _fakeDio(const []),
      stations: _fakeStationCatalog({'여수해만': '15LTC10'}),
    );

    final evidence = await source.fetch(
      requestedAt: DateTime(2026, 8, 13, 12),
      requestedUntil: DateTime(2026, 8, 13, 6),
      stationName: '여수해만',
    );

    expect(evidence, isNull);
  });

  test('returns null when the station name has no known obsCode', () async {
    final source = CurrentDataSource(
      dio: _fakeDio([_item(time: '2026-08-13 00:00', speed: '84.55', direction: '동')]),
      stations: _fakeStationCatalog({}),
    );

    final evidence = await source.fetch(
      requestedAt: DateTime(2026, 8, 13),
      requestedUntil: DateTime(2026, 8, 13, 6),
      stationName: '알수없는곳',
    );

    expect(evidence, isNull);
  });
}

Map<String, dynamic> _item({
  required String time,
  required String speed,
  required String direction,
}) => {
  'obsvtrNm': '여수해만',
  'lot': '127.75',
  'lat': '34.75',
  'predcDt': time,
  'crdir': direction,
  'crsp': speed,
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
