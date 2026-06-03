enum ScoreTier {
  excellent, // 90~100
  good, // 70~89
  fair, // 50~69
  poor, // 0~49
}

extension ScoreTierExtension on ScoreTier {
  static ScoreTier fromScore(int score) {
    if (score >= 90) return ScoreTier.excellent;
    if (score >= 70) return ScoreTier.good;
    if (score >= 50) return ScoreTier.fair;
    return ScoreTier.poor;
  }

  String get label {
    return switch (this) {
      ScoreTier.excellent => 'Excellent',
      ScoreTier.good => 'Good',
      ScoreTier.fair => 'Fair',
      ScoreTier.poor => 'Caution',
    };
  }
}
