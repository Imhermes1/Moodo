package com.moodo.android.ml

import com.google.mlkit.nl.languageid.LanguageIdentification
import com.google.mlkit.nl.languageid.LanguageIdentifier
import com.moodo.android.domain.model.*
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.coroutines.resume
import kotlin.math.abs
import kotlin.random.Random

/**
 * ML-powered task recommendation engine
 * Equivalent to MLTaskEngine.swift in iOS version
 * Uses Google's ML Kit (equivalent to Apple's Core ML + Natural Language frameworks)
 */
@Singleton
class AndroidMLTaskEngine @Inject constructor() {
    
    private val languageIdentifier: LanguageIdentifier = LanguageIdentification.getClient()
    
    // Local learning data storage (equivalent to iOS UserDefaults approach)
    private var userLearningData = UserLearningData()
    
    data class AITaskRecommendation(
        val title: String,
        val description: String,
        val emotion: TaskEmotion,
        val priority: TaskPriority,
        val category: TaskCategory,
        val confidence: Double,
        val reasoning: String
    )
    
    data class UserLearningData(
        val taskCompletions: MutableList<TaskCompletionPattern> = mutableListOf(),
        val moodPatterns: MutableList<MoodPattern> = mutableListOf(),
        val timePreferences: MutableMap<String, Double> = mutableMapOf()
    )
    
    data class TaskCompletionPattern(
        val mood: MoodType,
        val emotion: TaskEmotion,
        val timeOfDay: Int, // hour of day 0-23
        val successRate: Double,
        val completionTime: Long // milliseconds
    )
    
    data class MoodPattern(
        val mood: MoodType,
        val timeOfDay: Int,
        val frequency: Int,
        val context: String
    )
    
    /**
     * Generate AI-powered task recommendations based on current context
     * Following Google's ML Kit best practices for on-device processing
     */
    suspend fun generateRecommendations(
        currentMood: MoodType,
        existingTasks: List<Task>,
        completedTasks: List<Task>,
        timeOfDay: Instant = Clock.System.now()
    ): List<AITaskRecommendation> {
        
        // 1. Analyze user context using Android ML patterns
        val context = analyzeUserContext(currentMood, existingTasks, completedTasks, timeOfDay)
        
        // 2. Generate contextual recommendations
        val recommendations = generateContextualRecommendations(context)
        
        // 3. Enhance with natural language processing (ML Kit)
        val enhancedRecommendations = enhanceWithMLKit(recommendations)
        
        // 4. Rank using learned patterns
        return rankWithMLPatterns(enhancedRecommendations, context)
    }
    
    /**
     * Natural Language Processing for task input
     * Equivalent to iOS NaturalLanguageProcessor
     */
    suspend fun processNaturalLanguageInput(input: String): ProcessedTaskResult {
        if (input.isBlank()) {
            return ProcessedTaskResult(
                title = input,
                description = null,
                priority = TaskPriority.MEDIUM,
                emotion = TaskEmotion.ROUTINE,
                reminderAt = null,
                deadlineAt = null,
                tags = emptyList()
            )
        }
        
        // Use ML Kit for language detection and analysis
        val language = detectLanguage(input)
        
        // Extract task components using regex patterns and ML Kit insights
        val cleanTitle = cleanTitleFromNLPPatterns(input)
        val priority = determinePriority(input)
        val emotion = determineEmotion(input)
        val reminderTime = extractReminderTime(input)
        val tags = extractTags(input)
        
        return ProcessedTaskResult(
            title = cleanTitle,
            description = input,
            priority = priority,
            emotion = emotion,
            reminderAt = reminderTime,
            deadlineAt = null,
            tags = tags
        )
    }
    
    private suspend fun detectLanguage(text: String): String = suspendCancellableCoroutine { continuation ->
        languageIdentifier.identifyLanguage(text)
            .addOnSuccessListener { languageCode ->
                continuation.resume(languageCode)
            }
            .addOnFailureListener {
                continuation.resume("en") // Default to English
            }
    }
    
