// Wd_icon.png 스프라이트 → 15개 개별 PNG
//
// 전략: 각 타일에서 라벨 영역만 제외하고 카드+아이콘을 그대로 크롭.
//      카드 글래스 배경은 앱 디자인(글래스모피즘)과 자연스럽게 어우러짐.
//      결과: 정사각 512×512 (투명 패딩).
//
// 실행: dart run tool/slice_weather_icons.dart

import 'dart:io';
import 'package:image/image.dart' as img;

const _names = <String>[
  'sunny', 'partly_cloudy', 'cloudy', 'hazy', 'windy',
  'slight_rain', 'rain', 'heavy_rain', 'thunderstorm', 'rain_thunder',
  'light_snow', 'snow', 'sleet', 'hot', 'cold_wave',
];

Future<void> main() async {
  const inputPath = 'etc/Wd_icon.png';
  const outputDir = 'assets/icons/weather';

  final decoded = img.decodePng(await File(inputPath).readAsBytes())!;
  final srcW = decoded.width;
  final srcH = decoded.height;
  stdout.writeln('원본: ${srcW}×$srcH');

  // 타일 그리드
  const outerMarginX = 30;
  const outerMarginY = 28;
  const gapX = 24;
  const gapY = 16;
  const cols = 5;
  const rows = 3;

  final tileW = (srcW - outerMarginX * 2 - gapX * (cols - 1)) ~/ cols;
  final tileH = (srcH - outerMarginY * 2 - gapY * (rows - 1)) ~/ rows;
  stdout.writeln('타일: ${tileW}×$tileH');

  // 타일 상단부만 사용 (라벨 제외).
  // find_icon_bbox.dart 측정치 기반 (라벨 top - 2% 여유).
  // row 0 라벨 top 68.3%, row 1 58.0%, row 2 48.4%
  const rowCropFrac = <double>[0.66, 0.56, 0.46];

  await Directory(outputDir).create(recursive: true);

  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      final idx = r * cols + c;
      final name = _names[idx];

      final tileX = outerMarginX + c * (tileW + gapX);
      final tileY = outerMarginY + r * (tileH + gapY);
      final cropH = (tileH * rowCropFrac[r]).round();

      final cropped = img.copyCrop(
        decoded,
        x: tileX,
        y: tileY,
        width: tileW,
        height: cropH,
      );

      // 정사각 캔버스 (투명 패딩)
      final side = tileW > cropH ? tileW : cropH;
      final canvas = img.Image(width: side, height: side, numChannels: 4);
      img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));
      img.compositeImage(
        canvas,
        cropped,
        dstX: (side - tileW) ~/ 2,
        dstY: (side - cropH) ~/ 2,
      );

      final resized = img.copyResize(
        canvas,
        width: 512,
        height: 512,
        interpolation: img.Interpolation.cubic,
      );

      await File('$outputDir/$name.png').writeAsBytes(img.encodePng(resized));
      stdout.writeln('  [${(idx + 1).toString().padLeft(2)}/15] $name.png');
    }
  }

  stdout.writeln('\n완료 — $outputDir');
}
