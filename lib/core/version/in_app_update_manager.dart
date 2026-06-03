import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:logger/logger.dart';

import '../../l10n/app_localizations.dart';

final _logger = Logger();

class InAppUpdateManager {
  static final InAppUpdateManager _instance = InAppUpdateManager._internal();

  factory InAppUpdateManager() {
    return _instance;
  }

  InAppUpdateManager._internal();

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (!context.mounted) return;

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        _logger.i('Update available');
        _showUpdateDialog(context, isFlexible: true);
      } else if (info.updateAvailability ==
          UpdateAvailability.updateNotAvailable) {
        _logger.i('App is up to date');
      }
    } catch (e, st) {
      _logger.w('Update check failed', error: e, stackTrace: st);
    }
  }

  void _showUpdateDialog(BuildContext context, {required bool isFlexible}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.updateNoticeTitle),
          content: Text(l10n.updateNewVersionMessage),
          actions: [
            if (isFlexible)
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.later),
              ),
            TextButton(
              onPressed: () =>
                  _performUpdate(dialogContext, isFlexible: isFlexible),
              child: Text(
                l10n.updateAction,
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performUpdate(
    BuildContext context, {
    required bool isFlexible,
  }) async {
    try {
      if (isFlexible) {
        await InAppUpdate.performImmediateUpdate();
      } else {
        await InAppUpdate.startFlexibleUpdate();
      }
      if (context.mounted) Navigator.pop(context);
    } catch (e, st) {
      _logger.w('Update start failed', error: e, stackTrace: st);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
