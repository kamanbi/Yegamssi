import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/utils/location_provider.dart';
import '../../../core/version/app_update_service.dart';
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

    // 애니메이션과 동시에 데이터 갱신 시작 (3초 동안 병렬 처리)
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

    // initState에서 이미 시작된 warmup 완료 대기 (최대 1초)
    // 3초 애니메이션 동안 대부분 완료됨
    await Future.any([
      _warmupFuture ?? Future.value(),
      Future.delayed(const Duration(seconds: 1)),
    ]).catchError((_) {});
    if (!mounted) return;

    await _showReleaseNoticeIfNeeded();
    if (!mounted) return;

    final profile = ref.read(userProfileNotifierProvider).valueOrNull;
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
        return AlertDialog(
          title: const Text('예감씨 업데이트 안내'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReleaseNoticeItem('운세 멘트 옵션이 추가되었습니다.'),
              _ReleaseNoticeItem('기본, 유머, 츤데레, 시니컬, 감성, 사극, AI 톤을 선택할 수 있습니다.'),
              _ReleaseNoticeItem('위젯 갱신 시간이 30분에서 15분으로 변경되었습니다.'),
              _ReleaseNoticeItem('운세 명리학 로직 일부를 수정했습니다.'),
              _ReleaseNoticeItem('대기질 정보가 표시되지 않던 오류를 수정했습니다.'),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('확인'),
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
      if (profile == null) return; // 프로필 없음 → 온보딩으로 이동, 갱신 불필요

      final position = await ref.read(currentPositionProvider.future);

      // 날씨·점수·운세 동시 시작 (Riverpod가 의존성 순서 자동 관리)
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
            return AlertDialog(
              title: Text(decision.requiresUpdate ? '업데이트 필요' : '업데이트 안내'),
              content: Text(
                decision.requiresUpdate
                    ? '현재 버전 ${decision.currentVersion}은 더 이상 지원되지 않습니다.\n최신 버전 ${decision.latestVersion}으로 업데이트해 주세요.'
                    : '새 버전 ${decision.latestVersion}이 준비되었습니다.\n지금 업데이트하시겠어요?',
              ),
              actions: [
                if (!decision.requiresUpdate)
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('나중에'),
                  ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('업데이트'),
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
            return AlertDialog(
              title: const Text('업데이트 안내'),
              content: const Text('새 버전이 출시되었습니다.\n지금 업데이트하시겠어요?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('나중에'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('업데이트'),
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

class _ReleaseNoticeItem extends StatelessWidget {
  const _ReleaseNoticeItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
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
