import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/data/fishing_destination_catalog.dart';
import 'package:yegamssi/features/activity_forecast/domain/activity_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads 115 unique current official fishing ports', () async {
    final destinations = await FishingDestinationCatalog().load();

    expect(destinations, hasLength(115));
    expect(destinations.map((item) => item.id).toSet(), hasLength(115));
    expect(
      destinations.every(
        (item) =>
            item.kind == ActivityDestinationKind.officialFishingPort &&
            item.latitude >= 32 &&
            item.latitude <= 39.5 &&
            item.longitude >= 123 &&
            item.longitude <= 132,
      ),
      isTrue,
    );
    expect(destinations.any((item) => item.officialName == '득암항'), isFalse);
    expect(destinations.any((item) => item.officialName == '당포항'), isTrue);
    expect(
      destinations.where((item) => item.officialName == '오천항'),
      hasLength(2),
    );
  });

  test('uses verified coordinates for previously corrupted ports', () async {
    final destinations = await FishingDestinationCatalog().load();
    final byName = {for (final item in destinations) item.officialName: item};

    expect(byName['소안항']?.latitude, closeTo(34.1495216, 0.0000001));
    expect(byName['소안항']?.longitude, closeTo(126.6312276, 0.0000001));
    expect(byName['진두항']?.latitude, closeTo(37.2559575, 0.0000001));
    expect(byName['대변항']?.latitude, closeTo(35.2242162, 0.0000001));
    expect(byName['송도항']?.longitude, closeTo(126.2032384, 0.0000001));
  });

  test('loads 40 official index stations for each fishing type', () async {
    final catalog = FishingDestinationCatalog();
    final rock = await catalog.loadOfficialIndexStations('갯바위');
    final boat = await catalog.loadOfficialIndexStations('선상');

    expect(rock, hasLength(40));
    expect(boat, hasLength(40));
    expect(
      [...rock, ...boat].every(
        (item) =>
            item.kind == ActivityDestinationKind.officialIndexStation &&
            item.supportsOfficialFishingIndex,
      ),
      isTrue,
    );
    expect(rock.any((item) => item.supportedOptions.isNotEmpty), isTrue);
    expect(boat.any((item) => item.supportedOptions.isNotEmpty), isTrue);
  });

  test('same-name official station and port remain distinct when merged', () {
    const port = ActivityDestination(
      id: 'fipa-port:1',
      name: '시험항',
      areaName: '시험 주소',
      latitude: 35,
      longitude: 129,
      source: '한국어촌어항공단 국가어항 현황',
      kind: ActivityDestinationKind.officialFishingPort,
    );
    const station = ActivityDestination(
      id: 'khoa-station:1',
      name: '시험항',
      areaName: '갯바위',
      latitude: 35.01,
      longitude: 129.01,
      source: '국립해양조사원 바다낚시지수',
      kind: ActivityDestinationKind.officialIndexStation,
    );

    final merged = FishingDestinationCatalog.merge(
      officialFishingPorts: const [port],
      officialIndexStations: const [station],
    );

    expect(merged, hasLength(2));
  });

  test('restores legacy and current official port destination kinds', () {
    for (final id in ['mof-port:다대포항', 'fipa-port:2441']) {
      final port = ActivityDestination.fromJson({
        'id': id,
        'name': '다대포항',
        'areaName': '부산광역시',
        'latitude': 35.05,
        'longitude': 128.99,
        'source': '한국어촌어항공단 국가어항 현황',
      });
      expect(port.kind, ActivityDestinationKind.officialFishingPort);
    }
  });

  test('resolves renamed legacy port and rejects removed port', () async {
    final catalog = FishingDestinationCatalog();
    final renamed = await catalog.resolveSavedDestination(
      _legacyRequest('삼덕항', latitude: 34.8, longitude: 128.38),
    );
    final removed = await catalog.resolveSavedDestination(
      _legacyRequest('득암항', latitude: 34.36, longitude: 126.89),
    );

    expect(renamed?.officialName, '당포항');
    expect(removed, isNull);
  });
}

ActivityJudgmentRequest _legacyRequest(
  String name, {
  required double latitude,
  required double longitude,
}) {
  return ActivityJudgmentRequest(
    activityType: ActivityType.seaFishing,
    locationName: name,
    latitude: latitude,
    longitude: longitude,
    startsAt: DateTime(2026, 8, 12),
    durationMinutes: 120,
    options: const ActivityOptions(variant: '갯바위'),
    destinationId: 'mof-port:$name',
    destinationSource: '해양수산부 어항정보_20191231',
  );
}
