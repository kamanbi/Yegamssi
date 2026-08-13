import 'dart:math' as math;

import '../../weather/domain/entities/weather_entity.dart';
import 'activity_models.dart';
import 'marine_warning_matcher.dart';

class ActivityJudgmentCalculator {
  static const calculationVersion = 'activity-v6';
  static const _freshnessLimit = Duration(hours: 2);
  static const _resultLifetime = Duration(minutes: 30);
  static const _planningResultLifetime = Duration(hours: 6);
  static const _coverageTolerance = Duration(hours: 1);
  static const _currentMetricWindow = Duration(minutes: 30);

  bool hasForecastCoverage({
    required ActivityJudgmentRequest request,
    required WeatherEntity weather,
  }) {
    final now = DateTime.now();
    if (!request.evidenceEndsAt.isAfter(now.add(_currentMetricWindow))) {
      return true;
    }
    if (weather.hourlyForecasts.isEmpty) return false;
    final forecasts = [...weather.hourlyForecasts]
      ..sort((left, right) => left.time.compareTo(right.time));
    final firstCoveredAt = forecasts.first.time.subtract(_coverageTolerance);
    final lastCoveredAt = forecasts.last.time.add(_coverageTolerance);
    return !request.startsAt.isBefore(firstCoveredAt) &&
        !request.evidenceEndsAt.isAfter(lastCoveredAt);
  }

  ActivityJudgmentMode judgmentModeFor({
    required ActivityJudgmentRequest request,
    required WeatherEntity weather,
  }) {
    if (hasForecastCoverage(request: request, weather: weather)) {
      return ActivityJudgmentMode.detailed;
    }
    if (_dailyForecastsFor(request, weather).isNotEmpty) {
      return ActivityJudgmentMode.planning;
    }
    return ActivityJudgmentMode.pending;
  }

  ActivityJudgment calculate({
    required ActivityJudgmentRequest request,
    required WeatherEntity weather,
    String? existingId,
    SeaFishingEvidence? seaFishingEvidence,
    MidSeaForecastEvidence? midSeaForecastEvidence,
    ForestFireEvidence? forestFireEvidence,
    WeatherWarningEvidence? weatherWarningEvidence,
    TideEvidence? tideEvidence,
    CurrentEvidence? currentEvidence,
    MarineTimeSeriesEvidence? waveEvidence,
    MarineTimeSeriesEvidence? waterTemperatureEvidence,
  }) {
    final now = DateTime.now();
    final validationMessage = _validate(request, weather, now);
    if (validationMessage != null) {
      return _limited(
        request: request,
        weather: weather,
        message: validationMessage,
        now: now,
        existingId: existingId,
      );
    }

    final judgmentMode = judgmentModeFor(request: request, weather: weather);
    if (judgmentMode == ActivityJudgmentMode.pending) {
      return _limited(
        request: request,
        weather: weather,
        message: '아직 선택한 날짜를 포함하는 예보가 없습니다.',
        now: now,
        existingId: existingId,
        planStatus: ActivityPlanStatus.forecastPending,
        judgmentMode: ActivityJudgmentMode.pending,
        action: _forecastPendingAction(request, weather, now),
      );
    }
    if (judgmentMode == ActivityJudgmentMode.planning) {
      return _calculatePlanning(
        request: request,
        weather: weather,
        seaFishingEvidence: seaFishingEvidence,
        midSeaForecastEvidence: midSeaForecastEvidence,
        forestFireEvidence: forestFireEvidence,
        now: now,
        existingId: existingId,
      );
    }

    if (request.activityType == ActivityType.seaFishing) {
      return _calculateSeaFishing(
        request: request,
        weather: weather,
        evidence: seaFishingEvidence,
        weatherWarningEvidence: weatherWarningEvidence,
        tideEvidence: tideEvidence,
        currentEvidence: currentEvidence,
        waveEvidence: waveEvidence,
        waterTemperatureEvidence: waterTemperatureEvidence,
        now: now,
        existingId: existingId,
      );
    }
    if (request.activityType == ActivityType.hiking &&
        forestFireEvidence == null) {
      return _limited(
        request: request,
        weather: weather,
        message: '산불위험예보 자료가 없어 등산 안전 판단을 만들지 않습니다.',
        now: now,
        existingId: existingId,
        action: '산불위험 자료가 갱신된 뒤 다시 판단하세요.',
      );
    }

    final samples = _samplesFor(request, weather);
    final metrics = _WindowMetrics.from(samples, weather);
    final fireRiskStop =
        request.activityType == ActivityType.hiking &&
        forestFireEvidence!.maxRiskIndex >= 85;
    final fireRiskCaution =
        request.activityType == ActivityType.hiking &&
        forestFireEvidence!.maxRiskIndex >= 66;
    final weatherSafetyOverride = _safetyOverride(
      request.activityType,
      metrics,
    );
    final safetyOverride = fireRiskStop
        ? ActivitySafetyLevel.stop
        : weatherSafetyOverride;
    final factors = _scoreFactors(request, metrics);
    if (request.activityType == ActivityType.hiking) {
      factors.add(
        JudgmentFactor(
          label: forestFireEvidence!.coverageName.contains('최대위험')
              ? '${forestFireEvidence.coverageName.replaceAll(' 최대위험', '')} 산불위험 최대지수 ${forestFireEvidence.maxRiskIndex}'
              : '${forestFireEvidence.coverageName} 산불위험 최대지수 ${forestFireEvidence.maxRiskIndex}',
          contribution: fireRiskStop ? -40 : (fireRiskCaution ? -20 : 0),
        ),
      );
    }
    final score =
        (75 + factors.fold<int>(0, (sum, item) => sum + item.contribution))
            .clamp(0, 100);
    final safetyLevel =
        safetyOverride ??
        (fireRiskCaution || score < 45
            ? ActivitySafetyLevel.caution
            : ActivitySafetyLevel.allowed);

    return ActivityJudgment(
      id:
          existingId ??
          '${request.activityType.name}-${now.microsecondsSinceEpoch}',
      request: request,
      score: score,
      safetyLevel: safetyLevel,
      coverageLevel: _coverageLevel(request, metrics),
      summary: _summary(score, safetyLevel),
      action: _actionFor(safetyLevel),
      factors: factors,
      calculatedAt: now,
      dataObservedAt: weather.observedAt,
      expiresAt: now.add(_resultLifetime),
      sources: [
        '예감씨 위치별 날씨',
        if (request.activityType == ActivityType.hiking) '국립산림과학원 산불위험예보',
        calculationVersion,
      ],
      confidence: _detailedConfidence(request, weather),
      unverifiedFactors: _detailedUnverifiedFactors(request, weather),
      alternativeWindows: _hourlyAlternatives(request, weather),
    );
  }