    private fun analyzeUserContext(
        currentMood: MoodType,
        existingTasks: List<Task>,
        completedTasks: List<Task>,
        timeOfDay: Instant
    ): UserContext {
        val hour = timeOfDay.toEpochMilliseconds() / 1000 / 3600 % 24
        
        // Analyze patterns from completed tasks
        val recentCompletions = completedTasks.filter { task ->
            task.completedAt?.let { completedAt ->
                val timeDiff = Clock.System.now().toEpochMilliseconds() - completedAt.toEpochMilliseconds()
                timeDiff < 7 * 24 * 60 * 60 * 1000 // Last 7 days
            } ?: false
        }
        
        // Calculate productivity score based on recent completions
        val productivityScore = calculateProductivityScore(recentCompletions, currentMood)
        
        // Determine optimal task count based on mood and time
        val optimalTaskCount = getOptimalTaskCount(currentMood, hour.toInt())
        
        return UserContext(
            mood = currentMood,
            timeOfDay = hour.toInt(),
            productivityScore = productivityScore,
            optimalTaskCount = optimalTaskCount,
            recentCompletions = recentCompletions,
            existingTaskLoad = existingTasks.size
        )
    }
    
    private fun generateContextualRecommendations(context: UserContext): List<AITaskRecommendation> {
        val recommendations = mutableListOf<AITaskRecommendation>()
        
        // Generate mood-specific recommendations
        val moodRecommendations = getMoodSpecificRecommendations(context.mood, context.timeOfDay)
        recommendations.addAll(moodRecommendations)
        
        // Generate time-specific recommendations
        val timeRecommendations = getTimeSpecificRecommendations(context.timeOfDay, context.mood)
        recommendations.addAll(timeRecommendations)
        
        // Generate wellness recommendations based on stress indicators
        if (context.mood == MoodType.STRESSED || context.mood == MoodType.ANXIOUS) {
            val wellnessRecommendations = getWellnessRecommendations(context.mood)
            recommendations.addAll(wellnessRecommendations)
        }
        
        return recommendations.take(context.optimalTaskCount)
    }
    
    private suspend fun enhanceWithMLKit(recommendations: List<AITaskRecommendation>): List<AITaskRecommendation> {
        // Use ML Kit for text analysis and enhancement
        return recommendations.map { recommendation ->
            // Enhance recommendation descriptions with ML insights
            val enhancedDescription = enhanceDescriptionWithML(recommendation.description)
            recommendation.copy(description = enhancedDescription)
        }
    }
    
    private suspend fun enhanceDescriptionWithML(description: String): String {
        // Use ML Kit for sentiment analysis and text enhancement
        // This would typically involve ML Kit's Natural Language APIs
        return description // Simplified for now
    }
    
    private fun rankWithMLPatterns(
        recommendations: List<AITaskRecommendation>,
        context: UserContext
    ): List<AITaskRecommendation> {
        return recommendations.sortedByDescending { recommendation ->
            calculateRecommendationScore(recommendation, context)
        }
    }
    
    private fun calculateRecommendationScore(
        recommendation: AITaskRecommendation,
        context: UserContext
    ): Double {
        var score = recommendation.confidence
        
        // Boost score for mood-compatible emotions
        if (context.mood.compatibleTaskEmotions.contains(recommendation.emotion)) {
            score += 0.3
        }
        
        // Time-based scoring
        val timeScore = getTimeCompatibilityScore(context.timeOfDay, recommendation.emotion)
        score += timeScore * 0.2
        
        // Priority adjustment based on current stress level
        when (context.mood) {
            MoodType.STRESSED, MoodType.ANXIOUS -> {
                if (recommendation.emotion == TaskEmotion.CALMING) score += 0.4
                if (recommendation.priority == TaskPriority.LOW) score += 0.2
                if (recommendation.emotion == TaskEmotion.STRESSFUL) score -= 0.5
            }
            MoodType.ENERGIZED -> {
                if (recommendation.emotion == TaskEmotion.ENERGIZING) score += 0.3
                if (recommendation.priority == TaskPriority.HIGH) score += 0.2
            }
            MoodType.FOCUSED -> {
                if (recommendation.emotion == TaskEmotion.FOCUSED) score += 0.3
                if (recommendation.priority == TaskPriority.HIGH) score += 0.1
            }
            else -> {
                // Default scoring for other moods
            }
        }
        
        return score
    }
    
