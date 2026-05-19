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
    final radius = BorderRadius.circular(28);
    final baseColor = backgroundColor ?? AppColors.darkSurface.withAlpha(150);
    final outlineColor = borderColor ?? AppColors.glassBorder;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withAlpha(32),
                baseColor,
                AppColors.waterSurface.withAlpha(80),
              ],
            ),
            border: Border.all(color: outlineColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(56),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: AppColors.skyGlow.withAlpha(28),
                blurRadius: 24,
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
                    Colors.white.withAlpha(120),
                    Colors.white.withAlpha(14),
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
                    color: AppColors.waterMist.withAlpha(44),
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
                        Colors.white.withAlpha(170),
                        Colors.white.withAlpha(38),
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
