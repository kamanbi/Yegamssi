import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/data/forest_fire_data_source.dart';

void main() {
  test('uses current administrative codes for special provinces', () {
    expect(ForestFireDataSource.provinceCodeFor('강원특별자치도 속초시'), '51');
    expect(ForestFireDataSource.provinceCodeFor('전북특별자치도 남원시'), '52');
    expect(ForestFireDataSource.provinceCodeFor('경상남도 산청군'), '48');
  });

  test('selects the nearest three-hour regional forecast', () {
    final result = ForestFireDataSource.parseResponse(
      _response([
        {'analdate': '2026-08-11 18', 'maxi': '25', 'doname': '부산광역시'},
        {'analdate': '2026-08-11 21', 'maxi': '72', 'doname': '부산광역시'},
        {'analdate': '2026-08-12 00', 'maxi': '40', 'doname': '부산광역시'},
      ]),
      requestedAt: DateTime(2026, 8, 11, 22),
    );

    expect(result, isNotNull);
    expect(result!.forecastAt, DateTime(2026, 8, 11, 21));
    expect(result.maxRiskIndex, 72);
    expect(result.coverageName, '부산광역시');
  });

  test('rejects data outside the published 3-hour forecast slots', () {
    final result = ForestFireDataSource.parseResponse(
      _response([
        {'analdate': '2026-08-11 21', 'maxi': '72', 'doname': '부산광역시'},
      ]),
      requestedAt: DateTime(2026, 8, 12, 8),
    );
    expect(result, isNull);
  });
}

Map<String, dynamic> _response(List<Map<String, dynamic>> items) => {
  'response': {
    'body': {
      'items': {'item': items},
    },
  },
};
