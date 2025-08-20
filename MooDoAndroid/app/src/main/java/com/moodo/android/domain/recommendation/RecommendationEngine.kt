package com.moodo.android.domain.recommendation

import com.moodo.android.data.model.MoodType
import com.moodo.android.data.model.TaskCategory
import com.moodo.android.data.model.TaskEmotion
import com.moodo.android.data.model.TaskPriority
import java.util.Calendar
import java.util.UUID
import javax.inject.Inject

class RecommendationEngine @Inject constructor() {

    fun generateRecommendations(context: UserContext): List<AITaskRecommendation> {
        val recommendations = mutableListOf<AITaskRecommendation>()
        recommendations.addAll(generateContextualRecommendations(context))
        return rankRecommendations(recommendations, context).take(2)
    }

    private fun generateContextualRecommendations(context: UserContext): List<AITaskRecommendation> {
        val recommendations = mutableListOf<AITaskRecommendation>()
        if (context.energyLevel > 0.7) {
            recommendations.add(AITaskRecommendation(
                title = "Tackle your most challenging task",
                description = "Your energy is at 70%+ - this is the golden hour for your hardest work.",
                category = TaskCategory.WORK,
                priority = TaskPriority.HIGH,
                estimatedDuration = 45,
                emotion = TaskEmotion.FOCUSED
            ))
        }
        if (context.stressLevel > 0.6) {
            recommendations.add(AITaskRecommendation(
                title = "5-minute breathing break",
                description = "Your stress level is high. Try box breathing to reset your nervous system.",
                category = TaskCategory.HEALTH,
                priority = TaskPriority.HIGH,
                estimatedDuration = 5,
                emotion = TaskEmotion.CALMING
            ))
        }
        return recommendations
    }

    private fun rankRecommendations(recommendations: List<AITaskRecommendation>, context: UserContext): List<AITaskRecommendation> {
        return recommendations.sortedByDescending { recommendation ->
            var score = 0.5
            val requiredEnergy = getRequiredEnergyForEmotion(recommendation.emotion)
            val energyMatch = 1.0 - Math.abs(context.energyLevel - requiredEnergy)
            score += energyMatch * 0.3
            if (recommendation.estimatedDuration <= 30) {
                score += 0.2
            }
            score
        }
    }

    private fun getRequiredEnergyForEmotion(emotion: TaskEmotion): Double {
        return when (emotion) {
            TaskEmotion.ENERGIZING, TaskEmotion.STRESSFUL, TaskEmotion.ANXIOUS -> 0.8
            TaskEmotion.FOCUSED -> 0.7
            TaskEmotion.CREATIVE -> 0.6
            TaskEmotion.ROUTINE -> 0.4
            TaskEmotion.CALMING -> 0.3
        }
    }
}

data class AITaskRecommendation(
    val id: UUID = UUID.randomUUID(),
    val title: String,
    val description: String,
    val category: TaskCategory,
    val priority: TaskPriority,
    val estimatedDuration: Int,
    val emotion: TaskEmotion
)

data class UserContext(
    val hour: Int,
    val dayOfWeek: Int,
    val currentMood: MoodType,
    val energyLevel: Double,
    val stressLevel: Double
)

fun createUserContext(mood: MoodType): UserContext {
    val calendar = Calendar.getInstance()
    val hour = calendar.get(Calendar.HOUR_OF_DAY)
    val dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK)
    val energyLevel = when (mood) {
        MoodType.ENERGIZED -> 0.9
        MoodType.FOCUSED -> 0.7
        MoodType.CREATIVE -> 0.6
        MoodType.CALM -> 0.4
        MoodType.TIRED -> 0.2
        MoodType.STRESSED, MoodType.ANXIOUS -> 0.3
    }
    val stressLevel = when (mood) {
        MoodType.STRESSED -> 0.9
        MoodType.ANXIOUS -> 0.8
        MoodType.TIRED -> 0.6
        else -> 0.2
    }
    return UserContext(hour, dayOfWeek, mood, energyLevel, stressLevel)
}
