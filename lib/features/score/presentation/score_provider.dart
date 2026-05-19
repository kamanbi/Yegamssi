import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../weather/presentation/weather_provider.dart';
import '../domain/calculators/kr_score_calculator.dart';
import '../domain/entities/activity_score.dart';

part 'score_provider.g.dart';

/// 현재 날씨 기반 활동 점수 provider.
/// 국가 코드에 따라 가중치 계산기를 자동 선택.
@Riverpod(keepAlive: true)
Future<ActivityScore> currentScore(Ref ref) async {
  final weather = await ref.watch(currentWeatherProvider.future);
  return const KrScoreCalculator().calculate(weather);
}
