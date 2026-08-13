import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/data/mid_sea_forecast_data_source.dart';

void main() {
  test('maps representative Korean coasts to official sea regions', () {
    expect(
      MidSeaForecastDataSource.regionFor(
        latitude: 34.07,
        longitude: 125.09,
      )?.id,
      '12A20000',
    );
    expect(
      MidSeaForecastDataSource.regionFor(
        latitude: 37.97,
        longitude: 124.63,
      )?.id,
      '12A10000',
    );
    expect(
      MidSeaForecastDataSource.regionFor(
        latitude: 33.49,
        longitude: 126.53,
      )?.id,
      '12D00000',
    );
  });

  test('parses the selected D+7 afternoon sea forecast', () {
    const region = MidSeaRegion('12A20000', '서해남부');
    final result = MidSeaForecastDataSource.parseItem(
      {'wf7Pm': '구름많음', 'wh7APm': 0.5, 'wh7BPm': 1.0},
      issueAt: DateTime(2026, 8, 12, 6),
      requestedAt: DateTime(2026, 8, 19, 15),
      requestedUntil: DateTime(2026, 8, 19, 17),
      region: region,
    );

    expect(result, isNotNull);
    expect(result!.forecastPeriod, '오후');
    expect(result.weatherSummary, '구름많음');
    expect(result.minWaveHeightM, 0.5);
    expect(result.maxWaveHeightM, 1.0);
  });
}