  ActivityJudgment _calculateSeaFishing({
    required ActivityJudgmentRequest request,
    required WeatherEntity weather,
    required SeaFishingEvidence? evidence,
    required WeatherWarningEvidence? weatherWarningEvidence,
    required DateTime now,
    required String? existingId,
    TideEvidence? tideEvidence,
    CurrentEvidence? currentEvidence,
    MarineTimeSeriesEvidence? waveEvidence,
    MarineTimeSeriesEvidence? waterTemperatureEvidence,
  }) {
    final relevantWarnings = weatherWarningEvidence == null
        ? const <ActiveWeatherWarning>[]
        : MarineWarningMatcher().relevantWarnings(
            request: request,
            evidence: weatherWarningEvidence,
            evaluatedAt: now,
          );
    if (relevantWarnings.isNotEmpty) {
      final warningNames = relevantWarnings
          .map((warning) => warning.phenomenon)
          .toSet()
          .join('·');
      return ActivityJudgment(
        id:
            existingId ??
            '${request.activityType.name}-${now.microsecondsSinceEpoch}',
        request: request,
        score: null,
        safetyLevel: ActivitySafetyLevel.stop,
        coverageLevel: ActivityCoverageLevel.partial,
        summary: '출조 지역에 $warningNames가 발효 중입니다.',
        action: '특보가 해제되고 해양 상태가 안정된 뒤 다시 판단하세요.',
        factors: [
          JudgmentFactor(label: '기상청 현행 특보 $warningNames', contribution: -100),
        ],
        calculatedAt: now,
        dataObservedAt: weather.observedAt,
        expiresAt: now.add(_resultLifetime),
        sources: const ['기상청 기상특보 현황', '예감씨 위치별 날씨', calculationVersion],
      );
    }
    if (evidence == null) {
      final supportsOfficialIndex = request.supportsOfficialFishingIndex;
      return _limited(
        request: request,
        weather: weather,
        message: supportsOfficialIndex
            ? '공식 낚시지점의 해양자료를 찾지 못해 출조 점수를 만들지 않습니다.'
            : '선택한 출조지는 공식 지수 미지원 지역이며 좌표 기반 해양자료가 부족해 출조 점수를 만들지 않습니다.',
        now: now,
        existingId: existingId,
        action: supportsOfficialIndex
            ? '공식 지점명을 확인해 다시 판단하세요.'
            : '현재는 날씨만 확인할 수 있습니다. 조석·조류·파랑 자료 연동 후 다시 판단하세요.',
      );
    }
    if (evidence.maxWaveHeightM == null || evidence.maxWindSpeedMs == null) {
      return _limited(
        request: request,
        weather: weather,
        message: '공식 해양자료의 파고 또는 풍속이 누락되어 출조 점수를 만들지 않습니다.',
        now: now,
        existingId: existingId,
        action: '필수 해양자료가 갱신된 뒤 다시 판단하세요.',
      );
    }
    final officialScore = switch (evidence.officialIndex.replaceAll(' ', '')) {
      '매우좋음' => 95,
      '좋음' => 80,
      '보통' => 60,
      '나쁨' => 35,
      '매우나쁨' => 15,
      _ => null,
    };
    if (officialScore == null) {
      return _limited(
        request: request,
        weather: weather,
        message: '공식 바다낚시지수 형식을 확인할 수 없어 점수를 만들지 않습니다.',
        now: now,
        existingId: existingId,
        action: '공급기관 자료 형식이 확인된 뒤 다시 판단하세요.',
      );
    }
    final stationDistanceKm = _distanceKm(
      request.latitude,
      request.longitude,
      evidence.latitude,
      evidence.longitude,
    );
    if (stationDistanceKm > 30) {
      return _limited(
        request: request,
        weather: weather,
        message: '선택 위치와 공식 낚시지점이 ${stationDistanceKm.round()}km 떨어져 있습니다.',
        now: now,
        existingId: existingId,
        action: '공식 지점에서 30km 이내인 위치를 선택하세요.',
      );
    }

    final weatherMetrics = _WindowMetrics.from(
      _samplesFor(request, weather),
      weather,
    );
    final weatherSafety = _safetyOverride(
      ActivityType.seaFishing,
      weatherMetrics,
    );
    final tideFactor = _tideFactor(tideEvidence, request.startsAt);
    final currentFactor = _currentFactor(currentEvidence);
    // 요청 구간 실측 파고(있으면)가 공식 지수의 일 최대 파고보다 더
    // 정밀하므로 우선한다.
    final effectiveMaxWaveHeightM =
        waveEvidence?.maxValue ?? evidence.maxWaveHeightM;
    final waveStopThreshold = request.options.variant == '선상' ? 2.5 : 1.5;
    final marineStop =
        (effectiveMaxWaveHeightM ?? 0) >= waveStopThreshold ||
        (evidence.maxWindSpeedMs ?? 0) >= 14 ||
        (currentEvidence?.maxSpeedCms ?? 0) >= _dangerousCurrentSpeedCms;
    final safetyLevel = marineStop || weatherSafety == ActivitySafetyLevel.stop
        ? ActivitySafetyLevel.stop
        : ActivitySafetyLevel.allowed;
    final weatherFactors = _scoreFactors(request, weatherMetrics);
    final weatherScore =
        (75 +
                weatherFactors.fold<int>(
                  0,
                  (sum, item) => sum + item.contribution,
                ))
            .clamp(0, 100);
    final tideCurrentContribution =
        (tideFactor?.contribution ?? 0) + (currentFactor?.contribution ?? 0);
    final score =
        ((officialScore * 0.6 + weatherScore * 0.4).round() +
                tideCurrentContribution)
            .clamp(0, 100);
    final factors = <JudgmentFactor>[
      JudgmentFactor(
        label: '공식 바다낚시지수 ${evidence.officialIndex}',
        contribution: officialScore - 60,
      ),
      if (effectiveMaxWaveHeightM != null)
        JudgmentFactor(
          label: waveEvidence != null
              ? '요청 구간 실측 파고 ${effectiveMaxWaveHeightM.toStringAsFixed(1)}m'
              : '최대 파고 ${effectiveMaxWaveHeightM.toStringAsFixed(1)}m',
          contribution: effectiveMaxWaveHeightM >= 1.0 ? -15 : 5,
        ),
      if (evidence.maxWindSpeedMs != null)
        JudgmentFactor(
          label: '최대 풍속 ${evidence.maxWindSpeedMs!.toStringAsFixed(1)}m/s',
          contribution: evidence.maxWindSpeedMs! >= 8 ? -12 : 4,
        ),
      if (tideFactor != null) tideFactor,
      if (currentFactor != null) currentFactor,
      if (waterTemperatureEvidence?.maxValue != null)
        JudgmentFactor(
          label:
              '요청 구간 실측 수온 ${waterTemperatureEvidence!.maxValue!.toStringAsFixed(1)}°C',
          contribution: 0,
        ),
      ...weatherFactors,
    ];
    return ActivityJudgment(
      id:
          existingId ??
          '${request.activityType.name}-${now.microsecondsSinceEpoch}',
      request: request,
      score: score,
      safetyLevel: safetyLevel,
      coverageLevel: ActivityCoverageLevel.partial,
      summary: _summary(score, safetyLevel),
      action: safetyLevel == ActivitySafetyLevel.stop
          ? '출조를 미루고 해양 상태가 안정된 뒤 다시 판단하세요.'
          : '${evidence.stationName} ${evidence.forecastPeriod} 자료입니다. 출항 직전 특보를 다시 확인하세요.',
      factors: factors,
      calculatedAt: now,
      dataObservedAt: weather.observedAt,
      expiresAt: evidence.forecastEndsAt.isBefore(now.add(_resultLifetime))
          ? evidence.forecastEndsAt
          : now.add(_resultLifetime),
      evidenceValidFrom: evidence.forecastStartsAt,
      evidenceValidUntil: evidence.forecastEndsAt,
      sources: [
        '국립해양조사원 바다낚시지수',
        '예감씨 위치별 날씨',
        if (tideFactor != null) '국립해양조사원 조석예보',
        if (currentFactor != null) '국립해양조사원 조류예보',
        if (waveEvidence != null) '국립해양조사원 실측 파랑',
        if (waterTemperatureEvidence != null) '국립해양조사원 해양관측부이',
        calculationVersion,
      ],
    );
  }

