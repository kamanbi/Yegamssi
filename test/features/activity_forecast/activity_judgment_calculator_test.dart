import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/domain/activity_judgment_calculator.dart';
import 'package:yegamssi/features/activity_forecast/domain/activity_models.dart';
import 'package:yegamssi/features/weather/domain/entities/weather_entity.dart';

void main() {
  group('ActivityJudgmentCalculator', () {
    final calculator = ActivityJudgmentCalculator();

    test('stops activity before score when thunderstorm is present', () {
      final now = DateTime.now();
      final result = calculator.calculate(
        request: _request(ActivityType.hiking, now),
        weather: _weather(now, condition: WeatherCondition.thunderstorm),
        forestFireEvidence: ForestFireEvidence(
          forecastAt: now,
          maxRiskIndex: 20,
          coverageName: '전국 최대위험',
        ),
      );

      expect(result.safetyLevel, ActivitySafetyLevel.stop);
      expect(result.summary, contains('중단'));
    });

    test('stops hiking when the official fire risk is very high', () {
      final now = DateTime.now();
      final result = calculator.calculate(
        request: _request(ActivityType.hiking, now),
        weather: _weather(now),
        forestFireEvidence: ForestFireEvidence(
          forecastAt: now,
          maxRiskIndex: 90,
          coverageName: '전국 최대위험',
        ),
      );

      expect(result.safetyLevel, ActivitySafetyLevel.stop);
      expect(
        result.factors.map((factor) => factor.label),
        contains('전국 산불위험 최대지수 90'),
      );
    });

    test('does not infer a sea fishing score from land weather', () {
      final now = DateTime.now();
      final result = calculator.calculate(
        request: _request(ActivityType.seaFishing, now),
        weather: _weather(now),
      );

      expect(result.score, isNull);
      expect(result.safetyLevel, ActivitySafetyLevel.limited);
      expect(result.coverageLevel, ActivityCoverageLevel.unavailable);
    });

    test(
      'stops a near-term fishing trip when its marine zone has a warning',
      () {
        final now = DateTime.now();
        final result = calculator.calculate(
          request: ActivityJudgmentRequest(
            activityType: ActivityType.seaFishing,
            locationName: '부산남부',
            latitude: 35.04,
            longitude: 129.08,
            startsAt: now.add(const Duration(minutes: 10)),
            durationMinutes: 120,
            options: const ActivityOptions(variant: '선상'),
            destinationId: 'khoa-index:부산남부',
            destinationSource: '국립해양조사원',
            destinationAreaName: '부산광역시',
            destinationKind: ActivityDestinationKind.officialIndexStation,
          ),
          weather: _weather(now),
          weatherWarningEvidence: WeatherWarningEvidence(
            issuedAt: now,
            effectiveAt: now,
            activeWarnings: const [
              ActiveWeatherWarning(phenomenon: '풍랑주의보', areas: ['남해동부먼바다']),
            ],
          ),
        );

        expect(result.score, isNull);
        expect(result.safetyLevel, ActivitySafetyLevel.stop);
        expect(result.summary, contains('풍랑주의보'));
      },
    );

    test('explains that an official port has no official fishing index', () {
      final now = DateTime.now();
      final result = calculator.calculate(
        request: ActivityJudgmentRequest(
          activityType: ActivityType.seaFishing,
          locationName: '다대포항',
          latitude: 35.05,
          longitude: 128.99,
          startsAt: now.add(const Duration(minutes: 10)),
          durationMinutes: 120,
          options: const ActivityOptions(variant: '갯바위'),
          destinationId: 'mof-port:다대포항',
          destinationSource: '해양수산부 어항정보_20191231',
          destinationKind: ActivityDestinationKind.officialFishingPort,
        ),
        weather: _weather(now),
      );

      expect(result.score, isNull);
      expect(result.summary, contains('공식 지수 미지원'));
      expect(result.request.supportsOfficialFishingIndex, isFalse);
    });

    test('combines nearby official fishing evidence with weather', () {
      final now = DateTime.now();
      final result = calculator.calculate(
        request: _request(ActivityType.seaFishing, now),
        weather: _weather(now),
        seaFishingEvidence: SeaFishingEvidence(
          stationName: '서울 인근 시험지점',
          targetFish: '감성돔',
          forecastPeriod: '오전',
          officialIndex: '좋음',
          latitude: 37.57,
          longitude: 126.98,
          maxWindSpeedMs: 4,
          maxWaveHeightM: 0.5,
          maxWaterTemperatureC: 23,
          tideDescription: '중조기',
          forecastStartsAt: now,
          forecastEndsAt: now.add(const Duration(hours: 12)),
        ),
      );

      expect(result.score, isNotNull);
      expect(result.coverageLevel, ActivityCoverageLevel.partial);
      expect(result.sources, contains('국립해양조사원 바다낚시지수'));
    });

    test('rewards a request that starts shortly after a tide turn', () {
      final now = DateTime.now();
      final request = _request(ActivityType.seaFishing, now);
      final result = calculator.calculate(
        request: request,
        weather: _weather(now),
        seaFishingEvidence: _seaFishingEvidence(now),
        tideEvidence: TideEvidence(
          stationName: '가거도',
          events: [
            TideEventEntry(
              type: TideEventType.lowTide,
              time: request.startsAt.subtract(const Duration(minutes: 60)),
              levelCm: 50,
            ),
          ],
          forecastAt: now,
        ),
      );

      expect(
        result.factors.any((f) => f.label.contains('초들물')),
        isTrue,
        reason: result.factors.map((f) => f.label).join(', '),
      );
      expect(
        result.factors.firstWhere((f) => f.label.contains('초들물')).contribution,
        8,
      );
      expect(result.sources, contains('국립해양조사원 조석예보'));
    });

    test('warns when a request starts near slack tide', () {
      final now = DateTime.now();
      final request = _request(ActivityType.seaFishing, now);
      final result = calculator.calculate(
        request: request,
        weather: _weather(now),
        seaFishingEvidence: _seaFishingEvidence(now),
        tideEvidence: TideEvidence(
          stationName: '가거도',
          events: [
            TideEventEntry(
              type: TideEventType.highTide,
              time: request.startsAt.subtract(const Duration(minutes: 10)),
              levelCm: 300,
            ),
          ],
          forecastAt: now,
        ),
      );

      expect(
        result.factors.any((f) => f.label.contains('정조')),
        isTrue,
        reason: result.factors.map((f) => f.label).join(', '),
      );
      expect(
        result.factors.firstWhere((f) => f.label.contains('정조')).contribution,
        -6,
      );
    });

    test('does not add a tide factor mid-tide, away from any turn', () {
      final now = DateTime.now();
      final request = _request(ActivityType.seaFishing, now);
      final result = calculator.calculate(
        request: request,
        weather: _weather(now),
        seaFishingEvidence: _seaFishingEvidence(now),
        tideEvidence: TideEvidence(
          stationName: '가거도',
          events: [
            TideEventEntry(
              type: TideEventType.lowTide,
              time: request.startsAt.subtract(const Duration(hours: 3)),
              levelCm: 50,
            ),
            TideEventEntry(
              type: TideEventType.highTide,
              time: request.startsAt.add(const Duration(hours: 3)),
              levelCm: 300,
            ),
          ],
          forecastAt: now,
        ),
      );

      expect(
        result.factors.any(
          (f) => f.label.contains('정조') || f.label.contains('들물') || f.label.contains('날물'),
        ),
        isFalse,
        reason: result.factors.map((f) => f.label).join(', '),
      );
    });

    test('stops a trip for a dangerous current speed', () {
      final now = DateTime.now();
      final result = calculator.calculate(
        request: _request(ActivityType.seaFishing, now),
        weather: _weather(now),
        seaFishingEvidence: _seaFishingEvidence(now),
        currentEvidence: const CurrentEvidence(
          stationName: '가거도',
          maxSpeedCms: 200,
          direction: '낙조',
        ),
      );

      expect(result.safetyLevel, ActivitySafetyLevel.stop);
      expect(
        result.factors.any((f) => f.label.contains('위험 수준')),
        isTrue,
        reason: result.factors.map((f) => f.label).join(', '),
      );
      expect(result.sources, contains('국립해양조사원 조류예보'));
    });

    test('cautions but does not stop for a moderate current speed', () {
      final now = DateTime.now();
      final result = calculator.calculate(
        request: _request(ActivityType.seaFishing, now),
        weather: _weather(now),
        seaFishingEvidence: _seaFishingEvidence(now),
        currentEvidence: const CurrentEvidence(
          stationName: '가거도',
          maxSpeedCms: 100,
          direction: '창조',
        ),
      );

      expect(result.safetyLevel, ActivitySafetyLevel.allowed);
      expect(
        result.factors.any((f) => f.label.contains('100cm/s')),
        isTrue,
        reason: result.factors.map((f) => f.label).join(', '),
      );
    });

    test('prefers a windowed wave measurement over the daily official max', () {
      final now = DateTime.now();
      final request = _request(ActivityType.seaFishing, now);
      final result = calculator.calculate(
        request: request,
        weather: _weather(now),
        seaFishingEvidence: _seaFishingEvidence(now),
        waveEvidence: MarineTimeSeriesEvidence(
          kind: MarineTimeSeriesKind.waveHeight,
          stationName: '가거도',
          points: [
            MarineTimeSeriesPoint(time: request.startsAt, value: 1.6),
          ],
        ),
      );

      expect(result.safetyLevel, ActivitySafetyLevel.stop);
      expect(
        result.factors.any(
          (f) => f.label.contains('요청 구간 실측 파고 1.6m'),
        ),
        isTrue,
        reason: result.factors.map((f) => f.label).join(', '),
      );
    });

    test('adds an informational water temperature factor without a score change', () {
      final now = DateTime.now();
      final request = _request(ActivityType.seaFishing, now);
      final result = calculator.calculate(
        request: request,
        weather: _weather(now),
        seaFishingEvidence: _seaFishingEvidence(now),
        waterTemperatureEvidence: MarineTimeSeriesEvidence(
          kind: MarineTimeSeriesKind.waterTemperature,
          stationName: '가거도',
          points: [
            MarineTimeSeriesPoint(time: request.startsAt, value: 24.5),
          ],
        ),
      );

      final tempFactor = result.factors.firstWhere(
        (f) => f.label.contains('요청 구간 실측 수온 24.5'),
      );
      expect(tempFactor.contribution, 0);
      expect(result.sources, contains('국립해양조사원 해양관측부이'));
    });

    test('marks future walking weather as partial without hourly UV', () {
      final now = DateTime.now();
      final result = calculator.calculate(
        request: _request(ActivityType.walkingRunning, now),
        weather: _weather(now),
      );

      expect(result.score, greaterThanOrEqualTo(65));
      expect(result.safetyLevel, ActivitySafetyLevel.allowed);
      expect(result.coverageLevel, ActivityCoverageLevel.partial);
    });

    test(
      'uses the requested window precipitation instead of current value',
      () {
        final now = DateTime.now();
        final weather = _weather(now).copyWith(
          hourlyForecasts: [
            HourlyForecast(
              time: now.add(const Duration(hours: 1)),
              tempCelsius: 20,
              condition: WeatherCondition.rainy,
              precipProbability: 90,
              windSpeedMs: 3,
            ),
            HourlyForecast(
              time: now.add(const Duration(hours: 2)),
              tempCelsius: 19,
              condition: WeatherCondition.rainy,
              precipProbability: 90,
              windSpeedMs: 3,
            ),
          ],
        );

        final result = calculator.calculate(
          request: _request(ActivityType.walkingRunning, now),
          weather: weather,
        );

        expect(
          result.factors.map((factor) => factor.label),
          contains('강수 가능성 높음'),
        );
        expect(result.score, lessThan(65));
      },
    );

    test('does not substitute current wind and rain into future hours', () {
      final now = DateTime.now();
      final weather = _weather(now).copyWith(
        windSpeedMs: 20,
        precipProbability: 90,
        hourlyForecasts: [
          HourlyForecast(
            time: now.add(const Duration(hours: 1)),
            tempCelsius: 20,
            condition: WeatherCondition.sunny,
          ),
          HourlyForecast(
            time: now.add(const Duration(hours: 2)),
            tempCelsius: 20,
            condition: WeatherCondition.sunny,
          ),
        ],
      );
      final result = calculator.calculate(
        request: _request(ActivityType.walkingRunning, now),
        weather: weather,
      );
      final labels = result.factors.map((factor) => factor.label);

      expect(labels, isNot(contains('강한 바람')));
      expect(labels, isNot(contains('강수 가능성 높음')));
      expect(result.unverifiedFactors, contains('일부 시간대 풍속'));
      expect(result.unverifiedFactors, contains('일부 시간대 강수확률'));
    });

    test('walking intensity changes the suitability score', () {
      final now = DateTime.now();
      final walking = calculator.calculate(
        request: _request(ActivityType.walkingRunning, now, variant: '걷기 · 보통'),
        weather: _weather(now),
      );
      final hardRunning = calculator.calculate(
        request: _request(
          ActivityType.walkingRunning,
          now,
          variant: '달리기 · 강하게',
        ),
        weather: _weather(now),
      );

      expect(walking.score, greaterThan(hardRunning.score!));
    });

    test('hiking experience changes preparedness but not safety override', () {
      final now = DateTime.now();
      final evidence = ForestFireEvidence(
        forecastAt: now,
        maxRiskIndex: 20,
        coverageName: '전국 최대위험',
      );
      final beginner = calculator.calculate(
        request: _request(ActivityType.hiking, now, variant: '초보'),
        weather: _weather(now),
        forestFireEvidence: evidence,
      );
      final expert = calculator.calculate(
        request: _request(ActivityType.hiking, now, variant: '숙련'),
        weather: _weather(now),
        forestFireEvidence: evidence,
      );

      expect(expert.score, greaterThan(beginner.score!));
      expect(expert.safetyLevel, beginner.safetyLevel);
    });

    test('thick laundry receives a drying penalty', () {
      final now = DateTime.now();
      final regular = calculator.calculate(
        request: _request(ActivityType.laundry, now, variant: '실외 · 일반'),
        weather: _weather(now),
      );
      final thick = calculator.calculate(
        request: _request(ActivityType.laundry, now, variant: '실외 · 두꺼운 빨래'),
        weather: _weather(now),
      );

      expect(regular.score, greaterThan(thick.score!));
    });

    test('48-hour car wash checks rain beyond the 24-hour window', () {
      final now = DateTime.now();
      final weather = _weather(now).copyWith(
        hourlyForecasts: [
          for (var hour = 1; hour <= 50; hour++)
            HourlyForecast(
              time: now.add(Duration(hours: hour)),
              tempCelsius: 20,
              condition: hour == 30
                  ? WeatherCondition.rainy
                  : WeatherCondition.sunny,
              precipProbability: hour == 30 ? 90 : 0,
              windSpeedMs: 2,
            ),
        ],
      );
      final oneDay = calculator.calculate(
        request: _request(ActivityType.carWash, now, variant: '일반 · 24시간'),
        weather: weather,
      );
      final twoDays = calculator.calculate(
        request: _request(ActivityType.carWash, now, variant: '정밀 · 48시간'),
        weather: weather,
      );

      expect(oneDay.score, greaterThan(twoDays.score!));
      expect(
        twoDays.factors.map((factor) => factor.label),
        contains('세차 후 강수 가능성'),
      );
    });

    test('serialized judgment restores the same cache identity', () {
      final now = DateTime.now();
      final original = calculator.calculate(
        request: _request(ActivityType.laundry, now),
        weather: _weather(now),
      );

      final restored = ActivityJudgment.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.request.activityType, ActivityType.laundry);
      expect(restored.score, original.score);
      expect(restored.dataObservedAt, original.dataObservedAt);
    });

    test(
      'stores a future plan as forecast pending without partial coverage',
      () {
        final now = DateTime.now();
        final result = calculator.calculate(
          request: ActivityJudgmentRequest(
            activityType: ActivityType.hiking,
            locationName: '지리산',
            latitude: 35.3369,
            longitude: 127.7306,
            startsAt: now.add(const Duration(hours: 4)),
            durationMinutes: 240,
            options: const ActivityOptions(variant: '보통'),
            destinationId: 'mountain:20000946',
            destinationSource: '산림청 산 정보 조회_GW',
          ),
          weather: _weather(now),
        );

        expect(result.score, isNull);
        expect(result.planStatus, ActivityPlanStatus.forecastPending);
        expect(result.judgmentMode, ActivityJudgmentMode.pending);
        expect(result.summary, contains('선택한 날짜'));
      },
    );

    test('uses hourly forecasts beyond the former 24 item limit', () {
      final now = DateTime.now();
      final hourlyForecasts = List.generate(
        73,
        (index) => HourlyForecast(
          time: now.add(Duration(hours: index + 1)),
          tempCelsius: 20,
          condition: WeatherCondition.sunny,
          precipProbability: 10,
          windSpeedMs: 2,
        ),
      );
      final result = calculator.calculate(
        request: ActivityJudgmentRequest(
          activityType: ActivityType.walkingRunning,
          locationName: '서울',
          latitude: 37.5665,
          longitude: 126.978,
          startsAt: now.add(const Duration(hours: 48)),
          durationMinutes: 120,
          options: const ActivityOptions(variant: '보통'),
        ),
        weather: _weather(now).copyWith(hourlyForecasts: hourlyForecasts),
      );

      expect(result.planStatus, ActivityPlanStatus.ready);
      expect(result.score, isNotNull);
    });

    test('creates a detailed planning judgment from daily forecasts', () {
      final now = DateTime.now();
      final target = now.add(const Duration(days: 5));
      final weather = _weather(now).copyWith(
        hourlyForecasts: const [],
        dailyForecasts: [
          _daily(target, min: 14, max: 24),
          _daily(target.add(const Duration(days: 1)), precipitation: 0.1),
        ],
      );
      final result = calculator.calculate(
        request: ActivityJudgmentRequest(
          activityType: ActivityType.walkingRunning,
          locationName: '서울',
          latitude: 37.5665,
          longitude: 126.978,
          startsAt: DateTime(target.year, target.month, target.day, 10),
          durationMinutes: 120,
          options: const ActivityOptions(variant: '걷기 · 보통'),
        ),
        weather: weather,
      );

      expect(result.judgmentMode, ActivityJudgmentMode.planning);
      expect(result.scoreRangeMin, isNotNull);
      expect(result.scoreRangeMax, greaterThan(result.scoreRangeMin!));
      expect(result.unverifiedFactors, contains('시간대별 풍속'));
      expect(result.alternativeWindows, isNotEmpty);
    });

    test('does not score an unknown official fishing index', () {
      final now = DateTime.now();
      final target = now.add(const Duration(days: 5));
      final result = calculator.calculate(
        request: ActivityJudgmentRequest(
          activityType: ActivityType.seaFishing,
          locationName: '백령도',
          latitude: 37.97,
          longitude: 124.63,
          startsAt: DateTime(target.year, target.month, target.day, 10),
          durationMinutes: 120,
          options: const ActivityOptions(variant: '갯바위'),
          destinationId: 'test-port',
          destinationSource: 'test',
          destinationKind: ActivityDestinationKind.officialFishingPort,
        ),
        weather: _weather(
          now,
        ).copyWith(hourlyForecasts: const [], dailyForecasts: [_daily(target)]),
        seaFishingEvidence: SeaFishingEvidence(
          stationName: '백령도',
          targetFish: '우럭',
          forecastPeriod: '오전',
          officialIndex: '자료없음',
          latitude: 37.97,
          longitude: 124.63,
          maxWindSpeedMs: 4,
          maxWaveHeightM: 0.6,
          maxWaterTemperatureC: 20,
          tideDescription: '중조기',
          forecastStartsAt: target,
          forecastEndsAt: target.add(const Duration(hours: 12)),
        ),
      );

      expect(result.score, isNull);
      expect(result.safetyLevel, ActivitySafetyLevel.limited);
      expect(result.unverifiedFactors, contains('공식 바다낚시지수 값'));
    });

    test('does not create a fishing score without future marine evidence', () {
      final now = DateTime.now();
      final target = now.add(const Duration(days: 5));
      final result = calculator.calculate(
        request: ActivityJudgmentRequest(
          activityType: ActivityType.seaFishing,
          locationName: '백령도',
          latitude: 37.96,
          longitude: 124.66,
          startsAt: DateTime(target.year, target.month, target.day, 6),
          durationMinutes: 360,
          options: const ActivityOptions(variant: '갯바위'),
          destinationId: 'fipa-port:test',
          destinationSource: '한국어촌어항공단',
        ),
        weather: _weather(
          now,
        ).copyWith(hourlyForecasts: const [], dailyForecasts: [_daily(target)]),
      );

      expect(result.judgmentMode, ActivityJudgmentMode.planning);
      expect(result.score, isNull);
      expect(result.unverifiedFactors, contains('파고'));
      expect(result.safetyLevel, ActivitySafetyLevel.limited);
    });

    test(
      'creates a D+7 fishing environment score from official mid-sea data',
      () {
        final now = DateTime.now();
        final target = now.add(const Duration(days: 7));
        final result = calculator.calculate(
          request: ActivityJudgmentRequest(
            activityType: ActivityType.seaFishing,
            locationName: '가거도',
            latitude: 34.07308,
            longitude: 125.08805,
            startsAt: DateTime(target.year, target.month, target.day, 15),
            durationMinutes: 120,
            options: const ActivityOptions(variant: '갯바위'),
            destinationId: 'official:gageodo',
            destinationSource: '공식 테스트 자료',
          ),
          weather: _weather(now).copyWith(
            hourlyForecasts: const [],
            dailyForecasts: [_daily(target)],
          ),
          midSeaForecastEvidence: MidSeaForecastEvidence(
            seaRegionId: '12A20000',
            seaRegionName: '서해남부',
            forecastPeriod: '오후',
            weatherSummary: '구름많음',
            minWaveHeightM: 0.5,
            maxWaveHeightM: 1.0,
            forecastStartsAt: DateTime(
              target.year,
              target.month,
              target.day,
              12,
            ),
            forecastEndsAt: DateTime(target.year, target.month, target.day + 1),
          ),
        );

        expect(result.score, isNotNull);
        expect(result.safetyLevel, ActivitySafetyLevel.limited);
        expect(result.sources, contains('기상청 중기 해상예보'));
        expect(result.unverifiedFactors, contains('어종별 바다낚시지수'));
        expect(
          result.factors.map((factor) => factor.label),
          contains('중기 파고 0.5~1.0m'),
        );
      },
    );

    test('keeps a 48 hour car wash pending when a date is missing', () {
      final now = DateTime.now();
      final target = now.add(const Duration(days: 5));
      final result = calculator.calculate(
        request: ActivityJudgmentRequest(
          activityType: ActivityType.carWash,
          locationName: '서울',
          latitude: 37.5665,
          longitude: 126.978,
          startsAt: DateTime(target.year, target.month, target.day, 9),
          durationMinutes: 60,
          options: const ActivityOptions(variant: '정밀 · 48시간'),
        ),
        weather: _weather(
          now,
        ).copyWith(hourlyForecasts: const [], dailyForecasts: [_daily(target)]),
      );

      expect(result.judgmentMode, ActivityJudgmentMode.pending);
      expect(result.score, isNull);
    });

    test('uses the selected PM precipitation instead of the daily average', () {
      final now = DateTime.now();
      final target = now.add(const Duration(days: 5));
      final forecast = _daily(
        target,
        precipitation: 0.8,
        amPrecipitation: 0,
        pmPrecipitation: 0.8,
        amTemperature: 18,
        pmTemperature: 32,
      );
      final afternoon = calculator.calculate(
        request: ActivityJudgmentRequest(
          activityType: ActivityType.walkingRunning,
          locationName: '서울',
          latitude: 37.5665,
          longitude: 126.978,
          startsAt: DateTime(target.year, target.month, target.day, 15),
          durationMinutes: 120,
          options: const ActivityOptions(variant: '걷기 · 보통'),
        ),
        weather: _weather(
          now,
        ).copyWith(hourlyForecasts: const [], dailyForecasts: [forecast]),
      );
      final morning = calculator.calculate(
        request: ActivityJudgmentRequest(
          activityType: ActivityType.walkingRunning,
          locationName: '서울',
          latitude: 37.5665,
          longitude: 126.978,
          startsAt: DateTime(target.year, target.month, target.day, 9),
          durationMinutes: 120,
          options: const ActivityOptions(variant: '걷기 · 보통'),
        ),
        weather: _weather(
          now,
        ).copyWith(hourlyForecasts: const [], dailyForecasts: [forecast]),
      );

      expect(
        afternoon.factors.map((factor) => factor.label),
        contains('선택 시간대 강수확률 80%'),
      );
      expect(morning.score, greaterThan(afternoon.score!));
    });

    test('does not score a missing mid-term temperature as zero degrees', () {
      final now = DateTime.now();
      final target = now.add(const Duration(days: 5));
      final result = calculator.calculate(
        request: ActivityJudgmentRequest(
          activityType: ActivityType.laundry,
          locationName: '서울',
          latitude: 37.5665,
          longitude: 126.978,
          startsAt: DateTime(target.year, target.month, target.day, 14),
          durationMinutes: 120,
          options: const ActivityOptions(variant: '실외 · 일반'),
        ),
        weather: _weather(now).copyWith(
          hourlyForecasts: const [],
          dailyForecasts: [
            _daily(target, min: 0, max: 0, temperatureAvailable: false),
          ],
        ),
      );

      expect(
        result.factors.any((factor) => factor.label.contains('기온')),
        isFalse,
      );
      expect(result.safetyLevel, ActivitySafetyLevel.allowed);
    });

    test('does not apply a fixed penalty to a 48-hour car wash plan', () {
      final now = DateTime.now();
      final target = now.add(const Duration(days: 5));
      final forecasts = [
        _daily(target, precipitation: 0.1),
        _daily(target.add(const Duration(days: 1)), precipitation: 0.1),
        _daily(target.add(const Duration(days: 2)), precipitation: 0.1),
      ];
      ActivityJudgment calculate(String variant) => calculator.calculate(
        request: ActivityJudgmentRequest(
          activityType: ActivityType.carWash,
          locationName: '서울',
          latitude: 37.5665,
          longitude: 126.978,
          startsAt: DateTime(target.year, target.month, target.day, 9),
          durationMinutes: 120,
          options: ActivityOptions(variant: variant),
        ),
        weather: _weather(
          now,
        ).copyWith(hourlyForecasts: const [], dailyForecasts: forecasts),
      );

      final day = calculate('일반 · 24시간');
      final twoDays = calculate('정밀 · 48시간');

      expect(twoDays.score, day.score);
      expect(
        twoDays.factors.map((factor) => factor.label),
        isNot(contains('48시간 재오염 범위')),
      );
      expect(twoDays.safetyLevel, ActivitySafetyLevel.allowed);
    });

    test('restores version 1 history without destination fields', () {
      final now = DateTime.now();
      final json =
          calculator
              .calculate(
                request: _request(ActivityType.walkingRunning, now),
                weather: _weather(now),
              )
              .toJson()
            ..remove('planStatus');
      (json['request'] as Map<String, dynamic>)
        ..remove('destinationId')
        ..remove('destinationSource');

      final restored = ActivityJudgment.fromJson(json);

      expect(restored.planStatus, ActivityPlanStatus.ready);
      expect(restored.judgmentMode, ActivityJudgmentMode.detailed);
      expect(restored.request.destinationId, isEmpty);
    });
  });
}

