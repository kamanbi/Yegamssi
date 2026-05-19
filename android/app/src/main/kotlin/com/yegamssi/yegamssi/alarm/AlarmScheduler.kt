package com.yegamssi.yegamssi.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

object AlarmScheduler {

    private const val REQUEST_CODE = 7777
    private const val INTERVAL_MS = 15 * 60 * 1000L // 15분

    fun schedule(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = widgetAlarmIntent(context)

        // 이미 등록된 알람 취소 후 재등록 (중복 방지)
        alarmManager.cancel(intent)

        val triggerAt = System.currentTimeMillis() + INTERVAL_MS

        // Android 6+ Doze 모드에서도 정확히 실행되는 알람
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAt,
                intent,
            )
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAt, intent)
        }
    }

    fun cancel(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(widgetAlarmIntent(context))
    }

    private fun widgetAlarmIntent(context: Context): PendingIntent {
        val intent = Intent(context, WidgetAlarmReceiver::class.java)
        return PendingIntent.getBroadcast(
            context,
            REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
