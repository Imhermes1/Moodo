package com.moodo.android.data.db.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.moodo.android.data.model.MoodEntry
import kotlinx.coroutines.flow.Flow

@Dao
interface MoodDao {
    @Query("SELECT * FROM mood_entries ORDER BY timestamp DESC")
    fun getAllMoodEntries(): Flow<List<MoodEntry>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMoodEntry(moodEntry: MoodEntry)
}