DailyForecast _daily(
  DateTime date, {
  double precipitation = 0.2,
  double min = 12,
  double max = 23,
  WeatherCondition condition = WeatherCondition.sunny,
  double? amPrecipitation,
  double? pmPrecipitation,
  double? amTemperature,
  double? pmTemperature,
  bool temperatureAvailable = true,
}) {
  return DailyForecast(
    date: DateTime(date.year, date.month, date.day),
    tempMin: min,
    tempMax: max,
    condition: condition,
    precipProbability: precipitation,
    amPrecipProbability: amPrecipitation,
    pmPrecipProbability: pmPrecipitation,
    amCondition: condition,
    pmCondition: condition,
    amTempCelsius: amTemperature,
    pmTempCelsius: pmTemperature,
    temperatureAvailable: temperatureAvailable,
  );
}

ActivityJudgmentRequest _request(
  ActivityType type,
  DateTime now, {
  String variant = '보통',
}) {
  final requiresDestination =
      type == ActivityType.seaFishing || type == ActivityType.hiking;
  return ActivityJudgmentRequest(
    activityType: type,
    locationName: '서울',
    latitude: 37.5665,
    longitude: 126.978,
    startsAt: now.add(const Duration(minutes: 10)),
    durationMinutes: 120,
    options: ActivityOptions(variant: variant),
    destinationId: requiresDestination ? 'official:test' : '',
    destinationSource: requiresDestination ? '공식 테스트 자료' : '',
  );
}

