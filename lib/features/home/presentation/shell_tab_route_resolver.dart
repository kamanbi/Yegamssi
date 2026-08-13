import '../../../core/router/app_routes.dart';

int resolveShellTabIndex({
  required String location,
  required List<String> tabRoutes,
}) {
  if (tabRoutes.isEmpty) return 0;
  if (location.startsWith(AppRoutes.settings)) return tabRoutes.length - 1;

  final resolvedLocation =
      location.startsWith(AppRoutes.monthlyYegamssi) &&
          !tabRoutes.contains(AppRoutes.monthlyYegamssi)
      ? AppRoutes.fortune
      : location;
  final index = tabRoutes.indexWhere(
    (route) => route != AppRoutes.home && resolvedLocation.startsWith(route),
  );
  return index < 0 ? 0 : index;
}
