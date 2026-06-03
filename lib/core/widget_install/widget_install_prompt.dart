import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final shouldInstall =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(l10n.widgetInstallTitle),
              content: Text(l10n.widgetInstallMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.later),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.widgetInstallAction),
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
      SnackBar(
        content: Text(l10n.widgetInstallManual),
        backgroundColor: AppColors.darkSurface,
      ),
    );
  }
}
