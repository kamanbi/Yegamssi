import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/background/background_refresh_permission_service.dart';
import '../../../core/config/admob_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design/app_radius.dart';
import '../../../core/design/app_shadows.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/locale/country_code.dart';
import '../../../core/locale/country_resolver.dart';
import '../../../core/refresh/refresh_policy.dart';
import '../../../core/storage/weather_cache_store.dart';
import '../../../core/utils/location_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/purchase/premium_provider.dart';
import '../../../core/review/app_review_prompt.dart';
import '../../../core/widget_install/widget_install_prompt.dart';
import '../../../l10n/app_localizations.dart';
import '../../fortune/domain/entities/fortune_result.dart';
import '../../fortune/presentation/fortune_provider.dart';
import '../../score/domain/entities/activity_score.dart';
import '../../score/presentation/score_provider.dart';
import '../../fortune/presentation/fortune_screen.dart';
import '../../home/presentation/home_tab_screen.dart';
import '../../monthly/presentation/monthly_yegamssi_screen.dart';
import '../../settings/presentation/app_info_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../weather/domain/entities/weather_entity.dart';
import '../../weather/presentation/weather_provider.dart';
import '../../weather/presentation/weather_screen.dart';
import '../../widget_bridge/widget_snapshot_sync.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  static const MethodChannel _appControlChannel = MethodChannel(
    'yegamssi/app_control',
  );
  // ── 전면 광고 ──────────────────────────────────────────────────
  static const Duration _minSessionDuration = Duration(minutes: 5);

  DateTime? _appOpenTime;
  InterstitialAd? _interstitialAd;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: ${error.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  bool get _isSessionLongEnough {
    final t = _appOpenTime;
    if (t == null) return false;
    return DateTime.now().difference(t) >= _minSessionDuration;
  }

  /// 전면 광고 표시 후 앱 종료. 광고 없거나 세션 짧으면 바로 종료.
  Future<void> _closeAppImmediately() async {
    try {
      await _appControlChannel.invokeMethod<void>('closeApp');
    } on PlatformException {
      await SystemNavigator.pop();
    }
  }

  Future<void> _showInterstitialThenExit() async {
    final ad = _interstitialAd;
    if (ref.read(premiumNotifierProvider) ||
        !_isSessionLongEnough ||
        ad == null) {
      await _closeAppImmediately();
      return;
    }
    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (a) {
        _closeAppImmediately();
      },
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
      },
      onAdFailedToShowFullScreenContent: (a, _) async {
        a.dispose();
        await _closeAppImmediately();
      },
    );
    await ad.show();
  }
  // ────────────────────────────────────────────────────────────────

  static const List<_ShellTabItem> _tabs = [
    _ShellTabItem(
      route: AppRoutes.home,
      label: '홈',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _ShellTabItem(
      route: AppRoutes.weather,
      label: '날씨',
      icon: Icons.wb_sunny_outlined,
      selectedIcon: Icons.wb_sunny_rounded,
    ),
    _ShellTabItem(
      route: AppRoutes.fortune,
      label: '운세',
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome_rounded,
    ),
    _ShellTabItem(
      route: AppRoutes.monthlyYegamssi,
      label: '월간예감',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
    ),
    _ShellTabItem(
      route: AppRoutes.settings,
      label: '설정',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
    ),
  ];

  String? _lastWidgetSignature;
  bool _isHandlingBackPress = false;

  @override
  void initState() {
    super.initState();
    _appOpenTime = DateTime.now();
    if (!ref.read(premiumNotifierProvider)) {
      _loadInterstitialAd();
    }
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await WidgetInstallPromptController.showIfNeeded(context);
      if (!mounted) return;
      await AppReviewPromptController.showIfNeeded(context);
      if (!mounted) return;
      await _showBatteryOptimizationReminderIfNeeded();
      _tryInitialWidgetSync();
    });
  }

  Future<void> _showBatteryOptimizationReminderIfNeeded() async {
    if (!await BackgroundRefreshPermissionService.shouldShowBatteryOptimizationReminder()) {
      return;
    }
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    final action = await showDialog<_BatteryReminderAction>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: AppColors.glassBorder),
        ),
        title: Text(l10n.batteryOptimizationReminderTitle),
        content: Text(l10n.batteryOptimizationReminderMessage),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_BatteryReminderAction.never),
            child: Text(l10n.batteryOptimizationReminderNever),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_BatteryReminderAction.later),
            child: Text(l10n.batteryOptimizationReminderLater),
          ),
          TextButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(_BatteryReminderAction.settings),
            child: Text(
              l10n.batteryOptimizationReminderSettings,
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    switch (action) {
      case _BatteryReminderAction.settings:
        await BackgroundRefreshPermissionService.requestBatteryOptimizationException();
      case _BatteryReminderAction.never:
        await BackgroundRefreshPermissionService.suppressBatteryOptimizationReminder();
      case _BatteryReminderAction.later:
      case null:
        return;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      resetPassiveWeatherThrottle();
      _realignCurrentWeatherAfterResume();
      // 포그라운드 복귀: 15분 쓰로틀 리셋 → 다음 접근 시 백그라운드 갱신 트리거
      resetPassiveWeatherThrottle();
    }
  }

  Future<void> _realignCurrentWeatherAfterResume() async {
    final cachedWeather = await WeatherCacheStore.load(allowStale: true);
    if (!mounted || !RefreshPolicy.isWeatherRefreshDue(cachedWeather)) {
      return;
    }
    ref.invalidate(currentWeatherProvider);
    ref.invalidate(currentScoreProvider);
  }

  void _tryInitialWidgetSync() {
    final weather = ref.read(currentWeatherProvider).valueOrNull;
    final score = ref.read(currentScoreProvider).valueOrNull;
    if (weather == null || score == null) return;
    ref.read(currentPositionProvider.future).then((position) {
      if (!mounted) return;
      _scheduleWidgetSync(
        weather: weather,
        score: score,
        latitude: position.lat,
        longitude: position.lon,
        fortune: ref.read(dailyFortuneProvider).valueOrNull,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> _handleBackPress() async {
    if (_isHandlingBackPress) return;
    _isHandlingBackPress = true;
    try {
      if (!mounted) return;
      // 스와이프 직후에도 정확한 탭을 읽기 위해 GoRouter에서 직접 조회
      final location = GoRouter.of(
        context,
      ).routeInformationProvider.value.uri.path;
      final currentIndex = _resolvedCurrentTabIndex(location);
      if (currentIndex != 0) {
        context.go(AppRoutes.home);
        return;
      }

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final shouldExit =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.card,
                side: BorderSide(color: AppColors.glassBorder),
              ),
              title: Text(l10n.appExitTitle),
              content: Text(l10n.appExitMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(
                    l10n.exit,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ) ??
          false;

      if (!mounted) return;
      if (shouldExit) {
        await _showInterstitialThenExit();
      }
    } finally {
      _isHandlingBackPress = false;
    }
  }

  int _tabIndexForLocation(String location) {
    if (location.startsWith(AppRoutes.weather)) return 1;
    if (location.startsWith(AppRoutes.fortune)) return 2;
    if (location.startsWith(AppRoutes.monthlyYegamssi)) return 3;
    if (location.startsWith(AppRoutes.settings)) return 4;
    return 0;
  }

  int _tabIndexForChild() {
    final child = widget.child;
    if (child is WeatherScreen) return 1;
    if (child is FortuneScreen) return 2;
    if (child is MonthlyYegamssiScreen) return 3;
    if (child is SettingsScreen || child is AppInfoScreen) return 4;
    if (child is HomeTabScreen) return 0;
    return -1;
  }

  int _resolvedCurrentTabIndex(String location) {
    final childIndex = _tabIndexForChild();
    if (childIndex >= 0) {
      return childIndex;
    }
    return _tabIndexForLocation(location);
  }

  void _handleSwipeNavigation(DragEndDetails details, int currentIndex) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 500) {
      return;
    }
    if (velocity < 0 && currentIndex < _tabs.length - 1) {
      context.go(_tabs[currentIndex + 1].route);
      return;
    }

    if (velocity > 0 && currentIndex > 0) {
      context.go(_tabs[currentIndex - 1].route);
    }
  }

  void _scheduleWidgetSync({
    required WeatherEntity weather,
    required ActivityScore score,
    required double latitude,
    required double longitude,
    FortuneResult? fortune,
  }) {
    final language = ref.read(appLanguageNotifierProvider);
    final country = ref.read(resolvedCountryProvider).valueOrNull;
    final signature = [
      language.name,
      country?.isoCode ?? 'UNKNOWN',
      weather.condition.name,
      weather.isNight ? 'night' : 'day',
      weather.tempCelsius.round(),
      weather.feelsLikeCelsius.round(),
      fortune == null ? 'null' : widgetFortuneSymbolFor(fortune),
      score.score,
    ].join('|');

    if (_lastWidgetSignature == signature) {
      return;
    }

    _lastWidgetSignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      syncWidgetSnapshot(
        weather: weather,
        score: score,
        latitude: latitude,
        longitude: longitude,
        language: language,
        country: country ?? CountryCode.kr,
        fortune: fortune,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;
    final currentIndex = _resolvedCurrentTabIndex(location);
    ref.watch(currentWeatherProvider);
    ref.watch(currentScoreProvider);
    ref.watch(dailyFortuneProvider);
    ref.watch(appLanguageNotifierProvider);

    ref.listen(currentWeatherProvider, (_, next) {
      final nextWeather = next.valueOrNull;
      if (nextWeather == null) {
        return;
      }
      ref.read(currentPositionProvider.future).then((position) {
        final country = ref.read(resolvedCountryProvider).valueOrNull;
        final score = calculateActivityScore(
          weather: nextWeather,
          country: country ?? CountryCode.kr,
        );
        _scheduleWidgetSync(
          weather: nextWeather,
          score: score,
          latitude: position.lat,
          longitude: position.lon,
          fortune: ref.read(dailyFortuneProvider).valueOrNull,
        );
      });
    });

    ref.listen(dailyFortuneProvider, (_, next) {
      final nextWeather = ref.read(currentWeatherProvider).valueOrNull;
      if (nextWeather == null) {
        return;
      }
      ref.read(currentPositionProvider.future).then((position) {
        final country = ref.read(resolvedCountryProvider).valueOrNull;
        final score = calculateActivityScore(
          weather: nextWeather,
          country: country ?? CountryCode.kr,
        );
        _scheduleWidgetSync(
          weather: nextWeather,
          score: score,
          latitude: position.lat,
          longitude: position.lon,
          fortune: next.valueOrNull,
        );
      });
    });

    ref.listen(appLanguageNotifierProvider, (_, __) {
      final nextWeather = ref.read(currentWeatherProvider).valueOrNull;
      if (nextWeather == null) {
        return;
      }
      ref.read(currentPositionProvider.future).then((position) {
        final country = ref.read(resolvedCountryProvider).valueOrNull;
        final score = calculateActivityScore(
          weather: nextWeather,
          country: country ?? CountryCode.kr,
        );
        _scheduleWidgetSync(
          weather: nextWeather,
          score: score,
          latitude: position.lat,
          longitude: position.lon,
          fortune: ref.read(dailyFortuneProvider).valueOrNull,
        );
      });
    });

    // Android 13+ predictive back API(OnBackInvokedCallback) 활성화 시
    // BackButtonListener는 이벤트를 받지 못함 → PopScope 사용 필수.
    // canPop: false → 시스템이 자동으로 Activity finish 하지 않음
    // onPopInvokedWithResult → Flutter가 back 이벤트를 처리
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        extendBody: true,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragEnd: (details) =>
              _handleSwipeNavigation(details, currentIndex),
          child: Stack(children: [const _SkyWaterBackdrop(), widget.child]),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2,
              AppSpacing.x1,
              AppSpacing.x2,
              AppSpacing.x1,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).bottomNavigationBarTheme.backgroundColor,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: AppColors.glassBorder),
                    boxShadow: AppShadows.surface(Theme.of(context).brightness),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x1,
                      vertical: AppSpacing.x1,
                    ),
                    child: Row(
                      children: [
                        for (var index = 0; index < _tabs.length; index++)
                          Expanded(
                            child: _NavigationTab(
                              item: _tabs[index],
                              isSelected: currentIndex == index,
                              onTap: () => context.go(_tabs[index].route),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.x1),
                const _MannerAdBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellTabItem {
  const _ShellTabItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _NavigationTab extends StatelessWidget {
  const _NavigationTab({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _ShellTabItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = _labelFor(context, item.route);
    final brightness = Theme.of(context).brightness;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isSelected
                ? colorScheme.primary.withAlpha(22)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                size: 20,
                color: isSelected
                    ? colorScheme.primary
                    : AppColors.caption(brightness),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? colorScheme.primary
                      : AppColors.caption(brightness),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelFor(BuildContext context, String route) {
    final l10n = AppLocalizations.of(context);
    return switch (route) {
      AppRoutes.weather => l10n.tabWeather,
      AppRoutes.fortune => l10n.tabFortune,
      AppRoutes.monthlyYegamssi => l10n.tabMonthlyYegamssi,
      AppRoutes.settings => l10n.tabSettings,
      _ => l10n.tabHome,
    };
  }
}

class _MannerAdBanner extends ConsumerStatefulWidget {
  const _MannerAdBanner();

  @override
  ConsumerState<_MannerAdBanner> createState() => _MannerAdBannerState();
}

class _MannerAdBannerState extends ConsumerState<_MannerAdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!ref.read(premiumNotifierProvider)) {
      _loadAd();
    }
  }

  void _loadAd() {
    final bannerAd = BannerAd(
      adUnitId: AdMobConfig.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: ${error.message}');
          ad.dispose();
        },
      ),
    );

    bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(premiumNotifierProvider)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    if (!_isLoaded || _bannerAd == null) {
      return Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.center,
        child: Text(
          l10n.loadingAd,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.white38),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}

class _SkyWaterBackdrop extends StatelessWidget {
  const _SkyWaterBackdrop();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF08142A),
                  Color(0xFF102044),
                  Color(0xFF163160),
                  Color(0xFF23457A),
                ]
              : const [
                  Color(0xFFEAF7FF),
                  Color(0xFFCFEFFF),
                  Color(0xFFF8FCFF),
                  Color(0xFFDDF3FF),
                ],
          stops: const [0, 0.28, 0.64, 1],
        ),
      ),
      child: CustomPaint(
        painter: _BubblePainter(brightness: brightness),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter({required this.brightness});

  final Brightness brightness;

  static const List<(double, double, double, double)> _bubbles = [
    (0.16, 0.12, 0.18, 0.10),
    (0.86, 0.14, 0.15, 0.08),
    (0.28, 0.56, 0.22, 0.07),
    (0.76, 0.68, 0.20, 0.09),
    (0.52, 0.34, 0.12, 0.06),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = brightness == Brightness.dark;
    if (!isDark) {
      _drawDaylight(canvas, size);
    }
    for (final bubble in _bubbles) {
      final center = Offset(bubble.$1 * size.width, bubble.$2 * size.height);
      final radius = bubble.$3 * size.width;
      _drawBubble(canvas, center, radius, bubble.$4);
    }
  }

  void _drawDaylight(Canvas canvas, Size size) {
    final sunlightPaint = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x66FFE2A3), Color(0x00FFE2A3)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.14, size.height * 0.08),
              radius: size.width * 0.55,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.14, size.height * 0.08),
      size.width * 0.55,
      sunlightPaint,
    );

    final waterPaint = Paint()
      ..color = const Color(0x265EBEE8)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromLTWH(
        -size.width * 0.2,
        size.height * 0.82,
        size.width * 1.4,
        size.height * 0.28,
      ),
      waterPaint,
    );
  }

  void _drawBubble(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
  ) {
    final isDark = brightness == Brightness.dark;
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.35),
        radius: 1,
        colors: isDark
            ? [
                const Color(
                  0xFFDFEAFF,
                ).withAlpha((opacity * 255 * 1.25).clamp(0, 255).round()),
                const Color(
                  0xFF8FA8FF,
                ).withAlpha((opacity * 255 * 0.45).round()),
                const Color(
                  0xFF4668D8,
                ).withAlpha((opacity * 255 * 0.18).round()),
                Colors.transparent,
              ]
            : [
                const Color(
                  0xFFFFFFFF,
                ).withAlpha((opacity * 255 * 2.2).clamp(0, 255).round()),
                const Color(
                  0xFFBEEBFF,
                ).withAlpha((opacity * 255 * 0.95).round()),
                const Color(
                  0xFF79CBEF,
                ).withAlpha((opacity * 255 * 0.28).round()),
                Colors.transparent,
              ],
        stops: const [0, 0.38, 0.72, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, bodyPaint);

    final highlightOffset = Offset(
      center.dx - radius * 0.3,
      center.dy - radius * 0.3,
    );
    final highlightRadius = radius * 0.35;
    final highlightPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withAlpha(
                (opacity * 255 * 2.4).clamp(0, 255).round(),
              ),
              Colors.white.withAlpha(
                (opacity * 255 * 0.45).clamp(0, 255).round(),
              ),
              Colors.transparent,
            ],
            stops: const [0, 0.5, 1],
          ).createShader(
            Rect.fromCircle(center: highlightOffset, radius: highlightRadius),
          );

    canvas.drawCircle(highlightOffset, highlightRadius, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) {
    return oldDelegate.brightness != brightness;
  }
}

enum _BatteryReminderAction { later, never, settings }
