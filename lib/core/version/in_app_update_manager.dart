import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

/// 구글 플레이 스토어 인앱 업데이트 관리
class InAppUpdateManager {
  static final InAppUpdateManager _instance = InAppUpdateManager._internal();

  factory InAppUpdateManager() {
    return _instance;
  }

  InAppUpdateManager._internal();

  /// 앱 시작 시 업데이트 확인 (권장 또는 필수)
  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (!context.mounted) return;

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        _logger.i('업데이트 가능');

        // 즉시 업데이트 (권장)
        _showUpdateDialog(
          context,
          0,
          isFlexible: true,
        );
      } else if (info.updateAvailability == UpdateAvailability.updateNotAvailable) {
        _logger.i('최신 버전입니다');
      }
    } catch (e, st) {
      _logger.w('업데이트 확인 실패', error: e, stackTrace: st);
    }
  }

  void _showUpdateDialog(
    BuildContext context,
    int newVersionCode, {
    required bool isFlexible,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('앱 업데이트'),
        content: const Text('새로운 버전이 있습니다.\n지금 업데이트하시겠어요?'),
        actions: [
          if (isFlexible)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('나중에'),
            ),
          TextButton(
            onPressed: () => _performUpdate(context, isFlexible: isFlexible),
            child: const Text(
              '업데이트',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performUpdate(
    BuildContext context, {
    required bool isFlexible,
  }) async {
    try {
      if (isFlexible) {
        // 즉시 업데이트 (플레이 스토어 앱 내 업데이트 UI)
        await InAppUpdate.performImmediateUpdate();
      } else {
        // 유연한 업데이트 (백그라운드 다운로드 후 나중에 설치)
        await InAppUpdate.startFlexibleUpdate();
      }
      if (context.mounted) Navigator.pop(context);
    } catch (e, st) {
      _logger.w('업데이트 시작 실패', error: e, stackTrace: st);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
