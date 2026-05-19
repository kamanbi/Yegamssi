enum FortuneTone {
  base('base', '기본', ''),
  humor('humor', '유머', 'humor'),
  tsundere('tsundere', '츤데레', 'tsundere'),
  cynical('cynical', '시니컬', 'cynical'),
  emotional('emotional', '감성', 'emotional'),
  historical('historical', '사극', 'historical'),
  ai('ai', 'AI', 'ai');

  const FortuneTone(this.storageValue, this.label, this.tableSuffix);

  final String storageValue;
  final String label;
  final String tableSuffix;

  String tableNameForLang(String lang) {
    final supportedLang = lang == 'ko' ? lang : 'ko';
    final baseTableName = 'fortune_$supportedLang';
    if (tableSuffix.isEmpty) {
      return baseTableName;
    }
    return '${baseTableName}_$tableSuffix';
  }

  static FortuneTone fromStorage(String? value) {
    if (value == null) return FortuneTone.base;
    for (final tone in FortuneTone.values) {
      if (tone.storageValue == value || tone.name == value) {
        return tone;
      }
    }
    return FortuneTone.base;
  }
}
