import 'dart:math' as math;

enum ActivityType { seaFishing, walkingRunning, hiking, laundry, carWash }

enum ActivitySafetyLevel { allowed, caution, stop, limited }

enum ActivityCoverageLevel { full, partial, weatherOnly, unavailable }

enum ActivityPlanStatus { forecastPending, ready, limited, completed }

enum ActivityJudgmentMode { detailed, planning, pending }

enum ActivityConfidence { high, medium, low, unavailable }

enum ActivityDestinationKind {
  officialIndexStation,
  officialFishingPort,
  customLocation,
  mountain,
}

class ActivityDestination {
  const ActivityDestination({
    required this.id,
    required this.name,
    required this.areaName,
    required this.latitude,
    required this.longitude,
    required this.source,
    String? officialName,
    this.kind = ActivityDestinationKind.customLocation,
    this.supportedOptions = const [],
    this.aliases = const [],
  }) : officialName = officialName ?? name;

  final String id;
  final String name;
  final String areaName;
  final double latitude;
  final double longitude;
  final String source;
  final String officialName;
  final ActivityDestinationKind kind;
  final List<String> supportedOptions;
  final List<String> aliases;

  bool get supportsOfficialFishingIndex =>
      kind == ActivityDestinationKind.officialIndexStation;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'areaName': areaName,
    'latitude': latitude,
    'longitude': longitude,
    'source': source,
    'officialName': officialName,
    'kind': kind.name,
    'supportedOptions': supportedOptions,
    'aliases': aliases,
  };

  factory ActivityDestination.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final source = json['source'] as String;
    return ActivityDestination(
      id: id,
      name: json['name'] as String,
      areaName: json['areaName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      source: source,
      officialName: json['officialName'] as String?,
      kind: _destinationKindFromJson(json['kind'], id: id, source: source),
      supportedOptions: (json['supportedOptions'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      aliases: (json['aliases'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }
}

class MountainSearchResult {
  const MountainSearchResult({
    required this.id,
    required this.name,
    required this.address,
    required this.heightMeters,
  });

  final String id;
  final String name;
  final String address;
  final int? heightMeters;
}

class SeaFishingEvidence {
  const SeaFishingEvidence({
    required this.stationName,
    required this.targetFish,
    required this.forecastPeriod,
    required this.officialIndex,
    required this.latitude,
    required this.longitude,
    required this.maxWindSpeedMs,
    required this.maxWaveHeightM,
    required this.maxWaterTemperatureC,
    required this.tideDescription,
    required this.forecastStartsAt,
    required this.forecastEndsAt,
  });

  final String stationName;
  final String targetFish;
  final String forecastPeriod;
  final String officialIndex;
  final double latitude;
  final double longitude;
  final double? maxWindSpeedMs;
  final double? maxWaveHeightM;
  final double? maxWaterTemperatureC;
  final String tideDescription;
  final DateTime forecastStartsAt;
  final DateTime forecastEndsAt;

  Map<String, dynamic> toJson() => {
    'stationName': stationName,
    'targetFish': targetFish,
    'forecastPeriod': forecastPeriod,
    'officialIndex': officialIndex,
    'latitude': latitude,
    'longitude': longitude,
    'maxWindSpeedMs': maxWindSpeedMs,
    'maxWaveHeightM': maxWaveHeightM,
    'maxWaterTemperatureC': maxWaterTemperatureC,
    'tideDescription': tideDescription,
    'forecastStartsAt': forecastStartsAt.toIso8601String(),
    'forecastEndsAt': forecastEndsAt.toIso8601String(),
  };

  factory SeaFishingEvidence.fromJson(Map<String, dynamic> json) {
    return SeaFishingEvidence(
      stationName: json['stationName'] as String,
      targetFish: json['targetFish'] as String,
      forecastPeriod: json['forecastPeriod'] as String,
      officialIndex: json['officialIndex'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      maxWindSpeedMs: (json['maxWindSpeedMs'] as num?)?.toDouble(),
      maxWaveHeightM: (json['maxWaveHeightM'] as num?)?.toDouble(),
      maxWaterTemperatureC: (json['maxWaterTemperatureC'] as num?)?.toDouble(),
      tideDescription: json['tideDescription'] as String,
      forecastStartsAt: DateTime.parse(json['forecastStartsAt'] as String),
      forecastEndsAt: DateTime.parse(json['forecastEndsAt'] as String),
    );
  }
}

class MidSeaForecastEvidence {
  const MidSeaForecastEvidence({
    required this.seaRegionId,
    required this.seaRegionName,
    required this.forecastPeriod,
    required this.weatherSummary,
    required this.minWaveHeightM,
    required this.maxWaveHeightM,
    required this.forecastStartsAt,
    required this.forecastEndsAt,
  });

  final String seaRegionId;
  final String seaRegionName;
  final String forecastPeriod;
  final String weatherSummary;
  final double minWaveHeightM;
  final double maxWaveHeightM;
  final DateTime forecastStartsAt;
  final DateTime forecastEndsAt;

  Map<String, dynamic> toJson() => {
    'seaRegionId': seaRegionId,
    'seaRegionName': seaRegionName,
    'forecastPeriod': forecastPeriod,
    'weatherSummary': weatherSummary,
    'minWaveHeightM': minWaveHeightM,
    'maxWaveHeightM': maxWaveHeightM,
    'forecastStartsAt': forecastStartsAt.toIso8601String(),
    'forecastEndsAt': forecastEndsAt.toIso8601String(),
  };

  factory MidSeaForecastEvidence.fromJson(Map<String, dynamic> json) {
    return MidSeaForecastEvidence(
      seaRegionId: json['seaRegionId'] as String,
      seaRegionName: json['seaRegionName'] as String,
      forecastPeriod: json['forecastPeriod'] as String,
      weatherSummary: json['weatherSummary'] as String,
      minWaveHeightM: (json['minWaveHeightM'] as num).toDouble(),
      maxWaveHeightM: (json['maxWaveHeightM'] as num).toDouble(),
      forecastStartsAt: DateTime.parse(json['forecastStartsAt'] as String),
      forecastEndsAt: DateTime.parse(json['forecastEndsAt'] as String),
    );
  }
}

class ForestFireEvidence {
  const ForestFireEvidence({
    required this.forecastAt,
    required this.maxRiskIndex,
    required this.coverageName,
  });

  final DateTime forecastAt;
  final int maxRiskIndex;
  final String coverageName;

  Map<String, dynamic> toJson() => {
    'forecastAt': forecastAt.toIso8601String(),
    'maxRiskIndex': maxRiskIndex,
    'coverageName': coverageName,
  };

  factory ForestFireEvidence.fromJson(Map<String, dynamic> json) {
    return ForestFireEvidence(
      forecastAt: DateTime.parse(json['forecastAt'] as String),
      maxRiskIndex: (json['maxRiskIndex'] as num).toInt(),
      coverageName: json['coverageName'] as String,
    );
  }
}

class WeatherWarningEvidence {
  const WeatherWarningEvidence({
    required this.issuedAt,
    required this.effectiveAt,
    required this.activeWarnings,
  });

  final DateTime issuedAt;
  final DateTime effectiveAt;
  final List<ActiveWeatherWarning> activeWarnings;

  Map<String, dynamic> toJson() => {
    'issuedAt': issuedAt.toIso8601String(),
    'effectiveAt': effectiveAt.toIso8601String(),
    'activeWarnings': activeWarnings.map((item) => item.toJson()).toList(),
  };

  factory WeatherWarningEvidence.fromJson(Map<String, dynamic> json) {
    return WeatherWarningEvidence(
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      effectiveAt: DateTime.parse(json['effectiveAt'] as String),
      activeWarnings: (json['activeWarnings'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ActiveWeatherWarning.fromJson)
          .toList(growable: false),
    );
  }
}

class ActiveWeatherWarning {
  const ActiveWeatherWarning({required this.phenomenon, required this.areas});

  final String phenomenon;
  final List<String> areas;

  Map<String, dynamic> toJson() => {'phenomenon': phenomenon, 'areas': areas};

  factory ActiveWeatherWarning.fromJson(Map<String, dynamic> json) {
    return ActiveWeatherWarning(
      phenomenon: json['phenomenon'] as String,
      areas: (json['areas'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }
}

enum TideEventType { highTide, lowTide }

class TideEventEntry {
  const TideEventEntry({
    required this.type,
    required this.time,
    required this.levelCm,
  });

  final TideEventType type;
  final DateTime time;
  final int levelCm;

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'time': time.toIso8601String(),
    'levelCm': levelCm,
  };

  factory TideEventEntry.fromJson(Map<String, dynamic> json) {
    return TideEventEntry(
      type: TideEventType.values.byName(json['type'] as String),
      time: DateTime.parse(json['time'] as String),
      levelCm: (json['levelCm'] as num).toInt(),
    );
  }
}

/// 조석예보(고·저조) 근거. 관측·예보 지점 기준 만조·간조 시각과 조위(cm)를 담는다.
class TideEvidence {
  const TideEvidence({
    required this.stationName,
    required this.events,
    required this.forecastAt,
  });

  final String stationName;

  /// 요청 구간을 포함하는 고조·저조 이벤트 목록(보통 최대 4건).
  final List<TideEventEntry> events;
  final DateTime forecastAt;

  Map<String, dynamic> toJson() => {
    'stationName': stationName,
    'events': events.map((event) => event.toJson()).toList(),
    'forecastAt': forecastAt.toIso8601String(),
  };

  factory TideEvidence.fromJson(Map<String, dynamic> json) {
    return TideEvidence(
      stationName: json['stationName'] as String,
      events: (json['events'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TideEventEntry.fromJson)
          .toList(growable: false),
      forecastAt: DateTime.parse(json['forecastAt'] as String),
    );
  }
}

/// 조류예보 근거. 요청 구간 내 최대 유속과 방향(창조/낙조)을 담는다.
/// 최강창낙조·전류 시각은 별도 API 연동 전까지 null로 남긴다.
class CurrentEvidence {
  const CurrentEvidence({
    required this.stationName,
    required this.maxSpeedCms,
    required this.direction,
    this.maxFloodAt,
    this.maxEbbAt,
    this.slackAt,
  });

  final String stationName;
  final double maxSpeedCms;

  /// 창조(밀물) 또는 낙조(썰물).
  final String direction;
  final DateTime? maxFloodAt;
  final DateTime? maxEbbAt;
  final DateTime? slackAt;

  Map<String, dynamic> toJson() => {
    'stationName': stationName,
    'maxSpeedCms': maxSpeedCms,
    'direction': direction,
    'maxFloodAt': maxFloodAt?.toIso8601String(),
    'maxEbbAt': maxEbbAt?.toIso8601String(),
    'slackAt': slackAt?.toIso8601String(),
  };

  factory CurrentEvidence.fromJson(Map<String, dynamic> json) {
    return CurrentEvidence(
      stationName: json['stationName'] as String,
      maxSpeedCms: (json['maxSpeedCms'] as num).toDouble(),
      direction: json['direction'] as String,
      maxFloodAt: (json['maxFloodAt'] as String?) != null
          ? DateTime.parse(json['maxFloodAt'] as String)
          : null,
      maxEbbAt: (json['maxEbbAt'] as String?) != null
          ? DateTime.parse(json['maxEbbAt'] as String)
          : null,
      slackAt: (json['slackAt'] as String?) != null
          ? DateTime.parse(json['slackAt'] as String)
          : null,
    );
  }
}

class MarineTimeSeriesPoint {
  const MarineTimeSeriesPoint({required this.time, required this.value});

  final DateTime time;
  final double value;

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'value': value,
  };

  factory MarineTimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    return MarineTimeSeriesPoint(
      time: DateTime.parse(json['time'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }
}

enum MarineTimeSeriesKind { waveHeight, waterTemperature }

/// 파고·수온 등 3시간 간격 시계열 근거. `kind`로 파고(m)와 수온(°C)을 구분한다.
class MarineTimeSeriesEvidence {
  const MarineTimeSeriesEvidence({
    required this.kind,
    required this.stationName,
    required this.points,
  });

  final MarineTimeSeriesKind kind;
  final String stationName;
  final List<MarineTimeSeriesPoint> points;

  double? get maxValue => points.isEmpty
      ? null
      : points.map((point) => point.value).reduce(math.max);

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'stationName': stationName,
    'points': points.map((point) => point.toJson()).toList(),
  };

  factory MarineTimeSeriesEvidence.fromJson(Map<String, dynamic> json) {
    return MarineTimeSeriesEvidence(
      kind: MarineTimeSeriesKind.values.byName(json['kind'] as String),
      stationName: json['stationName'] as String,
      points: (json['points'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(MarineTimeSeriesPoint.fromJson)
          .toList(growable: false),
    );
  }
}

/// 어종별 포획금지기간·금지체장. 수산자원관리법 시행령 별표 기반 정적 자산에서 로드한다.
class FishRegulationEvidence {
  const FishRegulationEvidence({
    required this.fishName,
    required this.inhibitionPeriodLabel,
    this.prohibitedSizeCm,
    required this.source,
  });

  final String fishName;

  /// 예: "05.01~05.31(전지역)". 기간이 여러 개면 세미콜론으로 이어 붙인다.
  final String inhibitionPeriodLabel;

  /// 금지체장(cm 이하). 규정이 없으면 null.
  final String? prohibitedSizeCm;
  final String source;

  Map<String, dynamic> toJson() => {
    'fishName': fishName,
    'inhibitionPeriodLabel': inhibitionPeriodLabel,
    'prohibitedSizeCm': prohibitedSizeCm,
    'source': source,
  };

  factory FishRegulationEvidence.fromJson(Map<String, dynamic> json) {
    return FishRegulationEvidence(
      fishName: json['fishName'] as String,
      inhibitionPeriodLabel: json['inhibitionPeriodLabel'] as String,
      prohibitedSizeCm: json['prohibitedSizeCm'] as String?,
      source: json['source'] as String,
    );
  }
}

class ActivityOptions {
  const ActivityOptions({
    this.variant = '',
    this.intensity = '',
    this.experience = '',
    this.secondary = '',
  });

  final String variant;
  final String intensity;
  final String experience;
  final String secondary;

  Map<String, dynamic> toJson() => {
    'variant': variant,
    'intensity': intensity,
    'experience': experience,
    'secondary': secondary,
  };

  factory ActivityOptions.fromJson(Map<String, dynamic> json) {
    return ActivityOptions(
      variant: json['variant'] as String? ?? '',
      intensity: json['intensity'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      secondary: json['secondary'] as String? ?? '',
    );
  }
}

class ActivityJudgmentRequest {
  const ActivityJudgmentRequest({
    required this.activityType,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.startsAt,
    required this.durationMinutes,
    required this.options,
    this.destinationId = '',
    this.destinationSource = '',
    this.destinationAreaName = '',
    this.destinationKind,
  });

  final ActivityType activityType;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime startsAt;
  final int durationMinutes;
  final ActivityOptions options;
  final String destinationId;
  final String destinationSource;
  final String destinationAreaName;
  final ActivityDestinationKind? destinationKind;

  bool get supportsOfficialFishingIndex =>
      destinationKind == ActivityDestinationKind.officialIndexStation;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));

  DateTime get evidenceEndsAt {
    if (activityType != ActivityType.carWash) return endsAt;
    final hours = options.variant.contains('48시간') ? 48 : 24;
    return startsAt.add(Duration(hours: hours));
  }

  Map<String, dynamic> toJson() => {
    'activityType': activityType.name,
    'locationName': locationName,
    'latitude': latitude,
    'longitude': longitude,
    'startsAt': startsAt.toIso8601String(),
    'durationMinutes': durationMinutes,
    'options': options.toJson(),
    'destinationId': destinationId,
    'destinationSource': destinationSource,
    'destinationAreaName': destinationAreaName,
    'destinationKind': destinationKind?.name,
  };

  factory ActivityJudgmentRequest.fromJson(Map<String, dynamic> json) {
    final destinationId = json['destinationId'] as String? ?? '';
    final destinationSource = json['destinationSource'] as String? ?? '';
    return ActivityJudgmentRequest(
      activityType: ActivityType.values.byName(json['activityType'] as String),
      locationName: json['locationName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      startsAt: DateTime.parse(json['startsAt'] as String),
      durationMinutes: json['durationMinutes'] as int,
      options: ActivityOptions.fromJson(
        json['options'] as Map<String, dynamic>,
      ),
      destinationId: destinationId,
      destinationSource: destinationSource,
      destinationAreaName: json['destinationAreaName'] as String? ?? '',
      destinationKind: destinationId.isEmpty
          ? null
          : _destinationKindFromJson(
              json['destinationKind'],
              id: destinationId,
              source: destinationSource,
            ),
    );
  }
}

ActivityDestinationKind _destinationKindFromJson(
  Object? raw, {
  required String id,
  required String source,
}) {
  final name = raw?.toString();
  if (name != null) {
    for (final kind in ActivityDestinationKind.values) {
      if (kind.name == name) return kind;
    }
  }
  if (source.contains('바다낚시지수')) {
    return ActivityDestinationKind.officialIndexStation;
  }
  if (id.startsWith('mof-port:') || id.startsWith('fipa-port:')) {
    return ActivityDestinationKind.officialFishingPort;
  }
  if (id.startsWith('mountain:')) {
    return ActivityDestinationKind.mountain;
  }
  return ActivityDestinationKind.customLocation;
}

class JudgmentFactor {
  const JudgmentFactor({required this.label, required this.contribution});

  final String label;
  final int contribution;

  Map<String, dynamic> toJson() => {
    'label': label,
    'contribution': contribution,
  };

  factory JudgmentFactor.fromJson(Map<String, dynamic> json) {
    return JudgmentFactor(
      label: json['label'] as String,
      contribution: json['contribution'] as int,
    );
  }
}

class ActivityJudgment {
  const ActivityJudgment({
    required this.id,
    required this.request,
    required this.score,
    required this.safetyLevel,
    required this.coverageLevel,
    required this.summary,
    required this.action,
    required this.factors,
    required this.calculatedAt,
    required this.dataObservedAt,
    required this.expiresAt,
    required this.sources,
    this.evidenceValidFrom,
    this.evidenceValidUntil,
    this.planStatus = ActivityPlanStatus.ready,
    this.isPinned = false,
    this.judgmentMode = ActivityJudgmentMode.detailed,
    this.confidence = ActivityConfidence.high,
    this.scoreRangeMin,
    this.scoreRangeMax,
    this.unverifiedFactors = const [],
    this.alternativeWindows = const [],
  });

  static const schemaVersion = 4;

  final String id;
  final ActivityJudgmentRequest request;
  final int? score;
  final ActivitySafetyLevel safetyLevel;
  final ActivityCoverageLevel coverageLevel;
  final String summary;
  final String action;
  final List<JudgmentFactor> factors;
  final DateTime calculatedAt;
  final DateTime dataObservedAt;
  final DateTime expiresAt;
  final List<String> sources;
  final DateTime? evidenceValidFrom;
  final DateTime? evidenceValidUntil;
  final ActivityPlanStatus planStatus;
  final bool isPinned;
  final ActivityJudgmentMode judgmentMode;
  final ActivityConfidence confidence;
  final int? scoreRangeMin;
  final int? scoreRangeMax;
  final List<String> unverifiedFactors;
  final List<String> alternativeWindows;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  ActivityJudgment copyWith({bool? isPinned}) {
    return ActivityJudgment(
      id: id,
      request: request,
      score: score,
      safetyLevel: safetyLevel,
      coverageLevel: coverageLevel,
      summary: summary,
      action: action,
      factors: factors,
      calculatedAt: calculatedAt,
      dataObservedAt: dataObservedAt,
      expiresAt: expiresAt,
      sources: sources,
      evidenceValidFrom: evidenceValidFrom,
      evidenceValidUntil: evidenceValidUntil,
      planStatus: planStatus,
      isPinned: isPinned ?? this.isPinned,
      judgmentMode: judgmentMode,
      confidence: confidence,
      scoreRangeMin: scoreRangeMin,
      scoreRangeMax: scoreRangeMax,
      unverifiedFactors: unverifiedFactors,
      alternativeWindows: alternativeWindows,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'id': id,
    'request': request.toJson(),
    'score': score,
    'safetyLevel': safetyLevel.name,
    'coverageLevel': coverageLevel.name,
    'summary': summary,
    'action': action,
    'factors': factors.map((factor) => factor.toJson()).toList(),
    'calculatedAt': calculatedAt.toIso8601String(),
    'dataObservedAt': dataObservedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'sources': sources,
    'evidenceValidFrom': evidenceValidFrom?.toIso8601String(),
    'evidenceValidUntil': evidenceValidUntil?.toIso8601String(),
    'planStatus': planStatus.name,
    'isPinned': isPinned,
    'judgmentMode': judgmentMode.name,
    'confidence': confidence.name,
    'scoreRangeMin': scoreRangeMin,
    'scoreRangeMax': scoreRangeMax,
    'unverifiedFactors': unverifiedFactors,
    'alternativeWindows': alternativeWindows,
  };

  factory ActivityJudgment.fromJson(Map<String, dynamic> json) {
    return ActivityJudgment(
      id: json['id'] as String,
      request: ActivityJudgmentRequest.fromJson(
        json['request'] as Map<String, dynamic>,
      ),
      score: json['score'] as int?,
      safetyLevel: ActivitySafetyLevel.values.byName(
        json['safetyLevel'] as String,
      ),
      coverageLevel: ActivityCoverageLevel.values.byName(
        json['coverageLevel'] as String,
      ),
      summary: json['summary'] as String,
      action: json['action'] as String,
      factors: (json['factors'] as List<dynamic>)
          .map((item) => JudgmentFactor.fromJson(item as Map<String, dynamic>))
          .toList(),
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
      dataObservedAt: DateTime.parse(json['dataObservedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      sources: (json['sources'] as List<dynamic>).cast<String>(),
      evidenceValidFrom: json['evidenceValidFrom'] == null
          ? null
          : DateTime.parse(json['evidenceValidFrom'] as String),
      evidenceValidUntil: json['evidenceValidUntil'] == null
          ? null
          : DateTime.parse(json['evidenceValidUntil'] as String),
      planStatus: ActivityPlanStatus.values.byName(
        json['planStatus'] as String? ?? ActivityPlanStatus.ready.name,
      ),
      isPinned: json['isPinned'] as bool? ?? false,
      judgmentMode: _judgmentModeFromJson(json),
      confidence: ActivityConfidence.values.byName(
        json['confidence'] as String? ?? ActivityConfidence.high.name,
      ),
      scoreRangeMin: json['scoreRangeMin'] as int?,
      scoreRangeMax: json['scoreRangeMax'] as int?,
      unverifiedFactors:
          (json['unverifiedFactors'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .toList(growable: false),
      alternativeWindows:
          (json['alternativeWindows'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .toList(growable: false),
    );
  }
}

ActivityJudgmentMode _judgmentModeFromJson(Map<String, dynamic> json) {
  final raw = json['judgmentMode'] as String?;
  if (raw != null) {
    return ActivityJudgmentMode.values.byName(raw);
  }
  return json['planStatus'] == ActivityPlanStatus.forecastPending.name
      ? ActivityJudgmentMode.pending
      : ActivityJudgmentMode.detailed;
}
