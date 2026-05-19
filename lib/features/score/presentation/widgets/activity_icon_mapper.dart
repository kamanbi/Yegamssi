import 'package:flutter/material.dart';

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
          label: '야외활동 추천',
          widgetSymbol: '🏃',
        ),
      ScoreTier.good => const ActivityVisualSpec(
          icon: Icons.hiking_rounded,
          color: Color(0xFF8EE086),
          label: '가벼운 활동 적합',
          widgetSymbol: '🚶',
        ),
      ScoreTier.fair => const ActivityVisualSpec(
          icon: Icons.shield_moon_rounded,
          color: Color(0xFFFFD166),
          label: '주의가 필요한 날',
          widgetSymbol: '⚠',
        ),
      ScoreTier.poor => const ActivityVisualSpec(
          icon: Icons.weekend_rounded,
          color: Color(0xFFFF8A80),
          label: '실내 활동 권장',
          widgetSymbol: '🛋',
        ),
    };
  }
}
