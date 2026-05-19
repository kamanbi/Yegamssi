import 'package:flutter/material.dart';

/// 3D 광택 효과 진행 바 (운세 카테고리 점수 + 오행 분석에서 재사용)
class Fortune3dBar extends StatelessWidget {
  const Fortune3dBar({
    super.key,
    required this.value, // 0.0 ~ 1.0
    required this.color,
    this.height = 8.0,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _Bar3dPainter(
          value: value.clamp(0.0, 1.0),
          color: color,
          barHeight: height,
        ),
      ),
    );
  }
}

class _Bar3dPainter extends CustomPainter {
  const _Bar3dPainter({
    required this.value,
    required this.color,
    required this.barHeight,
  });
  final double value;
  final Color color;
  final double barHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final r = barHeight / 2;
    final w = size.width;
    final h = size.height;

    // 1. Background groove (dark shadow — sunken look)
    final bgGroove = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(r),
    );
    canvas.drawRRect(bgGroove, Paint()..color = Colors.black.withAlpha(80));

    // 2. Background fill (dark inner)
    final bgFill = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, w - 2, h - 2),
      Radius.circular(r - 1),
    );
    canvas.drawRRect(bgFill, Paint()..color = Colors.white.withAlpha(18));

    if (value <= 0) return;
    final fillW = ((w - 2) * value).clamp(h, w - 2);

    // 3. Glow layer (blurred behind fill)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, fillW, h - 2),
        Radius.circular(r - 1),
      ),
      Paint()
        ..color = color.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 4. Filled bar with gradient (dark left → bright right)
    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, fillW, h - 2),
      Radius.circular(r - 1),
    );
    final gradient = LinearGradient(
      colors: [color.withAlpha(160), color, color.withAlpha(220)],
      stops: const [0.0, 0.6, 1.0],
    );
    canvas.drawRRect(
      fillRect,
      Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, fillW, h)),
    );

    // 5. Top highlight (white sheen on upper 1/3)
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, fillW, (h - 2) * 0.4),
      Radius.circular(r - 1),
    );
    canvas.drawRRect(
      highlightRect,
      Paint()..color = Colors.white.withAlpha(55),
    );

    // 6. End cap shine
    final capX = 1 + fillW - r;
    final capY = h / 2;
    canvas.drawCircle(
      Offset(capX, capY),
      r * 0.45,
      Paint()..color = Colors.white.withAlpha(120),
    );
  }

  @override
  bool shouldRepaint(_Bar3dPainter old) =>
      old.value != value || old.color != color || old.barHeight != barHeight;
}