    private fun getMoodSpecificRecommendations(mood: MoodType, timeOfDay: Int): List<AITaskRecommendation> {
        return when (mood) {
            MoodType.ENERGIZED -> listOf(
                AITaskRecommendation(
                    "Tackle important project",
                    "Use your high energy for complex work",
                    TaskEmotion.ENERGIZING,
                    TaskPriority.HIGH,
                    TaskCategory.WORK,
                    0.9,
                    "High energy mood perfect for challenging tasks"
                ),
                AITaskRecommendation(
                    "Exercise or workout",
                    "Channel your energy into physical activity",
                    TaskEmotion.ENERGIZING,
                    TaskPriority.MEDIUM,
                    TaskCategory.HEALTH,
                    0.8,
                    "Energy levels ideal for physical activity"
                )
            )
            
            MoodType.FOCUSED -> listOf(
                AITaskRecommendation(
                    "Deep work session",
                    "Perfect time for concentrated tasks",
                    TaskEmotion.FOCUSED,
                    TaskPriority.HIGH,
                    TaskCategory.WORK,
                    0.9,
                    "Focused state optimal for complex thinking"
                ),
                AITaskRecommendation(
                    "Plan your week",
                    "Organize and strategize your upcoming tasks",
                    TaskEmotion.FOCUSED,
                    TaskPriority.MEDIUM,
                    TaskCategory.PERSONAL,
                    0.7,
                    "Clear mind great for planning"
                )
            )
            
            MoodType.CALM -> listOf(
                AITaskRecommendation(
                    "Review and organize",
                    "A calm mind is perfect for organizing",
                    TaskEmotion.CALMING,
                    TaskPriority.MEDIUM,
                    TaskCategory.PERSONAL,
                    0.8,
                    "Peaceful state ideal for organization"
                ),
                AITaskRecommendation(
                    "Call a friend or family",
                    "Gentle social connection",
                    TaskEmotion.CALMING,
                    TaskPriority.LOW,
                    TaskCategory.PERSONAL,
                    0.7,
                    "Calm mood perfect for meaningful conversations"
                )
            )
            
            MoodType.CREATIVE -> listOf(
                AITaskRecommendation(
                    "Creative brainstorming",
                    "Capture your creative ideas",
                    TaskEmotion.CREATIVE,
                    TaskPriority.MEDIUM,
                    TaskCategory.CREATIVE,
                    0.9,
                    "Creative flow state optimal for ideation"
                ),
                AITaskRecommendation(
                    "Work on a personal project",
                    "Channel creativity into meaningful work",
                    TaskEmotion.CREATIVE,
                    TaskPriority.MEDIUM,
                    TaskCategory.PERSONAL,
                    0.8,
                    "Creative energy perfect for personal projects"
                )
            )
            
            MoodType.STRESSED -> listOf(
                AITaskRecommendation(
                    "Take a mindful walk",
                    "Gentle movement to reduce stress",
                    TaskEmotion.CALMING,
                    TaskPriority.HIGH,
                    TaskCategory.HEALTH,
                    0.9,
                    "Movement helps reduce stress hormones"
                ),
                AITaskRecommendation(
                    "5-minute breathing exercise",
                    "Quick stress relief technique",
                    TaskEmotion.CALMING,
                    TaskPriority.HIGH,
                    TaskCategory.HEALTH,
                    0.8,
                    "Breathing exercises proven to reduce stress"
                )
            )
            
            MoodType.TIRED -> listOf(
                AITaskRecommendation(
                    "Simple organizing task",
                    "Low-energy task that still feels productive",
                    TaskEmotion.ROUTINE,
                    TaskPriority.LOW,
                    TaskCategory.PERSONAL,
                    0.8,
                    "Low energy perfect for simple tasks"
                ),
                AITaskRecommendation(
                    "Rest and recharge",
                    "Take a short break or power nap",
                    TaskEmotion.CALMING,
                    TaskPriority.HIGH,
                    TaskCategory.HEALTH,
                    0.9,
                    "Rest is productive when tired"
                )
            )
            
            MoodType.ANXIOUS -> listOf(
                AITaskRecommendation(
                    "Grounding exercise",
                    "5-4-3-2-1 sensory grounding technique",
                    TaskEmotion.CALMING,
                    TaskPriority.HIGH,
                    TaskCategory.HEALTH,
                    0.9,
                    "Grounding helps manage anxiety"
                ),
                AITaskRecommendation(
                    "Gentle routine task",
                    "Familiar, comfortable activity",
                    TaskEmotion.ROUTINE,
                    TaskPriority.MEDIUM,
                    TaskCategory.PERSONAL,
                    0.7,
                    "Routine provides comfort during anxiety"
                )
            )
        }
    }
    
