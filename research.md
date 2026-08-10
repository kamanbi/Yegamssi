# Activity Forecast Research

## Current Structure
- The app uses a `ShellRoute` with five bottom destinations: home, weather, fortune, monthly forecast, and settings.
- Adding a sixth bottom destination would make labels and touch targets crowded. Monthly forecast is lower-frequency and can move under fortune.
- Weather already supports searched locations, favorites, and location-specific caches separated from the current-location cache.
- Small structured lists are persisted as versioned JSON in `SharedPreferences`; this is sufficient for an initial capped activity-history list.
- Existing weather forecasts include hourly location/time data required by the first activity judgments. Marine, tide, trail, and route-specific sources require separate integrations.
- Country resolution currently uses GPS reverse geocoding but falls back to the last country and then Korea when resolution fails. That fallback is not safe for restricting a Korea-only feature.

## Korea-Only Availability
- Activity Forecast availability is based on the device's verified current physical country, not app language, selected weather location, SIM country, or timezone.
- The feature is eligible only when a dedicated availability provider positively resolves `KR` or has a recent verified-Korea cache.
- Foreign and unresolved states are ineligible. The global resolver's default-Korea fallback must never grant access.
- Before eligibility resolves, the existing monthly destination remains visible to avoid briefly exposing the activity destination.
- On foreign access, the activity tab, home promotion, route content, and entry links are hidden while saved activity data remains stored.
- Direct navigation to `/activities` while ineligible must redirect to home without exposing cached activity details.
- The initial release also limits searched activity locations to South Korea because its scoring sources are Korea-specific.

## Required User Flow
1. Open the Activity Forecast page.
2. Select an activity button.
3. If no saved input exists, open the input state of a dismissible full-height modal sheet.
4. Submit location, start time, duration, and activity-specific fields.
5. Replace the modal body with the result without closing it.
6. Close at any time; reopening restores the latest saved result immediately.
7. Use `Change conditions` or `New judgment` to run another query.
8. Open any saved judgment from the page history list.

## Data Ownership
- Activity data must not use `WeatherCacheStore`, `SelectedLocationWeatherCacheStore`, or widget storage.
- A saved activity plan owns its activity type, named location, coordinates, start time, duration, typed options, and creation time.
- A cached judgment owns its score, safety level, best window, factor breakdown, message, forecast observation time, expiry, and calculation version.
- Cache identity must include activity type, coordinates, requested time range, activity options, and scoring version.
- Cached results display immediately, then show `forecast changed` or `recalculate` when their source forecast is stale.

## External Data
- The current weather stack is sufficient for walking/running, laundry, car wash, and baseline weather factors.
- The discontinued legacy BadaNuri APIs have an official replacement in the new KHOA Ocean Data Platform and its national-core Open APIs.
- The replacement `Sea Fishing Index` covers major rock-fishing and boat-fishing points and provides species, tide phase, wave height, water temperature, current speed, wind speed, and a five-level official index. It is produced twice daily and is not an arbitrary-coordinate or hourly prediction.
- KHOA tide/current forecasts, ROMS surface current and temperature forecasts, buoy observations, and observed-wave feeds provide the raw inputs needed to extend beyond the official index points.
- KMA Nationwide Beach Weather remains a fallback for supported beach/coastal points; it provides beach forecasts plus nearby tide, wave, water-temperature, sunrise/sunset, and ebb/flood data.
- Hiking safety requires the National Institute of Forest Science forest-fire-risk forecast. Mountain and trail APIs supply place and route context but are not substitutes for weather or safety forecasts.
- KMA Lifestyle Weather Index adds UV and apparent-temperature inputs used by outdoor judgments.
- The public-data portal service key is stored server-side as `PUBLIC_DATA_API_KEY`, but each API product still requires its own utilization approval.
- Freshwater fishing is outside the KHOA sea-fishing coverage and requires a separate river/reservoir data design.

## Proxy Security
- Provider secrets are stored in Supabase Edge Function secrets and are not shipped in the app bundle.
- The weather proxy verifies JWTs and restricts provider paths, but the client-visible anon credential is not an authorization boundary by itself.
- The current client-controlled `nocache=1` path can force upstream calls, and no caller/provider rate limit is enforced. This can exhaust third-party quotas without exposing the secret value.
- Manual refresh must remain available, but cache revalidation must be decided by the server rather than by an unrestricted client bypass flag.

## UX Constraints
- Use a modal bottom sheet rather than a small alert dialog because location search, date/time, duration, factor details, and results exceed a safe dialog height.
- The activity page owns browsing, history, pinning, and deletion; the modal owns one plan's input and result.
- Safety warnings override the numeric score and must remain visible at the top of the result.
- A score represents activity suitability, not guaranteed performance such as catch probability.
- Initial history should be capped at 20 items with explicit delete and clear-all actions.

## Risks
- A free-form options map would make scoring and migrations fragile; activity-specific options need typed models.
- Reusing a cached score after the forecast changes can mislead users unless source time and expiry are visible.
- Marine fishing cannot be presented as precise using land-weather data alone; wave, tide, current, and marine-warning sources are required for the full version.
- Reusing the general country resolver would incorrectly expose the feature abroad when country detection fails.
- Dynamically changing bottom destinations can shift the selected index; route-based tab resolution must replace hard-coded indices.
- An unrestricted cache bypass or missing rate limit can turn a public mobile endpoint into an upstream quota-exhaustion path.