  /// 조석 기반 조황 유·불리 요인. 만조·간조 시각(정조) 부근은 조류가 멈춰
  /// 입질이 뜸해지고, 정조 직후 유속이 다시 붙는 "초들물·초날물" 구간은
  /// 먹이가 다시 움직이며 입질이 활발해진다는 물때 낚시 통설을 근거로 한다.
  /// 공식 규정이 아니라 예감씨가 정한 판단 기준이며, 근거는 판단 요인
  /// 라벨에 그대로 노출한다.
  static const _slackTideWindow = Duration(minutes: 30);
  static const _favorableTideWindowStart = Duration(minutes: 30);
  static const _favorableTideWindowEnd = Duration(minutes: 150);
  static const _dangerousCurrentSpeedCms = 150.0;
  static const _cautionCurrentSpeedCms = 80.0;

  JudgmentFactor? _tideFactor(TideEvidence? evidence, DateTime requestedAt) {
    if (evidence == null || evidence.events.isEmpty) return null;

    TideEventEntry? precedingEvent;
    TideEventEntry? followingEvent;
    for (final event in evidence.events) {
      if (!event.time.isAfter(requestedAt)) {
        if (precedingEvent == null ||
            event.time.isAfter(precedingEvent.time)) {
          precedingEvent = event;
        }
      } else if (followingEvent == null ||
          event.time.isBefore(followingEvent.time)) {
        followingEvent = event;
      }
    }

    final nearSlack =
        (precedingEvent != null &&
            requestedAt.difference(precedingEvent.time) <= _slackTideWindow) ||
        (followingEvent != null &&
            followingEvent.time.difference(requestedAt) <= _slackTideWindow);
    if (nearSlack) {
      return const JudgmentFactor(
        label: '정조(물때 전환) 인근, 조류 정지로 입질 저조 우려',
        contribution: -6,
      );
    }

    if (precedingEvent != null) {
      final sincePreceding = requestedAt.difference(precedingEvent.time);
      if (sincePreceding >= _favorableTideWindowStart &&
          sincePreceding <= _favorableTideWindowEnd) {
        final label = precedingEvent.type == TideEventType.highTide
            ? '초날물(만조 직후 유속 재개) 구간, 조황에 유리'
            : '초들물(간조 직후 유속 재개) 구간, 조황에 유리';
        return JudgmentFactor(label: label, contribution: 8);
      }
    }
    return null;
  }

  /// 조류 유속이 강하면 갯바위·선상 모두 안전이 우선이라는 판단으로,
  /// 임계값은 예감씨가 정한 기준이다(공식 규정 아님).
  JudgmentFactor? _currentFactor(CurrentEvidence? evidence) {
    if (evidence == null) return null;
    if (evidence.maxSpeedCms >= _dangerousCurrentSpeedCms) {
      return JudgmentFactor(
        label:
            '조류 최대 유속 ${evidence.maxSpeedCms.toStringAsFixed(0)}cm/s(${evidence.direction}), 위험 수준',
        contribution: -20,
      );
    }
    if (evidence.maxSpeedCms >= _cautionCurrentSpeedCms) {
      return JudgmentFactor(
        label:
            '조류 최대 유속 ${evidence.maxSpeedCms.toStringAsFixed(0)}cm/s(${evidence.direction})',
        contribution: -6,
      );
    }
    return null;
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const kmPerLatitudeDegree = 111.0;
    final latitudeDistance = (lat1 - lat2) * kmPerLatitudeDegree;
    final longitudeScale =
        kmPerLatitudeDegree * math.cos(((lat1 + lat2) / 2) * math.pi / 180);
    final longitudeDistance = (lon1 - lon2) * longitudeScale;
    return math.sqrt(
      latitudeDistance * latitudeDistance +
          longitudeDistance * longitudeDistance,
    );
  }

