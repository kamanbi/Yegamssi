// 스프라이트를 작게 리사이즈해서 출력 (레이아웃 확인용)
import 'dart:io';
import 'package:image/image.dart' as img;

Future<void> main() async {
  final decoded = img.decodePng(await File('etc/Wd_icon.png').readAsBytes())!;
  // 1536x1024 → 800으로 축소
  final small = img.copyResize(decoded, width: 800);
  await File('tool/_debug_small.png').writeAsBytes(img.encodePng(small));
  stdout.writeln('저장: tool/_debug_small.png (${small.width}x${small.height})');

  // 각 셀 중앙을 십자로 표시 (기본 5x3 가정)
  final marked = img.Image.from(small);
  final W = small.width, H = small.height;
  final cw = W / 5, ch = H / 3;
  final red = img.ColorRgba8(255, 0, 0, 255);
  for (var r = 0; r < 3; r++) {
    for (var c = 0; c < 5; c++) {
      final cx = (cw * c + cw / 2).round();
      final cy = (ch * r + ch / 2).round();
      img.drawLine(marked, x1: cx - 10, y1: cy, x2: cx + 10, y2: cy, color: red);
      img.drawLine(marked, x1: cx, y1: cy - 10, x2: cx, y2: cy + 10, color: red);
    }
  }
  await File('tool/_debug_centers.png').writeAsBytes(img.encodePng(marked));
  stdout.writeln('저장: tool/_debug_centers.png (셀 중앙점 표시)');
}
