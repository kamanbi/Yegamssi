import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/score_tier.dart';

/// 프리미엄 수평 존 게이지
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({super.key, required this.score, required this.tier});

  final int score;
  final ScoreTier tier;

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Column(
      children: [
        // ── 점수 숫자 ──
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
                height: 1.0,
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
        // ── 티어 라벨 ──
        Text(
          tier.label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        // ── 수평 존 바 ──
        SizedBox(
          height: 22,
          child: CustomPaint(
            painter: _ZoneGaugePainter(score: score),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: 10),
        // ── 존 라벨 ──
        const Row(
          children: [
            Expanded(
              child: Text(
                '주의',
                style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                '보통',
                style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                '좋음',
                style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                '매우 좋음',
                style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
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
}

class _ZoneGaugePainter extends CustomPainter {
  const _ZoneGaugePainter({required this.score});
  final int score;

  static const _zoneColors = [
    AppColors.scorePoor, // D: 0~25
    AppColors.scoreFair, // C: 25~50
    AppColors.scoreGood, // B: 50~75
    AppColors.scoreExcellent, // A: 75~100
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2;
    final w = size.width;

    // ── 1. 배경 (어두운 홈) ──
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, size.height),
        Radius.circular(r),
      ),
      Paint()..color = Colors.black.withAlpha(70),
    );

    // ── 2. 존 배경 (연한 색) ──
    for (int i = 0; i < 4; i++) {
      final x1 = w * i / 4;
      final x2 = w * (i + 1) / 4;
      final col = _zoneColors[i];

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTRB(x1, 0, x2, size.height),
        topLeft: Radius.circular(i == 0 ? r : 0),
        bottomLeft: Radius.circular(i == 0 ? r : 0),
        topRight: Radius.circular(i == 3 ? r : 0),
        bottomRight: Radius.circular(i == 3 ? r : 0),
      );
      canvas.drawRRect(rrect, Paint()..color = col.withAlpha(45));
    }

    // ── 3. 존 구분선 ──
    for (final pct in [0.25, 0.5, 0.75]) {
      final x = w * pct;
      canvas.drawLine(
        Offset(x, 2),
        Offset(x, size.height - 2),
        Paint()
          ..color = Colors.black.withAlpha(100)
          ..strokeWidth = 1.5,
      );
    }

    // ── 4. 채워진 부분 (점수까지) ──
    if (score > 0) {
      final fillX = w * score.clamp(0, 100) / 100;

      // 글로우
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, -3, fillX, size.height + 6),
          Radius.circular(r + 3),
        ),
        Paint()
          ..color = _zoneColors[_zoneIndex].withAlpha(60)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // 그라데이션 채움
      final gradient = LinearGradient(
        colors: [
          AppColors.scorePoor.withAlpha(210),
          AppColors.scoreFair.withAlpha(210),
          AppColors.scoreGood.withAlpha(210),
          AppColors.scoreExcellent.withAlpha(210),
        ],
        stops: const [0.0, 0.33, 0.66, 1.0],
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, fillX, size.height),
          Radius.circular(r),
        ),
        Paint()
          ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, size.height)),
      );

      // 상단 광택
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, fillX, size.height * 0.45),
          Radius.circular(r),
        ),
        Paint()..color = Colors.white.withAlpha(55),
      );

      // ── 5. 포인터 ──
      final px = fillX;
      final py = size.height / 2;
      // 외부 글로우
      canvas.drawCircle(
        Offset(px, py),
        r + 5,
        Paint()
          ..color = _zoneColors[_zoneIndex].withAlpha(90)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // 흰 원
      canvas.drawCircle(Offset(px, py), r + 1, Paint()..color = Colors.white);
      // 내부 색상 원
      canvas.drawCircle(
        Offset(px, py),
        r * 0.6,
        Paint()..color = _zoneColors[_zoneIndex],
      );
    }
  }

  int get _zoneIndex {
    if (score >= 75) return 3;
    if (score >= 50) return 2;
    if (score >= 25) return 1;
    return 0;
  }

  @override
  bool shouldRepaint(_ZoneGaugePainter old) => old.score != score;
}
