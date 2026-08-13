import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/data/weather_warning_data_source.dart';
import 'package:yegamssi/features/activity_forecast/domain/activity_models.dart';
import 'package:yegamssi/features/activity_forecast/domain/marine_warning_matcher.dart';

void main() {
  test('parses the official current-warning response fields', () {
    final evidence = WeatherWarningDataSource.parseResponse({
      'response': {
        'body': {
          'items': {
            'item': {
              'tmFc': 202608112130,
              'tmEf': '202608112130',
              't6':
                  'o 강풍주의보 : 제주도(추자도)\r\n'
                  'o 풍랑주의보 : 남해동부먼바다, 제주도전해상',
            },
          },
        },
      },
    });

    expect(evidence, isNotNull);
    expect(evidence!.effectiveAt, DateTime(2026, 8, 11, 21, 30));
    expect(evidence.activeWarnings, hasLength(2));
    expect(evidence.activeWarnings.last.areas, hasLength(2));
  });

  group('MarineWarningMatcher', () {
    final matcher = MarineWarningMatcher();
    final now = DateTime(2026, 8, 11, 22);
    final evidence = WeatherWarningEvidence(
      issuedAt: now,
      effectiveAt: now,
      activeWarnings: const [
        ActiveWeatherWarning(phenomenon: '풍랑주의보', areas: ['남해동부먼바다']),
        ActiveWeatherWarning(phenomenon: '강풍주의보', areas: ['부산광역시']),
      ],
    );

    test('matches offshore warnings for a nearby boat trip', () {
      final warnings = matcher.relevantWarnings(
        request: _request(now, variant: '선상'),
        evidence: evidence,
        evaluatedAt: now,
      );
      expect(warnings.map((item) => item.phenomenon), contains('풍랑주의보'));
    });

    test('does not apply an offshore-only warning to rock fishing', () {
      final warnings = matcher.relevantWarnings(
        request: _request(
          now,
          variant: '갯바위',
          areaName: '',
          locationName: '거제도',
        ),
        evidence: WeatherWarningEvidence(
          issuedAt: now,
          effectiveAt: now,
          activeWarnings: const [
            ActiveWeatherWarning(phenomenon: '풍랑주의보', areas: ['남해동부먼바다']),
          ],
        ),
        evaluatedAt: now,
      );
      expect(warnings, isEmpty);
    });

    test('does not apply current warnings to a distant plan', () {
      final warnings = matcher.relevantWarnings(
        request: _request(now.add(const Duration(days: 1)), variant: '선상'),
        evidence: evidence,
        evaluatedAt: now,
      );
      expect(warnings, isEmpty);
    });
  });
}

ActivityJudgmentRequest _request(
  DateTime startsAt, {
  required String variant,
  String locationName = '부산남부',
  String areaName = '부산광역시',
}) {
  return ActivityJudgmentRequest(
    activityType: ActivityType.seaFishing,
    locationName: locationName,
    latitude: 35.04,
    longitude: 129.08,
    startsAt: startsAt,
    durationMinutes: 120,
    options: ActivityOptions(variant: variant),
    destinationId: 'khoa-index:$locationName',
    destinationSource: '국립해양조사원',
    destinationAreaName: areaName,
    destinationKind: ActivityDestinationKind.officialIndexStation,
  );
}
