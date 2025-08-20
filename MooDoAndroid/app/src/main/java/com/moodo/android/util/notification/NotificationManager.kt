package com.moodo.android.util.notification

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.moodo.android.R
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject

const val NOTIFICATION_CHANNEL_ID = "moodo_channel"
const val NOTIFICATION_ID = 1
const val EXTRA_TITLE = "extra_title"
const val EXTRA_MESSAGE = "extra_message"

class TaskNotificationManager @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    fun showNotification(title: String, message: String) {
        val notification = NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()

        notificationManager.notify(NOTIFICATION_ID, notification)
    }
}

class TaskNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra(EXTRA_TITLE) ?: "Task Reminder"
        val message = intent.getStringExtra(EXTRA_MESSAGE) ?: "You have a task due."

        val notificationManager = TaskNotificationManager(context)
        notificationManager.showNotification(title, message)
    }
}