    private fun getTimeSpecificRecommendations(timeOfDay: Int, mood: MoodType): List<AITaskRecommendation> {
        return when (timeOfDay) {
            in 6..11 -> { // Morning
                listOf(
                    AITaskRecommendation(
                        "Morning review",
                        "Set intentions for the day",
                        TaskEmotion.FOCUSED,
                        TaskPriority.MEDIUM,
                        TaskCategory.PERSONAL,
                        0.7,
                        "Morning is ideal for planning"
                    )
                )
            }
            in 12..17 -> { // Afternoon
                listOf(
                    AITaskRecommendation(
                        "Afternoon productivity boost",
                        "Handle important tasks during peak hours",
                        TaskEmotion.ENERGIZING,
                        TaskPriority.HIGH,
                        TaskCategory.WORK,
                        0.8,
                        "Afternoon energy peak"
                    )
                )
            }
            else -> { // Evening
                listOf(
                    AITaskRecommendation(
                        "Evening wind-down",
                        "Prepare for restful evening",
                        TaskEmotion.CALMING,
                        TaskPriority.LOW,
                        TaskCategory.PERSONAL,
                        0.7,
                        "Evening ideal for calming activities"
                    )
                )
            }
        }
    }
    
    private fun getWellnessRecommendations(mood: MoodType): List<AITaskRecommendation> {
        return listOf(
            AITaskRecommendation(
                "Wellness check-in",
                "Take a moment for self-care",
                TaskEmotion.CALMING,
                TaskPriority.HIGH,
                TaskCategory.HEALTH,
                0.9,
                "Self-care is essential during difficult moods"
            )
        )
    }
    
    // Helper methods for NLP processing
    
    private fun cleanTitleFromNLPPatterns(input: String): String {
        var cleanTitle = input
        
        // Remove time patterns
        val timePatterns = listOf(
            "\\bat\\s+\\d{1,2}(:\\d{2})?\\s*(am|pm)\\b",
            "\\btonight\\b", "\\btomorrow\\b", "\\btoday\\b"
        )
        
        timePatterns.forEach { pattern ->
            cleanTitle = cleanTitle.replace(Regex(pattern, RegexOption.IGNORE_CASE), " ")
        }
        
        return cleanTitle.replace(Regex("\\s+"), " ").trim()
    }
    
    private fun determinePriority(input: String): TaskPriority {
        val lowercased = input.lowercase()
        
        val highPriorityKeywords = listOf("urgent", "asap", "important", "critical", "today", "deadline")
        val lowPriorityKeywords = listOf("later", "sometime", "eventually", "maybe", "when possible")
        
        return when {
            highPriorityKeywords.any { lowercased.contains(it) } -> TaskPriority.HIGH
            lowPriorityKeywords.any { lowercased.contains(it) } -> TaskPriority.LOW
            else -> TaskPriority.MEDIUM
        }
    }
    
