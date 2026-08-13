import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/data/marine_station_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('finds an exact station name match', () async {
    final catalog = _catalog({'가거도': 'SO_0577', '제주': 'DT_0004'});

    expect(await catalog.findObsCode('가거도'), 'SO_0577');
  });

  test('falls back to a containment match when the exact name differs', () async {
    final catalog = _catalog({'제주': 'DT_0004'});

    expect(await catalog.findObsCode('제주항'), 'DT_0004');
  });

  test('returns null when no station name is even a partial match', () async {
    final catalog = _catalog({'가거도': 'SO_0577'});

    expect(await catalog.findObsCode('완전히다른곳'), isNull);
  });

  test('returns null for an empty station name', () async {
    final catalog = _catalog({'가거도': 'SO_0577'});

    expect(await catalog.findObsCode(''), isNull);
  });
}

MarineStationCatalog _catalog(Map<String, String> stationsByName) {
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
