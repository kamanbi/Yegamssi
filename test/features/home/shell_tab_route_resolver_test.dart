import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/core/router/app_routes.dart';
import 'package:yegamssi/features/home/presentation/shell_tab_route_resolver.dart';

void main() {
  const koreanRoutes = [
    AppRoutes.home,
    AppRoutes.weather,
    AppRoutes.fortune,
    AppRoutes.activityForecast,
    AppRoutes.settings,
  ];
  const globalRoutes = [
    AppRoutes.home,
    AppRoutes.weather,
    AppRoutes.fortune,
    AppRoutes.monthlyYegamssi,
    AppRoutes.settings,
  ];

  test('maps monthly route to fortune tab for Korean navigation', () {
    expect(
      resolveShellTabIndex(
        location: AppRoutes.monthlyYegamssi,
        tabRoutes: koreanRoutes,
      ),
      2,
    );
  });

  test('keeps monthly tab selected for global navigation', () {
    expect(
      resolveShellTabIndex(
        location: AppRoutes.monthlyYegamssi,
        tabRoutes: globalRoutes,
      ),
      3,
    );
  });
}
