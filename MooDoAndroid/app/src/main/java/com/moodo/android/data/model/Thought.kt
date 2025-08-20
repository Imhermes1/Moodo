package com.moodo.android.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.Date
import java.util.UUID

@Entity(tableName = "thoughts")
data class Thought(
    @PrimaryKey
    val id: UUID = UUID.randomUUID(),
    val title: String,
    val content: String,
    val dateCreated: Date = Date(),
    val mood: MoodType = MoodType.CALM,
    val linkedTaskId: UUID? = null
)
