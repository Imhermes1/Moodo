package com.moodo.android.domain.model

import android.os.Parcelable
import androidx.compose.ui.graphics.Color
import kotlinx.parcelize.Parcelize
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import java.util.UUID

/**
 * Core data models for MooDo Android
 * Equivalent to Models.swift in iOS version
 */

@Parcelize
data class TaskNote(
    val id: String = UUID.randomUUID().toString(),
    val text: String,
    val timestamp: Instant = Clock.System.now()
) : Parcelable

@Parcelize
data class Thought(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val content: String,
    val dateCreated: Instant = Clock.System.now(),
    val mood: MoodType = MoodType.CALM,
    val linkedTaskId: String? = null
) : Parcelable

@Parcelize
data class Task(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val description: String? = null,
    val isCompleted: Boolean = false,
    val isFlagged: Boolean = false,
    val isRecurring: Boolean = false,
    val priority: TaskPriority = TaskPriority.MEDIUM,
    val emotion: TaskEmotion = TaskEmotion.FOCUSED,
    val category: TaskCategory = TaskCategory.PERSONAL,
    val estimatedTime: Int? = null, // in minutes
    val completedAt: Instant? = null,
    val completedMood: MoodType? = null,
    val reminderAt: Instant? = null,
    val deadlineAt: Instant? = null,
    val naturalLanguageInput: String? = null,
    val createdAt: Instant = Clock.System.now(),
    val list: TaskList? = null,
    val tags: List<String> = emptyList(),
    val subtasks: List<Task>? = null,
    val eventKitIdentifier: String? = null,
    val isAIGenerated: Boolean = false,
    val notes: List<TaskNote> = emptyList(),
    val sourceThoughtId: String? = null
) : Parcelable {
    
    /**
     * Dynamic priority system - escalates based on deadlines
     * Equivalent to iOS dynamicPriority computed property
     */
    val dynamicPriority: TaskPriority
        get() {
            if (isCompleted) return priority
            
            val deadline = reminderAt ?: deadlineAt ?: return priority
            val now = Clock.System.now()
            val daysUntil = (deadline.toEpochMilliseconds() - now.toEpochMilliseconds()) / (24 * 60 * 60 * 1000)
            
            return when {
                daysUntil <= 0 -> TaskPriority.HIGH // Overdue or today
                daysUntil == 1L -> TaskPriority.HIGH // Tomorrow
                daysUntil in 2..3 -> if (priority == TaskPriority.LOW) TaskPriority.MEDIUM else TaskPriority.HIGH
                daysUntil in 4..7 -> if (priority == TaskPriority.LOW) TaskPriority.MEDIUM else priority
                else -> priority
            }
        }
    
    val isEscalated: Boolean
        get() = dynamicPriority != priority
    
    val priorityDescription: String
        get() = if (isEscalated) {
            when (dynamicPriority) {
                TaskPriority.HIGH -> "High (Due Soon)"
                TaskPriority.MEDIUM -> "Medium (This Week)"
                TaskPriority.LOW -> priority.displayName
            }
        } else {
            dynamicPriority.displayName
        }
}

enum class TaskPriority(val displayName: String, val numericValue: Int) {
    LOW("Low", 1),
    MEDIUM("Medium", 2),
    HIGH("High", 3);
    
    val color: Color
        get() = when (this) {
            LOW -> Color(0xFF38B349) // Green
            MEDIUM -> Color(0xFFF39C12) // Orange
            HIGH -> Color(0xFFE74C3C) // Red
        }
}

enum class TaskEmotion(
    val displayName: String,
    val iconName: String
) {
    ENERGIZING("Energizing", "bolt"),
    FOCUSED("Focused", "psychology"),
    CALMING("Calming", "eco"),
    CREATIVE("Creative", "lightbulb"),
    ROUTINE("Routine", "repeat"),
    STRESSFUL("Stressful", "warning"),
    ANXIOUS("Anxious", "help");
    
    val color: Color
        get() = when (this) {
            ENERGIZING -> Color(0xFFF39C12) // Orange
            FOCUSED -> Color(0xFF3498DB) // Blue
            CALMING -> Color(0xFF38B349) // Green
            CREATIVE -> Color(0xFF9B59B6) // Purple
            ROUTINE -> Color(0xFF27AE60) // Green
            STRESSFUL -> Color(0xFFE74C3C) // Red
            ANXIOUS -> Color(0xFFF1C40F) // Yellow
        }
}

enum class TaskCategory(
    val displayName: String,
    val iconName: String
) {
    WORK("Work", "work"),
    PERSONAL("Personal", "person"),
    HEALTH("Health", "favorite"),
    SHOPPING("Shopping", "shopping_cart"),
    LEARNING("Learning", "school"),
    FINANCE("Finance", "attach_money"),
    TRAVEL("Travel", "flight"),
    CREATIVE("Creative", "brush");
    
    val color: Color
        get() = when (this) {
            WORK -> Color(0xFF3498DB)
            PERSONAL -> Color(0xFF27AE60)
            HEALTH -> Color(0xFFE74C3C)
            SHOPPING -> Color(0xFFF39C12)
            LEARNING -> Color(0xFF9B59B6)
            FINANCE -> Color(0xFFF1C40F)
            TRAVEL -> Color(0xFF1ABC9C)
            CREATIVE -> Color(0xFFE91E63)
        }
}

