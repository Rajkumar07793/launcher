package com.example.launcher

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.content.Intent


class NotificationService : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName
        val extras = sbn.notification.extras
        val title = extras.getString("android.title") ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""

        val intent = Intent("com.example.launcher.NOTIFICATION")
        intent.putExtra("packageName", packageName)
        intent.putExtra("title", title)
        intent.putExtra("text", text)
        intent.putExtra("id", sbn.id)
        sendBroadcast(intent)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        val intent = Intent("com.example.launcher.NOTIFICATION_REMOVED")
        intent.putExtra("id", sbn.id)
        sendBroadcast(intent)
    }
}
