package com.moodo.android.data.repository

import com.moodo.android.data.db.dao.MoodDao
import com.moodo.android.data.db.dao.TaskDao
import com.moodo.android.data.db.dao.ThoughtDao
import com.moodo.android.data.model.MoodEntry
import com.moodo.android.data.model.Task
import com.moodo.android.data.model.Thought
import kotlinx.coroutines.flow.Flow
import java.util.UUID
import javax.inject.Inject

interface MooDoRepository {
    // Task operations
    fun getAllTasks(): Flow<List<Task>>
    suspend fun getTaskById(taskId: UUID): Task?
    suspend fun insertTask(task: Task)
    suspend fun updateTask(task: Task)
    suspend fun deleteTask(task: Task)

    // Thought operations
    fun getAllThoughts(): Flow<List<Thought>>
    suspend fun insertThought(thought: Thought)
    suspend fun updateThought(thought: Thought)
    suspend fun deleteThought(thought: Thought)

    // Mood operations
    fun getAllMoodEntries(): Flow<List<MoodEntry>>
    suspend fun insertMoodEntry(moodEntry: MoodEntry)
}

class MooDoRepositoryImpl @Inject constructor(
    private val taskDao: TaskDao,
    private val thoughtDao: ThoughtDao,
    private val moodDao: MoodDao
) : MooDoRepository {

    override fun getAllTasks(): Flow<List<Task>> = taskDao.getAllTasks()

    override suspend fun getTaskById(taskId: UUID): Task? = taskDao.getTaskById(taskId)

    override suspend fun insertTask(task: Task) = taskDao.insertTask(task)

    override suspend fun updateTask(task: Task) = taskDao.updateTask(task)

    override suspend fun deleteTask(task: Task) = taskDao.deleteTask(task)

    override fun getAllThoughts(): Flow<List<Thought>> = thoughtDao.getAllThoughts()

    override suspend fun insertThought(thought: Thought) = thoughtDao.insertThought(thought)

    override suspend fun updateThought(thought: Thought) = thoughtDao.updateThought(thought)

    override suspend fun deleteThought(thought: Thought) = thoughtDao.deleteThought(thought)

    override fun getAllMoodEntries(): Flow<List<MoodEntry>> = moodDao.getAllMoodEntries()

    override suspend fun insertMoodEntry(moodEntry: MoodEntry) = moodDao.insertMoodEntry(moodEntry)
}
