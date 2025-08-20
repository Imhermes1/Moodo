package com.moodo.android.data.db

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.moodo.android.data.db.dao.MoodDao
import com.moodo.android.data.db.dao.TaskDao
import com.moodo.android.data.db.dao.ThoughtDao
import com.moodo.android.data.model.MoodEntry
import com.moodo.android.data.model.Task
import com.moodo.android.data.model.Thought

@Database(
    entities = [Task::class, Thought::class, MoodEntry::class],
    version = 1,
    exportSchema = false
)
@TypeConverters(com.moodo.android.data.db.TypeConverters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun taskDao(): TaskDao
    abstract fun thoughtDao(): ThoughtDao
    abstract fun moodDao(): MoodDao
}
