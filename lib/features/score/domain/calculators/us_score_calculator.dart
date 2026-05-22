import '../../../weather/domain/entities/weather_entity.dart';
import '../entities/activity_score.dart';
import 'score_calculator.dart';

/// 미국 기준 활동 점수 계산기
/// EPA 기준 적용: UV 3부터 감점, PM2.5 EPA 임계값, NAAQS 오존 기준
class UsScoreCalculator implements ScoreCalculator {
  const UsScoreCalculator();

  static const _maxRainDeduction = 90;
  static const _maxDustDeduction = 35;

  @override
  ActivityScore calculate(WeatherEntity weather) {
    int score = 100;

    int rainDeduction = _rainDeduction(weather.precipProbability) +
        _conditionDeduction(weather.condition);
    if (rainDeduction > _maxRainDeduction) rainDeduction = _maxRainDeduction;

    final windDeduction = _windDeduction(weather.windSpeedMs);
    final heatDeduction = _temperatureDeduction(weather.tempCelsius);
    final dustDeduction = _dustDeduction(weather.pm10, weather.pm25);
    final uvDeduction = _uvDeduction(weather.uvIndex);
    final ozoneDeduction = _ozoneDeduction(weather.o3);

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

  int _rainDeduction(double prob) {
    if (prob >= 0.9) return 70;
    if (prob >= 0.7) return 50;
    if (prob >= 0.5) return 30;
    if (prob >= 0.3) return 10;
    return 0;
  }

  int _conditionDeduction(WeatherCondition condition) {
    return switch (condition) {
      WeatherCondition.slightRain => 5,
      WeatherCondition.rainy => 10,
      WeatherCondition.heavyRain => 20,
      WeatherCondition.thunderstorm || WeatherCondition.rainThunder => 20,
      WeatherCondition.lightSnow => 10,
      WeatherCondition.snowy => 15,
      WeatherCondition.sleet => 10,
      _ => 0,
    };
  }

  // 25 mph = 11.2 m/s, 35 mph = 15.6 m/s
  int _windDeduction(double ms) {
    if (ms >= 15) return 30;
    if (ms >= 11) return 18;
    if (ms >= 6) return 8;
    return 0;
  }

  // 104°F = 40°C, 95°F = 35°C, 14°F = -10°C
  int _temperatureDeduction(double c) {
    if (c >= 40 || c <= -15) return 35;
    if (c >= 35 || c <= -10) return 20;
    if (c >= 32 || c <= -5) return 8;
    return 0;
  }

  // EPA PM2.5 기준: Good(0-12) / Moderate(12.1-35.4) /
  //   Unhealthy for Sensitive(35.5-55.4) / Unhealthy(55.5-150.4) / Very Unhealthy(150.5+)
  // EPA PM10 기준: Good(0-54) / Moderate(55-154) / Unhealthy(155-254) / Very Unhealthy(255+)
  int _dustDeduction(double? pm10, double? pm25) {
    int deduction = 0;
    if (pm25 != null) {
      if (pm25 >= 150.5) {
        deduction += 30;
      } else if (pm25 >= 55.5) {
        deduction += 20;
      } else if (pm25 >= 35.5) {
        deduction += 12;
      } else if (pm25 >= 12.1) {
        deduction += 5;
      }
    }
    if (pm10 != null) {
      if (pm10 >= 255) {
        deduction += 20;
      } else if (pm10 >= 155) {
        deduction += 12;
      } else if (pm10 >= 55) {
        deduction += 5;
      }
    }
    return deduction.clamp(0, _maxDustDeduction);
  }

  // EPA UV 지수: Low(0-2) / Moderate(3-5) / High(6-7) / Very High(8-10) / Extreme(11+)
  int _uvDeduction(int uv) {
    if (uv >= 11) return 25;
    if (uv >= 8) return 15;
    if (uv >= 6) return 8;
    if (uv >= 3) return 3;
    return 0;
  }

  // EPA NAAQS 오존 기준 (ppm): 0.070 = NAAQS 8h 기준
  int _ozoneDeduction(double? o3) {
    if (o3 == null) return 0;
    if (o3 > 0.200) return 25;
    if (o3 > 0.150) return 15;
    if (o3 > 0.100) return 8;
    if (o3 > 0.070) return 3;
    return 0;
  }
}
