import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/fortune/presentation/fortune_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/home_tab_screen.dart';
import '../../features/monthly/presentation/monthly_yegamssi_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/settings/presentation/app_info_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/weather/presentation/weather_screen.dart';
import '../../l10n/app_localizations.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

Page<T> _noTransition<T>({required LocalKey key, required Widget child}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (_, __, ___, child) => child,
  );
}

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, state) =>
            _noTransition(key: state.pageKey, child: const OnboardingScreen()),
      ),
      ShellRoute(
        pageBuilder: (_, state, child) => _noTransition(
          key: state.pageKey,
          child: HomeScreen(child: child),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, state) =>
                _noTransition(key: state.pageKey, child: const HomeTabScreen()),
          ),
          GoRoute(
            path: AppRoutes.weather,
            pageBuilder: (_, state) =>
                _noTransition(key: state.pageKey, child: const WeatherScreen()),
          ),
          GoRoute(
            path: AppRoutes.fortune,
            pageBuilder: (_, state) =>
                _noTransition(key: state.pageKey, child: const FortuneScreen()),
          ),
          GoRoute(
            path: AppRoutes.monthlyYegamssi,
            pageBuilder: (_, state) => _noTransition(
              key: state.pageKey,
              child: const MonthlyYegamssiScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (_, state) => _noTransition(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.appInfo,
            pageBuilder: (_, state) =>
                _noTransition(key: state.pageKey, child: const AppInfoScreen()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          AppLocalizations.of(context).notFoundPage(state.error.toString()),
        ),
      ),
    ),
  );
}
