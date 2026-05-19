import '../../../weather/domain/entities/weather_entity.dart';
import '../entities/activity_score.dart';
import 'score_calculator.dart';

/// 미국 기준 활동 점수 계산기
/// UV 지수 가중치가 높음
class UsScoreCalculator implements ScoreCalculator {
  const UsScoreCalculator();

  @override
  ActivityScore calculate(WeatherEntity weather) {
    // TODO: Phase 2 구현
    throw UnimplementedError('미국 점수 계산기 구현 예정 (Phase 2)');
  }
}
