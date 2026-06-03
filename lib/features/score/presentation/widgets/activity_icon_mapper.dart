import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/score_tier.dart';

class ActivityVisualSpec {
  const ActivityVisualSpec({
    required this.icon,
    required this.color,
    required this.label,
    required this.widgetSymbol,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String widgetSymbol;
}

class ActivityIconMapper {
  ActivityIconMapper._();

  static ActivityVisualSpec specFor(ScoreTier tier) {
    return switch (tier) {
      ScoreTier.excellent => const ActivityVisualSpec(
        icon: Icons.directions_run_rounded,
        color: Color(0xFF62E49B),
        label: 'Outdoor activity recommended',
        widgetSymbol: 'RUN',
      ),
      ScoreTier.good => const ActivityVisualSpec(
        icon: Icons.hiking_rounded,
        color: Color(0xFF8EE086),
        label: 'Light activity fits',
        widgetSymbol: 'WALK',
      ),
      ScoreTier.fair => const ActivityVisualSpec(
        icon: Icons.shield_moon_rounded,
        color: Color(0xFFFFD166),
        label: 'Caution needed',
        widgetSymbol: 'CAUTION',
      ),
      ScoreTier.poor => const ActivityVisualSpec(
        icon: Icons.weekend_rounded,
        color: Color(0xFFFF8A80),
        label: 'Indoor activity recommended',
        widgetSymbol: 'INDOOR',
      ),
    };
  }

  static String localizedLabelFor(BuildContext context, ScoreTier tier) {
    final l10n = AppLocalizations.of(context);
    return switch (tier) {
      ScoreTier.excellent => l10n.activityRecommendOutdoor,
      ScoreTier.good => l10n.activityRecommendLight,
      ScoreTier.fair => l10n.activityRecommendCaution,
      ScoreTier.poor => l10n.activityRecommendIndoor,
    };
  }
}
