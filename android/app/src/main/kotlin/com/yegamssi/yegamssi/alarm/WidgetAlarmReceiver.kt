package com.yegamssi.yegamssi.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.work.Constraints
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.yegamssi.yegamssi.widget.YegamssiWidget
import com.yegamssi.yegamssi.worker.WeatherUpdateWorker

class WidgetAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        YegamssiWidget.refreshAll(context)
        Log.i(TAG, "Widget alarm received; cached widget refresh requested")

        enqueueWeatherFetch(context)
        AlarmScheduler.schedule(context)
    }

    private fun enqueueWeatherFetch(context: Context) {
        try {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()

            val request = OneTimeWorkRequestBuilder<WeatherUpdateWorker>()
                .setConstraints(constraints)
                .addTag(WIDGET_WEATHER_WORK_TAG)
                .build()

            WorkManager.getInstance(context).enqueueUniqueWork(
                WIDGET_WEATHER_WORK_NAME,
                ExistingWorkPolicy.REPLACE,
                request,
            )
            Log.i(TAG, "Widget weather worker enqueued")
        } catch (error: Exception) {
            Log.w(TAG, "Widget weather worker enqueue failed: ${error.message}")
        }
    }

    companion object {
        private const val TAG = "YegamssiWidgetAlarm"
        private const val WIDGET_WEATHER_WORK_NAME = "widget_weather_refresh_once"
        private const val WIDGET_WEATHER_WORK_TAG = "widget_weather_refresh"
    }
}
