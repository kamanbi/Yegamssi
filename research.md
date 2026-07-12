# Widget Weather Mirror Research

## Current State
- The Android widget reads only `HomeWidgetPlugin` data and renders the cached snapshot. It does not call a weather API or calculate score/fortune.
- Current-location weather is stored in `WeatherCacheStore`; selected-location weather uses a separate location-keyed app cache.
- `AppRefreshController` is shared by manual refresh and WorkManager background refresh.
- Weather refresh is due every 30 minutes. A due refresh now requires a successful API result before downstream signals continue.
- Fortune slots are 06:00-12:59 and 13:00-05:59. Cache keys include date, slot, profile, language, and tone.
- Outdoor score is recalculated from the current-location weather and resolved country on each completed refresh.

## Confirmed Fixes
- Selected/favorite location reads and writes no longer use the current-location weather cache.
- Widget synchronization is limited to current-location weather and writes cached values for weather, score, and fortune symbol.
- If a due weather refresh fails, fortune generation and widget synchronization are skipped so the previous valid snapshot remains visible.
- A new fortune slot cannot generate from a weather snapshot older than the 30-minute policy.
- Widget time remains Android `TextClock` device time.
- App and widget weather icons now use the same state-by-state PNG source, including a distinct cloudy-night state.

## Verification Evidence
- Weather tests: 26 passed.
- Fortune and score tests: 53 passed.
- Static analysis exits successfully with one pre-existing informational warning.
- Device logs showed weather success, outdoor score `60`, and matching app/widget snapshot values.
- Icon mapping tests cover the cloudy-night key and Flutter/Android resource set contains all 21 supported states.
- Release APK and AAB build successfully as version `1.1.48+82`; the APK installs and starts on the test device.
- Release artifact credential scan passes for both APK and AAB. No fatal exception was observed during launch.

## Security State
- Release builds require `android/key.properties` and the configured release keystore; debug-signing fallback is disabled.
- Cleartext HTTP is disabled at the Android application level.
- Detailed Dio, background, and update stack traces are debug-only.
- User profile fields are stored in encrypted platform storage with migration from legacy preferences.
- Supabase provider keys remain server-side in the weather proxy; the client uses the public anon configuration.

## Remaining Risk
- Android may defer WorkManager execution under system power/network policy. The scheduler requests a 30-minute period and connected-network constraint, but exact wall-clock execution is platform-controlled.
- Supabase production RLS, premium entitlement verification, and proxy rate limiting require dashboard/server-side verification; they are not provable from this client repository alone.
- Dependency versions have known available updates; a separate advisory scan and upgrade pass is still required.
