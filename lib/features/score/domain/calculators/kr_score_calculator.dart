import '../../../weather/domain/entities/weather_entity.dart';
import '../entities/activity_score.dart';
import 'score_calculator.dart';

class KrScoreCalculator implements ScoreCalculator {
  const KrScoreCalculator();

  static const _maxRainDeduction = 90;
  static const _maxDustDeduction = 35;

  @override
  ActivityScore calculate(WeatherEntity weather) {
    int score = 100;
    int rainDeduction = 0;
    int windDeduction = 0;
    int heatDeduction = 0;
    int dustDeduction = 0;
    int uvDeduction = 0;
    int ozoneDeduction = 0;

    rainDeduction = _rainProbabilityDeduction(weather.precipProbability) +
        _precipitationConditionBonus(weather.condition);
    if (rainDeduction > _maxRainDeduction) {
      rainDeduction = _maxRainDeduction;
    }

    windDeduction = _windDeduction(weather.windSpeedMs);
    heatDeduction = _temperatureDeduction(weather.tempCelsius);
    dustDeduction = _dustDeduction(weather.pm10, weather.pm25);
    uvDeduction = _uvDeduction(weather.uvIndex);
    ozoneDeduction = _ozoneDeduction(weather.o3);

    score -= rainDeduction +
        windDeduction +
        heatDeduction +
        dustDeduction +
        uvDeduction +
        ozoneDeduction;

    return ActivityScore.fromRaw(
      score,
      ScoreBreakdown(
        rainDeduction: rainDeduction,
        windDeduction: windDeduction,
        heatDeduction: heatDeduction,
        dustDeduction: dustDeduction,
        uvDeduction: uvDeduction,
        ozoneDeduction: ozoneDeduction,
      ),
    );
  }

  int _rainProbabilityDeduction(double probability) {
    if (probability >= 0.9) return 70;
    if (probability >= 0.8) return 60;
    if (probability >= 0.7) return 50;
    if (probability >= 0.6) return 40;
    return 0;
  }

  int _precipitationConditionBonus(WeatherCondition condition) {
    return switch (condition) {
      WeatherCondition.slightRain => 5,
      WeatherCondition.rainy => 10,
      WeatherCondition.heavyRain => 20,
      WeatherCondition.thunderstorm || WeatherCondition.rainThunder => 20,
      WeatherCondition.lightSnow => 10,
      WeatherCondition.snowy => 12,
      WeatherCondition.sleet => 5,
      _ => 0,
    };
  }

  int _windDeduction(double windSpeedMs) {
    if (windSpeedMs >= 14) {
      return 30;
    }
    if (windSpeedMs >= 9) {
      return 18;
    }
    if (windSpeedMs >= 5) {
      return 8;
    }
    return 0;
  }

  int _temperatureDeduction(double tempCelsius) {
    if (tempCelsius >= 35 || tempCelsius <= -10) {
      return 35;
    }
    if (tempCelsius >= 30 || tempCelsius <= -5) {
      return 18;
    }
    if (tempCelsius >= 28 || tempCelsius <= 0) {
      return 8;
    }
    return 0;
  }

  int _dustDeduction(double? pm10, double? pm25) {
    int deduction = 0;

    if (pm10 != null) {
      if (pm10 >= 151) {
        deduction += 30;
      } else if (pm10 >= 81) {
        deduction += 18;
      } else if (pm10 >= 31) {
        deduction += 8;
      }
    }

    if (pm25 != null) {
      if (pm25 >= 76) {
        deduction += 25;
      } else if (pm25 >= 36) {
        deduction += 15;
      } else if (pm25 >= 16) {
        deduction += 6;
      }
    }

    if (deduction > _maxDustDeduction) {
      return _maxDustDeduction;
    }
    return deduction;
  }

  int _uvDeduction(int uvIndex) {
    if (uvIndex >= 11) {
      return 18;
    }
    if (uvIndex >= 8) {
      return 10;
    }
    if (uvIndex >= 6) {
      return 5;
    }
    return 0;
  }

  int _ozoneDeduction(double? o3) {
    if (o3 == null) {
      return 0;
    }
    if (o3 > 0.150) {
      return 25;
    }
    if (o3 > 0.090) {
      return 15;
    }
    if (o3 > 0.030) {
      return 5;
    }
    return 0;
  }
}
