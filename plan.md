# Widget Weather Mirror Plan

## Goal
Keep the widget as a passive mirror of the current-location cached snapshot. Generate fortune only after a successful weather refresh for the active 06:00 or 13:00 slot.

## Implementation
1. Keep current-location, selected-location, and favorite-location cache ownership separate.
2. Require a successful weather API result whenever the 30-minute policy says refresh is due.
3. Stop the refresh transaction before fortune generation and widget sync when weather refresh fails.
4. Reject new fortune generation when the available weather snapshot is stale; return an existing slot cache first.
5. Recalculate outdoor score from the successfully refreshed current-location weather and country policy.
6. Sync the widget only after the weather, score, and fortune snapshot is ready.
7. Keep all 21 weather icon states aligned between Flutter assets and Android widget drawables, including cloudy night.
8. Keep release artifacts hardened: mandatory release signing, no cleartext traffic, debug-only detailed logs, and encrypted profile storage migration.

## Readability Rules
- Early return on unusable cache, failed weather refresh, and unavailable profile.
- Use `weatherRefreshDue`, `currentLocationWeather`, and `widgetSnapshot` as contextual names.
- Keep 30 minutes, 1 hour, timeout, and fortune boundary hours as named constants.
- Keep widget data grouped in `WidgetSnapshotPayload`.
- Target readability: 8/10; current refresh flow is linear with explicit failure boundaries.

## Completion Criteria
- A failed due weather refresh cannot create a new fortune or overwrite the widget.
- A successful weather refresh recalculates score and updates the widget.
- Fortune remains unchanged within its active time slot.
- Widget code performs no API call and displays only cached values.
- App and widget show the same icon for every supported weather condition and night variant.
- APK `1.1.48+82` builds, installs, and starts on the test device.
- APK and AAB pass the credential-pattern scan; release signing and client-side hardening are verified.
- Treat Supabase RLS, premium entitlement authority, and proxy rate limiting as deployment-side acceptance checks.