  ActivityJudgment _calculatePlanning({
    required ActivityJudgmentRequest request,
    required WeatherEntity weather,
    required SeaFishingEvidence? seaFishingEvidence,
    required MidSeaForecastEvidence? midSeaForecastEvidence,
    required ForestFireEvidence? forestFireEvidence,
    required DateTime now,
    required String? existingId,
  }) {
    final dailyForecasts = _dailyForecastsFor(request, weather);
    final evidenceWindow = _PlanningEvidenceWindow.from(
      request: request,
      forecasts: dailyForecasts,
    );
    final unverified = <String>[
      ..._planningUnverifiedFactors(
        request,
        seaFishingEvidence: seaFishingEvidence,
        midSeaForecastEvidence: midSeaForecastEvidence,
        forestFireEvidence: forestFireEvidence,
      ),
    ];
    final officialFishingScore = seaFishingEvidence == null
        ? null
        : _officialFishingScore(seaFishingEvidence.officialIndex);
    final hasMidSeaEvidence = midSeaForecastEvidence != null;
    if (request.activityType == ActivityType.seaFishing &&
        seaFishingEvidence == null &&
        !hasMidSeaEvidence) {
      return ActivityJudgment(
        id:
            existingId ??
            '${request.activityType.name}-${now.microsecondsSinceEpoch}',
        request: request,
        score: null,
        safetyLevel: ActivitySafetyLevel.limited,
        coverageLevel: ActivityCoverageLevel.weatherOnly,
        summary: '선택 날짜의 육상 날씨는 확인되지만 해양자료가 없어 출조 판단은 미확정입니다.',
        action: '파고·해상날씨 자료가 확보된 뒤 다시 판단하고 출항 직전 특보를 확인하세요.',
        factors: _planningFactors(request, evidenceWindow),
        calculatedAt: now,
        dataObservedAt: weather.observedAt,
        expiresAt: now.add(_planningResultLifetime),
        sources: const ['예감씨 위치별 일별예보', calculationVersion],
        judgmentMode: ActivityJudgmentMode.planning,
        confidence: ActivityConfidence.low,
        unverifiedFactors: unverified,
        alternativeWindows: _dailyAlternatives(request, weather),
      );
    }
    if (request.activityType == ActivityType.seaFishing &&
        seaFishingEvidence != null &&
        officialFishingScore == null) {
      unverified.add('공식 바다낚시지수 값');
      return ActivityJudgment(
        id:
            existingId ??
            '${request.activityType.name}-${now.microsecondsSinceEpoch}',
        request: request,
        score: null,
        safetyLevel: ActivitySafetyLevel.limited,
        coverageLevel: ActivityCoverageLevel.weatherOnly,
        summary: '공식 바다낚시지수 값을 해석할 수 없어 출조 판단은 미확정입니다.',
        action: '파고·풍속·물때 자료가 확보된 뒤 다시 판단하고 출항 직전 특보를 확인하세요.',
        factors: _planningFactors(request, evidenceWindow),
        calculatedAt: now,
        dataObservedAt: weather.observedAt,
        expiresAt: now.add(_planningResultLifetime),
        sources: const ['예감씨 위치별 일별예보', calculationVersion],
        judgmentMode: ActivityJudgmentMode.planning,
        confidence: ActivityConfidence.low,
        unverifiedFactors: unverified,
        alternativeWindows: _dailyAlternatives(request, weather),
      );
    }

    final factors = _planningFactors(request, evidenceWindow);
    if (seaFishingEvidence != null && officialFishingScore != null) {
      factors.add(
        JudgmentFactor(
          label: '공식 바다낚시지수 ${seaFishingEvidence.officialIndex}',
          contribution: officialFishingScore - 60,
        ),
      );
      if (seaFishingEvidence.maxWaveHeightM != null) {
        factors.add(
          JudgmentFactor(
            label:
                '공식 일 최대 파고 ${seaFishingEvidence.maxWaveHeightM!.toStringAsFixed(1)}m',
            contribution: seaFishingEvidence.maxWaveHeightM! >= 1.0 ? -15 : 5,
          ),
        );
      }
      if (seaFishingEvidence.maxWindSpeedMs != null) {
        factors.add(
          JudgmentFactor(
            label:
                '공식 일 최대 풍속 ${seaFishingEvidence.maxWindSpeedMs!.toStringAsFixed(1)}m/s',
            contribution: seaFishingEvidence.maxWindSpeedMs! >= 8 ? -12 : 4,
          ),
        );
      }
      if (seaFishingEvidence.maxWaterTemperatureC != null) {
        factors.add(
          JudgmentFactor(
            label:
                '공식 일 최고 수온 ${seaFishingEvidence.maxWaterTemperatureC!.toStringAsFixed(1)}°C',
            contribution: 0,
          ),
        );
      }
      if (seaFishingEvidence.tideDescription.isNotEmpty) {
        factors.add(
          JudgmentFactor(
            label: '물때 ${seaFishingEvidence.tideDescription}',
            contribution: 0,
          ),
        );
      }
    }
    if (midSeaForecastEvidence != null) {
      factors.addAll([
        JudgmentFactor(
          label:
              '${midSeaForecastEvidence.seaRegionName} ${midSeaForecastEvidence.forecastPeriod} 해상날씨 ${midSeaForecastEvidence.weatherSummary}',
          contribution: _midSeaWeatherContribution(
            midSeaForecastEvidence.weatherSummary,
          ),
        ),
        JudgmentFactor(
          label:
              '중기 파고 ${midSeaForecastEvidence.minWaveHeightM.toStringAsFixed(1)}~${midSeaForecastEvidence.maxWaveHeightM.toStringAsFixed(1)}m',
          contribution: midSeaForecastEvidence.maxWaveHeightM >= 2.0
              ? -25
              : midSeaForecastEvidence.maxWaveHeightM >= 1.0
              ? -12
              : 5,
        ),
      ]);
    }
    if (forestFireEvidence != null) {
      factors.add(
        JudgmentFactor(
          label:
              '${forestFireEvidence.coverageName} 산불위험 ${forestFireEvidence.maxRiskIndex}',
          contribution: forestFireEvidence.maxRiskIndex >= 85
              ? -40
              : forestFireEvidence.maxRiskIndex >= 66
              ? -20
              : 0,
        ),
      );
    }

    final baseScore = switch (request.activityType) {
      ActivityType.walkingRunning => 72,
      ActivityType.hiking => 72,
      ActivityType.laundry => 72,
      ActivityType.carWash => 78,
      ActivityType.seaFishing => 70,
    };
    final score =
        (baseScore +
                factors.fold<int>(
                  0,
                  (sum, factor) => sum + factor.contribution,
                ))
            .clamp(0, 100);
    final hasDangerousCondition = evidenceWindow.conditions.any(
      _isDangerousCondition,
    );
    final fireRisk = forestFireEvidence?.maxRiskIndex;
    final fishingWaveStopThreshold = request.options.variant == '선상'
        ? 2.5
        : 1.5;
    final hasMarineDanger =
        request.activityType == ActivityType.seaFishing &&
        seaFishingEvidence != null &&
        ((seaFishingEvidence.maxWaveHeightM ?? 0) >= fishingWaveStopThreshold ||
            (seaFishingEvidence.maxWindSpeedMs ?? 0) >= 14);
    final safetyLevel = _planningSafetyLevel(
      request.activityType,
      score: score,
      hasDangerousCondition: hasDangerousCondition,
      hasMarineDanger: hasMarineDanger,
      fireRisk: fireRisk,
    );
    final confidence = _planningConfidence(
      request.activityType,
      hasOfficialFishingEvidence: seaFishingEvidence != null,
      hasForestFireEvidence: forestFireEvidence != null,
      hasTemperatureData: evidenceWindow.hasTemperatureData,
    );
    final rangePadding = switch (request.activityType) {
      ActivityType.laundry || ActivityType.carWash => 6,
      ActivityType.walkingRunning => 8,
      ActivityType.hiking || ActivityType.seaFishing => 12,
    };
    final scoreRangeMin = (score - rangePadding).clamp(0, 100);
    final scoreRangeMax = (score + rangePadding).clamp(0, 100);
    final summary = _planningSummary(
      request.activityType,
      score: score,
      hasDangerousCondition: hasDangerousCondition,
    );
    final action = _planningAction(
      request,
      hasDangerousCondition: hasDangerousCondition,
      forestFireEvidence: forestFireEvidence,
      seaFishingEvidence: seaFishingEvidence,
      midSeaForecastEvidence: midSeaForecastEvidence,
    );

    return ActivityJudgment(
      id:
          existingId ??
          '${request.activityType.name}-${now.microsecondsSinceEpoch}',
      request: request,
      score: score,
      safetyLevel: safetyLevel,
      coverageLevel:
          seaFishingEvidence != null ||
              midSeaForecastEvidence != null ||
              forestFireEvidence != null
          ? ActivityCoverageLevel.partial
          : ActivityCoverageLevel.weatherOnly,
      summary: summary,
      action: action,
      factors: factors,
      calculatedAt: now,
      dataObservedAt: weather.observedAt,
      expiresAt: now.add(_planningResultLifetime),
      evidenceValidFrom:
          seaFishingEvidence?.forecastStartsAt ??
          midSeaForecastEvidence?.forecastStartsAt,
      evidenceValidUntil:
          seaFishingEvidence?.forecastEndsAt ??
          midSeaForecastEvidence?.forecastEndsAt,
      sources: [
        '예감씨 위치별 일별예보',
        if (seaFishingEvidence != null) '국립해양조사원 바다낚시지수',
        if (midSeaForecastEvidence != null) '기상청 중기 해상예보',
        if (forestFireEvidence != null) '국립산림과학원 산불위험예보',
        calculationVersion,
      ],
      judgmentMode: ActivityJudgmentMode.planning,
      confidence: confidence,
      scoreRangeMin: scoreRangeMin,
      scoreRangeMax: scoreRangeMax,
      unverifiedFactors: unverified,
      alternativeWindows: _dailyAlternatives(request, weather),
    );
  }

  List<DailyForecast> _dailyForecastsFor(
    ActivityJudgmentRequest request,
    WeatherEntity weather,
  ) {
    final byDate = <String, DailyForecast>{
      for (final forecast in weather.dailyForecasts)
        _dateKey(forecast.date): forecast,
    };
    final required = <DailyForecast>[];
    var date = _dateOnly(request.startsAt);
    final lastDate = _dateOnly(request.evidenceEndsAt);
    while (!date.isAfter(lastDate)) {
      final forecast = byDate[_dateKey(date)];
      if (forecast == null) return const [];
      required.add(forecast);
      date = date.add(const Duration(days: 1));
    }
    return required;
  }

