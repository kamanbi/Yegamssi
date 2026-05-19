import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../design/app_radius.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(_lightScheme());
  static ThemeData get dark => _buildTheme(_darkScheme());

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final titleColor = AppColors.title(colorScheme.brightness);
    final bodyColor = AppColors.body(colorScheme.brightness);
    final captionColor = AppColors.caption(colorScheme.brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: titleColor),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: titleColor),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: titleColor),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: titleColor,
        ),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: titleColor),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: titleColor),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: bodyColor),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: bodyColor),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: titleColor),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: bodyColor),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: captionColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: titleColor,
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: titleColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTextStyles.titleMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: titleColor,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTextStyles.titleMedium.copyWith(color: titleColor),
        ),
      ),
      dividerColor: colorScheme.outlineVariant,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark
            ? AppColors.darkSurface.withAlpha(230)
            : AppColors.lightSurface.withAlpha(235),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: captionColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: captionColor,
        ),
      ),
    );
  }

  static ColorScheme _lightScheme() {
    return ColorScheme.fromSeed(seedColor: AppColors.primaryBlue).copyWith(
      primary: AppColors.primaryBlue,
      onPrimary: Colors.white,
      secondary: AppColors.secondaryPurple,
      onSecondary: Colors.white,
      tertiary: AppColors.accentGold,
      onTertiary: const Color(0xFF271A04),
      surface: AppColors.lightBackground,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: const Color(0x33244A7B),
      outlineVariant: AppColors.lightBorder,
      shadow: const Color(0x1A244A7B),
      scrim: const Color(0x6607111F),
      inverseSurface: AppColors.darkSurface,
      onInverseSurface: AppColors.textPrimary,
      inversePrimary: const Color(0xFFB9C7FF),
    );
  }

  static ColorScheme _darkScheme() {
    return ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF96A8FF),
      onPrimary: const Color(0xFF11204C),
      secondary: const Color(0xFFC3B8FF),
      onSecondary: const Color(0xFF241A57),
      tertiary: const Color(0xFFE4C17E),
      onTertiary: const Color(0xFF2B2108),
      surface: AppColors.darkBackground,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: const Color(0x4DFFFFFF),
      outlineVariant: AppColors.darkBorder,
      shadow: const Color(0x4D000000),
      scrim: const Color(0xB3000000),
      inverseSurface: AppColors.lightSurface,
      onInverseSurface: AppColors.textPrimaryDark,
      inversePrimary: AppColors.primaryBlue,
    );
  }
}
