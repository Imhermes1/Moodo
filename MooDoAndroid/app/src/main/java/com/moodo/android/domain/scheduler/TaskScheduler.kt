package com.moodo.android.domain.scheduler

import com.moodo.android.data.model.MoodType
import com.moodo.android.data.model.Task
import com.moodo.android.data.model.TaskEmotion
import com.moodo.android.data.model.TaskPriority
import java.util.Calendar
import javax.inject.Inject

class TaskScheduler @Inject constructor() {

    var currentMood: MoodType = MoodType.CALM

    fun optimizeTaskSchedule(tasks: List<Task>, maxTasks: Int? = null): List<Task> {
        val incompleteTasks = tasks.filter { !it.isCompleted }
        val moodPreferences = getMoodTaskPreferences(currentMood)

        val scoredTasks = incompleteTasks.map { task ->
            task to calculateMoodCompatibilityScore(task, moodPreferences)
        }

        val prioritizedTasks = scoredTasks.filter { (task, score) ->
            if (currentMood == MoodType.STRESSED) {
                return@filter task.emotion != TaskEmotion.STRESSFUL && (score >= 0.5 || task.emotion == TaskEmotion.CALMING)
            }
            val isHighPriority = task.priority == TaskPriority.HIGH
            val isDueToday = task.deadlineAt?.isToday() ?: false
            val hasGoodMoodMatch = score >= 0.6
            isHighPriority || isDueToday || hasGoodMoodMatch
        }

        val sortedTasks = prioritizedTasks.sortedWith(compareByDescending<Pair<Task, Double>> { (task, _) ->
            isUrgent(task)
        }.thenByDescending { (_, score) ->
            score
        }.thenByDescending { (task, _) ->
            task.priority
        }.thenBy { (task, _) ->
            task.reminderAt
        })

        val optimalCount = maxTasks ?: getOptimalTaskCount(currentMood)
        return sortedTasks.map { it.first }.take(optimalCount)
    }

    private fun getMoodTaskPreferences(mood: MoodType): MoodTaskPreferences {
        return when (mood) {
            MoodType.ENERGIZED -> MoodTaskPreferences(
                preferredEmotions = listOf(TaskEmotion.ENERGIZING, TaskEmotion.CREATIVE, TaskEmotion.FOCUSED),
                preferredPriorities = listOf(TaskPriority.HIGH, TaskPriority.MEDIUM)
            )
            MoodType.CALM -> MoodTaskPreferences(
                preferredEmotions = listOf(TaskEmotion.CALMING, TaskEmotion.ROUTINE),
                preferredPriorities = listOf(TaskPriority.LOW, TaskPriority.MEDIUM)
            )
            MoodType.FOCUSED -> MoodTaskPreferences(
                preferredEmotions = listOf(TaskEmotion.FOCUSED, TaskEmotion.ROUTINE),
                preferredPriorities = listOf(TaskPriority.HIGH, TaskPriority.MEDIUM)
            )
            MoodType.STRESSED -> MoodTaskPreferences(
                preferredEmotions = listOf(TaskEmotion.CALMING, TaskEmotion.ROUTINE),
                preferredPriorities = listOf(TaskPriority.LOW)
            )
            MoodType.CREATIVE -> MoodTaskPreferences(
                preferredEmotions = listOf(TaskEmotion.CREATIVE, TaskEmotion.CALMING, TaskEmotion.FOCUSED),
                preferredPriorities = listOf(TaskPriority.MEDIUM, TaskPriority.HIGH)
            )
            MoodType.TIRED -> MoodTaskPreferences(
                preferredEmotions = listOf(TaskEmotion.CALMING),
                preferredPriorities = listOf(TaskPriority.LOW)
            )
            MoodType.ANXIOUS -> MoodTaskPreferences(
                preferredEmotions = listOf(TaskEmotion.CALMING, TaskEmotion.ROUTINE),
                preferredPriorities = listOf(TaskPriority.LOW, TaskPriority.MEDIUM)
            )
        }
    }

    private fun calculateMoodCompatibilityScore(task: Task, preferences: MoodTaskPreferences): Double {
        var score = 0.0
        if (preferences.preferredEmotions.contains(task.emotion)) {
            score += 0.4
        } else {
            score += 0.1
        }
        if (preferences.preferredPriorities.contains(task.priority)) {
            score += 0.3
        } else if (task.priority == TaskPriority.HIGH && currentMood != MoodType.STRESSED) {
            score += 0.2
        }
        return score.coerceIn(0.0, 1.0)
    }

    private fun isUrgent(task: Task): Boolean {
        return (task.deadlineAt?.isToday() ?: false) && task.priority == TaskPriority.HIGH
    }

    private fun getOptimalTaskCount(mood: MoodType): Int {
        val baseCount = when (mood) {
            MoodType.ENERGIZED -> 8
            MoodType.CALM -> 5
            MoodType.FOCUSED -> 6
            MoodType.STRESSED -> 3
            MoodType.CREATIVE -> 7
            MoodType.TIRED -> 2
            MoodType.ANXIOUS -> 4
        }
        val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        val timeMultiplier = when (hour) {
            in 0..8 -> 0.8
            in 9..11 -> 1.0
            in 12..13 -> 0.9
            in 14..16 -> 1.0
            in 17..19 -> 0.8
            else -> 0.6
        }
        return (baseCount * timeMultiplier).toInt().coerceAtLeast(2)
    }
}

data class MoodTaskPreferences(
    val preferredEmotions: List<TaskEmotion>,
    val preferredPriorities: List<TaskPriority>
)

fun java.util.Date.isToday(): Boolean {
    val today = Calendar.getInstance()
    val thisDate = Calendar.getInstance()
    thisDate.time = this
    return today.get(Calendar.YEAR) == thisDate.get(Calendar.YEAR) &&
            today.get(Calendar.DAY_OF_YEAR) == thisDate.get(Calendar.DAY_OF_YEAR)
}
