# Activity Forecast Plan

## Goal
Add a Korea-only Activity Forecast page where eligible users can calculate, close, restore, modify, and browse explainable location-and-time-based judgments.

## Availability Policy
1. Add `ActivityForecastAvailability` with `checking`, `eligible`, and `ineligible` states.
2. Resolve eligibility from current-device GPS country and a timestamped verified-country cache; grant access only to `KR`.
3. Treat foreign, missing permission, timeout, lookup failure, and stale cache as ineligible.
4. Keep the feature independent from language, timezone, selected weather city, and the general default-Korea fallback.
5. Guard navigation, page rendering, home entry points, and stored-result access with the same policy.
6. Retain history when the feature becomes unavailable and restore it after Korea eligibility returns.

## Product Structure
1. For eligible Korea access, replace the bottom `Monthly forecast` destination with `Activity forecast` and expose monthly forecast inside fortune.
2. For foreign or unresolved access, retain the existing `Monthly forecast` destination and do not expose Activity Forecast.
3. Add activity buttons for the first release: fishing, walking/running, hiking, laundry, and car wash.
4. Show pinned and recent saved judgments below the activity buttons.

## Modal Flow
1. Open a dismissible, draggable full-height modal sheet.
2. Input common fields: location, date, start time, and duration.
3. Render typed fields for the selected activity.
4. Keep the modal open while switching from input to loading and result states.
5. Save the plan and result only after a successful calculation.
6. Provide `Change conditions`, `Recalculate`, `Save as new`, and `Delete` commands.

## Domain And Storage
1. Add `ActivityType`, `SavedActivityPlan`, typed activity options, `ActivityJudgment`, `JudgmentFactor`, and `SafetyLevel`.
2. Add a pure scoring contract so each activity calculator is independently testable.
3. Add `ActivityJudgmentStore` with schema versioning, a 20-item limit, newest-first order, pinning, deletion, and corruption recovery.
4. Add Riverpod controllers for saved history and active calculation.
5. Keep activity storage and refresh rules fully separate from current weather, selected-location weather, fortune, and widget caches.
6. Add a timestamped, versioned eligibility cache separate from the general country cache.

## External API Activation
1. Activate the new KHOA national-core `Sea Fishing Index` as the primary official sea-fishing source.
2. Activate KHOA `Tide Forecast (high/low and time series)` and `Current Forecast (time series and maximum flood/ebb/slack)` for time-window scoring.
3. Activate KHOA `ROMS Numerical Forecast Model` for coordinate-based surface current and water-temperature forecasts.
4. Activate KHOA `Latest Ocean Buoy Observations` and `Observed Waves of the National Ocean Observing Network` for current-condition and forecast-quality checks.
5. Activate `KMA Nationwide Beach Weather Query Service` as a supported-beach fallback and cross-check source.
6. Activate `National Institute of Forest Science Forest Fire Risk Forecast Information` for hiking safety overrides.
7. Activate `KMA Lifestyle Weather Index Query Service` for UV and apparent-temperature factors.
8. Activate `Korea Forest Service Mountain Information Query` and `Forest Spatial Information Trail Information_GW` for mountain search and route context.
9. Do not integrate any discontinued legacy BadaNuri endpoint. Keep every key in Supabase secrets and expose only normalized activity data through allowlisted proxy routes.

## Sea Fishing Data Policy
1. Map a request to rock fishing or boat fishing and to a supported target species before calculating suitability.
2. At an official KHOA fishing point, use the official five-level Sea Fishing Index as a baseline factor, not as the entire Yegamssi score.
3. Combine hourly KMA weather with KHOA tide, current, wave, water-temperature, and wind inputs for the requested time window.
4. For arbitrary coordinates, use coordinate-capable or nearest-station raw feeds only within named distance and freshness limits; otherwise return `coverage unavailable` instead of extrapolating.
5. Apply marine warnings, excessive waves/wind/current, and stale observations as safety overrides before numeric scoring.
6. Display source time, forecast window, nearest observation distance, coverage level, and whether the result is official-point or interpolated.
7. Keep freshwater fishing out of the first sea-fishing release.

## Proxy Abuse Protection
1. Remove public control of `nocache=1`; reject or ignore it for app/anon requests.
2. Reserve forced upstream refresh for trusted scheduled jobs or explicitly authorized server-side operations.
3. Make manual refresh request server-side revalidation; the server serves a still-valid cache or refreshes an expired/eligible entry.
4. Add atomic rate limits by caller and IP, plus provider-wide quotas and concurrency limits. Return `429` with `Retry-After` when exceeded.
5. Apply stricter limits to manual refresh than ordinary cached reads and deduplicate identical in-flight requests.
6. Log provider, route, cache outcome, limit outcome, and latency without logging API keys, authorization headers, raw coordinates, or personal identifiers.
7. Add alert thresholds for repeated bypass attempts, elevated upstream error rates, and provider quota consumption.

## Delivery Order
1. Activate and smoke-test the required public-data products without changing Claude Code's in-progress weather contract.
2. Harden the proxy cache-bypass and rate-limit paths before exposing new provider routes.
3. Build and test the fail-closed Korea eligibility policy and guarded navigation.
4. Build the shared page, modal state machine, models, storage, and existing-weather adapter.
5. Implement walking/running, laundry, and car-wash calculators using current weather data.
6. Add hiking with forest-fire safety overrides and available environmental data.
7. Add sea fishing in two levels: official KHOA fishing points first, then coordinate-based coverage using approved raw KHOA feeds.
8. Add localization, analytics events, unit/widget tests, and release verification.

## Readability Rules
- Early Return: reject invalid time ranges, unsupported forecast horizons, unavailable locations, and safety-stop conditions before scoring.
- Contextual Naming: use `requestedWindow`, `forecastObservedAt`, `safetyOverride`, and `scoreContributions`.
- Magic Number Hunter: every threshold and history limit belongs to named policy constants.
- Parameter Object: pass `ActivityJudgmentRequest` instead of separate location/time/options arguments.
- Complexity Check: target page/controller readability 8/10 and each calculator cyclomatic complexity below 10.

## Completion Criteria
- Verified Korea access exposes Activity Forecast; verified foreign and unresolved access expose no page, tab, promotion, deep link, or cached result.
- Korean language abroad does not enable the feature, and a foreign language in Korea does not disable it.
- Eligibility changes do not corrupt tab selection or delete activity history.
- Activity selection, input, inline result, dismissal, restoration, editing, recalculation, history opening, and deletion work.
- Cached results appear immediately and clearly indicate stale or changed forecasts.
- Activity caches cannot overwrite app weather or widget data.
- Every displayed score has factor contributions and an independent safety status.
- Calculator, serialization, cache migration, provider, and modal interaction tests pass.
- App callers cannot force an upstream cache bypass, and sustained excess traffic receives deterministic `429` responses without consuming uncontrolled provider quota.
- Every enabled external API passes a server-side smoke test, and unavailable marine coverage is labeled rather than inferred from land weather.
