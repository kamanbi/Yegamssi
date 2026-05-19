package com.yegamssi.yegamssi.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import com.yegamssi.yegamssi.MainActivity
import com.yegamssi.yegamssi.R
import es.antonborri.home_widget.HomeWidgetPlugin

class YegamssiWidget : AppWidgetProvider() {

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
        private const val DEFAULT_WEATHER_CONDITION = "unknown"
        private const val DEFAULT_FORTUNE_SYMBOL = "\u27A1"
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

            views.setImageViewResource(R.id.widget_weather_icon, weatherIconResId(weatherConditionKey))
            views.setTextViewText(R.id.widget_temperature, formatTemperature(temperature))
            views.setTextViewText(
                R.id.widget_feels_like,
                "\uCCB4\uAC10 ${formatTemperature(feelsLikeTemperature)}",
            )
            views.setTextViewText(R.id.widget_fortune_symbol, fortuneSymbol)
            views.setTextViewText(R.id.widget_score, formatScore(score))
            views.setTextColor(R.id.widget_fortune_symbol, fortuneColor(fortuneSymbol))
            views.setOnClickPendingIntent(R.id.widget_root, launchAppIntent(context))

            appWidgetManager.updateAppWidget(appWidgetId, views)
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
                "sunny_night", "hot_night" -> R.drawable.widget_weather_sunny_night
                "partlyCloudy_night" -> R.drawable.widget_weather_partly_cloudy_night
                "hazy_night" -> R.drawable.widget_weather_hazy_night
                "sunny", "hot" -> R.drawable.widget_weather_sunny
                "partlyCloudy" -> R.drawable.widget_weather_partly_cloudy
                "cloudy", "unknown" -> R.drawable.widget_weather_cloudy
                "hazy" -> R.drawable.widget_weather_hazy
                "windy" -> R.drawable.widget_weather_windy
                "slightRain", "rainy", "heavyRain", "sleet" -> R.drawable.widget_weather_rain
                "thunderstorm", "rainThunder" -> R.drawable.widget_weather_thunderstorm
                "lightSnow", "snowy", "coldWave" -> R.drawable.widget_weather_snow
                else -> R.drawable.widget_weather_cloudy
            }
        }

        private fun formatTemperature(value: Int): String {
            return if (value == EMPTY_NUMBER) "--" else "$value\u00B0"
        }

        private fun formatScore(score: Int): String {
            return if (score == EMPTY_NUMBER) "--" else score.toString()
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
