# Release Security Checklist

1. Rotate the previously exposed Supabase service-role key and database password.
2. Remove any Play Console draft that contains the prior `1.1.33+67` artifact.
3. Configure the Edge Function secrets before building: `KMA_API_KEY`, `AIRKOREA_API_KEY`, `OPENWEATHER_API_KEY`, and `AIRNOW_API_KEY`.
4. Deploy `supabase/functions/weather-proxy` with JWT verification enabled.
5. Build only with `tool/build_release.ps1`; do not add `.env` to Flutter assets.
6. Run `tool/security_check.ps1` against source and the generated APK/AAB.
7. Confirm the new archive does not contain `.env`, a database URL, a Supabase service-role key, or provider API keys.
