import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../features/fortune/domain/entities/fortune_result.dart';
import '../../features/fortune/presentation/fortune_provider.dart';
import '../../features/score/presentation/score_provider.dart';
import '../../features/user/presentation/user_profile_provider.dart';
import '../../features/weather/presentation/weather_provider.dart';
import '../../features/widget_bridge/widget_snapshot_sync.dart';
import '../../l10n/app_localizations.dart';
import '../locale/country_resolver.dart';
import '../locale/locale_provider.dart';
import '../router/app_routes.dart';
import '../utils/location_provider.dart';
import '../version/app_update_service.dart';

class AppStartupContext {
  const AppStartupContext({
    required this.context,
    required this.ref,
    required this.isMounted,
  });

  final BuildContext context;
  final WidgetRef ref;
  final bool Function() isMounted;

  bool get mounted => isMounted() && context.mounted;
}

class AppStartupCoordinator {
  const AppStartupCoordinator(this.startupContext);

  static const _releaseNoticeKey = 'release_notice_20260518_fortune_tones_v1';
  static const _firstLaunchKey = 'app_first_launch_done';
  static const _warmupWait = Duration(milliseconds: 1500);

  final AppStartupContext startupContext;

  BuildContext get _context => startupContext.context;
  WidgetRef get _ref => startupContext.ref;
  bool get _mounted => startupContext.mounted;

  Future<bool> runAfterFirstFrame() async {
    final warmupFuture = _warmupCurrentSnapshot();
    const updateService = AppUpdateService();

    final shouldStop = await _handleAppUpdate(
      await updateService.check(),
      updateService,
    );
    if (!_mounted || shouldStop) {
      return false;
    }

    if (await updateService.hasPlayCoreUpdate()) {
      if (!_mounted) {
        return false;
      }
      await _handlePlayCoreUpdate(updateService);
    }
    if (!_mounted) {
      return false;
    }

    await Future.any<void>([
      warmupFuture,
      Future<void>.delayed(_warmupWait),
    ]).catchError((_) {});
    if (!_mounted) {
      return false;
    }

    await _showReleaseNoticeIfNeeded();
    if (!_mounted) {
      return false;
    }

    final profile =
        _ref.read(userProfileNotifierProvider).valueOrNull ??
        await _ref.read(userProfileNotifierProvider.future);
    final context = _context;
    if (!startupContext.isMounted() || !context.mounted) {
      return false;
    }
    if (profile == null) {
      context.go(AppRoutes.onboarding);
      return false;
    }

    return true;
  }

  Future<void> _showReleaseNoticeIfNeeded() async {
    final preferences = await SharedPreferences.getInstance();
    final isFirstLaunch = !(preferences.getBool(_firstLaunchKey) ?? false);

    if (isFirstLaunch) {
      await preferences.setBool(_firstLaunchKey, true);
      await preferences.setBool(_releaseNoticeKey, true);
      return;
    }
    if (preferences.getBool(_releaseNoticeKey) ?? false) {
      return;
    }
    final context = _context;
    if (!startupContext.isMounted() || !context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.updateNoticeTitle),
          content: Text(l10n.updateNewVersionMessage),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );

    await preferences.setBool(_releaseNoticeKey, true);
  }

  Future<void> _warmupCurrentSnapshot() async {
    try {
      final profile = await _ref.read(userProfileNotifierProvider.future);
      if (profile == null) {
        return;
      }

      final position = await _ref.read(currentPositionProvider.future);
      final weatherFuture = _ref.read(currentWeatherProvider.future);
      final scoreFuture = _ref.read(currentScoreProvider.future);
      final fortuneFuture = _ref
          .read(dailyFortuneProvider.future)
          .then<FortuneResult?>((fortune) => fortune)
          .catchError((_) => null);

      final weather = await weatherFuture;
      final score = await scoreFuture;
      final fortune = await fortuneFuture;
      final country = await _ref.read(resolvedCountryProvider.future);

      await syncWidgetSnapshot(
        weather: weather,
        score: score,
        latitude: position.lat,
        longitude: position.lon,
        language: _ref.read(appLanguageNotifierProvider),
        country: country,
        fortune: fortune,
      );
    } catch (_) {}
  }

  Future<bool> _handleAppUpdate(
    AppUpdateDecision? decision,
    AppUpdateService updateService,
  ) async {
    if (!_mounted || decision == null || !decision.shouldPrompt) {
      return false;
    }

    final shouldUpdate =
        await showDialog<bool>(
          context: _context,
          barrierDismissible: !decision.requiresUpdate,
          builder: (dialogContext) {
            final l10n = AppLocalizations.of(dialogContext);
            return AlertDialog(
              title: Text(
                decision.requiresUpdate
                    ? l10n.updateRequiredTitle
                    : l10n.updateNoticeTitle,
              ),
              content: Text(
                decision.requiresUpdate
                    ? l10n.updateRequiredMessage(
                        decision.currentVersion,
                        decision.latestVersion,
                      )
                    : l10n.updateAvailableMessage(decision.latestVersion),
              ),
              actions: [
                if (!decision.requiresUpdate)
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(l10n.later),
                  ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.updateAction),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldUpdate) {
      return false;
    }

    final updatedByPlayCore = await updateService.tryPlayCoreUpdate();
    if (!updatedByPlayCore) {
      await launchUrlString(
        decision.storeUrl,
        mode: LaunchMode.externalApplication,
      );
    }
    return decision.requiresUpdate;
  }

  Future<void> _handlePlayCoreUpdate(AppUpdateService updateService) async {
    final shouldUpdate =
        await showDialog<bool>(
          context: _context,
          builder: (dialogContext) {
            final l10n = AppLocalizations.of(dialogContext);
            return AlertDialog(
              title: Text(l10n.updateNoticeTitle),
              content: Text(l10n.updateNewVersionMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.later),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.updateAction),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldUpdate) {
      return;
    }

    final updatedByPlayCore = await updateService.tryPlayCoreUpdate();
    if (!updatedByPlayCore) {
      await launchUrlString(
        AppUpdateService.defaultPlayStoreUrl,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
