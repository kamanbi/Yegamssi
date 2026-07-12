import '../../../weather/domain/entities/weather_entity.dart';
import '../entities/activity_score.dart';
import 'score_calculator.dart';

/// 글로벌 기본 활동 점수 계산기
class GlobalScoreCalculator implements ScoreCalculator {
  const GlobalScoreCalculator();

  static const _maxAirDeduction = 35;

  @override
  ActivityScore calculate(WeatherEntity weather) {
    int score = 100;
    int rainDeduction = 0;
    int windDeduction = 0;
    int heatDeduction = 0;
    final dustDeduction = _dustDeduction(weather.pm10, weather.pm25);
    final ozoneDeduction = _ozoneDeduction(weather.o3);

    if (weather.precipProbability >= 0.7) {
      rainDeduction = 40;
    } else if (weather.precipProbability >= 0.4) {
      rainDeduction = 20;
    }

    if (weather.windSpeedMs >= 14) {
      windDeduction = 20;
    } else if (weather.windSpeedMs >= 9) {
      windDeduction = 10;
    }

    if (weather.tempCelsius >= 35 || weather.tempCelsius <= -10) {
      heatDeduction = 30;
    } else if (weather.tempCelsius >= 30 || weather.tempCelsius <= -5) {
      heatDeduction = 15;
    }

    score -=
        rainDeduction +
        windDeduction +
        heatDeduction +
        dustDeduction +
        ozoneDeduction;

    return ActivityScore.fromRaw(
      score,
      ScoreBreakdown(
        rainDeduction: rainDeduction,
        windDeduction: windDeduction,
        heatDeduction: heatDeduction,
        dustDeduction: dustDeduction,
        ozoneDeduction: ozoneDeduction,
      ),
    );
  }

  int _dustDeduction(double? pm10, double? pm25) {
    int deduction = 0;
    if (pm25 != null) {
      if (pm25 >= 75) {
        deduction += 25;
      } else if (pm25 >= 35) {
        deduction += 15;
      } else if (pm25 >= 15) {
        deduction += 6;
      }
    }
    if (pm10 != null) {
      if (pm10 >= 150) {
        deduction += 25;
      } else if (pm10 >= 80) {
        deduction += 15;
      } else if (pm10 >= 30) {
        deduction += 6;
      }
    }
    return deduction.clamp(0, _maxAirDeduction);
  }

  int _ozoneDeduction(double? o3) {
    if (o3 == null) return 0;
    if (o3 > 0.150) return 20;
    if (o3 > 0.090) return 12;
    if (o3 > 0.060) return 5;
    return 0;
  }
}
