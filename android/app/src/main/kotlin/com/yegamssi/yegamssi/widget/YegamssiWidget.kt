package com.yegamssi.yegamssi.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.util.Log
import android.widget.RemoteViews
import com.yegamssi.yegamssi.MainActivity
import com.yegamssi.yegamssi.R
import com.yegamssi.yegamssi.alarm.AlarmScheduler
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class YegamssiWidget : AppWidgetProvider() {

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.i(TAG, "Widget enabled. Rendering cached snapshot.")
        refreshAll(context)
        AlarmScheduler.schedule(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.i(TAG, "Widget disabled. Cancelling alarm.")
        AlarmScheduler.cancel(context)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val TAG = "YegamssiWidget"
        private const val DEFAULT_WEATHER_CONDITION = "unknown"
        private const val DEFAULT_FORTUNE_SYMBOL = "\u27A1"
        private const val DEFAULT_LANGUAGE = "ko"
        private const val EMPTY_TEXT = ""
        private const val EMPTY_NUMBER = Int.MIN_VALUE

        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, YegamssiWidget::class.java)
            val widgetIds = manager.getAppWidgetIds(componentName)
            widgetIds.forEach { widgetId ->
                updateWidget(context, manager, widgetId)
            }
        }

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val views = RemoteViews(context.packageName, R.layout.yegamssi_widget)
            val widgetData = HomeWidgetPlugin.getData(context)

            val weatherConditionKey = widgetData?.getString(
                "widget_weather_condition",
                DEFAULT_WEATHER_CONDITION,
            ) ?: DEFAULT_WEATHER_CONDITION
            val temperature = widgetData?.getInt("widget_temperature", EMPTY_NUMBER)
                ?: EMPTY_NUMBER
            val feelsLikeTemperature = widgetData?.getInt(
                "widget_feels_like_temperature",
                EMPTY_NUMBER,
            ) ?: EMPTY_NUMBER
            val fortuneSymbol = widgetData?.getString(
                "widget_fortune_symbol",
                DEFAULT_FORTUNE_SYMBOL,
            ) ?: DEFAULT_FORTUNE_SYMBOL
            val score = widgetData?.getInt("widget_score", EMPTY_NUMBER) ?: EMPTY_NUMBER
            val language = widgetData?.getString("widget_language", DEFAULT_LANGUAGE)
                ?: DEFAULT_LANGUAGE
            // widget_date/widget_time은 TextClock이 시스템 시계로 자동 갱신 — 값 주입 금지
            views.setImageViewResource(R.id.widget_weather_icon, weatherIconResId(weatherConditionKey))
            views.setTextViewText(R.id.widget_temperature, formatTemperature(temperature))
            views.setTextViewText(
                R.id.widget_feels_like,
                "${feelsLikeLabel(language)} ${formatTemperature(feelsLikeTemperature)}",
            )
            views.setTextViewText(R.id.widget_outdoor_label, outdoorLabel(language))
            views.setTextViewText(R.id.widget_fortune_symbol, fortuneSymbol)
            views.setTextViewText(R.id.widget_fortune_label, fortuneLabel(language))
            views.setTextViewText(R.id.widget_score, formatScore(score))
            views.setTextColor(R.id.widget_fortune_symbol, fortuneColor(fortuneSymbol))
            views.setOnClickPendingIntent(R.id.widget_root, launchAppIntent(context))

            appWidgetManager.updateAppWidget(appWidgetId, views)
            Log.i(
                TAG,
                "WidgetRefresh[${logTimestamp()}] weather=$weatherConditionKey " +
                    "outdoorScore=${formatScore(score)} fortuneArrow=$fortuneSymbol " +
                    "widgetId=$appWidgetId",
            )
        }

        private fun launchAppIntent(context: Context): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            return PendingIntent.getActivity(
                context,
                1001,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        private fun weatherIconResId(condition: String): Int {
            return when (condition) {
                "sunny_night" -> R.drawable.widget_weather_sunny_night
                "partlyCloudy_night", "cloudy_night" -> R.drawable.widget_weather_cloudy_night
                "hazy_night" -> R.drawable.widget_weather_hazy_night
                "hot_night" -> R.drawable.widget_weather_hot_night
                "sunny" -> R.drawable.widget_weather_sunny
                "partlyCloudy" -> R.drawable.widget_weather_partly_cloudy
                "cloudy" -> R.drawable.widget_weather_cloudy
                "hazy" -> R.drawable.widget_weather_hazy
                "windy" -> R.drawable.widget_weather_windy
                "slightRain" -> R.drawable.widget_weather_slight_rain
                "rainy" -> R.drawable.widget_weather_rain
                "heavyRain" -> R.drawable.widget_weather_heavy_rain
                "thunderstorm" -> R.drawable.widget_weather_thunderstorm
                "rainThunder" -> R.drawable.widget_weather_rain_thunder
                "lightSnow" -> R.drawable.widget_weather_light_snow
                "snowy" -> R.drawable.widget_weather_snow
                "sleet" -> R.drawable.widget_weather_sleet
                "hot" -> R.drawable.widget_weather_hot
                "coldWave" -> R.drawable.widget_weather_cold_wave
                "unknown" -> R.drawable.widget_weather_unknown
                else -> R.drawable.widget_weather_unknown
            }
        }

        private fun formatTemperature(value: Int): String {
            return if (value == EMPTY_NUMBER) "--" else "$value\u00B0"
        }

        private fun formatScore(score: Int): String {
            return if (score == EMPTY_NUMBER) "--" else score.toString()
        }

        private fun logTimestamp(): String {
            return SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ", Locale.US).format(Date())
        }

        private fun feelsLikeLabel(language: String): String {
            return when (language) {
                "ja" -> "\u4F53\u611F"
                "en" -> "Feels"
                "ro" -> "Resimte"
                "hi" -> "\u092E\u0939\u0938\u0942\u0938"
                "zh" -> "\u4F53\u611F"
                "es" -> "Sensaci\u00F3n"
                "pt" -> "Sensa\u00E7\u00E3o"
                "de" -> "Gef\u00FChlt"
                "fr" -> "Ressenti"
                "vi" -> "C\u1EA3m gi\u00E1c"
                else -> "\uCCB4\uAC10"
            }
        }

        private fun outdoorLabel(language: String): String {
            return when (language) {
                "ja" -> "\u5C4B\u5916"
                "en" -> "Outdoor"
                "ro" -> "Exterior"
                "hi" -> "\u092C\u093E\u0939\u0930"
                "zh" -> "\u6237\u5916"
                "es" -> "Exterior"
                "pt" -> "Exterior"
                "de" -> "Drau\u00DFen"
                "fr" -> "Ext\u00E9rieur"
                "vi" -> "Ngo\u00E0i tr\u1EDDi"
                else -> "\uC57C\uC678"
            }
        }

        private fun fortuneLabel(language: String): String {
            return when (language) {
                "ja" -> "\u904B\u52E2"
                "en" -> "Fortune"
                "ro" -> "Horoscop"
                "hi" -> "\u092D\u0935\u093F\u0937\u094D\u092F"
                "zh" -> "\u8FD0\u52BF"
                "es" -> "Fortuna"
                "pt" -> "Fortuna"
                "de" -> "Gl\u00FCck"
                "fr" -> "Fortune"
                "vi" -> "V\u1EADn m\u1EC7nh"
                else -> "\uC6B4\uC138"
            }
        }

        private fun fortuneColor(symbol: String): Int {
            return when (symbol) {
                "\u2B06" -> Color.parseColor("#7EDB9C")
                "\u2B07" -> Color.parseColor("#F29A8B")
                else -> Color.parseColor("#FFD76A")
            }
        }
    }
}
