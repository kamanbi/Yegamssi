// 각 행에서 라벨 TOP 경계를 아래→위 스캔으로 검출
// 라벨은 타일 하단에 위치. 아래에서 위로 올라가며 화이트 밀도 급감 지점을 찾음.
import 'dart:io';
import 'package:image/image.dart' as img;

Future<void> main() async {
  final decoded = img.decodePng(await File('etc/Wd_icon.png').readAsBytes())!;

  const mx = 30, my = 28, gx = 24, gy = 16;
  const cols = 5, rows = 3;
  final tw = (decoded.width - mx * 2 - gx * (cols - 1)) ~/ cols;
  final th = (decoded.height - my * 2 - gy * (rows - 1)) ~/ rows;

  for (var r = 0; r < rows; r++) {
    stdout.writeln('\n== row $r (tile ${tw}×$th) ==');
    // 각 상대 y에 대해: 모든 타일의 white 픽셀 카운트 합산
    final whiteRow = List<int>.filled(th, 0);
    for (var c = 0; c < cols; c++) {
      final tx = mx + c * (tw + gx);
      final ty = my + r * (th + gy);
      for (var dy = 0; dy < th; dy++) {
        for (var dx = 0; dx < tw; dx++) {
          final p = decoded.getPixel(tx + dx, ty + dy);
          final R = p.r.toInt(), G = p.g.toInt(), B = p.b.toInt();
          if (R > 200 && G > 200 && B > 200) {
            final maxCh = [R, G, B].reduce((a, b) => a > b ? a : b);
            final minCh = [R, G, B].reduce((a, b) => a < b ? a : b);
            if (maxCh - minCh < 30) whiteRow[dy]++;
          }
        }
      }
    }

    // 전체 평균·최대
    var totalMax = 0;
    for (final w in whiteRow) { if (w > totalMax) totalMax = w; }

    // 하단 50% 영역 중 가장 밀집된 밴드 찾기 (라벨 영역)
    final half = th ~/ 2;
    var labelPeakY = half;
    var labelPeakV = 0;
    for (var y = half; y < th; y++) {
      if (whiteRow[y] > labelPeakV) { labelPeakV = whiteRow[y]; labelPeakY = y; }
    }
    // 라벨 피크에서 위로 스캔, 밀도가 피크의 15% 이하가 되는 y = 라벨 top
    final topThreshold = labelPeakV * 0.15;
    var labelTop = labelPeakY;
    for (var y = labelPeakY; y >= 0; y--) {
      if (whiteRow[y] <= topThreshold) { labelTop = y + 1; break; }
    }
    stdout.writeln('  white max (overall): $totalMax');
    stdout.writeln('  label peak y=$labelPeakY (v=$labelPeakV)');
    stdout.writeln('  label top y=$labelTop (${(labelTop / th * 100).toStringAsFixed(1)}%)');
    stdout.writeln('  → 크롭 frac = ${((labelTop - 6) / th).toStringAsFixed(3)}');
  }
}
