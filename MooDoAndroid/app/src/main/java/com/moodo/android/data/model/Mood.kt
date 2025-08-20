package com.moodo.android.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.Date
import java.util.UUID

@Entity(tableName = "mood_entries")
data class MoodEntry(
    @PrimaryKey
    val id: UUID = UUID.randomUUID(),
    val mood: MoodType,
    val timestamp: Date = Date()
)
