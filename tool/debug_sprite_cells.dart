// 스프라이트 시트 셀 위치 진단: 격자 라인을 그어 셀 경계 확인
import 'dart:io';
import 'package:image/image.dart' as img;

Future<void> main() async {
  final bytes = await File('etc/Wd_icon.png').readAsBytes();
  final decoded = img.decodePng(bytes)!;
  final srcW = decoded.width;
  final srcH = decoded.height;
  stdout.writeln('원본: ${srcW}×$srcH');

  // 그리드 라인을 그려서 셀 경계 확인
  final grid = img.Image.from(decoded);
  const cols = 5;
  const rows = 3;
  final cellW = srcW / cols;
  final cellH = srcH / rows;
  final red = img.ColorRgba8(255, 0, 0, 255);

  for (var c = 0; c <= cols; c++) {
    final x = (cellW * c).round().clamp(0, srcW - 1);
    img.drawLine(grid, x1: x, y1: 0, x2: x, y2: srcH - 1, color: red);
  }
  for (var r = 0; r <= rows; r++) {
    final y = (cellH * r).round().clamp(0, srcH - 1);
    img.drawLine(grid, x1: 0, y1: y, x2: srcW - 1, y2: y, color: red);
  }

  await File('tool/_debug_grid.png').writeAsBytes(img.encodePng(grid));
  stdout.writeln('그리드: tool/_debug_grid.png');

  // 각 셀을 있는 그대로 저장 (라벨 포함, 전체 영역)
  await Directory('tool/_debug_cells').create(recursive: true);
  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      final x0 = (cellW * c).round();
      final y0 = (cellH * r).round();
      final w = ((cellW * (c + 1)).round() - x0);
      final h = ((cellH * (r + 1)).round() - y0);
      final crop = img.copyCrop(decoded, x: x0, y: y0, width: w, height: h);
      await File('tool/_debug_cells/cell_r${r}_c$c.png')
          .writeAsBytes(img.encodePng(crop));
    }
  }
  stdout.writeln('개별 셀: tool/_debug_cells/');
}
