enum LuckyColorFamily { red, orange, yellow, green, teal, blue, purple, pink }

class LuckyColor {
  const LuckyColor({
    required this.hue,
    required this.saturation,
    required this.lightness,
  });

  static const _fullChannel = 255.0;
  static const _hueCycle = 360.0;
  static const _redToOrangeHue = 20.0;
  static const _orangeToYellowHue = 45.0;
  static const _yellowToGreenHue = 70.0;
  static const _greenToTealHue = 160.0;
  static const _tealToBlueHue = 200.0;
  static const _blueToPurpleHue = 260.0;
  static const _purpleToPinkHue = 310.0;
  static const _pinkToRedHue = 340.0;
  static const _hueSegment = 60.0;
  static const _secondaryHueRange = 2.0;
  static const _hueSectionCount = 6;
  static const _minimumChannel = 0;
  static const _maximumChannel = 255;
  static const _hexRadix = 16;
  static const _hexWidth = 2;

  final double hue;
  final double saturation;
  final double lightness;

  LuckyColorFamily get family {
    final normalizedHue = hue % _hueCycle;
    if (normalizedHue < _redToOrangeHue || normalizedHue >= _pinkToRedHue) {
      return LuckyColorFamily.red;
    }
    if (normalizedHue < _orangeToYellowHue) return LuckyColorFamily.orange;
    if (normalizedHue < _yellowToGreenHue) return LuckyColorFamily.yellow;
    if (normalizedHue < _greenToTealHue) return LuckyColorFamily.green;
    if (normalizedHue < _tealToBlueHue) return LuckyColorFamily.teal;
    if (normalizedHue < _blueToPurpleHue) return LuckyColorFamily.blue;
    if (normalizedHue < _purpleToPinkHue) return LuckyColorFamily.purple;
    return LuckyColorFamily.pink;
  }

  Map<String, dynamic> toJson() => {
    'hue': hue,
    'saturation': saturation,
    'lightness': lightness,
  };

  factory LuckyColor.fromJson(Map<String, dynamic> json) => LuckyColor(
    hue: (json['hue'] as num).toDouble(),
    saturation: (json['saturation'] as num).toDouble(),
    lightness: (json['lightness'] as num).toDouble(),
  );

  String get hexCode {
    final chroma = (_one - (2 * lightness - _one).abs()) * saturation;
    final hueSection = hue / _hueSegment;
    final secondary =
        chroma * (_one - ((hueSection % _secondaryHueRange) - _one).abs());
    final match = lightness - chroma / 2;
    final (red, green, blue) = _rgbComponents(chroma, secondary, match);

    return '#${_hexChannel(red)}${_hexChannel(green)}${_hexChannel(blue)}';
  }

  static const _one = 1.0;

  (double, double, double) _rgbComponents(
    double chroma,
    double secondary,
    double match,
  ) {
    final section = (hue / _hueSegment).floor() % _hueSectionCount;
    return switch (section) {
      0 => (chroma + match, secondary + match, match),
      1 => (secondary + match, chroma + match, match),
      2 => (match, chroma + match, secondary + match),
      3 => (match, secondary + match, chroma + match),
      4 => (secondary + match, match, chroma + match),
      _ => (chroma + match, match, secondary + match),
    };
  }

  String _hexChannel(double value) {
    final channel = (value * _fullChannel)
        .round()
        .clamp(_minimumChannel, _maximumChannel)
        .toInt();
    return channel
        .toRadixString(_hexRadix)
        .padLeft(_hexWidth, '0')
        .toUpperCase();
  }
}
