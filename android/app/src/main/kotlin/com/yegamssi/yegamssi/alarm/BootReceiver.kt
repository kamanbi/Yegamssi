package com.yegamssi.yegamssi.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * 기기 재부팅 후 AlarmManager 알람이 초기화되므로 재등록.
 * AndroidManifest에 RECEIVE_BOOT_COMPLETED 권한 필요 (이미 등록됨).
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            AlarmScheduler.schedule(context)
        }
    }
}