SeaFishingEvidence _seaFishingEvidence(DateTime now) {
  return SeaFishingEvidence(
    stationName: '서울 인근 시험지점',
    targetFish: '감성돔',
    forecastPeriod: '오전',
    officialIndex: '좋음',
    latitude: 37.57,
    longitude: 126.98,
    maxWindSpeedMs: 4,
    maxWaveHeightM: 0.5,
    maxWaterTemperatureC: 23,
    tideDescription: '중조기',
    forecastStartsAt: now,
    forecastEndsAt: now.add(const Duration(hours: 12)),
  );
}

WeatherEntity _weather(
  DateTime now, {
  WeatherCondition condition = WeatherCondition.sunny,
}) {
  return WeatherEntity(
    tempCelsius: 20,
    feelsLikeCelsius: 20,
    condition: condition,
    windSpeedMs: 2,
    precipProbability: 10,
    uvIndex: 3,
    humidity: 55,
    observedAt: now,
    locationName: '서울',
    hourlyForecasts: [
      HourlyForecast(
        time: now.add(const Duration(hours: 1)),
        tempCelsius: 20,
        condition: condition,
      ),
      HourlyForecast(
        time: now.add(const Duration(hours: 2)),
        tempCelsius: 19,
        condition: condition,
      ),
    ],
  );
}
