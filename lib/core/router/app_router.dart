import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/fortune/presentation/fortune_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/home_tab_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/score/presentation/score_screen.dart';
import '../../features/settings/presentation/app_info_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/weather/presentation/weather_screen.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // ── 스플래시 ──
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      // ── 온보딩 ──
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      // ── 메인 Shell ──
      ShellRoute(
        builder: (_, __, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomeTabScreen(),
          ),
          GoRoute(
            path: AppRoutes.weather,
            builder: (_, __) => const WeatherScreen(),
          ),
          GoRoute(
            path: AppRoutes.score,
            builder: (_, __) => const ScoreScreen(),
          ),
          GoRoute(
            path: AppRoutes.fortune,
            builder: (_, __) => const FortuneScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.appInfo,
            builder: (_, __) => const AppInfoScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('페이지를 찾을 수 없습니다: ${state.error}'))),
  );
}
