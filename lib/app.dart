import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/locale/country_code.dart';
import 'core/locale/locale_provider.dart';
import 'core/purchase/premium_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/version/update_checker_widget.dart';
import 'l10n/app_localizations.dart';

class YegamssiApp extends ConsumerWidget {
  const YegamssiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final appLanguage = ref.watch(appLanguageNotifierProvider);
    // 앱 시작 시 구매 상태 캐시 확인 + purchaseStream 구독 시작 (자동 복원)
    ref.watch(premiumNotifierProvider);

    return MaterialApp.router(
      title: '\uC608\uAC10\uC528',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: appLanguage.locale,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final overlayStyle = brightness == Brightness.dark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
              );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: UpdateCheckerWidget(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
