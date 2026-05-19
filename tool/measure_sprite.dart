// 어두운 타일 직사각형의 실제 경계를 자동 감지
// 타일은 반투명 어두운 카드 (alpha값 높고 어두움), 배경은 더 어두운 그라디언트
// 각 픽셀의 밝기를 기준으로 카드 영역을 찾는다.

import 'dart:io';
import 'package:image/image.dart' as img;

Future<void> main() async {
  final decoded = img.decodePng(await File('etc/Wd_icon.png').readAsBytes())!;
  final W = decoded.width;
  final H = decoded.height;

  // 각 행의 수평 밝기 프로파일 → 타일 경계 찾기
  // 각 열(수직선)의 평균 밝기
  final colBrightness = List<double>.filled(W, 0);
  final rowBrightness = List<double>.filled(H, 0);

  for (var y = 0; y < H; y++) {
    for (var x = 0; x < W; x++) {
      final p = decoded.getPixel(x, y);
      final lum = (p.r + p.g + p.b) / 3;
      colBrightness[x] += lum;
      rowBrightness[y] += lum;
    }
  }
  for (var x = 0; x < W; x++) {
    colBrightness[x] /= H;
  }
  for (var y = 0; y < H; y++) {
    rowBrightness[y] /= W;
  }

  // 로컬 피크(밝은 영역, 타일 내부) 찾기
  // 타일은 배경보다 밝음 (더 밝은 글래스)
  final colMin = colBrightness.reduce((a, b) => a < b ? a : b);
  final colMax = colBrightness.reduce((a, b) => a > b ? a : b);
  final threshold = colMin + (colMax - colMin) * 0.55;

  stdout.writeln('col min=${colMin.toStringAsFixed(1)}, '
      'max=${colMax.toStringAsFixed(1)}, '
      'threshold=${threshold.toStringAsFixed(1)}');

  // 연속된 밝은 구간을 찾음
  final tileXRanges = <List<int>>[];
  int? start;
  for (var x = 0; x < W; x++) {
    if (colBrightness[x] > threshold) {
      start ??= x;
    } else {
      if (start != null) {
        tileXRanges.add([start, x - 1]);
        start = null;
      }
    }
  }
  if (start != null) tileXRanges.add([start, W - 1]);

  stdout.writeln('\n발견된 X 구간 (${tileXRanges.length}):');
  for (final r in tileXRanges) {
    stdout.writeln('  x=${r[0]}~${r[1]}  (w=${r[1] - r[0] + 1})');
  }

  // 행 방향도 동일
  final rowMin = rowBrightness.reduce((a, b) => a < b ? a : b);
  final rowMax = rowBrightness.reduce((a, b) => a > b ? a : b);
  final rowThreshold = rowMin + (rowMax - rowMin) * 0.55;

  final tileYRanges = <List<int>>[];
  start = null;
  for (var y = 0; y < H; y++) {
    if (rowBrightness[y] > rowThreshold) {
      start ??= y;
    } else {
      if (start != null) {
        tileYRanges.add([start, y - 1]);
        start = null;
      }
    }
  }
  if (start != null) tileYRanges.add([start, H - 1]);

  stdout.writeln('\n발견된 Y 구간 (${tileYRanges.length}):');
  for (final r in tileYRanges) {
    stdout.writeln('  y=${r[0]}~${r[1]}  (h=${r[1] - r[0] + 1})');
  }
}
