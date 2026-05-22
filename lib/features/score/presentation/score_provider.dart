import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/locale/country_code.dart';
import '../../../core/locale/country_resolver.dart';
import '../../weather/presentation/weather_provider.dart';
import '../domain/calculators/global_score_calculator.dart';
import '../domain/calculators/kr_score_calculator.dart';
import '../domain/entities/activity_score.dart';

part 'score_provider.g.dart';

/// 현재 날씨 기반 활동 점수 provider.
/// 국가 코드에 따라 가중치 계산기를 자동 선택.
@Riverpod(keepAlive: true)
Future<ActivityScore> currentScore(Ref ref) async {
  final weather = await ref.watch(currentWeatherProvider.future);
  final country = await ref.watch(resolvedCountryProvider.future);
  // US는 Phase 2에서 UsScoreCalculator로 교체 예정
  final calculator = switch (country) {
    CountryCode.kr => const KrScoreCalculator(),
    _ => const GlobalScoreCalculator(),
  };
  final score = calculator.calculate(weather);
  debugPrint(
    '[Score] score=${score.score} tier=${score.tier.name}'
    ' country=${country.isoCode}',
  );
  return score;
}