  List<JudgmentFactor> _planningFactors(
    ActivityJudgmentRequest request,
    _PlanningEvidenceWindow window,
  ) {
    final precipitationPercent = window.maxPrecipProbability * 100;
    final factors = <JudgmentFactor>[
      JudgmentFactor(
        label: request.activityType == ActivityType.carWash
            ? '${request.options.variant.contains('48시간') ? '48' : '24'}시간 내 최대 강수확률 ${precipitationPercent.round()}%'
            : '선택 시간대 강수확률 ${precipitationPercent.round()}%',
        contribution: _planningPrecipitationContribution(
          request.activityType,
          precipitationPercent,
        ),
      ),
    ];
    if (window.hasWetCondition) {
      factors.add(
        JudgmentFactor(
          label: request.activityType == ActivityType.carWash
              ? '유지 기간 비 또는 눈 가능성'
              : '비 또는 눈 가능성',
          contribution:
              request.activityType == ActivityType.laundry ||
                  request.activityType == ActivityType.carWash
              ? -20
              : -15,
        ),
      );
    }
    if (window.hasTemperatureData) {
      final minTemperature = window.minTemperature!;
      final maxTemperature = window.maxTemperature!;
      factors.add(
        JudgmentFactor(
          label:
              '선택 시간대 기온 ${minTemperature.round()}~${maxTemperature.round()}°C',
          contribution: _planningTemperatureContribution(
            request.activityType,
            minTemperature,
            maxTemperature,
          ),
        ),
      );
    }
    switch (request.activityType) {
      case ActivityType.walkingRunning:
        if (request.options.variant.contains('강하게')) {
          factors.add(
            const JudgmentFactor(label: '강한 운동 강도', contribution: -8),
          );
        } else if (request.options.variant.startsWith('걷기')) {
          factors.add(const JudgmentFactor(label: '보통 걷기', contribution: 4));
        }
      case ActivityType.hiking:
        if (request.options.variant == '초보') {
          factors.add(
            const JudgmentFactor(label: '초보 산행 준비 필요', contribution: -5),
          );
        } else if (request.options.variant == '숙련') {
          factors.add(const JudgmentFactor(label: '숙련 산행', contribution: 2));
        }
      case ActivityType.laundry:
        if (request.options.variant.contains('두꺼운')) {
          factors.add(
            const JudgmentFactor(label: '두꺼운 빨래 건조 부담', contribution: -10),
          );
        } else if (request.options.variant.contains('베란다')) {
          factors.add(const JudgmentFactor(label: '베란다 건조', contribution: -4));
        }
      case ActivityType.carWash:
      case ActivityType.seaFishing:
        break;
    }
    return factors;
  }

  List<String> _planningUnverifiedFactors(
    ActivityJudgmentRequest request, {
    required SeaFishingEvidence? seaFishingEvidence,
    required MidSeaForecastEvidence? midSeaForecastEvidence,
    required ForestFireEvidence? forestFireEvidence,
  }) {
    return switch (request.activityType) {
      ActivityType.walkingRunning => const ['시간대별 풍속', '시간대별 체감온도', '시간대별 자외선'],
      ActivityType.hiking => [
        '시간대별 풍속',
        '시간대별 체감온도',
        '시간대별 자외선',
        if (forestFireEvidence == null) '산불위험',
      ],
      ActivityType.laundry => const ['시간대별 습도', '건조 시간대 바람'],
      ActivityType.carWash => const [],
      ActivityType.seaFishing => [
        if (seaFishingEvidence == null && midSeaForecastEvidence == null) ...[
          '파고',
          '해상풍',
          '물때',
          '어종별 바다낚시지수',
        ] else if (midSeaForecastEvidence != null) ...[
          '시간대별 해상풍',
          '물때',
          '어종별 바다낚시지수',
          '출항 시점 기상특보',
        ] else ...[
          '시간대별 해상 상태',
          '출항 시점 기상특보',
        ],
      ],
    };
  }

  int _planningPrecipitationContribution(
    ActivityType activityType,
    double probability,
  ) {
    if (activityType == ActivityType.laundry ||
        activityType == ActivityType.carWash) {
      if (probability >= 70) return -45;
      if (probability >= 50) return -30;
      if (probability >= 30) return -15;
      if (probability >= 11) return 8;
      return 20;
    }
    if (probability >= 70) return -35;
    if (probability >= 40) return -18;
    return 8;
  }

  int _planningTemperatureContribution(
    ActivityType activityType,
    double minTemperature,
    double maxTemperature,
  ) {
    if (activityType == ActivityType.carWash) return 0;
    if (activityType == ActivityType.laundry) {
      if (maxTemperature < 5) return -12;
      if (maxTemperature >= 20) return 8;
      return 2;
    }
    if (minTemperature < 0 || maxTemperature > 31) return -18;
    if (minTemperature >= 10 && maxTemperature <= 26) return 6;
    return 0;
  }

  ActivitySafetyLevel _planningSafetyLevel(
    ActivityType activityType, {
    required int score,
    required bool hasDangerousCondition,
    required bool hasMarineDanger,
    required int? fireRisk,
  }) {
    if (hasDangerousCondition || hasMarineDanger || (fireRisk ?? 0) >= 85) {
      return ActivitySafetyLevel.stop;
    }
    if (activityType == ActivityType.seaFishing ||
        activityType == ActivityType.hiking) {
      return ActivitySafetyLevel.limited;
    }
    return score < 45
        ? ActivitySafetyLevel.caution
        : ActivitySafetyLevel.allowed;
  }

  ActivityConfidence _planningConfidence(
    ActivityType activityType, {
    required bool hasOfficialFishingEvidence,
    required bool hasForestFireEvidence,
    required bool hasTemperatureData,
  }) {
    if (activityType == ActivityType.laundry ||
        activityType == ActivityType.carWash) {
      return hasTemperatureData
          ? ActivityConfidence.medium
          : ActivityConfidence.low;
    }
    if (activityType == ActivityType.walkingRunning) {
      return hasTemperatureData
          ? ActivityConfidence.medium
          : ActivityConfidence.low;
    }
    if (activityType == ActivityType.hiking) {
      return hasForestFireEvidence
          ? ActivityConfidence.medium
          : ActivityConfidence.low;
    }
    return hasOfficialFishingEvidence
        ? ActivityConfidence.medium
        : ActivityConfidence.low;
  }

  String _planningSummary(
    ActivityType activityType, {
    required int score,
    required bool hasDangerousCondition,
  }) {
    if (hasDangerousCondition) {
      return '선택 날짜에 위험 기상 가능성이 있어 계획 변경을 권합니다.';
    }
    return switch (activityType) {
      ActivityType.walkingRunning => '선택 시간대의 오전·오후 예보로 계산한 걷기·달리기 계획 적합도입니다.',
      ActivityType.hiking => '일 단위 산행 적합도입니다. 출발 전 풍속과 산불위험 확인이 필요합니다.',
      ActivityType.laundry =>
        score >= 65
            ? '중기예보 기준으로 빨래를 말리기 좋은 계획입니다.'
            : score >= 45
            ? '중기예보 기준으로 건조 조건을 확인하고 진행할 수 있습니다.'
            : '비 가능성이나 기온 조건 때문에 다른 날을 권합니다.',
      ActivityType.carWash =>
        score >= 65
            ? '선택한 유지 기간의 중기예보 기준으로 세차하기 좋습니다.'
            : score >= 45
            ? '세차 후 비 가능성을 확인하고 진행하세요.'
            : '유지 기간에 비 가능성이 있어 다른 날을 권합니다.',
      ActivityType.seaFishing => '일 단위 출조 환경 적합도입니다. 시간대별 출항 안전은 아직 미확정입니다.',
    };
  }

