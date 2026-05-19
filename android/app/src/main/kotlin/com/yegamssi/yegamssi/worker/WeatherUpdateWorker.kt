package com.yegamssi.yegamssi.worker

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.yegamssi.yegamssi.widget.YegamssiWidget
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URLEncoder
import java.net.URL
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import kotlin.math.floor
import kotlin.math.pow
import kotlin.math.roundToInt
import kotlin.math.sin
import kotlin.math.tan

class WeatherUpdateWorker(
    context: Context,
    params: WorkerParameters,
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        return@withContext try {
            val context = applicationContext
            val prefs = HomeWidgetPlugin.getData(context)
            val position = loadPosition(context, prefs)
            val apiKey = readEnvValue(context, "KMA_API_KEY")

            prefs.edit()
                .putString(KEY_BG_LAST_ATTEMPT, LocalDateTime.now().toString())
                .apply()

            if (apiKey.isBlank()) {
                prefs.edit()
                    .putString(KEY_BG_LAST_ERROR, "missing_kma_api_key")
                    .apply()
                YegamssiWidget.refreshAll(context)
                Log.w(TAG, "Widget weather refresh skipped: missing KMA API key")
                return@withContext Result.success()
            }

            val weather = fetchKmaNow(apiKey, position)
            val cachedOutdoorScore = prefs.readInt(KEY_SCORE)
            val weatherCondition = conditionKey(weather)
            val nowText = LocalDateTime.now().toString()
            val editor = prefs.edit()
                .putString(KEY_WEATHER_CONDITION, weatherCondition)
                .putString(KEY_WEATHER_SYMBOL, weatherSymbol(weatherCondition))
                .putInt(KEY_TEMPERATURE, weather.temperatureCelsius.roundToInt())
                .putInt(KEY_FEELS_LIKE, weather.temperatureCelsius.roundToInt())
                .putFloat(KEY_LATITUDE, position.lat.toFloat())
                .putFloat(KEY_LONGITUDE, position.lon.toFloat())
                .putString(KEY_UPDATED_AT, nowText)
                .putString(KEY_BG_LAST_SUCCESS, nowText)
                .remove(KEY_BG_LAST_ERROR)

            if (cachedOutdoorScore != null) {
                editor.putInt(KEY_SCORE, cachedOutdoorScore)
            }

            editor.apply()

            YegamssiWidget.refreshAll(context)
            Log.i(
                TAG,
                "Widget weather refresh success condition=$weatherCondition temp=${weather.temperatureCelsius.roundToInt()} cachedScore=${cachedOutdoorScore ?: "none"}",
            )
            Result.success()
        } catch (error: Exception) {
            HomeWidgetPlugin.getData(applicationContext)
                .edit()
                .putString(KEY_BG_LAST_ERROR, "${error::class.java.simpleName}: ${error.message}")
                .apply()
            YegamssiWidget.refreshAll(applicationContext)
            Log.w(TAG, "Widget weather refresh failed: ${error.message}")
            Result.retry()
        }
    }

    private fun loadPosition(
        context: Context,
        widgetPrefs: android.content.SharedPreferences,
    ): Position {
        val widgetLat = widgetPrefs.readDouble(KEY_LATITUDE)
        val widgetLon = widgetPrefs.readDouble(KEY_LONGITUDE)
        if (widgetLat != null && widgetLon != null) {
            return Position(widgetLat, widgetLon)
        }

        val flutterPrefs = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE,
        )
        val cachedLat = flutterPrefs.readDouble("flutter.last_known_latitude")
            ?: flutterPrefs.readDouble("last_known_latitude")
        val cachedLon = flutterPrefs.readDouble("flutter.last_known_longitude")
            ?: flutterPrefs.readDouble("last_known_longitude")

        return if (cachedLat != null && cachedLon != null) {
            Position(cachedLat, cachedLon)
        } else {
            Position(DEFAULT_LAT, DEFAULT_LON)
        }
    }

    private fun android.content.SharedPreferences.readDouble(key: String): Double? {
        if (!contains(key)) return null
        return when (val value = all[key]) {
            is Float -> value.toDouble()
            is Long -> java.lang.Double.longBitsToDouble(value)
            is Int -> value.toDouble()
            is String -> value.toDoubleOrNull()
            else -> null
        }
    }

    private fun android.content.SharedPreferences.readInt(key: String): Int? {
        if (!contains(key)) return null
        return when (val value = all[key]) {
            is Int -> value
            is Long -> value.toInt()
            is Float -> value.toInt()
            is String -> value.toIntOrNull()
            else -> null
        }
    }

    private fun readEnvValue(context: Context, key: String): String {
        val candidatePaths = listOf("flutter_assets/.env", ".env")
        for (path in candidatePaths) {
            try {
                context.assets.open(path).bufferedReader().useLines { lines ->
                    lines.forEach { rawLine ->
                        val line = rawLine.trim()
                        if (line.isEmpty() || line.startsWith("#")) return@forEach
                        val separator = line.indexOf('=')
                        if (separator <= 0) return@forEach
                        val envKey = line.substring(0, separator).trim()
                        if (envKey != key) return@forEach
                        return line.substring(separator + 1).trim().trim('"', '\'')
                    }
                }
            } catch (_: Exception) {
                // Try next asset path.
            }
        }
        return ""
    }

    private fun fetchKmaNow(apiKey: String, position: Position): NativeWeather {
        val grid = latLonToGrid(position.lat, position.lon)
        val baseTime = kmaBaseTime(LocalDateTime.now())
        val query = listOf(
            "authKey=${URLEncoder.encode(apiKey, "UTF-8")}",
            "dataType=JSON",
            "numOfRows=20",
            "pageNo=1",
            "base_date=${baseTime.date}",
            "base_time=${baseTime.time}",
            "nx=${grid.nx}",
            "ny=${grid.ny}",
        ).joinToString("&")
        val connection = (URL("$KMA_NCST_URL?$query").openConnection() as HttpURLConnection).apply {
            connectTimeout = NETWORK_TIMEOUT_MS
            readTimeout = NETWORK_TIMEOUT_MS
            requestMethod = "GET"
        }

        val responseText = try {
            if (connection.responseCode !in 200..299) {
                throw IllegalStateException("KMA HTTP ${connection.responseCode}")
            }
            connection.inputStream.bufferedReader().use { it.readText() }
        } finally {
            connection.disconnect()
        }

        val items = JSONObject(responseText)
            .getJSONObject("response")
            .getJSONObject("body")
            .getJSONObject("items")
            .getJSONArray("item")

        val values = mutableMapOf<String, String>()
        for (index in 0 until items.length()) {
            val item = items.getJSONObject(index)
            values[item.optString("category")] = item.optString("obsrValue")
        }

        val temperature = values["T1H"]?.toDoubleOrNull()
            ?: throw IllegalStateException("KMA temperature missing")
        val precipitationType = values["PTY"]?.toIntOrNull() ?: 0
        val humidity = values["REH"]?.toDoubleOrNull() ?: 0.0
        val windSpeed = values["WSD"]?.toDoubleOrNull() ?: 0.0
        val rainVolume = values["RN1"]?.toDoubleOrNull() ?: 0.0

        return NativeWeather(
            temperatureCelsius = temperature,
            precipitationType = precipitationType,
            humidity = humidity,
            windSpeedMs = windSpeed,
            rainVolumeMm = rainVolume,
            isNight = isNightNow(),
        )
    }

    private fun kmaBaseTime(now: LocalDateTime): KmaBaseTime {
        val base = if (now.minute < 45) now.minusHours(1) else now
        return KmaBaseTime(
            date = base.format(DateTimeFormatter.ofPattern("yyyyMMdd")),
            time = base.format(DateTimeFormatter.ofPattern("HH00")),
        )
    }

    private fun conditionKey(weather: NativeWeather): String {
        val dayCondition = when {
            weather.precipitationType == 3 || weather.precipitationType == 7 -> "snowy"
            weather.precipitationType == 2 || weather.precipitationType == 6 -> "sleet"
            weather.precipitationType != 0 || weather.rainVolumeMm > 0.0 -> "rainy"
            weather.windSpeedMs >= 8.0 -> "windy"
            weather.temperatureCelsius >= 33.0 -> "hot"
            weather.humidity >= 85.0 -> "cloudy"
            else -> "sunny"
        }

        return if (weather.isNight && dayCondition in NIGHT_VARIANTS) {
            "${dayCondition}_night"
        } else {
            dayCondition
        }
    }

    private fun weatherSymbol(condition: String): String {
        return when (condition.removeSuffix("_night")) {
            "rainy" -> "\uBE44"
            "snowy" -> "\uB208"
            "sleet" -> "\uC9C4\uB208\uAE68\uBE44"
            "windy" -> "\uBC14\uB78C"
            "hot" -> "\uB354\uC6C0"
            "cloudy" -> "\uD750\uB9BC"
            else -> "\uB9D1\uC74C"
        }
    }

    private fun isNightNow(): Boolean {
        val hour = LocalDateTime.now().hour
        return hour < 6 || hour >= 20
    }

    private fun latLonToGrid(lat: Double, lon: Double): Grid {
        val re = 6371.00877 / 5.0
        val slat1 = Math.toRadians(30.0)
        val slat2 = Math.toRadians(60.0)
        val olon = Math.toRadians(126.0)
        val olat = Math.toRadians(38.0)
        val xo = 43.0
        val yo = 136.0

        var sn = tan(Math.PI * 0.25 + slat2 * 0.5) / tan(Math.PI * 0.25 + slat1 * 0.5)
        sn = kotlin.math.ln(kotlin.math.cos(slat1) / kotlin.math.cos(slat2)) / kotlin.math.ln(sn)
        var sf = tan(Math.PI * 0.25 + slat1 * 0.5)
        sf = sf.pow(sn) * kotlin.math.cos(slat1) / sn
        var ro = tan(Math.PI * 0.25 + olat * 0.5)
        ro = re * sf / ro.pow(sn)

        var ra = tan(Math.PI * 0.25 + Math.toRadians(lat) * 0.5)
        ra = re * sf / ra.pow(sn)
        var theta = Math.toRadians(lon) - olon
        if (theta > Math.PI) theta -= 2.0 * Math.PI
        if (theta < -Math.PI) theta += 2.0 * Math.PI
        theta *= sn

        val nx = floor(ra * sin(theta) + xo + 0.5).toInt()
        val ny = floor(ro - ra * kotlin.math.cos(theta) + yo + 0.5).toInt()
        return Grid(nx, ny)
    }

    private data class Position(val lat: Double, val lon: Double)
    private data class Grid(val nx: Int, val ny: Int)
    private data class KmaBaseTime(val date: String, val time: String)
    private data class NativeWeather(
        val temperatureCelsius: Double,
        val precipitationType: Int,
        val humidity: Double,
        val windSpeedMs: Double,
        val rainVolumeMm: Double,
        val isNight: Boolean,
    )

    companion object {
        private const val DEFAULT_LAT = 37.5665
        private const val DEFAULT_LON = 126.9780
        private const val NETWORK_TIMEOUT_MS = 12_000
        private const val KMA_NCST_URL =
            "https://apihub.kma.go.kr/api/typ02/openApi/VilageFcstInfoService_2.0/getUltraSrtNcst"
        private const val TAG = "YegamssiWeatherWorker"

        private const val KEY_WEATHER_CONDITION = "widget_weather_condition"
        private const val KEY_WEATHER_SYMBOL = "widget_weather_symbol"
        private const val KEY_TEMPERATURE = "widget_temperature"
        private const val KEY_FEELS_LIKE = "widget_feels_like_temperature"
        private const val KEY_SCORE = "widget_score"
        private const val KEY_UPDATED_AT = "widget_updated_at"
        private const val KEY_LATITUDE = "widget_latitude"
        private const val KEY_LONGITUDE = "widget_longitude"
        private const val KEY_BG_LAST_ATTEMPT = "bg_last_attempt"
        private const val KEY_BG_LAST_SUCCESS = "bg_last_success"
        private const val KEY_BG_LAST_ERROR = "bg_last_error"

        private val NIGHT_VARIANTS = setOf("sunny", "hot")
    }
}
