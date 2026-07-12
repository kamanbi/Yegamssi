import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final radius = BorderRadius.circular(28);
    final baseColor =
        backgroundColor ??
        (isDark
            ? AppColors.darkSurface.withAlpha(150)
            : AppColors.lightSurfaceMuted.withAlpha(210));
    final outlineColor =
        borderColor ?? (isDark ? AppColors.glassBorder : AppColors.lightBorder);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isDark ? 18 : 10,
          sigmaY: isDark ? 18 : 10,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withAlpha(32),
                      baseColor,
                      AppColors.waterSurface.withAlpha(80),
                    ]
                  : [
                      Colors.white.withAlpha(184),
                      baseColor,
                      AppColors.waterMist.withAlpha(116),
                    ],
            ),
            border: Border.all(color: outlineColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 56 : 18),
                blurRadius: isDark ? 30 : 24,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: AppColors.skyGlow.withAlpha(isDark ? 28 : 24),
                blurRadius: isDark ? 24 : 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -16,
                left: -8,
                child: _HighlightBubble(
                  width: 150,
                  height: 86,
                  borderRadius: BorderRadius.circular(80),
                  colors: [
                    Colors.white.withAlpha(isDark ? 120 : 96),
                    Colors.white.withAlpha(isDark ? 14 : 20),
                  ],
                ),
              ),
              Positioned(
                left: 18,
                bottom: 18,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.waterMist.withAlpha(isDark ? 44 : 54),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: 1.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withAlpha(isDark ? 170 : 132),
                        Colors.white.withAlpha(isDark ? 38 : 42),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding ?? const EdgeInsets.all(20),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightBubble extends StatelessWidget {
  const _HighlightBubble({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.colors,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }
}
