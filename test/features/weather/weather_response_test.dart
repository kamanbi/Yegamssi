import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/weather/data/models/weather_response.dart';
import 'package:yegamssi/features/weather/domain/entities/weather_entity.dart';

// ── WeatherResponse 생성 헬퍼 ────────────────────────────────────
WeatherResponse _response({
  double temp = 20,
  WeatherCondition condition = WeatherCondition.sunny,
  List<HourlyForecast> hourly = const [],
  List<DailyForecast> daily = const [],
}) {
  return WeatherResponse(
    tempCelsius: temp,
    feelsLikeCelsius: temp,
    condition: condition,
    windSpeedMs: 0,
    precipProbability: 0,
    uvIndex: 0,
    humidity: 50,
    locationName: 'Test',
    hourlyForecasts: hourly,
    dailyForecasts: daily,
  );
}

DailyForecast _daily({
  required double tempMin,
  required double tempMax,
  WeatherCondition condition = WeatherCondition.sunny,
  double precipProb = 0,
}) {
  return DailyForecast(
    date: DateTime(2026, 5, 22),
    tempMin: tempMin,
    tempMax: tempMax,
    condition: condition,
    precipProbability: precipProb,
  );
}

void main() {
  // ══════════════════════════════════════════════════════════════
  // _applyTempOverrides (WeatherResponse.toEntity 내부 로직)
  // ══════════════════════════════════════════════════════════════
  group('온도 오버라이드 (_applyTempOverrides)', () {
    test('sunny + 33°C → hot으로 변환', () {
      final entity = _response(temp: 33).toEntity();
      expect(entity.condition, WeatherCondition.hot);
    });

    test('sunny + 32°C → 변환 없음 (33°C 미만)', () {
      final entity = _response(temp: 32).toEntity();
      expect(entity.condition, WeatherCondition.sunny);
    });

    test('sunny + -10°C → coldWave로 변환', () {
      final entity = _response(temp: -10).toEntity();
      expect(entity.condition, WeatherCondition.coldWave);
    });

    test('sunny + -9°C → 변환 없음 (-10°C 초과)', () {
      final entity = _response(temp: -9).toEntity();
      expect(entity.condition, WeatherCondition.sunny);
    });

    test('rainy + 40°C → rainy 유지 (강수 조건은 온도 오버라이드 미적용)', () {
      final entity = _response(temp: 40, condition: WeatherCondition.rainy)
          .toEntity();
      expect(entity.condition, WeatherCondition.rainy);
    });

    test('heavyRain + -15°C → heavyRain 유지', () {
      final entity = _response(temp: -15, condition: WeatherCondition.heavyRain)
          .toEntity();
      expect(entity.condition, WeatherCondition.heavyRain);
    });

    test('thunderstorm + 38°C → thunderstorm 유지 (비강수 아님)', () {
      final entity = _response(temp: 38, condition: WeatherCondition.thunderstorm)
          .toEntity();
      expect(entity.condition, WeatherCondition.thunderstorm);
    });

    test('hazy + 34°C → hot으로 변환 (hazy는 benign)', () {
      final entity = _response(temp: 34, condition: WeatherCondition.hazy)
          .toEntity();
      expect(entity.condition, WeatherCondition.hot);
    });

    test('windy + -11°C → coldWave로 변환 (windy는 benign)', () {
      final entity = _response(temp: -11, condition: WeatherCondition.windy)
          .toEntity();
      expect(entity.condition, WeatherCondition.coldWave);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // 일별 예보 — tempMax 기준 오버라이드
  // ══════════════════════════════════════════════════════════════
  group('일별 예보 온도 오버라이드', () {
    test('daily tempMax 33°C → hot으로 변환', () {
      final entity = _response(
        daily: [_daily(tempMin: 25, tempMax: 33)],
      ).toEntity();
      expect(entity.dailyForecasts.first.condition, WeatherCondition.hot);
    });

    test('daily tempMin -10°C → coldWave로 변환', () {
      final entity = _response(
        daily: [_daily(tempMin: -10, tempMax: -5)],
      ).toEntity();
      expect(entity.dailyForecasts.first.condition, WeatherCondition.coldWave);
    });

    test('daily rainy + 38°C → rainy 유지', () {
      final entity = _response(
        daily: [
          _daily(
            tempMin: 30,
            tempMax: 38,
            condition: WeatherCondition.rainy,
          ),
        ],
      ).toEntity();
      expect(entity.dailyForecasts.first.condition, WeatherCondition.rainy);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // hourly 예보 전달 확인
  // ══════════════════════════════════════════════════════════════
  group('시간별 예보 전달', () {
    test('hourlyForecasts가 entity로 올바르게 전달됨', () {
      final now = DateTime(2026, 5, 22, 12);
      final entity = _response(
        hourly: [
          HourlyForecast(
            time: now,
            tempCelsius: 25,
            condition: WeatherCondition.partlyCloudy,
          ),
          HourlyForecast(
            time: now.add(const Duration(hours: 1)),
            tempCelsius: 26,
            condition: WeatherCondition.sunny,
          ),
        ],
      ).toEntity();

      expect(entity.hourlyForecasts.length, 2);
      expect(entity.hourlyForecasts[0].tempCelsius, 25);
      expect(entity.hourlyForecasts[1].tempCelsius, 26);
    });

    test('hourly 25°C sunny → hot 오버라이드 (33°C 미만이므로 유지)', () {
      final entity = _response(
        hourly: [
          HourlyForecast(
            time: DateTime(2026, 5, 22, 14),
            tempCelsius: 25,
            condition: WeatherCondition.sunny,
          ),
        ],
      ).toEntity();
      expect(entity.hourlyForecasts.first.condition, WeatherCondition.sunny);
    });

    test('hourly sunny + 35°C → hot으로 변환', () {
      final entity = _response(
        hourly: [
          HourlyForecast(
            time: DateTime(2026, 5, 22, 14),
            tempCelsius: 35,
            condition: WeatherCondition.sunny,
          ),
        ],
      ).toEntity();
      expect(entity.hourlyForecasts.first.condition, WeatherCondition.hot);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // NOAA _toCelsius 변환 로직 검증 (독립 함수로 테스트)
  // ══════════════════════════════════════════════════════════════
  group('화씨→섭씨 변환', () {
    double toCelsius(double temp, String unit) {
      if (unit.toUpperCase() == 'C') return temp;
      return (temp - 32) * 5 / 9;
    }

    test('32°F → 0°C', () {
      expect(toCelsius(32, 'F'), closeTo(0, 0.01));
    });

    test('212°F → 100°C', () {
      expect(toCelsius(212, 'F'), closeTo(100, 0.01));
    });

    test('98.6°F → 37°C', () {
      expect(toCelsius(98.6, 'F'), closeTo(37, 0.01));
    });

    test('0°F → -17.78°C', () {
      expect(toCelsius(0, 'F'), closeTo(-17.78, 0.01));
    });

    test('단위 C이면 변환 없음', () {
      expect(toCelsius(25, 'C'), 25);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // NOAA mph → m/s 변환 검증
  // ══════════════════════════════════════════════════════════════
  group('mph → m/s 변환', () {
    double parseMphToMs(String text) {
      final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
      final mph = double.tryParse(match?.group(1) ?? '0') ?? 0;
      return mph * 0.44704;
    }

    test('10 mph → 4.47 m/s', () {
      expect(parseMphToMs('10 mph'), closeTo(4.47, 0.01));
    });

    test('25 mph → 11.18 m/s (강풍 기준)', () {
      expect(parseMphToMs('25 mph'), closeTo(11.18, 0.01));
    });

    test('35 mph → 15.65 m/s', () {
      expect(parseMphToMs('35 mph'), closeTo(15.65, 0.01));
    });

    test('숫자 없는 입력 → 0', () {
      expect(parseMphToMs('Calm'), 0);
    });
  });
}
