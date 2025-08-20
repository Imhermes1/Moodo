package com.moodo.android.data.remote.firebase

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import com.moodo.android.domain.model.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.tasks.await
import kotlinx.datetime.Instant
import kotlinx.datetime.toJavaInstant
import java.util.Date
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Firebase integration for cloud sync
 * Equivalent to CloudKitManager.swift in iOS version
 */
@Singleton
class FirebaseManager @Inject constructor(
    private val firestore: FirebaseFirestore,
    private val auth: FirebaseAuth
) {
    
    private val currentUserId: String?
        get() = auth.currentUser?.uid
    
    companion object {
        private const val TASKS_COLLECTION = "tasks"
        private const val MOOD_ENTRIES_COLLECTION = "mood_entries" 
        private const val THOUGHTS_COLLECTION = "thoughts"
        private const val VOICE_CHECKINS_COLLECTION = "voice_checkins"
        private const val USERS_COLLECTION = "users"
    }
    
    // MARK: - Authentication
    
    suspend fun signInAnonymously(): Result<String> {
        return try {
            val result = auth.signInAnonymously().await()
            val userId = result.user?.uid ?: throw Exception("Failed to get user ID")
            Result.success(userId)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    fun isSignedIn(): Boolean = auth.currentUser != null
    
    // MARK: - Task Operations
    
    suspend fun saveTasks(tasks: List<Task>): Result<Unit> {
        val userId = currentUserId ?: return Result.failure(Exception("User not signed in"))
        
        return try {
            val batch = firestore.batch()
            
            tasks.forEach { task ->
                val taskDoc = firestore.collection(USERS_COLLECTION)
                    .document(userId)
                    .collection(TASKS_COLLECTION)
                    .document(task.id)
                
                val taskData = mapOf(
                    "id" to task.id,
                    "title" to task.title,
                    "description" to task.description,
                    "isCompleted" to task.isCompleted,
                    "isFlagged" to task.isFlagged,
                    "isRecurring" to task.isRecurring,
                    "priority" to task.priority.name,
                    "emotion" to task.emotion.name,
                    "category" to task.category.name,
                    "estimatedTime" to task.estimatedTime,
                    "completedAt" to task.completedAt?.toFirebaseTimestamp(),
                    "completedMood" to task.completedMood?.name,
                    "reminderAt" to task.reminderAt?.toFirebaseTimestamp(),
                    "deadlineAt" to task.deadlineAt?.toFirebaseTimestamp(),
                    "naturalLanguageInput" to task.naturalLanguageInput,
                    "createdAt" to task.createdAt.toFirebaseTimestamp(),
                    "tags" to task.tags,
                    "eventKitIdentifier" to task.eventKitIdentifier,
                    "isAIGenerated" to task.isAIGenerated,
                    "sourceThoughtId" to task.sourceThoughtId,
                    "lastModified" to Date()
                )
                
                batch.set(taskDoc, taskData)
            }
            
            batch.commit().await()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun fetchTasks(): Result<List<Task>> {
        val userId = currentUserId ?: return Result.failure(Exception("User not signed in"))
        
        return try {
            val snapshot = firestore.collection(USERS_COLLECTION)
                .document(userId)
                .collection(TASKS_COLLECTION)
                .orderBy("createdAt", Query.Direction.DESCENDING)
                .get()
                .await()
            
            val tasks = snapshot.documents.mapNotNull { doc ->
                try {
                    Task(
                        id = doc.getString("id") ?: return@mapNotNull null,
                        title = doc.getString("title") ?: return@mapNotNull null,
                        description = doc.getString("description"),
                        isCompleted = doc.getBoolean("isCompleted") ?: false,
                        isFlagged = doc.getBoolean("isFlagged") ?: false,
                        isRecurring = doc.getBoolean("isRecurring") ?: false,
                        priority = TaskPriority.valueOf(doc.getString("priority") ?: "MEDIUM"),
                        emotion = TaskEmotion.valueOf(doc.getString("emotion") ?: "FOCUSED"),
                        category = TaskCategory.valueOf(doc.getString("category") ?: "PERSONAL"),
                        estimatedTime = doc.getLong("estimatedTime")?.toInt(),
                        completedAt = doc.getTimestamp("completedAt")?.toInstant(),
                        completedMood = doc.getString("completedMood")?.let { MoodType.valueOf(it) },
                        reminderAt = doc.getTimestamp("reminderAt")?.toInstant(),
                        deadlineAt = doc.getTimestamp("deadlineAt")?.toInstant(),
                        naturalLanguageInput = doc.getString("naturalLanguageInput"),
                        createdAt = doc.getTimestamp("createdAt")?.toInstant() ?: kotlinx.datetime.Clock.System.now(),
                        tags = (doc.get("tags") as? List<*>)?.filterIsInstance<String>() ?: emptyList(),
                        eventKitIdentifier = doc.getString("eventKitIdentifier"),
                        isAIGenerated = doc.getBoolean("isAIGenerated") ?: false,
                        sourceThoughtId = doc.getString("sourceThoughtId")
                    )
                } catch (e: Exception) {
                    null
                }
            }
            
            Result.success(tasks)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun deleteTask(taskId: String): Result<Unit> {
        val userId = currentUserId ?: return Result.failure(Exception("User not signed in"))
        
        return try {
            firestore.collection(USERS_COLLECTION)
                .document(userId)
                .collection(TASKS_COLLECTION)
                .document(taskId)
                .delete()
                .await()
            
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    // MARK: - Mood Operations
    
    suspend fun saveMoodEntries(entries: List<MoodEntry>): Result<Unit> {
        val userId = currentUserId ?: return Result.failure(Exception("User not signed in"))
        
        return try {
            val batch = firestore.batch()
            
            entries.forEach { entry ->
                val entryDoc = firestore.collection(USERS_COLLECTION)
                    .document(userId)
                    .collection(MOOD_ENTRIES_COLLECTION)
                    .document(entry.id)
                
                val entryData = mapOf(
                    "id" to entry.id,
                    "mood" to entry.mood.name,
                    "timestamp" to entry.timestamp.toFirebaseTimestamp(),
                    "lastModified" to Date()
                )
                
                batch.set(entryDoc, entryData)
            }
            
            batch.commit().await()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun fetchMoodEntries(): Result<List<MoodEntry>> {
        val userId = currentUserId ?: return Result.failure(Exception("User not signed in"))
        
        return try {
            val snapshot = firestore.collection(USERS_COLLECTION)
                .document(userId)
                .collection(MOOD_ENTRIES_COLLECTION)
                .orderBy("timestamp", Query.Direction.DESCENDING)
                .get()
                .await()
            
            val entries = snapshot.documents.mapNotNull { doc ->
                try {
                    MoodEntry(
                        id = doc.getString("id") ?: return@mapNotNull null,
                        mood = MoodType.valueOf(doc.getString("mood") ?: return@mapNotNull null),
                        timestamp = doc.getTimestamp("timestamp")?.toInstant() ?: kotlinx.datetime.Clock.System.now()
                    )
                } catch (e: Exception) {
                    null
                }
            }
            
            Result.success(entries)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    // MARK: - Thoughts Operations
    
    suspend fun saveThoughts(thoughts: List<Thought>): Result<Unit> {
        val userId = currentUserId ?: return Result.failure(Exception("User not signed in"))
        
        return try {
            val batch = firestore.batch()
            
            thoughts.forEach { thought ->
                val thoughtDoc = firestore.collection(USERS_COLLECTION)
                    .document(userId)
                    .collection(THOUGHTS_COLLECTION)
                    .document(thought.id)
                
                val thoughtData = mapOf(
                    "id" to thought.id,
                    "title" to thought.title,
                    "content" to thought.content,
                    "dateCreated" to thought.dateCreated.toFirebaseTimestamp(),
                    "mood" to thought.mood.name,
                    "linkedTaskId" to thought.linkedTaskId,
                    "lastModified" to Date()
                )
                
                batch.set(thoughtDoc, thoughtData)
            }
            
            batch.commit().await()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun fetchThoughts(): Result<List<Thought>> {
        val userId = currentUserId ?: return Result.failure(Exception("User not signed in"))
        
        return try {
            val snapshot = firestore.collection(USERS_COLLECTION)
                .document(userId)
                .collection(THOUGHTS_COLLECTION)
                .orderBy("dateCreated", Query.Direction.DESCENDING)
                .get()
                .await()
            
            val thoughts = snapshot.documents.mapNotNull { doc ->
                try {
                    Thought(
                        id = doc.getString("id") ?: return@mapNotNull null,
                        title = doc.getString("title") ?: return@mapNotNull null,
                        content = doc.getString("content") ?: return@mapNotNull null,
                        dateCreated = doc.getTimestamp("dateCreated")?.toInstant() ?: kotlinx.datetime.Clock.System.now(),
                        mood = MoodType.valueOf(doc.getString("mood") ?: "CALM"),
                        linkedTaskId = doc.getString("linkedTaskId")
                    )
                } catch (e: Exception) {
                    null
                }
            }
            
            Result.success(thoughts)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    // MARK: - Voice Check-ins Operations
    
    suspend fun saveVoiceCheckins(checkins: List<VoiceCheckin>): Result<Unit> {
        val userId = currentUserId ?: return Result.failure(Exception("User not signed in"))
        
        return try {
            val batch = firestore.batch()
            
            checkins.forEach { checkin ->
                val checkinDoc = firestore.collection(USERS_COLLECTION)
                    .document(userId)
                    .collection(VOICE_CHECKINS_COLLECTION)
                    .document(checkin.id)
                
                val checkinData = mapOf(
                    "id" to checkin.id,
                    "transcript" to checkin.transcript,
                    "mood" to checkin.mood?.name,
                    "tasks" to checkin.tasks,
                    "timestamp" to checkin.timestamp.toFirebaseTimestamp(),
                    "duration" to checkin.duration,
                    "lastModified" to Date()
                )
                
                batch.set(checkinDoc, checkinData)
            }
            
            batch.commit().await()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun fetchVoiceCheckins(): Result<List<VoiceCheckin>> {
        val userId = currentUserId ?: return Result.failure(Exception("User not signed in"))
        
        return try {
            val snapshot = firestore.collection(USERS_COLLECTION)
                .document(userId)
                .collection(VOICE_CHECKINS_COLLECTION)
                .orderBy("timestamp", Query.Direction.DESCENDING)
                .get()
                .await()
            
            val checkins = snapshot.documents.mapNotNull { doc ->
                try {
                    VoiceCheckin(
                        id = doc.getString("id") ?: return@mapNotNull null,
                        transcript = doc.getString("transcript") ?: return@mapNotNull null,
                        mood = doc.getString("mood")?.let { MoodType.valueOf(it) },
                        tasks = (doc.get("tasks") as? List<*>)?.filterIsInstance<String>() ?: emptyList(),
                        timestamp = doc.getTimestamp("timestamp")?.toInstant() ?: kotlinx.datetime.Clock.System.now(),
                        duration = doc.getLong("duration") ?: 0
                    )
                } catch (e: Exception) {
                    null
                }
            }
            
            Result.success(checkins)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    // MARK: - Real-time Updates
    
    fun getTasksFlow(): Flow<List<Task>> = flow {
        val userId = currentUserId ?: return@flow
        
        firestore.collection(USERS_COLLECTION)
            .document(userId)
            .collection(TASKS_COLLECTION)
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .addSnapshotListener { snapshot, error ->
                if (error != null) return@addSnapshotListener
                
                val tasks = snapshot?.documents?.mapNotNull { doc ->
                    try {
                        Task(
                            id = doc.getString("id") ?: return@mapNotNull null,
                            title = doc.getString("title") ?: return@mapNotNull null,
                            description = doc.getString("description"),
                            isCompleted = doc.getBoolean("isCompleted") ?: false,
                            isFlagged = doc.getBoolean("isFlagged") ?: false,
                            isRecurring = doc.getBoolean("isRecurring") ?: false,
                            priority = TaskPriority.valueOf(doc.getString("priority") ?: "MEDIUM"),
                            emotion = TaskEmotion.valueOf(doc.getString("emotion") ?: "FOCUSED"),
                            category = TaskCategory.valueOf(doc.getString("category") ?: "PERSONAL"),
                            estimatedTime = doc.getLong("estimatedTime")?.toInt(),
                            completedAt = doc.getTimestamp("completedAt")?.toInstant(),
                            completedMood = doc.getString("completedMood")?.let { MoodType.valueOf(it) },
                            reminderAt = doc.getTimestamp("reminderAt")?.toInstant(),
                            deadlineAt = doc.getTimestamp("deadlineAt")?.toInstant(),
                            naturalLanguageInput = doc.getString("naturalLanguageInput"),
                            createdAt = doc.getTimestamp("createdAt")?.toInstant() ?: kotlinx.datetime.Clock.System.now(),
                            tags = (doc.get("tags") as? List<*>)?.filterIsInstance<String>() ?: emptyList(),
                            eventKitIdentifier = doc.getString("eventKitIdentifier"),
                            isAIGenerated = doc.getBoolean("isAIGenerated") ?: false,
                            sourceThoughtId = doc.getString("sourceThoughtId")
                        )
                    } catch (e: Exception) {
                        null
                    }
                } ?: emptyList()
                
                // emit(tasks) // Flow emission would happen here in real implementation
            }
    }
    
    // MARK: - Helper Extensions
    
    private fun Instant.toFirebaseTimestamp(): Date {
        return Date.from(this.toJavaInstant())
    }
    
    private fun com.google.firebase.Timestamp.toInstant(): Instant {
        return Instant.fromEpochMilliseconds(this.toDate().time)
    }
}