  String _planningAction(
    ActivityJudgmentRequest request, {
    required bool hasDangerousCondition,
    required ForestFireEvidence? forestFireEvidence,
    required SeaFishingEvidence? seaFishingEvidence,
    required MidSeaForecastEvidence? midSeaForecastEvidence,
  }) {
    if (hasDangerousCondition) {
      return '강수·낙뢰 가능성이 낮은 대안 날짜를 선택하세요.';
    }
    return switch (request.activityType) {
      ActivityType.walkingRunning => '출발이 가까워지면 시간대별 바람과 자외선을 다시 확인하세요.',
      ActivityType.hiking =>
        forestFireEvidence == null
            ? '출발 전 시간대별 바람과 산불위험을 반드시 다시 확인하세요.'
            : '출발 전 시간대별 풍속과 기상특보를 다시 확인하세요.',
      ActivityType.laundry =>
        request.options.variant.contains('두꺼운')
            ? '두꺼운 빨래는 건조 시간이 길 수 있으므로 해가 있는 시간에 시작하세요.'
            : '중기 강수예보가 바뀌지 않는지 시작 전에 확인하세요.',
      ActivityType.carWash =>
        '${request.options.variant.contains('48시간') ? '48' : '24'}시간 유지 구간의 강수예보를 기준으로 판단했습니다.',
      ActivityType.seaFishing =>
        seaFishingEvidence == null
            ? midSeaForecastEvidence == null
                  ? '해양자료가 확보된 뒤 다시 판단하고 출항 직전 특보를 확인하세요.'
                  : '중기 해상예보 기반 출조 환경 판단입니다. 조황과 출항 안전은 상세자료가 나온 뒤 다시 확인하세요.'
            : '공식 일 자료 기반 계획입니다. 출항 직전 시간대별 파고·풍속과 특보를 확인하세요.',
    };
  }

  int _midSeaWeatherContribution(String summary) {
    if (summary.contains('비') || summary.contains('눈')) return -15;
    if (summary.contains('흐')) return -5;
    if (summary.contains('맑')) return 5;
    return 0;
  }

  List<String> _dailyAlternatives(
    ActivityJudgmentRequest request,
    WeatherEntity weather,
  ) {
    final requestedDates = _requiredDateKeys(request);
    final alternatives = <({DateTime date, _PlanningEvidenceWindow window})>[];
    for (final forecast in weather.dailyForecasts) {
      if (requestedDates.contains(_dateKey(forecast.date)) ||
          forecast.date.isBefore(_dateOnly(DateTime.now()))) {
        continue;
      }
      final candidateRequest = _requestStartingOnDate(request, forecast.date);
      final candidateForecasts = _dailyForecastsFor(candidateRequest, weather);
      if (candidateForecasts.isEmpty) continue;
      alternatives.add((
        date: forecast.date,
        window: _PlanningEvidenceWindow.from(
          request: candidateRequest,
          forecasts: candidateForecasts,
        ),
      ));
    }
    alternatives.sort(
      (left, right) =>
          _planningAlternativePenalty(
            request.activityType,
            left.window,
          ).compareTo(
            _planningAlternativePenalty(request.activityType, right.window),
          ),
    );
    return alternatives
        .take(3)
        .map((candidate) {
          final probability = (candidate.window.maxPrecipProbability * 100)
              .round();
          final temperature = candidate.window.hasTemperatureData
              ? ' · ${candidate.window.minTemperature!.round()}~${candidate.window.maxTemperature!.round()}°C'
              : '';
          return '${_formatDate(candidate.date)} · 강수 $probability%$temperature';
        })
        .toList(growable: false);
  }

  ActivityJudgmentRequest _requestStartingOnDate(
    ActivityJudgmentRequest request,
    DateTime date,
  ) {
    return ActivityJudgmentRequest(
      activityType: request.activityType,
      locationName: request.locationName,
      latitude: request.latitude,
      longitude: request.longitude,
      startsAt: DateTime(
        date.year,
        date.month,
        date.day,
        request.startsAt.hour,
        request.startsAt.minute,
      ),
      durationMinutes: request.durationMinutes,
      options: request.options,
      destinationId: request.destinationId,
      destinationSource: request.destinationSource,
      destinationAreaName: request.destinationAreaName,
      destinationKind: request.destinationKind,
    );
  }

  double _planningAlternativePenalty(
    ActivityType activityType,
    _PlanningEvidenceWindow window,
  ) {
    final precipitation = window.maxPrecipProbability * 100;
    final wetPenalty = window.hasWetCondition ? 35 : 0;
    if (activityType == ActivityType.laundry ||
        activityType == ActivityType.carWash) {
      return precipitation * 2 + wetPenalty;
    }
    final temperaturePenalty = window.hasTemperatureData
        ? _temperatureRangePenalty(
            window.minTemperature!,
            window.maxTemperature!,
          )
        : 20;
    return precipitation + wetPenalty + temperaturePenalty * 2;
  }

  ActivityConfidence _detailedConfidence(
    ActivityJudgmentRequest request,
    WeatherEntity weather,
  ) {
    return _detailedUnverifiedFactors(request, weather).isEmpty
        ? ActivityConfidence.high
        : ActivityConfidence.medium;
  }

  List<String> _detailedUnverifiedFactors(
    ActivityJudgmentRequest request,
    WeatherEntity weather,
  ) {
    final samples = _samplesFor(request, weather);
    final missing = <String>[];
    if (samples.any((sample) => sample.windSpeedMs == null)) {
      missing.add('일부 시간대 풍속');
    }
    if (samples.any((sample) => sample.precipProbability == null)) {
      missing.add('일부 시간대 강수확률');
    }
    if (request.activityType == ActivityType.walkingRunning ||
        request.activityType == ActivityType.hiking) {
      missing.add('미래 시간대 자외선');
    }
    if (request.activityType == ActivityType.laundry) {
      missing.add('미래 시간대 습도');
    }
    return missing;
  }

  List<String> _hourlyAlternatives(
    ActivityJudgmentRequest request,
    WeatherEntity weather,
  ) {
    final alternatives =
        weather.hourlyForecasts
            .where((forecast) => forecast.time.isAfter(DateTime.now()))
            .where(
              (forecast) =>
                  forecast.time.isBefore(request.startsAt) ||
                  forecast.time.isAfter(request.evidenceEndsAt),
            )
            .toList()
          ..sort(
            (left, right) =>
                _hourlyPenalty(left).compareTo(_hourlyPenalty(right)),
          );
    return alternatives
        .take(3)
        .map((forecast) {
          final precipitation = forecast.precipProbability?.round();
          final wind = forecast.windSpeedMs?.toStringAsFixed(1);
          return '${_formatDateTime(forecast.time)} · '
              '${precipitation == null ? '강수 미확인' : '강수 $precipitation%'} · '
              '${wind == null ? '바람 미확인' : '바람 ${wind}m/s'}';
        })
        .toList(growable: false);
  }

  int? _officialFishingScore(String index) {
    return switch (index.replaceAll(' ', '')) {
      '매우좋음' => 95,
      '좋음' => 80,
      '보통' => 60,
      '나쁨' => 35,
      '매우나쁨' => 15,
      _ => null,
    };
  }

  bool _isDangerousCondition(WeatherCondition? condition) {
    return condition == WeatherCondition.thunderstorm ||
        condition == WeatherCondition.rainThunder ||
        condition == WeatherCondition.heavyRain;
  }

  double _temperatureRangePenalty(
    double minTemperature,
    double maxTemperature,
  ) {
    if (minTemperature < 0) return 0 - minTemperature;
    if (maxTemperature > 26) return maxTemperature - 26;
    return 0;
  }

  double _hourlyPenalty(HourlyForecast forecast) {
    final precipitation = forecast.precipProbability ?? 100;
    final wind = forecast.windSpeedMs ?? 15;
    final temperature = forecast.tempCelsius < 5
        ? 5 - forecast.tempCelsius
        : forecast.tempCelsius > 27
        ? forecast.tempCelsius - 27
        : 0;
    return precipitation + wind * 3 + temperature * 2;
  }

  Set<String> _requiredDateKeys(ActivityJudgmentRequest request) {
    final keys = <String>{};
    var date = _dateOnly(request.startsAt);
    final lastDate = _dateOnly(request.evidenceEndsAt);
    while (!date.isAfter(lastDate)) {
      keys.add(_dateKey(date));
      date = date.add(const Duration(days: 1));
    }
    return keys;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}'
      '${value.month.toString().padLeft(2, '0')}'
      '${value.day.toString().padLeft(2, '0')}';

