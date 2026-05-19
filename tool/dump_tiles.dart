// 각 타일 영역을 있는 그대로 저장 (아이콘+라벨 포함)
import 'dart:io';
import 'package:image/image.dart' as img;

Future<void> main() async {
  final decoded = img.decodePng(await File('etc/Wd_icon.png').readAsBytes())!;
  stdout.writeln('${decoded.width}×${decoded.height}');

  // 다양한 margin/gap 조합 시도
  final configs = [
    {'name': 'a', 'mx': 30, 'my': 28, 'gx': 24, 'gy': 16},
    {'name': 'b', 'mx': 20, 'my': 20, 'gx': 10, 'gy': 10},
    {'name': 'c', 'mx': 40, 'my': 35, 'gx': 30, 'gy': 25},
  ];

  for (final cfg in configs) {
    final mx = cfg['mx'] as int, my = cfg['my'] as int;
    final gx = cfg['gx'] as int, gy = cfg['gy'] as int;
    final tw = (decoded.width - mx * 2 - gx * 4) ~/ 5;
    final th = (decoded.height - my * 2 - gy * 2) ~/ 3;
    stdout.writeln('cfg ${cfg['name']}: tile=${tw}x$th '
        'm=($mx,$my) gap=($gx,$gy)');
    final out = Directory('tool/_tiles_${cfg['name']}')..createSync(recursive: true);
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 5; c++) {
        final tx = mx + c * (tw + gx);
        final ty = my + r * (th + gy);
        final cropped = img.copyCrop(decoded, x: tx, y: ty, width: tw, height: th);
        await File('${out.path}/r${r}_c$c.png').writeAsBytes(img.encodePng(cropped));
      }
    }
  }
}
