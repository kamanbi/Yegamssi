import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/utils/location_provider.dart';
import '../../../core/version/app_update_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../fortune/domain/entities/fortune_result.dart';
import '../../fortune/presentation/fortune_provider.dart';
import '../../score/presentation/score_provider.dart';
import '../../user/presentation/user_profile_provider.dart';
import '../../weather/presentation/weather_provider.dart';
import '../../widget_bridge/widget_snapshot_sync.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _releaseNoticeKey = 'release_notice_20260518_fortune_tones_v1';

  late final AnimationController _controller;
  late final Animation<double> _progressAnim;
  late final Animation<double> _fadeAnim;
  Future<void>? _warmupFuture;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );

    _warmupFuture = _warmupSnapshot();

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _navigate();
      }
    });
  }

  Future<void> _navigate() async {
    const updateService = AppUpdateService();
    final shouldStopNavigation = await _handleAppUpdate(
      await updateService.check(),
      updateService,
    );
    if (!mounted || shouldStopNavigation) return;

    final shouldShowPlayCorePrompt = await updateService.hasPlayCoreUpdate();
    if (!mounted) return;
    if (shouldShowPlayCorePrompt) {
      await _handlePlayCoreUpdate(updateService);
      if (!mounted) return;
    }

    await Future.any([
      _warmupFuture ?? Future.value(),
      Future.delayed(const Duration(seconds: 3)),
    ]).catchError((_) {});
    if (!mounted) return;

    await _showReleaseNoticeIfNeeded();
    if (!mounted) return;

    final profile =
        ref.read(userProfileNotifierProvider).valueOrNull ??
        await ref.read(userProfileNotifierProvider.future);
    if (!mounted) return;
    context.go(profile != null ? AppRoutes.home : AppRoutes.onboarding);
  }

  Future<void> _showReleaseNoticeIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_releaseNoticeKey) ?? false) {
      return;
    }
    if (!mounted) return;

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

    await prefs.setBool(_releaseNoticeKey, true);
  }

  Future<void> _warmupSnapshot() async {
    try {
      final profile = await ref.read(userProfileNotifierProvider.future);
      if (profile == null) return;
      final position = await ref.read(currentPositionProvider.future);

      final weatherFuture = ref.read(currentWeatherProvider.future);
      final scoreFuture = ref.read(currentScoreProvider.future);
      final fortuneFuture = ref
          .read(dailyFortuneProvider.future)
          .then<FortuneResult?>((v) => v)
          .catchError((_) => null as FortuneResult?);

      final weather = await weatherFuture;
      final score = await scoreFuture;
      final fortune = await fortuneFuture;

      await syncWidgetSnapshot(
        weather: weather,
        score: score,
        latitude: position.lat,
        longitude: position.lon,
        fortune: fortune,
      );
    } catch (_) {}
  }

  Future<bool> _handleAppUpdate(
    AppUpdateDecision? decision,
    AppUpdateService updateService,
  ) async {
    if (!mounted || decision == null || !decision.shouldPrompt) {
      return false;
    }

    final shouldUpdate =
        await showDialog<bool>(
          context: context,
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
          context: context,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2B5E),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Image.asset(
                    'assets/images/ic_launcher.png',
                    width: 180,
                    height: 180,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 220,
                  height: 48,
                  child: CustomPaint(
                    painter: _HandDrawnProgressPainter(
                      progress: _progressAnim.value,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HandDrawnProgressPainter extends CustomPainter {
  _HandDrawnProgressPainter({required this.progress});

  final double progress;

  Path _wobblyRect(double left, double top, double right, double bottom) {
    const wobble = 1.5;
    final path = Path()
      ..moveTo(left + wobble, top - wobble)
      ..cubicTo(
        left + (right - left) * 0.3,
        top + wobble,
        left + (right - left) * 0.7,
        top - wobble,
        right - wobble,
        top + wobble,
      )
      ..cubicTo(
        right + wobble,
        top + (bottom - top) * 0.4,
        right - wobble,
        top + (bottom - top) * 0.7,
        right + wobble,
        bottom - wobble,
      )
      ..cubicTo(
        right - (right - left) * 0.3,
        bottom + wobble,
        right - (right - left) * 0.7,
        bottom - wobble,
        left + wobble,
        bottom + wobble,
      )
      ..cubicTo(
        left - wobble,
        bottom - (bottom - top) * 0.4,
        left + wobble,
        top + (bottom - top) * 0.6,
        left + wobble,
        top - wobble,
      )
      ..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    const barHeight = 22.0;
    const barTop = 0.0;
    const barBottom = barTop + barHeight;

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'LOADING ...',
        style: TextStyle(
          color: Color(0xFFAACCFF),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset((width - textPainter.width) / 2, -textPainter.height - 6),
    );

    final outlinePaint = Paint()
      ..color = const Color(0xFF4488CC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(_wobblyRect(0, barTop, width, barBottom), outlinePaint);
    if (progress <= 0) {
      return;
    }

    final fillWidth = (width * progress).clamp(0.0, width - 2);
    if (fillWidth <= 4) {
      return;
    }

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, barTop - 2, fillWidth + 2, barHeight + 4));

    final fillPaint = Paint()
      ..color = const Color(0xFF0D47A1)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(2, barTop + 2, fillWidth, barBottom - 2),
      fillPaint,
    );

    final highlightPaint = Paint()
      ..color = const Color(0xFF1565C0).withAlpha(180)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(2, barTop + 2, fillWidth, barTop + barHeight * 0.45),
      highlightPaint,
    );

    canvas.restore();

    final sketchPaint = Paint()
      ..color = Colors.white.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (double x = 8; x < fillWidth; x += 12) {
      canvas.drawLine(
        Offset(x, barTop + 3),
        Offset(x + 4, barBottom - 3),
        sketchPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_HandDrawnProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
