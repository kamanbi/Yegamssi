import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/app_colors.dart';
import '../storage/local_storage.dart';

class WidgetInstallPromptController {
  WidgetInstallPromptController._();

  static const MethodChannel _channel = MethodChannel('yegamssi/widget');
  static const String _launchCountKey = 'widget_prompt_launch_count';
  static const String _handledKeyPrefix = 'widget_prompt_policy_v2_handled';
  static const int _promptLaunchCount = 1;

  static bool _checking = false;

  static Future<void> showIfNeeded(BuildContext context) async {
    if (_checking || !context.mounted) return;
    _checking = true;

    try {
      final handledKey = await _currentHandledKey();
      final handled = await LocalStorage.getBool(handledKey) ?? false;
      final launchCount = (await LocalStorage.getInt(_launchCountKey) ?? 0) + 1;
      await LocalStorage.setInt(_launchCountKey, launchCount);

      if (handled || launchCount < _promptLaunchCount || !context.mounted) {
        return;
      }

      await _showDialog(context, handledKey: handledKey);
    } finally {
      _checking = false;
    }
  }

  static Future<String> _currentHandledKey() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${_handledKeyPrefix}_${packageInfo.version}_${packageInfo.buildNumber}';
  }

  static Future<bool> _requestPinWidget() async {
    try {
      return await _channel.invokeMethod<bool>('requestPinWidget') ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> _showDialog(
    BuildContext context, {
    required String handledKey,
  }) async {
    final shouldInstall =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text(
                '\uC608\uAC10\uC528 \uC704\uC82F\uC744 \uCD94\uAC00\uD574\uBCF4\uC138\uC694',
              ),
              content: const Text(
                '\uD648 \uD654\uBA74\uC5D0\uC11C \uB0A0\uC528, \uAE30\uC628, \uC57C\uC678 \uC810\uC218, \uC6B4\uC138\uB97C \uBC14\uB85C \uD655\uC778\uD560 \uC218 \uC788\uC2B5\uB2C8\uB2E4.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('\uB098\uC911\uC5D0'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('\uC704\uC82F \uC124\uCE58'),
                ),
              ],
            );
          },
        ) ??
        false;

    await LocalStorage.setBool(handledKey, true);
    if (!shouldInstall) {
      return;
    }

    final requested = await _requestPinWidget();
    if (!context.mounted || requested) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '\uD648 \uD654\uBA74\uC744 \uAE38\uAC8C \uB20C\uB7EC \uC608\uAC10\uC528 \uC704\uC82F\uC744 \uCD94\uAC00\uD574 \uC8FC\uC138\uC694.',
        ),
        backgroundColor: AppColors.darkSurface,
      ),
    );
  }
}
