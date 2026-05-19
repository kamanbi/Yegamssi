import '../../../weather/domain/entities/weather_entity.dart';
import '../entities/activity_score.dart';

/// 활동 점수 계산기 추상 인터페이스
/// 국가별 가중치가 다르므로 각 국가별 구현체가 존재함
abstract interface class ScoreCalculator {
  ActivityScore calculate(WeatherEntity weather);
}
