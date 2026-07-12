package com.yegamssi.yegamssi.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.yegamssi.yegamssi.widget.YegamssiWidget

class WidgetAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        YegamssiWidget.refreshAll(context)
        Log.i(TAG, "Widget alarm received; cached widget refresh requested")

        AlarmScheduler.schedule(context)
    }

    companion object {
        private const val TAG = "YegamssiWidgetAlarm"
    }
}
