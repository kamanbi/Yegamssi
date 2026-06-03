# Research: Yegamssi Language Pack Status

## Current Structure
- Supported app languages are Korean, Japanese, and English only.
- `MaterialApp.router` reads the saved `AppLanguage` and applies its `Locale`.
- The main page exposes a language selector, and settings also manages the same saved language state.
- `l10n/app_ko.arb`, `l10n/app_ja.arb`, and `l10n/app_en.arb` share the same key set; Chinese ARB/generated files were removed.
- Generated localization files under `lib/l10n/` are regenerated from ARB.

## Localized UI Coverage
- Home, bottom navigation, weather, score, fortune, settings, app info, onboarding, birth picker, splash/update dialogs, widget prompt, refresh, router error, and brand signature now use `AppLocalizations` for visible labels.
- Weather and activity visual mappers expose localized label helpers for UI use.
- Date formatting is currently neutral numeric formatting to avoid broken locale-specific weekday output.

## Weather Source Rule
- Weather source selection remains country-based.
- Korea uses KMA/AirKorea data paths.
- The United States uses NOAA where configured, with OpenWeather fallback.
- Other countries use OpenWeather/global fallback.

## Fortune Language Scope
- Fortune data contents were not migrated or rewritten.
- Fortune repository selects the table by language key: `fortune_ko`, `fortune_en`, or `fortune_ja`.
- Fortune tone tables use the same language key and fall back to the same language base table when tone-specific rows are empty.
- App UI around fortune is localized; fortune result messages still depend on external/data-layer fortune content.

## Remaining Risks
- Android widget text and native resource strings may still need separate platform localization if they are shown outside Flutter.
- Fortune data availability for English/Japanese must be validated when those data files/tables are prepared.
- Country display names are still simple enum labels; this is acceptable for current settings UI but may need locale-aware labels later.

## Verification
- `flutter gen-l10n` completed.
- `flutter analyze --no-fatal-infos` passed with no issues.
- `flutter test --reporter=expanded` passed: 71 tests.
