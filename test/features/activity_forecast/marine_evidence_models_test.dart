import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/domain/activity_models.dart';

void main() {
  test('TideEvidence round-trips through JSON', () {
    final evidence = TideEvidence(
      stationName: '제주',
      events: [
        TideEventEntry(
          type: TideEventType.highTide,
          time: DateTime(2026, 8, 13, 5, 52),
          levelCm: 612,
        ),
        TideEventEntry(
          type: TideEventType.lowTide,
          time: DateTime(2026, 8, 13, 11, 33),
          levelCm: 118,
        ),
      ],
      forecastAt: DateTime(2026, 8, 13),
    );

    final restored = TideEvidence.fromJson(evidence.toJson());

    expect(restored.stationName, '제주');
    expect(restored.events, hasLength(2));
    expect(restored.events.first.type, TideEventType.highTide);
    expect(restored.events.first.levelCm, 612);
    expect(restored.events.last.type, TideEventType.lowTide);
  });

  test('CurrentEvidence keeps optional slack/flood/ebb times nullable', () {
    const evidence = CurrentEvidence(
      stationName: '가거도',
      maxSpeedCms: 42.5,
      direction: '낙조',
    );

    final restored = CurrentEvidence.fromJson(evidence.toJson());

    expect(restored.maxSpeedCms, 42.5);
    expect(restored.direction, '낙조');
    expect(restored.maxFloodAt, isNull);
    expect(restored.maxEbbAt, isNull);
    expect(restored.slackAt, isNull);
  });

  test('MarineTimeSeriesEvidence.maxValue returns the largest sample', () {
    final evidence = MarineTimeSeriesEvidence(
      kind: MarineTimeSeriesKind.waveHeight,
      stationName: '가거도',
      points: [
        MarineTimeSeriesPoint(time: DateTime(2026, 8, 13, 9), value: 1.2),
        MarineTimeSeriesPoint(time: DateTime(2026, 8, 13, 12), value: 2.1),
        MarineTimeSeriesPoint(time: DateTime(2026, 8, 13, 15), value: 1.8),
      ],
    );

    expect(evidence.maxValue, 2.1);

    final restored = MarineTimeSeriesEvidence.fromJson(evidence.toJson());
    expect(restored.kind, MarineTimeSeriesKind.waveHeight);
    expect(restored.points, hasLength(3));
  });

  test('MarineTimeSeriesEvidence.maxValue is null when no samples exist', () {
    const evidence = MarineTimeSeriesEvidence(
      kind: MarineTimeSeriesKind.waterTemperature,
      stationName: '가거도',
      points: [],
    );

    expect(evidence.maxValue, isNull);
  });

  test('FishRegulationEvidence round-trips with a nullable prohibited size', () {
    const evidence = FishRegulationEvidence(
      fishName: '감성돔',
      inhibitionPeriodLabel: '05.01~05.31(전지역)',
      source: '수산자원관리법 시행령',
    );

    final restored = FishRegulationEvidence.fromJson(evidence.toJson());

    expect(restored.fishName, '감성돔');
    expect(restored.prohibitedSizeCm, isNull);
    expect(restored.source, '수산자원관리법 시행령');
  });
}