  String _formatDate(DateTime value) =>
      '${value.month.toString().padLeft(2, '0')}/'
      '${value.day.toString().padLeft(2, '0')}';

  String? _validate(
    ActivityJudgmentRequest request,
    WeatherEntity weather,
    DateTime now,
  ) {
    if (request.durationMinutes < 30 || request.durationMinutes > 720) {
      return '활동 시간은 30분 이상 12시간 이하로 입력해야 합니다.';
    }
    if (request.startsAt.isBefore(now.subtract(const Duration(minutes: 5)))) {
      return '이미 지난 시간은 판단할 수 없습니다.';
    }
    if (now.difference(weather.observedAt) > _freshnessLimit) {
      return '날씨 자료가 오래되어 안전한 판단을 만들 수 없습니다.';
    }
    if ((request.activityType == ActivityType.seaFishing ||
            request.activityType == ActivityType.hiking) &&
        request.destinationId.isEmpty) {
      return '공식 목적지를 먼저 선택해야 합니다.';
    }
    return null;
  }

  List<HourlyForecast> _samplesFor(
    ActivityJudgmentRequest request,
    WeatherEntity weather,
  ) {
    final from = request.startsAt;
    final to = request.evidenceEndsAt;
    return weather.hourlyForecasts
        .where(
          (forecast) =>
              !forecast.time.isBefore(from) && !forecast.time.isAfter(to),
        )
        .toList();
  }

  ActivitySafetyLevel? _safetyOverride(
    ActivityType activityType,
    _WindowMetrics metrics,
  ) {
    if (metrics.hasThunderstorm || metrics.hasHeavyRain) {
      return ActivitySafetyLevel.stop;
    }
    final windStopThreshold = activityType == ActivityType.hiking ? 12.0 : 15.0;
    if ((metrics.windSpeedMs ?? 0) >= windStopThreshold) {
      return ActivitySafetyLevel.stop;
    }
    final thermalLoad =
        metrics.apparentTemperatureCelsius ?? metrics.averageTemperatureCelsius;
    if (activityType == ActivityType.hiking &&
        (thermalLoad <= -10 || thermalLoad >= 35)) {
      return ActivitySafetyLevel.stop;
    }
    return null;
  }

  List<JudgmentFactor> _scoreFactors(
    ActivityJudgmentRequest request,
    _WindowMetrics metrics,
  ) {
    final activityType = request.activityType;
    final factors = <JudgmentFactor>[];
    final precipitationProbability = metrics.precipProbability;
    if (precipitationProbability != null) {
      if (precipitationProbability >= 70) {
        factors.add(
          const JudgmentFactor(label: '강수 가능성 높음', contribution: -35),
        );
      } else if (precipitationProbability >= 40) {
        factors.add(
          const JudgmentFactor(label: '강수 가능성 있음', contribution: -18),
        );
      } else {
        factors.add(const JudgmentFactor(label: '강수 가능성 낮음', contribution: 8));
      }
    }
    final windSpeed = metrics.windSpeedMs;
    if (windSpeed != null) {
      if (windSpeed >= 8) {
        factors.add(const JudgmentFactor(label: '강한 바람', contribution: -20));
      } else if (windSpeed <= 4) {
        factors.add(const JudgmentFactor(label: '바람 안정', contribution: 6));
      }
    }
    final thermalLoad =
        metrics.apparentTemperatureCelsius ?? metrics.averageTemperatureCelsius;
    if (thermalLoad < 0 || thermalLoad > 31) {
      factors.add(const JudgmentFactor(label: '체감온도 부담', contribution: -18));
    } else if (thermalLoad >= 10 && thermalLoad <= 24) {
      factors.add(const JudgmentFactor(label: '쾌적한 체감온도', contribution: 8));
    }
    if ((metrics.uvIndex ?? 0) >= 8 &&
        (activityType == ActivityType.walkingRunning ||
            activityType == ActivityType.hiking)) {
      factors.add(const JudgmentFactor(label: '자외선 매우 높음', contribution: -12));
    }
    if (activityType == ActivityType.laundry) {
      if (metrics.humidity != null) {
        factors.add(
          JudgmentFactor(
            label: metrics.humidity! >= 80 ? '습도 높음' : '건조 여건 양호',
            contribution: metrics.humidity! >= 80 ? -20 : 8,
          ),
        );
      }
      if (request.options.variant.contains('두꺼운')) {
        factors.add(
          JudgmentFactor(
            label: '두꺼운 빨래 건조 부담',
            contribution: (metrics.windSpeedMs ?? 4) < 4 ? -12 : -5,
          ),
        );
      } else if (request.options.variant.contains('베란다')) {
        factors.add(const JudgmentFactor(label: '베란다 건조 환경', contribution: -4));
      }
    }
    if (activityType == ActivityType.carWash &&
        (metrics.precipProbability ?? 0) >= 30) {
      factors.add(
        const JudgmentFactor(label: '세차 후 강수 가능성', contribution: -22),
      );
    }
    if (activityType == ActivityType.walkingRunning) {
      final intensityContribution = switch (request.options.variant) {
        '걷기 · 보통' => 4,
        '달리기 · 강하게' => -8,
        _ => 0,
      };
      if (intensityContribution != 0) {
        factors.add(
          JudgmentFactor(
            label: request.options.variant,
            contribution: intensityContribution,
          ),
        );
      }
    }
    if (activityType == ActivityType.hiking) {
      final experienceContribution = switch (request.options.variant) {
        '초보' => -5,
        '숙련' => 2,
        _ => 0,
      };
      factors.add(
        JudgmentFactor(
          label: '사용자 수준 ${request.options.variant}',
          contribution: experienceContribution,
        ),
      );
    }
    return factors;
  }

  ActivityCoverageLevel _coverageLevel(
    ActivityJudgmentRequest request,
    _WindowMetrics metrics,
  ) {
    if (request.activityType == ActivityType.hiking ||
        metrics.apparentTemperatureCelsius == null ||
        metrics.uvIndex == null ||
        (request.activityType == ActivityType.laundry &&
            metrics.humidity == null)) {
      return ActivityCoverageLevel.partial;
    }
    return ActivityCoverageLevel.weatherOnly;
  }

  String _summary(int score, ActivitySafetyLevel safetyLevel) {
    if (safetyLevel == ActivitySafetyLevel.stop) {
      return '위험 기상 조건으로 활동 중단을 권고합니다.';
    }
    if (score >= 80) return '선택한 시간은 활동하기 매우 좋습니다.';
    if (score >= 65) return '대체로 활동하기 좋은 조건입니다.';
    if (score >= 45) return '주의 요인을 확인하면 활동할 수 있습니다.';
    return '조건이 좋지 않아 시간 변경을 권합니다.';
  }

  String _actionFor(ActivitySafetyLevel safetyLevel) {
    return switch (safetyLevel) {
      ActivitySafetyLevel.allowed => '예보 변동 여부를 출발 전에 한 번 더 확인하세요.',
      ActivitySafetyLevel.caution => '부정 요인을 확인하고 활동 시간이나 강도를 조정하세요.',
      ActivitySafetyLevel.stop => '활동을 미루고 기상 상황이 안정된 뒤 다시 판단하세요.',
      ActivitySafetyLevel.limited => '필수 자료가 확보된 뒤 다시 판단하세요.',
    };
  }

