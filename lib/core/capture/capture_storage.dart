import 'package:flutter/services.dart';

class CaptureStorage {
  CaptureStorage._();

  static const MethodChannel _channel = MethodChannel('yegamssi/capture');

  static Future<String?> savePng({
    required Uint8List bytes,
    required String fileName,
  }) {
    return _channel.invokeMethod<String>('savePng', {
      'bytes': bytes,
      'fileName': fileName,
    });
  }

  static Future<void> openCaptureFolder() {
    return _channel.invokeMethod<void>('openCaptureFolder');
  }
}
