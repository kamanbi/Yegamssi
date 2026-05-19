import '../../../weather/domain/entities/weather_entity.dart';
import '../entities/activity_score.dart';
import 'score_calculator.dart';

/// 글로벌 기본 활동 점수 계산기
class GlobalScoreCalculator implements ScoreCalculator {
  const GlobalScoreCalculator();

  @override
  ActivityScore calculate(WeatherEntity weather) {
    int score = 100;

    if (weather.precipProbability >= 0.7) {
      score -= 40;
    } else if (weather.precipProbability >= 0.4) {
      score -= 20;
    }

    if (weather.windSpeedMs >= 14) {
      score -= 20;
    } else if (weather.windSpeedMs >= 9) {
      score -= 10;
    }

    if (weather.tempCelsius >= 35 || weather.tempCelsius <= -10) {
      score -= 30;
    } else if (weather.tempCelsius >= 30 || weather.tempCelsius <= -5) {
      score -= 15;
    }

    return ActivityScore.fromRaw(
      score,
      const ScoreBreakdown(),
    );
  }
}