    private fun determineEmotion(input: String): TaskEmotion {
        val lowercased = input.lowercase()
        
        return when {
            lowercased.contains("creative") || lowercased.contains("design") -> TaskEmotion.CREATIVE
            lowercased.contains("focus") || lowercased.contains("work") -> TaskEmotion.FOCUSED
            lowercased.contains("calm") || lowercased.contains("relax") -> TaskEmotion.CALMING
            lowercased.contains("energy") || lowercased.contains("exercise") -> TaskEmotion.ENERGIZING
            lowercased.contains("urgent") || lowercased.contains("deadline") -> TaskEmotion.STRESSFUL
            lowercased.contains("routine") || lowercased.contains("organize") -> TaskEmotion.ROUTINE
            else -> TaskEmotion.ROUTINE
        }
    }
    
    private fun extractReminderTime(input: String): Instant? {
        // Simplified time extraction - would be more sophisticated in production
        val now = Clock.System.now()
        val lowercased = input.lowercase()
        
        return when {
            lowercased.contains("today") -> now
            lowercased.contains("tomorrow") -> Instant.fromEpochMilliseconds(now.toEpochMilliseconds() + 24 * 60 * 60 * 1000)
            else -> null
        }
    }
    
    private fun extractTags(input: String): List<String> {
        val hashtagPattern = Regex("#(\\w+)")
        return hashtagPattern.findAll(input).map { it.groupValues[1] }.toList()
    }
    
    private fun calculateProductivityScore(completedTasks: List<Task>, currentMood: MoodType): Double {
        if (completedTasks.isEmpty()) return 0.5 // Neutral score for new users
        
        val moodCompatibleTasks = completedTasks.filter { task ->
            currentMood.compatibleTaskEmotions.contains(task.emotion)
        }
        
        return moodCompatibleTasks.size.toDouble() / completedTasks.size
    }
    
    private fun getOptimalTaskCount(mood: MoodType, timeOfDay: Int): Int {
        val baseCount = when (mood) {
            MoodType.ENERGIZED -> 8
            MoodType.FOCUSED -> 6
            MoodType.CALM -> 5
            MoodType.CREATIVE -> 7
            MoodType.STRESSED -> 3
            MoodType.TIRED -> 2
            MoodType.ANXIOUS -> 4
        }
        
        // Adjust for time of day
        val timeMultiplier = when (timeOfDay) {
            in 6..11 -> 1.0  // Morning
            in 12..17 -> 1.1 // Afternoon peak
            in 18..21 -> 0.8 // Evening
            else -> 0.6      // Night
        }
        
        return (baseCount * timeMultiplier).toInt().coerceAtLeast(2)
    }
    
    private fun getTimeCompatibilityScore(timeOfDay: Int, emotion: TaskEmotion): Double {
        return when (emotion) {
            TaskEmotion.ENERGIZING -> if (timeOfDay in 6..17) 1.0 else 0.3
            TaskEmotion.FOCUSED -> if (timeOfDay in 9..16) 1.0 else 0.5
            TaskEmotion.CALMING -> if (timeOfDay in 18..23 || timeOfDay in 0..7) 1.0 else 0.4
            TaskEmotion.CREATIVE -> if (timeOfDay in 10..14 || timeOfDay in 19..22) 1.0 else 0.6
            TaskEmotion.ROUTINE -> 0.8 // Good anytime
            TaskEmotion.STRESSFUL -> if (timeOfDay in 10..15) 0.8 else 0.3
            TaskEmotion.ANXIOUS -> 0.6 // Moderate compatibility
        }
    }
    
    data class UserContext(
        val mood: MoodType,
        val timeOfDay: Int,
        val productivityScore: Double,
        val optimalTaskCount: Int,
        val recentCompletions: List<Task>,
        val existingTaskLoad: Int
    )
    
    data class ProcessedTaskResult(
        val title: String,
        val description: String?,
        val priority: TaskPriority,
        val emotion: TaskEmotion,
        val reminderAt: Instant?,
        val deadlineAt: Instant?,
        val tags: List<String>
    )
}