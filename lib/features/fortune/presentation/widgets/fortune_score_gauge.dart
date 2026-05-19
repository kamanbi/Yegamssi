import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class FortuneScoreGauge extends StatelessWidget {
  const FortuneScoreGauge({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(72, 72),
                painter: _FortuneGaugePainter(score: score, color: _color),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      color: _color,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: TextStyle(color: _color.withAlpha(180), fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _label,
          style: TextStyle(
            color: _color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
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

  String get _label {
    if (score >= 75) return '매우 좋음';
    if (score >= 50) return '좋음';
    if (score >= 25) return '보통';
    return '주의';
  }
}

class _FortuneGaugePainter extends CustomPainter {
  const _FortuneGaugePainter({required this.score, required this.color});
  final int score;
  final Color color;

  static const _startAngle = math.pi * 0.75; // 135°
  static const _totalSweep = math.pi * 1.5; // 270°
  static const _strokeWidth = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Glow layer behind arc (blurred)
    if (score > 0) {
      final sweep = _totalSweep * (score.clamp(0, 100) / 100);
      canvas.drawArc(
        rect,
        _startAngle,
        sweep,
        false,
        Paint()
          ..color = color.withAlpha(50)
          ..strokeWidth = _strokeWidth + 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    // 2. Background groove (dark shadow underneath)
    canvas.drawArc(
      rect,
      _startAngle,
      _totalSweep,
      false,
      Paint()
        ..color = Colors.black.withAlpha(80)
        ..strokeWidth = _strokeWidth + 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // 3. Background track
    canvas.drawArc(
      rect,
      _startAngle,
      _totalSweep,
      false,
      Paint()
        ..color = Colors.white.withAlpha(25)
        ..strokeWidth = _strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // 4. Score arc with gradient
    if (score > 0) {
      final sweep = _totalSweep * (score.clamp(0, 100) / 100);
      final gradient = SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + sweep,
        colors: [color.withAlpha(160), color],
      );
      canvas.drawArc(
        rect,
        _startAngle,
        sweep,
        false,
        Paint()
          ..shader = gradient.createShader(rect)
          ..strokeWidth = _strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      // 5. End cap highlight
      final endAngle = _startAngle + sweep;
      final capCenter = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );
      canvas.drawCircle(
        capCenter,
        _strokeWidth * 0.65,
        Paint()..color = color.withAlpha(160),
      );
      canvas.drawCircle(
        capCenter,
        _strokeWidth * 0.3,
        Paint()..color = Colors.white.withAlpha(220),
      );
    }
  }

  @override
  bool shouldRepaint(_FortuneGaugePainter old) =>
      old.score != score || old.color != color;
}
