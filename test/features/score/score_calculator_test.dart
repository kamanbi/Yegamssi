import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/score/domain/calculators/global_score_calculator.dart';
import 'package:yegamssi/features/score/domain/calculators/kr_score_calculator.dart';
import 'package:yegamssi/features/score/domain/calculators/us_score_calculator.dart';
import 'package:yegamssi/features/weather/domain/entities/weather_entity.dart';

// ── 테스트용 날씨 엔티티 생성 헬퍼 ──────────────────────────────
WeatherEntity _weather({
  double temp = 20,
  double precipProb = 0,
  double windMs = 0,
  int uvIndex = 0,
  double? pm10,
  double? pm25,
  double? o3,
  WeatherCondition condition = WeatherCondition.sunny,
}) {
  return WeatherEntity(
    tempCelsius: temp,
    feelsLikeCelsius: temp,
    condition: condition,
    windSpeedMs: windMs,
    precipProbability: precipProb,
    uvIndex: uvIndex,
    humidity: 50,
    observedAt: DateTime(2026, 5, 22),
    locationName: 'Test',
    pm10: pm10,
    pm25: pm25,
    o3: o3,
  );
}

void main() {
  // ══════════════════════════════════════════════════════════════
  // KrScoreCalculator
  // ══════════════════════════════════════════════════════════════
  group('KrScoreCalculator', () {
    const calc = KrScoreCalculator();

    test('쾌청한 날 만점', () {
      final score = calc.calculate(_weather());
      expect(score.score, 100);
    });

    test('강수확률 60% → 40감점', () {
      final score = calc.calculate(_weather(precipProb: 0.6));
      expect(score.breakdown.rainDeduction, 40);
    });

    test('강수확률 70% → 50감점', () {
      final score = calc.calculate(_weather(precipProb: 0.7));
      expect(score.breakdown.rainDeduction, 50);
    });

    test('강수확률 50% → 감점 없음 (KR은 60% 미만 무시)', () {
      final score = calc.calculate(_weather(precipProb: 0.5));
      expect(score.breakdown.rainDeduction, 0);
    });

    test('강수 컨디션 heavyRain → 추가 20감점', () {
      final score = calc.calculate(
        _weather(precipProb: 0.7, condition: WeatherCondition.heavyRain),
      );
      expect(score.breakdown.rainDeduction, 70); // 50 + 20
    });

    test('풍속 9 m/s → 18감점', () {
      final score = calc.calculate(_weather(windMs: 9));
      expect(score.breakdown.windDeduction, 18);
    });

    test('풍속 14 m/s → 30감점', () {
      final score = calc.calculate(_weather(windMs: 14));
      expect(score.breakdown.windDeduction, 30);
    });

    test('기온 35°C → 35감점 (>= 35 최고 구간)', () {
      final score = calc.calculate(_weather(temp: 35));
      expect(score.breakdown.heatDeduction, 35);
    });

    test('기온 30°C → 18감점', () {
      final score = calc.calculate(_weather(temp: 30));
      expect(score.breakdown.heatDeduction, 18);
    });

    test('기온 -10°C → 35감점', () {
      final score = calc.calculate(_weather(temp: -10));
      expect(score.breakdown.heatDeduction, 35);
    });

    test('UV 5 → 감점 없음 (KR은 6부터)', () {
      final score = calc.calculate(_weather(uvIndex: 5));
      expect(score.breakdown.uvDeduction, 0);
    });

    test('UV 6 → 5감점', () {
      final score = calc.calculate(_weather(uvIndex: 6));
      expect(score.breakdown.uvDeduction, 5);
    });

    test('UV 11 → 18감점', () {
      final score = calc.calculate(_weather(uvIndex: 11));
      expect(score.breakdown.uvDeduction, 18);
    });

    test('PM2.5 15 → 감점 없음 (KR 임계값 16)', () {
      final score = calc.calculate(_weather(pm25: 15));
      expect(score.breakdown.dustDeduction, 0);
    });

    test('PM2.5 16 → 6감점', () {
      final score = calc.calculate(_weather(pm25: 16));
      expect(score.breakdown.dustDeduction, 6);
    });

    test('점수 clamp 0 이하 → 0', () {
      // 비+강풍+폭염 극단 조건
      final score = calc.calculate(
        _weather(
          temp: 36,
          precipProb: 0.9,
          windMs: 15,
          uvIndex: 11,
          pm10: 200,
          pm25: 100,
          condition: WeatherCondition.heavyRain,
        ),
      );
      expect(score.score, 0);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // UsScoreCalculator
  // ══════════════════════════════════════════════════════════════
  group('UsScoreCalculator', () {
    const calc = UsScoreCalculator();

    test('쾌청한 날 만점', () {
      final score = calc.calculate(_weather());
      expect(score.score, 100);
    });

    // UV — US는 3부터 감점 (KR은 6부터)
    test('UV 3 → 3감점 (KR은 0)', () {
      final score = calc.calculate(_weather(uvIndex: 3));
      expect(score.breakdown.uvDeduction, 3);
    });

    test('UV 5 → 3감점 (KR은 0)', () {
      final score = calc.calculate(_weather(uvIndex: 5));
      expect(score.breakdown.uvDeduction, 3);
    });

    test('UV 6 → 8감점', () {
      final score = calc.calculate(_weather(uvIndex: 6));
      expect(score.breakdown.uvDeduction, 8);
    });

    test('UV 8 → 15감점 (KR은 10)', () {
      final score = calc.calculate(_weather(uvIndex: 8));
      expect(score.breakdown.uvDeduction, 15);
    });

    test('UV 11 → 25감점 (KR은 18)', () {
      final score = calc.calculate(_weather(uvIndex: 11));
      expect(score.breakdown.uvDeduction, 25);
    });

    // PM2.5 EPA 기준
    test('PM2.5 12 → 감점 없음 (EPA Good)', () {
      final score = calc.calculate(_weather(pm25: 12));
      expect(score.breakdown.dustDeduction, 0);
    });

    test('PM2.5 12.1 → 5감점 (EPA Moderate, KR은 0)', () {
      final score = calc.calculate(_weather(pm25: 12.1));
      expect(score.breakdown.dustDeduction, 5);
    });

    test('PM2.5 35.5 → 12감점 (EPA Unhealthy for Sensitive)', () {
      final score = calc.calculate(_weather(pm25: 35.5));
      expect(score.breakdown.dustDeduction, 12);
    });

    test('PM2.5 55.5 → 20감점 (EPA Unhealthy)', () {
      final score = calc.calculate(_weather(pm25: 55.5));
      expect(score.breakdown.dustDeduction, 20);
    });

    // 강수 — US는 30%부터 감점
    test('강수확률 30% → 10감점 (KR은 0)', () {
      final score = calc.calculate(_weather(precipProb: 0.3));
      expect(score.breakdown.rainDeduction, 10);
    });

    test('강수확률 50% → 30감점 (KR은 0)', () {
      final score = calc.calculate(_weather(precipProb: 0.5));
      expect(score.breakdown.rainDeduction, 30);
    });

    // 온도 — US는 40°C 극고온
    test('기온 35°C → 20감점', () {
      final score = calc.calculate(_weather(temp: 35));
      expect(score.breakdown.heatDeduction, 20);
    });

    test('기온 40°C → 35감점', () {
      final score = calc.calculate(_weather(temp: 40));
      expect(score.breakdown.heatDeduction, 35);
    });

    test('기온 0°C → 감점 없음 (US는 -5°C부터)', () {
      final score = calc.calculate(_weather(temp: 0));
      expect(score.breakdown.heatDeduction, 0);
    });

    // 오존 NAAQS 기준
    test('오존 0.070 → 감점 없음 (NAAQS 임계값 미만)', () {
      final score = calc.calculate(_weather(o3: 0.070));
      expect(score.breakdown.ozoneDeduction, 0);
    });

    test('오존 0.071 → 3감점 (NAAQS 초과)', () {
      final score = calc.calculate(_weather(o3: 0.071));
      expect(score.breakdown.ozoneDeduction, 3);
    });

    test('오존 0.151 → 15감점', () {
      final score = calc.calculate(_weather(o3: 0.151));
      expect(score.breakdown.ozoneDeduction, 15);
    });

    test('점수 clamp 0 이하 → 0', () {
      final score = calc.calculate(
        _weather(
          temp: 42,
          precipProb: 0.9,
          windMs: 16,
          uvIndex: 11,
          pm25: 200,
          condition: WeatherCondition.heavyRain,
        ),
      );
      expect(score.score, 0);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // GlobalScoreCalculator
  // ══════════════════════════════════════════════════════════════
  group('GlobalScoreCalculator', () {
    const calc = GlobalScoreCalculator();

    // GlobalScoreCalculator는 ScoreBreakdown을 빈 값으로 리턴하므로
    // breakdown이 아닌 최종 score로 검증
    test('쾌청한 날 만점', () {
      final score = calc.calculate(_weather());
      expect(score.score, 100);
    });

    test('강수확률 40% → score 80 (-20)', () {
      final score = calc.calculate(_weather(precipProb: 0.4));
      expect(score.score, 80);
    });

    test('강수확률 70% → score 60 (-40)', () {
      final score = calc.calculate(_weather(precipProb: 0.7));
      expect(score.score, 60);
    });

    test('기온 35°C → score 70 (-30)', () {
      final score = calc.calculate(_weather(temp: 35));
      expect(score.score, 70);
    });

    test('기온 30°C → score 85 (-15)', () {
      final score = calc.calculate(_weather(temp: 30));
      expect(score.score, 85);
    });

    test('강수 70% + 기온 35°C → score 30 (-40 -30)', () {
      final score = calc.calculate(_weather(precipProb: 0.7, temp: 35));
      expect(score.score, 30);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // KR vs US 비교
  // ══════════════════════════════════════════════════════════════
  group('KR vs US 비교', () {
    const kr = KrScoreCalculator();
    const us = UsScoreCalculator();

    test('UV 4: US가 KR보다 낮은 점수', () {
      final weather = _weather(uvIndex: 4);
      final krScore = kr.calculate(weather).score;
      final usScore = us.calculate(weather).score;
      expect(usScore, lessThan(krScore)); // US UV 3부터 감점
    });

    // PM2.5 12.1~15 구간: US(5감점)가 KR(0감점)보다 엄격
    test('PM2.5 13: US가 KR보다 낮은 점수 (US EPA 12.1 초과, KR 16 미만)', () {
      final weather = _weather(pm25: 13);
      final krScore = kr.calculate(weather).score;
      final usScore = us.calculate(weather).score;
      expect(usScore, lessThan(krScore));
    });

    test('강수확률 45%: US가 KR보다 낮은 점수', () {
      final weather = _weather(precipProb: 0.45);
      final krScore = kr.calculate(weather).score;
      final usScore = us.calculate(weather).score;
      expect(usScore, lessThan(krScore)); // KR은 60% 미만 무시
    });

    // 38°C: KR(35감점) > US(20감점) — 한국이 중간 고온에 더 엄격
    test('기온 38°C: KR이 US보다 낮은 점수 (KR 35감점, US 20감점)', () {
      final weather = _weather(temp: 38);
      final krScore = kr.calculate(weather).score;
      final usScore = us.calculate(weather).score;
      expect(krScore, lessThan(usScore));
    });

    // 41°C: US(35감점) = KR(35감점) — 극고온에서 동일
    test('기온 41°C: KR과 US 동일 감점 (둘 다 최대 35)', () {
      final weather = _weather(temp: 41);
      final krScore = kr.calculate(weather).score;
      final usScore = us.calculate(weather).score;
      expect(krScore, equals(usScore));
    });
  });
}