  String _forecastPendingAction(
    ActivityJudgmentRequest request,
    WeatherEntity weather,
    DateTime now,
  ) {
    if (weather.hourlyForecasts.isEmpty) {
      return '시간별 예보가 확보된 뒤 다시 판단하세요.';
    }
    final lastForecastAt = weather.hourlyForecasts
        .map((forecast) => forecast.time)
        .reduce((left, right) => left.isAfter(right) ? left : right);
    final currentHorizon = lastForecastAt.difference(now);
    final forecastAvailableAt = request.evidenceEndsAt.subtract(currentHorizon);
    return '현재 예보는 ${_formatDateTime(lastForecastAt)}까지입니다. '
        '${_formatDateTime(forecastAvailableAt)} 이후 다시 판단하세요.';
  }

  String _formatDateTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }

  ActivityJudgment _limited({
    required ActivityJudgmentRequest request,
    required WeatherEntity weather,
    required String message,
    required DateTime now,
    required String? existingId,
    String action = '날씨를 갱신하거나 지원되는 시간과 장소로 다시 판단하세요.',
    ActivityPlanStatus planStatus = ActivityPlanStatus.limited,
    ActivityJudgmentMode judgmentMode = ActivityJudgmentMode.detailed,
  }) {
    return ActivityJudgment(
      id:
          existingId ??
          '${request.activityType.name}-${now.microsecondsSinceEpoch}',
      request: request,
      score: null,
      safetyLevel: ActivitySafetyLevel.limited,
      coverageLevel: ActivityCoverageLevel.unavailable,
      summary: message,
      action: action,
      factors: const [],
      calculatedAt: now,
      dataObservedAt: weather.observedAt,
      expiresAt: now,
      sources: const ['예감씨 현재 위치 날씨 캐시', calculationVersion],
      planStatus: planStatus,
      judgmentMode: judgmentMode,
      confidence: judgmentMode == ActivityJudgmentMode.pending
          ? ActivityConfidence.unavailable
          : ActivityConfidence.low,
    );
  }
}

class _WindowMetrics {
  const _WindowMetrics({
    required this.averageTemperatureCelsius,
    required this.apparentTemperatureCelsius,
    required this.windSpeedMs,
    required this.precipProbability,
    required this.uvIndex,
    required this.humidity,
    required this.hasThunderstorm,
    required this.hasHeavyRain,
  });

  factory _WindowMetrics.from(
    List<HourlyForecast> samples,
    WeatherEntity current,
  ) {
    final conditions = samples.map((sample) => sample.condition).toSet();
    if (samples.isEmpty) conditions.add(current.condition);
    final forecastPrecipitation = samples
        .map((sample) => sample.precipProbability)
        .whereType<double>();
    final forecastWind = samples
        .map((sample) => sample.windSpeedMs)
        .whereType<double>();
    final forecastTemperatures = samples.map((sample) => sample.tempCelsius);
    final usesCurrentMetrics =
        samples.isEmpty ||
        samples.every(
          (sample) =>
              sample.time.difference(DateTime.now()).abs() <=
              ActivityJudgmentCalculator._currentMetricWindow,
        );
    return _WindowMetrics(
      averageTemperatureCelsius: forecastTemperatures.isEmpty
          ? current.tempCelsius
          : forecastTemperatures.reduce((left, right) => left + right) /
                forecastTemperatures.length,
      apparentTemperatureCelsius: usesCurrentMetrics
          ? current.feelsLikeCelsius
          : null,
      windSpeedMs: forecastWind.isEmpty
          ? (usesCurrentMetrics ? current.windSpeedMs : null)
          : forecastWind.reduce((left, right) => left > right ? left : right),
      precipProbability: forecastPrecipitation.isEmpty
          ? (usesCurrentMetrics ? current.precipProbability : null)
          : forecastPrecipitation.reduce(
              (left, right) => left > right ? left : right,
            ),
      uvIndex: usesCurrentMetrics ? current.uvIndex : null,
      humidity: usesCurrentMetrics ? current.humidity : null,
      hasThunderstorm:
          conditions.contains(WeatherCondition.thunderstorm) ||
          conditions.contains(WeatherCondition.rainThunder),
      hasHeavyRain: conditions.contains(WeatherCondition.heavyRain),
    );
  }

  final double averageTemperatureCelsius;
  final double? apparentTemperatureCelsius;
  final double? windSpeedMs;
  final double? precipProbability;
  final int? uvIndex;
  final int? humidity;
  final bool hasThunderstorm;
  final bool hasHeavyRain;
}

class _PlanningEvidenceWindow {
  const _PlanningEvidenceWindow({
    required this.maxPrecipProbability,
    required this.minTemperature,
    required this.maxTemperature,
    required this.conditions,
  });

  factory _PlanningEvidenceWindow.from({
    required ActivityJudgmentRequest request,
    required List<DailyForecast> forecasts,
  }) {
    final precipitationProbabilities = <double>[];
    final temperatures = <double>[];
    final conditions = <WeatherCondition>[];

    for (final forecast in forecasts) {
      final dayStart = DateTime(
        forecast.date.year,
        forecast.date.month,
        forecast.date.day,
      );
      final noon = dayStart.add(const Duration(hours: 12));
      final dayEnd = dayStart.add(const Duration(days: 1));
      final includesMorning = _overlaps(
        request.startsAt,
        request.evidenceEndsAt,
        dayStart,
        noon,
      );
      final includesAfternoon = _overlaps(
        request.startsAt,
        request.evidenceEndsAt,
        noon,
        dayEnd,
      );

      if (includesMorning) {
        precipitationProbabilities.add(
          forecast.amPrecipProbability ?? forecast.precipProbability,
        );
        conditions.add(forecast.amCondition ?? forecast.condition);
        if (forecast.temperatureAvailable) {
          temperatures.add(
            forecast.amTempCelsius ??
                _estimateDayPartTemperature(forecast, isMorning: true),
          );
        }
      }
      if (includesAfternoon) {
        precipitationProbabilities.add(
          forecast.pmPrecipProbability ?? forecast.precipProbability,
        );
        conditions.add(forecast.pmCondition ?? forecast.condition);
        if (forecast.temperatureAvailable) {
          temperatures.add(
            forecast.pmTempCelsius ??
                _estimateDayPartTemperature(forecast, isMorning: false),
          );
        }
      }
    }

    return _PlanningEvidenceWindow(
      maxPrecipProbability: precipitationProbabilities.isEmpty
          ? 0
          : precipitationProbabilities.reduce(math.max),
      minTemperature: temperatures.isEmpty
          ? null
          : temperatures.reduce(math.min),
      maxTemperature: temperatures.isEmpty
          ? null
          : temperatures.reduce(math.max),
      conditions: conditions,
    );
  }

  final double maxPrecipProbability;
  final double? minTemperature;
  final double? maxTemperature;
  final List<WeatherCondition> conditions;

  bool get hasTemperatureData =>
      minTemperature != null && maxTemperature != null;

  bool get hasWetCondition => conditions.any(_isWet);

  static bool _overlaps(
    DateTime requestedStart,
    DateTime requestedEnd,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    return periodStart.isBefore(requestedEnd) &&
        periodEnd.isAfter(requestedStart);
  }

  static double _estimateDayPartTemperature(
    DailyForecast forecast, {
    required bool isMorning,
  }) {
    final range = forecast.tempMax - forecast.tempMin;
    return isMorning
        ? forecast.tempMin + range * 0.35
        : forecast.tempMin + range * 0.8;
  }

  static bool _isWet(WeatherCondition condition) {
    return condition == WeatherCondition.slightRain ||
        condition == WeatherCondition.rainy ||
        condition == WeatherCondition.heavyRain ||
        condition == WeatherCondition.thunderstorm ||
        condition == WeatherCondition.rainThunder ||
        condition == WeatherCondition.lightSnow ||
        condition == WeatherCondition.snowy ||
        condition == WeatherCondition.sleet;
  }
}
