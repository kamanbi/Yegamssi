import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/weather/data/sources/supplemental_temperature_source.dart';

void main() {
  Map<String, dynamic> sample(String time, double temperature) => {
    'time': time,
    'data': {
      'instant': {
        'details': {'air_temperature': temperature},
      },
    },
  };

  test('supplemental samples use Korean dates and noon boundary', () {
    final result = SupplementalTemperatureSource.parse({
      'properties': {
        'timeseries': [
          sample('2026-10-08T18:00:00Z', 13.2),
          sample('2026-10-09T00:00:00Z', 17.7),
          sample('2026-10-09T06:00:00Z', 24.8),
          sample('2026-10-09T12:00:00Z', 18.1),
        ],
      },
    });
    expect(result.keys, ['2026-10-09']);
    expect(result['2026-10-09']!.am, (min: 13.2, max: 17.7));
    expect(result['2026-10-09']!.pm, (min: 18.1, max: 24.8));
  });

  test('missing data does not fabricate temperature', () {
    expect(SupplementalTemperatureSource.parse({}), isEmpty);
    final result = SupplementalTemperatureSource.parse({
      'properties': {
        'timeseries': [sample('invalid', 15)],
      },
    });
    expect(result, isEmpty);
  });

  test('a single or duplicate instant cannot represent a half day', () {
    final result = SupplementalTemperatureSource.parse({
      'properties': {
        'timeseries': [
          sample('2026-10-18T15:00:00Z', 17),
          sample('2026-10-18T15:00:00Z', 17),
        ],
      },
    });
    expect(result, isEmpty);
  });

  test('equal temperatures at different instants remain a valid range', () {
    final result = SupplementalTemperatureSource.parse({
      'properties': {
        'timeseries': [
          sample('2026-10-18T18:00:00Z', 17),
          sample('2026-10-19T00:00:00Z', 17),
          sample('2026-10-19T06:00:00Z', 21),
        ],
      },
    });
    expect(result['2026-10-19']!.am, (min: 17.0, max: 17.0));
    expect(result['2026-10-19']!.pm, isNull);
  });
}
