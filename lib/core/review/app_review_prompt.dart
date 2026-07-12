import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../storage/local_storage.dart';
import '../version/app_update_service.dart';

class AppReviewPromptController {
  AppReviewPromptController._();

  static const String _launchCountKey = 'app_review_prompt_launch_count';
  static const String _completedKey = 'app_review_prompt_completed';
  static const String _shownKeyPrefix = 'app_review_prompt_shown_';
  static const List<int> _promptLaunchCounts = [3, 20, 50];

  static bool _checking = false;

  static Future<void> showIfNeeded(BuildContext context) async {
    if (_checking || !context.mounted) return;
    _checking = true;

    try {
      final completed = await LocalStorage.getBool(_completedKey) ?? false;
      final launchCount = (await LocalStorage.getInt(_launchCountKey) ?? 0) + 1;
      await LocalStorage.setInt(_launchCountKey, launchCount);

      if (completed ||
          !_promptLaunchCounts.contains(launchCount) ||
          !context.mounted) {
        return;
      }

      final shownKey = '$_shownKeyPrefix$launchCount';
      final shown = await LocalStorage.getBool(shownKey) ?? false;
      if (shown) {
        return;
      }
      await LocalStorage.setBool(shownKey, true);

      if (!context.mounted) return;
      await _showDialog(context);
    } finally {
      _checking = false;
    }
  }

  static Future<void> openStoreReview() async {
    if (await openStoreListing()) {
      return;
    }

    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
      return;
    }
    await inAppReview.openStoreListing();
  }

  static Future<bool> openStoreListing() async {
    final marketUri = Uri.parse('market://details?id=com.yegamssi.yegamssi');
    if (await canLaunchUrl(marketUri)) {
      return launchUrl(marketUri, mode: LaunchMode.externalApplication);
    }

    final webUri = Uri.parse(AppUpdateService.defaultPlayStoreUrl);
    if (await canLaunchUrl(webUri)) {
      return launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static Future<void> _showDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final shouldReview =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(l10n.appReviewTitle),
              content: Text(l10n.appReviewMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.appReviewLater),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.appReviewAction),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldReview) {
      return;
    }
    await LocalStorage.setBool(_completedKey, true);

    await openStoreReview();
  }
}