@Parcelize
data class MoodEntry(
    val id: String = UUID.randomUUID().toString(),
    val mood: MoodType,
    val timestamp: Instant = Clock.System.now()
) : Parcelable

enum class MoodType(
    val displayName: String,
    val iconName: String,
    val numericValue: Double
) {
    ENERGIZED("Energized", "flash_on", 9.0),
    FOCUSED("Focused", "psychology", 8.0),
    CALM("Calm", "eco", 7.0),
    CREATIVE("Creative", "lightbulb", 8.5),
    STRESSED("Stressed", "sentiment_dissatisfied", 3.0),
    TIRED("Tired", "bed", 2.0),
    ANXIOUS("Anxious", "favorite", 4.0);
    
    val color: Color
        get() = when (this) {
            ENERGIZED -> Color(0xFFF39C12) // Orange
            FOCUSED -> Color(0xFF3498DB) // Blue
            CALM -> Color(0xFF38B349) // Green
            CREATIVE -> Color(0xFF9B59B6) // Purple
            STRESSED -> Color(0xFFE74C3C) // Red
            TIRED -> Color(0xFF95A5A6) // Gray
            ANXIOUS -> Color(0xFFBF9AD6) // Light Purple
        }
    
    /**
     * Smart task matching - returns compatible task emotions for this mood
     * Equivalent to iOS compatibleTaskEmotions computed property
     */
    val compatibleTaskEmotions: List<TaskEmotion>
        get() = when (this) {
            ENERGIZED -> listOf(TaskEmotion.ENERGIZING, TaskEmotion.FOCUSED, TaskEmotion.CREATIVE)
            FOCUSED -> listOf(TaskEmotion.FOCUSED, TaskEmotion.ROUTINE, TaskEmotion.CREATIVE)
            CALM -> listOf(TaskEmotion.CALMING, TaskEmotion.ROUTINE)
            CREATIVE -> listOf(TaskEmotion.CREATIVE, TaskEmotion.CALMING)
            STRESSED -> listOf(TaskEmotion.CALMING, TaskEmotion.ROUTINE)
            TIRED -> listOf(TaskEmotion.CALMING)
            ANXIOUS -> listOf(TaskEmotion.CALMING, TaskEmotion.ROUTINE)
        }
}

@Parcelize
data class VoiceCheckin(
    val id: String = UUID.randomUUID().toString(),
    val transcript: String,
    val mood: MoodType? = null,
    val tasks: List<String> = emptyList(),
    val timestamp: Instant = Clock.System.now(),
    val duration: Long = 0 // in milliseconds
) : Parcelable

enum class SmartListType(
    val displayName: String,
    val iconName: String
) {
    TODAY("Today", "today"),
    TOMORROW("Tomorrow", "event"),
    THIS_WEEK("This Week", "date_range"),
    UPCOMING("Upcoming", "schedule"),
    IMPORTANT("Important", "priority_high"),
    COMPLETED("Completed", "check_circle"),
    ALL("All", "list");
    
    val color: Color
        get() = when (this) {
            TODAY -> Color(0xFF3498DB)
            TOMORROW -> Color(0xFF27AE60)
            THIS_WEEK -> Color(0xFFF39C12)
            UPCOMING -> Color(0xFF1ABC9C)
            IMPORTANT -> Color(0xFFE74C3C)
            COMPLETED -> Color(0xFF95A5A6)
            ALL -> Color(0xFF9B59B6)
        }
}

@Parcelize
data class TaskList(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val colorName: String,
    val iconName: String
) : Parcelable {
    
    val color: Color
        get() = when (colorName) {
            "red" -> Color(0xFFE74C3C)
            "blue" -> Color(0xFF3498DB)
            "green" -> Color(0xFF27AE60)
            "orange" -> Color(0xFFF39C12)
            "purple" -> Color(0xFF9B59B6)
            "pink" -> Color(0xFFE91E63)
            "yellow" -> Color(0xFFF1C40F)
            "cyan" -> Color(0xFF1ABC9C)
            else -> Color(0xFF3498DB)
        }
}

/**
 * Learning data models for AI recommendations
 */
@Parcelize
data class TaskCompletionData(
    val taskId: String,
    val emotion: TaskEmotion,
    val priority: TaskPriority,
    val dynamicPriority: TaskPriority,
    val category: TaskCategory,
    val mood: MoodType,
    val estimatedTime: Int?,
    val actualCompletionTime: Int?,
    val wasSuccessful: Boolean,
    val completedAt: Instant,
    val isAIGenerated: Boolean
) : Parcelable