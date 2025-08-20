package com.moodo.android.util.calendar

import android.content.ContentValues
import android.content.Context
import android.provider.CalendarContract
import com.moodo.android.data.model.Task
import dagger.hilt.android.qualifiers.ApplicationContext
import java.util.TimeZone
import javax.inject.Inject

class CalendarManager @Inject constructor(
    @ApplicationContext private val context: Context
) {

    fun addReminder(task: Task) {
        if (task.reminderAt == null) return

        val calID: Long = 1 // Use the primary calendar
        val startMillis: Long = task.reminderAt.time
        val endMillis: Long = startMillis + 60 * 60 * 1000 // 1 hour

        val values = ContentValues().apply {
            put(CalendarContract.Events.DTSTART, startMillis)
            put(CalendarContract.Events.DTEND, endMillis)
            put(CalendarContract.Events.TITLE, task.title)
            put(CalendarContract.Events.DESCRIPTION, task.description)
            put(CalendarContract.Events.CALENDAR_ID, calID)
            put(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().id)
        }
        // This will require calendar permissions, which need to be handled in the UI
        context.contentResolver.insert(CalendarContract.Events.CONTENT_URI, values)
    }
}
