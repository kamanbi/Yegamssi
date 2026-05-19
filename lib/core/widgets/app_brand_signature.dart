import 'package:flutter/material.dart';

class AppBrandSignature extends StatelessWidget {
  const AppBrandSignature({super.key, this.width = 88, this.opacity = 0.86});

  final double width;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: SizedBox(
          width: width,
          child: FittedBox(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '예감씨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    shadows: [
                      Shadow(
                        color: Color(0x66000000),
                        offset: Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                CustomPaint(
                  size: const Size(14, 18),
                  painter: _BrandSparkPainter(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandSparkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFE4A3)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * 0.52, 0)
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.32,
        size.width * 0.78,
        size.height * 0.42,
        size.width,
        size.height * 0.50,
      )
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.60,
        size.width * 0.60,
        size.height * 0.72,
        size.width * 0.50,
        size.height,
      )
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.72,
        size.width * 0.24,
        size.height * 0.60,
        0,
        size.height * 0.50,
      )
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.40,
        size.width * 0.39,
        size.height * 0.30,
        size.width * 0.52,
        0,
      )
      ..close();
    canvas.drawPath(path, paint);

    final stroke = Paint()
      ..color = const Color(0xFFFFE4A3)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.88, size.height * 0.05),
      Offset(size.width * 1.12, size.height * -0.08),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
