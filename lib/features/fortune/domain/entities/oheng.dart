// 오행(五行) 관련 도메인 모델

enum Oheng {
  mok, // 木 (나무, 봄)
  hwa, // 火 (불, 여름)
  to, //  土 (흙, 환절기)
  geum, // 金 (쇠, 가을)
  su; // 水 (물, 겨울)

  String get korean => switch (this) {
    Oheng.mok => '목 (木)',
    Oheng.hwa => '화 (火)',
    Oheng.to => '토 (土)',
    Oheng.geum => '금 (金)',
    Oheng.su => '수 (水)',
  };
}

/// 오행 강도
enum OhengStrength {
  ex, // 과다 (excess) — 사주 4기둥 중 3개 이상
  df, // 부족 (deficient) — 1개 이하
}

/// 운세 카테고리
enum FortuneCategory {
  overall, // 종합운세
  money, //   재물운
  love, //    연애운
  work, //    직장운
  health, //  건강운
  decision; // 결정운

  String get korean => switch (this) {
    FortuneCategory.overall => '종합운세',
    FortuneCategory.money => '재물운',
    FortuneCategory.love => '연애운',
    FortuneCategory.work => '직장운',
    FortuneCategory.health => '건강운',
    FortuneCategory.decision => '결정운',
  };
}

/// 천간(天干) 10개
enum HeavenlyStem {
  gap, //    甲
  eul, //    乙
  byeong, // 丙
  jeong, //  丁
  mu, //     戊
  gi, //     己
  gyeong, // 庚
  shin, //   辛
  im, //     壬
  gye; //    癸

  Oheng get oheng => switch (this) {
    HeavenlyStem.gap => Oheng.mok,
    HeavenlyStem.eul => Oheng.mok,
    HeavenlyStem.byeong => Oheng.hwa,
    HeavenlyStem.jeong => Oheng.hwa,
    HeavenlyStem.mu => Oheng.to,
    HeavenlyStem.gi => Oheng.to,
    HeavenlyStem.gyeong => Oheng.geum,
    HeavenlyStem.shin => Oheng.geum,
    HeavenlyStem.im => Oheng.su,
    HeavenlyStem.gye => Oheng.su,
  };
}

/// 지지(地支) 12개
enum EarthlyBranch {
  ja, //   子
  chuk, // 丑
  in_, //  寅
  myo, //  卯
  jin, //  辰
  sa, //   巳
  o, //    午
  mi, //   未
  sin, //  申
  yu, //   酉
  sul, //  戌
  hae; //  亥

  Oheng get oheng => switch (this) {
    EarthlyBranch.ja => Oheng.su,
    EarthlyBranch.chuk => Oheng.to,
    EarthlyBranch.in_ => Oheng.mok,
    EarthlyBranch.myo => Oheng.mok,
    EarthlyBranch.jin => Oheng.to,
    EarthlyBranch.sa => Oheng.hwa,
    EarthlyBranch.o => Oheng.hwa,
    EarthlyBranch.mi => Oheng.to,
    EarthlyBranch.sin => Oheng.geum,
    EarthlyBranch.yu => Oheng.geum,
    EarthlyBranch.sul => Oheng.to,
    EarthlyBranch.hae => Oheng.su,
  };
}

/// 운세 갱신 슬롯.
/// - morning  : 08~12시 → 오전 1회 갱신
/// - afternoon: 13~17시 → 오후 1회 갱신
/// - 00~07시  : 전날 afternoon 캐시 재사용
/// - 18~23시  : 오늘 afternoon 캐시 재사용
enum TimeSlot {
  morning,
  afternoon;

  /// 현재 시각 기준 슬롯과 캐시 날짜를 반환한다.
  ///
  /// 00~07시는 어제 afternoon 슬롯을 반환하므로,
  /// 전날 오후에 갱신한 결과를 그대로 보여준다.
  static ({TimeSlot slot, DateTime date}) forNow() {
    final now = DateTime.now();
    final h = now.hour;
    if (h >= 8 && h < 13) return (slot: TimeSlot.morning, date: now);
    if (h >= 13) return (slot: TimeSlot.afternoon, date: now);
    // 00~07시: 전날 오후 슬롯
    final yesterday = now.subtract(const Duration(days: 1));
    return (slot: TimeSlot.afternoon, date: yesterday);
  }

  String get label => switch (this) {
    TimeSlot.morning => '오전',
    TimeSlot.afternoon => '오후',
  };
}
