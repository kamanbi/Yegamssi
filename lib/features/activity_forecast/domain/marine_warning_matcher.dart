import 'activity_models.dart';

class MarineWarningMatcher {
  static const _stopPhenomena = {
    '강풍주의보',
    '강풍경보',
    '풍랑주의보',
    '풍랑경보',
    '태풍주의보',
    '태풍경보',
    '폭풍해일주의보',
    '폭풍해일경보',
    '지진해일주의보',
    '지진해일경보',
  };

  List<ActiveWeatherWarning> relevantWarnings({
    required ActivityJudgmentRequest request,
    required WeatherWarningEvidence evidence,
    DateTime? evaluatedAt,
  }) {
    if (request.activityType != ActivityType.seaFishing) return const [];
    final now = evaluatedAt ?? DateTime.now();
    if (request.startsAt.isAfter(now.add(const Duration(hours: 6)))) {
      return const [];
    }
    final aliases = _locationAliases(request);
    final includeOffshore = request.options.variant == '선상';
    return evidence.activeWarnings
        .where((warning) {
          if (!_stopPhenomena.contains(
            warning.phenomenon.replaceAll(' ', ''),
          )) {
            return false;
          }
          return warning.areas.any((area) {
            final normalizedArea = _normalize(area);
            if (!includeOffshore && normalizedArea.contains('먼바다')) {
              return false;
            }
            return aliases.any(normalizedArea.contains);
          });
        })
        .toList(growable: false);
  }

  Set<String> _locationAliases(ActivityJudgmentRequest request) {
    final aliases = <String>{};
    final normalizedName = _normalize(
      request.locationName,
    ).replaceAll(RegExp(r'(항|북동|동남동|북측|서측|남측|북북서|\([^)]+\))'), '');
    if (normalizedName.length >= 2) aliases.add(normalizedName);

    final area = _normalize(request.destinationAreaName);
    for (final token in area.split(RegExp(r'[^가-힣]+'))) {
      final cleaned = token.replaceAll(
        RegExp(r'(특별자치도|광역시|특별시|자치시|시|군|구|읍|면|동)$'),
        '',
      );
      if (cleaned.length >= 2) aliases.add(cleaned);
    }

    aliases.addAll(_marineZonesFor(request.latitude, request.longitude));
    if (request.latitude < 34.1 &&
        request.longitude >= 125.5 &&
        request.longitude <= 127.2) {
      aliases.addAll({'제주도전해상', '제주도앞바다', '제주도'});
    }
    if (request.longitude >= 130) aliases.add('울릉도독도');
    return aliases;
  }

  Set<String> _marineZonesFor(double latitude, double longitude) {
    if (longitude >= 130) return {'동해중부'};
    if (longitude >= 128.3) {
      if (latitude >= 36) return {'동해중부'};
      if (latitude < 35.3 && longitude < 129.4) {
        return {'동해남부', '남해동부'};
      }
      return {'동해남부'};
    }
    if (latitude < 35.5 && longitude >= 127) return {'남해동부'};
    if (latitude < 35.5 && longitude >= 125.5) return {'남해서부'};
    if (longitude < 127.5) {
      return {latitude >= 36 ? '서해중부' : '서해남부'};
    }
    return const {};
  }

  String _normalize(String value) =>
      value.replaceAll(RegExp(r'[\s.·]'), '').toLowerCase();
}
