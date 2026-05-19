import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryBlue = Color(0xFF4B68F2);
  static const Color secondaryPurple = Color(0xFF6B58D8);
  static const Color accentGold = Color(0xFFD6B168);
  static const Color gold = accentGold;
  static const Color goldLight = Color(0xFFE6CA8E);
  static const Color goldDark = Color(0xFF9D7A37);

  static const Color skyDeep = Color(0xFF0B1730);
  static const Color skyMid = Color(0xFF1A2C55);
  static const Color skyLight = Color(0xFF6E8CFF);
  static const Color skyGlow = Color(0xFFB6C7FF);
  static const Color waterMist = Color(0xFFDCEBFF);
  static const Color waterSurface = Color(0x663C6BFF);
  static const Color waterShadow = Color(0x332B4599);

  static const Color lightBackground = Color(0xFFF4F7FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFE9EEF8);
  static const Color lightBorder = Color(0x1A18243A);

  static const Color darkBackground = Color(0xFF07111F);
  static const Color darkSurface = Color(0xFF111D35);
  static const Color darkSurfaceMuted = Color(0xFF182744);
  static const Color darkBorder = Color(0x26FFFFFF);

  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassShadow = Color(0x26000000);
  static const Color glassHighlight = Color(0x99FFFFFF);
  static const Color glassLowlight = Color(0x337695FF);

  static const Color textPrimary = Color(0xFFF8FAFF);
  static const Color textSecondary = Color(0xB3F8FAFF);
  static const Color textMuted = Color(0x80F8FAFF);
  static const Color textPrimaryDark = Color(0xFF101826);
  static const Color textSecondaryDark = Color(0xFF5C6578);
  static const Color textMutedDark = Color(0xFF7E8799);

  static const Color scoreExcellent = Color(0xFF5FC98A);
  static const Color scoreGood = Color(0xFF85CF8A);
  static const Color scoreFair = Color(0xFFF0C46B);
  static const Color scorePoor = Color(0xFFE78C7D);

  static const Color weatherSun = Color(0xFFF3C56D);
  static const Color weatherCloud = Color(0xFFD7E4FF);
  static const Color weatherRain = Color(0xFF82C4FF);

  static Color scaffold(Brightness brightness) {
    return brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  static Color surface(Brightness brightness) {
    return brightness == Brightness.dark ? darkSurface : lightSurface;
  }

  static Color mutedSurface(Brightness brightness) {
    return brightness == Brightness.dark
        ? darkSurfaceMuted
        : lightSurfaceMuted;
  }

  static Color border(Brightness brightness) {
    return brightness == Brightness.dark ? darkBorder : lightBorder;
  }

  static Color title(Brightness brightness) {
    return brightness == Brightness.dark ? textPrimary : textPrimaryDark;
  }

  static Color body(Brightness brightness) {
    return brightness == Brightness.dark
        ? textSecondary
        : textSecondaryDark;
  }

  static Color caption(Brightness brightness) {
    return brightness == Brightness.dark ? textMuted : textMutedDark;
  }
}
