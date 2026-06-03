# Plan: Yegamssi Language Pack Follow-up

## Completed
- Limit app languages to Korean, Japanese, and English.
- Apply saved language to the full Flutter app locale.
- Show language selection on the main page.
- Replace visible Flutter UI text with ARB-based localization across major screens and app-level prompts.
- Keep fortune data work separate while wiring language-specific fortune table selection.
- Remove Chinese localization files from the generated app surface.

## Remaining Priority
1. Validate Android widget/native strings and add platform resource localization where required.
2. When fortune DATA is ready, verify `fortune_en` and `fortune_ja` base/tone table coverage.
3. Add locale-aware date/weekday formatting instead of the current neutral numeric fallback.
4. Decide whether country/region names should be localized per selected language.

## Completion Criteria
- Korean, Japanese, and English render without broken text on all Flutter screens.
- Main page and settings language changes immediately update app UI.
- Korea weather remains KMA/AirKorea based; non-Korean countries remain NOAA/OpenWeather/global fallback based.
- Fortune UI is localized without modifying fortune DATA content.
- `flutter gen-l10n`, `flutter analyze --no-fatal-infos`, and `flutter test --reporter=expanded` pass.

## Readability 5 Rules
- Early Return: fallback branches use direct returns and avoid nested language/data checks.
- Contextual Naming: language/table helpers use names such as `AppLanguage`, `tableKey`, `localizedLabelFor`, and `tableNameForLang`.
- Magic Number Hunter: new language work did not add business magic numbers; existing UI sizes remain unchanged.
- Parameter Object: no new high-arity call sites were introduced; future fortune data validation can use a request object if table inputs grow.
- Complexity Check: current language structure readability is about 86/100; adding native widget localization and locale-aware date formatting should bring it to about 92/100.
