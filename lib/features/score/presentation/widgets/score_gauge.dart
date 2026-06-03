import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/score_tier.dart';

class ScoreGauge extends StatelessWidget {
  const ScoreGauge({super.key, required this.score, required this.tier});

  final int score;
  final ScoreTier tier;

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$score',
              style: TextStyle(
                color: color,
                fontSize: 72,
                fontWeight: FontWeight.w200,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                ' / 100',
                style: TextStyle(
                  color: color.withAlpha(160),
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _tierLabel(l10n, tier),
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 22,
          child: CustomPaint(
            painter: _ZoneGaugePainter(score: score),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _ZoneLabel(text: l10n.scoreTierPoor),
            _ZoneLabel(text: l10n.scoreTierFair),
            _ZoneLabel(text: l10n.scoreTierGood),
            _ZoneLabel(text: l10n.scoreTierExcellent),
          ],
        ),
      ],
    );
  }

  Color get _color {
    if (score >= 75) return AppColors.scoreExcellent;
    if (score >= 50) return AppColors.scoreGood;
    if (score >= 25) return AppColors.scoreFair;
    return AppColors.scorePoor;
  }

  String _tierLabel(AppLocalizations l10n, ScoreTier tier) {
    return switch (tier) {
      ScoreTier.excellent => l10n.scoreTierExcellent,
      ScoreTier.good => l10n.scoreTierGood,
      ScoreTier.fair => l10n.scoreTierFair,
      ScoreTier.poor => l10n.scoreTierPoor,
    };
  }
}

class _ZoneLabel extends StatelessWidget {
  const _ZoneLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ZoneGaugePainter extends CustomPainter {
  const _ZoneGaugePainter({required this.score});

  final int score;

  static const _zoneColors = [
    AppColors.scorePoor,
    AppColors.scoreFair,
    AppColors.scoreGood,
    AppColors.scoreExcellent,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height / 2;
    final width = size.width;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, size.height),
        Radius.circular(radius),
      ),
      Paint()..color = Colors.black.withAlpha(70),
    );

    for (var index = 0; index < 4; index++) {
      final left = width * index / 4;
      final right = width * (index + 1) / 4;
      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTRB(left, 0, right, size.height),
        topLeft: Radius.circular(index == 0 ? radius : 0),
        bottomLeft: Radius.circular(index == 0 ? radius : 0),
        topRight: Radius.circular(index == 3 ? radius : 0),
        bottomRight: Radius.circular(index == 3 ? radius : 0),
      );
      canvas.drawRRect(
        rrect,
        Paint()..color = _zoneColors[index].withAlpha(45),
      );
    }

    for (final percent in [0.25, 0.5, 0.75]) {
      final x = width * percent;
      canvas.drawLine(
        Offset(x, 2),
        Offset(x, size.height - 2),
        Paint()
          ..color = Colors.black.withAlpha(100)
          ..strokeWidth = 1.5,
      );
    }

    if (score <= 0) return;

    final fillWidth = width * score.clamp(0, 100) / 100;
    final zoneColor = _zoneColors[_zoneIndex];

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -3, fillWidth, size.height + 6),
        Radius.circular(radius + 3),
      ),
      Paint()
        ..color = zoneColor.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    final gradient = LinearGradient(
      colors: [
        AppColors.scorePoor.withAlpha(210),
        AppColors.scoreFair.withAlpha(210),
        AppColors.scoreGood.withAlpha(210),
        AppColors.scoreExcellent.withAlpha(210),
      ],
      stops: const [0, 0.33, 0.66, 1],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, fillWidth, size.height),
        Radius.circular(radius),
      ),
      Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, width, size.height),
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, fillWidth, size.height * 0.45),
        Radius.circular(radius),
      ),
      Paint()..color = Colors.white.withAlpha(55),
    );

    final point = Offset(fillWidth, size.height / 2);
    canvas.drawCircle(
      point,
      radius + 5,
      Paint()
        ..color = zoneColor.withAlpha(90)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(point, radius + 1, Paint()..color = Colors.white);
    canvas.drawCircle(point, radius * 0.6, Paint()..color = zoneColor);
  }

  int get _zoneIndex {
    if (score >= 75) return 3;
    if (score >= 50) return 2;
    if (score >= 25) return 1;
    return 0;
  }

  @override
  bool shouldRepaint(_ZoneGaugePainter oldDelegate) =>
      oldDelegate.score != score;
}
