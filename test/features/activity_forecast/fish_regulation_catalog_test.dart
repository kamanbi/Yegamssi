import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/data/fish_regulation_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('finds a species with both closed season and prohibited size', () async {
    final catalog = FishRegulationCatalog();

    final regulation = await catalog.findByName('감성돔');

    expect(regulation, isNotNull);
    expect(regulation!.fishName, '감성돔');
    expect(regulation.inhibitionPeriodLabel, '5.1~5.31');
    expect(regulation.prohibitedSizeCm, '25cm');
    expect(regulation.source, isNotEmpty);
  });

  test('finds a species with only a prohibited size (no closed season)', () async {
    final catalog = FishRegulationCatalog();

    final regulation = await catalog.findByName('참돔');

    expect(regulation, isNotNull);
    expect(regulation!.inhibitionPeriodLabel, '지정된 금어기 없음');
    expect(regulation.prohibitedSizeCm, '24cm');
  });

  test('ignores surrounding whitespace when matching a fish name', () async {
    final catalog = FishRegulationCatalog();

    final regulation = await catalog.findByName(' 넙 치 ');

    expect(regulation, isNotNull);
    expect(regulation!.prohibitedSizeCm, '35cm');
  });

  test('returns null for a species not in the catalog', () async {
    final catalog = FishRegulationCatalog();

    final regulation = await catalog.findByName('상어');

    expect(regulation, isNull);
  });

  test('returns null for an empty name', () async {
    final catalog = FishRegulationCatalog();

    expect(await catalog.findByName(''), isNull);
  });
}
