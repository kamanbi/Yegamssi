import '../../../fortune/domain/entities/oheng.dart';

/// 전통 명리 신살(神殺) 계산 — 일지(日支) 기준으로 통일
class SinsalCalculator {
  SinsalCalculator._();

  // 삼합(三合) 그룹: 지지 4묶음. 도화/역마지가 그룹별로 고정된다.
  static const _samhapGroups = <List<EarthlyBranch>>[
    [EarthlyBranch.sin, EarthlyBranch.ja, EarthlyBranch.jin], // 신자진
    [EarthlyBranch.in_, EarthlyBranch.o, EarthlyBranch.sul], // 인오술
    [EarthlyBranch.sa, EarthlyBranch.yu, EarthlyBranch.chuk], // 사유축
    [EarthlyBranch.hae, EarthlyBranch.myo, EarthlyBranch.mi], // 해묘미
  ];

  // 그룹별 도화지(桃花): 신자진→유, 인오술→묘, 사유축→오, 해묘미→자
  static const _dohwaByGroup = <EarthlyBranch>[
    EarthlyBranch.yu,
    EarthlyBranch.myo,
    EarthlyBranch.o,
    EarthlyBranch.ja,
  ];

  // 그룹별 역마지(驛馬): 신자진→인, 인오술→신, 사유축→해, 해묘미→사
  static const _yeokmaByGroup = <EarthlyBranch>[
    EarthlyBranch.in_,
    EarthlyBranch.sin,
    EarthlyBranch.hae,
    EarthlyBranch.sa,
  ];

  static int _groupIndex(EarthlyBranch branch) {
    for (var i = 0; i < _samhapGroups.length; i++) {
      if (_samhapGroups[i].contains(branch)) return i;
    }
    return 0; // 모든 지지가 한 그룹에 속하므로 도달하지 않음
  }

  static bool isDohwa(EarthlyBranch dayBranch, EarthlyBranch targetBranch) {
    return _dohwaByGroup[_groupIndex(dayBranch)] == targetBranch;
  }

  static bool isYeokma(EarthlyBranch dayBranch, EarthlyBranch targetBranch) {
    return _yeokmaByGroup[_groupIndex(dayBranch)] == targetBranch;
  }

  // 육합(六合) 쌍: 자축·인해·묘술·진유·사신·오미
  static const _hapPairs = <Set<EarthlyBranch>>[
    {EarthlyBranch.ja, EarthlyBranch.chuk},
    {EarthlyBranch.in_, EarthlyBranch.hae},
    {EarthlyBranch.myo, EarthlyBranch.sul},
    {EarthlyBranch.jin, EarthlyBranch.yu},
    {EarthlyBranch.sa, EarthlyBranch.sin},
    {EarthlyBranch.o, EarthlyBranch.mi},
  ];

  static bool isHap(EarthlyBranch a, EarthlyBranch b) {
    return _hapPairs.any((pair) => pair.contains(a) && pair.contains(b));
  }

  // 육충(六沖) 쌍: 자오·축미·인신·묘유·진술·사해
  static const _chungPairs = <Set<EarthlyBranch>>[
    {EarthlyBranch.ja, EarthlyBranch.o},
    {EarthlyBranch.chuk, EarthlyBranch.mi},
    {EarthlyBranch.in_, EarthlyBranch.sin},
    {EarthlyBranch.myo, EarthlyBranch.yu},
    {EarthlyBranch.jin, EarthlyBranch.sul},
    {EarthlyBranch.sa, EarthlyBranch.hae},
  ];

  static bool isChung(EarthlyBranch a, EarthlyBranch b) {
    return _chungPairs.any((pair) => pair.contains(a) && pair.contains(b));
  }

  // 재성(財星): 일간이 극(剋)하는 오행. 목극토·화극금·토극수·금극목·수극화
  static Oheng jaeseongOhengFor(HeavenlyStem dayStem) {
    return switch (dayStem.oheng) {
      Oheng.mok => Oheng.to,
      Oheng.hwa => Oheng.geum,
      Oheng.to => Oheng.su,
      Oheng.geum => Oheng.mok,
      Oheng.su => Oheng.hwa,
    };
  }
}
