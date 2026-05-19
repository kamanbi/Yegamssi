import '../entities/oheng.dart';
import '../entities/saju.dart';

/// 사주(四柱) 계산 — 순수 Dart, 오프라인
class SajuCalculator {
  SajuCalculator._();

  /// 생년월일 + 출생시간(모름=12) → Saju
  static Saju calculate(DateTime birthDate, int birthHour) {
    final yearPillar = _yearPillar(birthDate.year);
    final monthPillar = _monthPillar(
      birthDate.year,
      birthDate.month,
      birthDate.day,
    );
    final dayPillar = _dayPillar(birthDate);
    final hourPillar = _hourPillar(birthHour, dayPillar.$1);

    final ohengCount = <Oheng, int>{for (final o in Oheng.values) o: 0};

    void addPillar(HeavenlyStem stem, EarthlyBranch branch) {
      ohengCount[stem.oheng] = (ohengCount[stem.oheng] ?? 0) + 1;
      ohengCount[branch.oheng] = (ohengCount[branch.oheng] ?? 0) + 1;
    }

    addPillar(yearPillar.$1, yearPillar.$2);
    addPillar(monthPillar.$1, monthPillar.$2);
    addPillar(dayPillar.$1, dayPillar.$2);
    addPillar(hourPillar.$1, hourPillar.$2);

    return Saju(
      yearStem: yearPillar.$1,
      yearBranch: yearPillar.$2,
      monthStem: monthPillar.$1,
      monthBranch: monthPillar.$2,
      dayStem: dayPillar.$1,
      dayBranch: dayPillar.$2,
      hourStem: hourPillar.$1,
      hourBranch: hourPillar.$2,
      ohengCount: ohengCount,
    );
  }

  // ── 년주 ─────────────────────────────────────────────────────
  static (HeavenlyStem, EarthlyBranch) _yearPillar(int year) {
    final stemIdx = (year - 4) % 10;
    final branchIdx = (year - 4) % 12;
    return (HeavenlyStem.values[stemIdx], EarthlyBranch.values[branchIdx]);
  }

  // ── 월주 (절기 기반 근사) ──────────────────────────────────────
  static (HeavenlyStem, EarthlyBranch) _monthPillar(
    int year,
    int month,
    int day,
  ) {
    // 절기 시작일 근사 (월별 입기일 평균)
    const solarTermDays = [6, 4, 6, 5, 6, 6, 7, 7, 8, 8, 7, 7];
    final termDay = solarTermDays[month - 1];

    // 절기를 지나지 않았으면 전월 적용
    int monthIndex = day >= termDay ? month : month - 1;
    // 1월 이전이면 12월
    if (monthIndex <= 0) monthIndex += 12;

    // 월 인덱스 0-based (인월=0)
    final adjustedMonth = (monthIndex - 1) % 12;

    // 년주 천간으로 월 천간 시작 결정
    // 갑기년→丙(2), 을경년→戊(4), 병신년→庚(6), 정임년→壬(8), 무계년→甲(0)
    final yearStemIndex = (year - 4) % 10;
    const monthStemStart = [2, 4, 6, 8, 0, 2, 4, 6, 8, 0];
    final startStem = monthStemStart[yearStemIndex];
    final stemIdx = (startStem + adjustedMonth) % 10;
    final branchIdx = (adjustedMonth + 2) % 12; // 인월(寅)=2

    return (HeavenlyStem.values[stemIdx], EarthlyBranch.values[branchIdx]);
  }

  // ── 일주 (기준일: 1900-01-01 = 甲子) ─────────────────────────
  static (HeavenlyStem, EarthlyBranch) _dayPillar(DateTime date) {
    final base = DateTime(1900);
    final diff = date.difference(base).inDays;
    final stemIdx = ((diff % 10) + 10) % 10;
    final branchIdx = ((diff % 12) + 12) % 12;
    return (HeavenlyStem.values[stemIdx], EarthlyBranch.values[branchIdx]);
  }

  // ── 시주 ─────────────────────────────────────────────────────
  static (HeavenlyStem, EarthlyBranch) _hourPillar(
    int hour,
    HeavenlyStem dayStem,
  ) {
    // 시지: 子(23~1)=0, 丑(1~3)=1 ... 亥(21~23)=11
    final branchIdx = ((hour + 1) ~/ 2) % 12;

    // 일간에 따른 子시 천간
    // 甲己→甲(0), 乙庚→丙(2), 丙辛→戊(4), 丁壬→庚(6), 戊癸→壬(8)
    const hourStemStart = [0, 2, 4, 6, 8, 0, 2, 4, 6, 8];
    final startStem = hourStemStart[dayStem.index];
    final stemIdx = (startStem + branchIdx) % 10;

    return (HeavenlyStem.values[stemIdx], EarthlyBranch.values[branchIdx]);
  }
}
