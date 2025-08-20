package com.moodo.android.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.Date
import java.util.UUID

@Entity(tableName = "tasks")
data class Task(
    @PrimaryKey
    val id: UUID = UUID.randomUUID(),
    val title: String,
    val description: String? = null,
    val isCompleted: Boolean = false,
    val isFlagged: Boolean = false,
    val isRecurring: Boolean = false,
    val priority: TaskPriority = TaskPriority.MEDIUM,
    val emotion: TaskEmotion = TaskEmotion.FOCUSED,
    val category: TaskCategory = TaskCategory.PERSONAL,
    val estimatedTime: Int? = null, // in minutes
    val completedAt: Date? = null,
    val completedMood: MoodType? = null,
    val reminderAt: Date? = null,
    val deadlineAt: Date? = null,
    val naturalLanguageInput: String? = null,
    val createdAt: Date = Date(),
    val tags: List<String> = emptyList(),
    val isAIGenerated: Boolean = false,
    val notes: List<TaskNote> = emptyList(),
    val sourceThoughtId: UUID? = null
)

data class TaskNote(
    val id: UUID = UUID.randomUUID(),
    val text: String,
    val timestamp: Date = Date()
)
