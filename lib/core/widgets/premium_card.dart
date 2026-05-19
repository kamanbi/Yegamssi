import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../design/app_radius.dart';
import '../design/app_shadows.dart';
import '../design/app_spacing.dart';

enum PremiumCardTone { neutral, muted, accent }

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.tone = PremiumCardTone.neutral,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final PremiumCardTone tone;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = switch (tone) {
      PremiumCardTone.neutral => AppColors.surface(brightness),
      PremiumCardTone.muted => AppColors.mutedSurface(brightness),
      PremiumCardTone.accent => colorScheme.secondary.withAlpha(
          brightness == Brightness.dark ? 48 : 18,
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border(brightness)),
        boxShadow: AppShadows.surface(brightness),
      ),
      child: Padding(
        padding: padding ?? AppSpacing.card,
        child: child,
      ),
    );
  }
}

class HeroGlassCard extends StatelessWidget {
  const HeroGlassCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    return ClipRRect(
      borderRadius: AppRadius.heroCard,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.heroCard,
            border: Border.all(color: AppColors.glassBorder),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withAlpha(brightness == Brightness.dark ? 44 : 92),
                colorScheme.primary.withAlpha(
                  brightness == Brightness.dark ? 88 : 54,
                ),
                colorScheme.secondary.withAlpha(
                  brightness == Brightness.dark ? 72 : 36,
                ),
              ],
            ),
            boxShadow: AppShadows.hero(brightness),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -36,
                right: -18,
                child: Container(
                  width: 180,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withAlpha(
                          brightness == Brightness.dark ? 54 : 120,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding ?? AppSpacing.hero,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
