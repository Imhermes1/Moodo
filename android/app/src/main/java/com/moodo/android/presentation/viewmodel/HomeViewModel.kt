package com.moodo.android.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.moodo.android.domain.model.*
import com.moodo.android.data.remote.firebase.FirebaseManager
import com.moodo.android.ml.AndroidMLTaskEngine
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock
import javax.inject.Inject

/**
 * Home screen ViewModel
 * Equivalent to iOS HomeView logic
 */
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val firebaseManager: FirebaseManager,
    private val mlEngine: AndroidMLTaskEngine
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()
    
    private val _tasks = MutableStateFlow<List<Task>>(emptyList())
    val tasks: StateFlow<List<Task>> = _tasks.asStateFlow()
    
    private val _currentMood = MutableStateFlow(MoodType.CALM)
    val currentMood: StateFlow<MoodType> = _currentMood.asStateFlow()
    
    private val _aiRecommendations = MutableStateFlow<List<AndroidMLTaskEngine.AITaskRecommendation>>(emptyList())
    val aiRecommendations: StateFlow<List<AndroidMLTaskEngine.AITaskRecommendation>> = _aiRecommendations.asStateFlow()
    
    init {
        loadTasks()
        loadCurrentMood()
        generateAIRecommendations()
    }
    
    fun updateMood(mood: MoodType) {
        _currentMood.value = mood
        
        // Save mood entry
        viewModelScope.launch {
            val moodEntry = MoodEntry(mood = mood)
            firebaseManager.saveMoodEntries(listOf(moodEntry))
        }
        
        // Regenerate AI recommendations based on new mood
        generateAIRecommendations()
    }
    
    fun addTask(task: Task) {
        viewModelScope.launch {
            val currentTasks = _tasks.value.toMutableList()
            currentTasks.add(task)
            _tasks.value = currentTasks
            
            firebaseManager.saveTasks(listOf(task))
        }
    }
    
    fun toggleTaskCompletion(task: Task) {
        viewModelScope.launch {
            val updatedTask = task.copy(
                isCompleted = !task.isCompleted,
                completedAt = if (!task.isCompleted) Clock.System.now() else null,
                completedMood = if (!task.isCompleted) _currentMood.value else null
            )
            
            val currentTasks = _tasks.value.toMutableList()
            val index = currentTasks.indexOfFirst { it.id == task.id }
            if (index != -1) {
                currentTasks[index] = updatedTask
                _tasks.value = currentTasks
                
                firebaseManager.saveTasks(listOf(updatedTask))
            }
        }
    }
    
    fun processNaturalLanguageTask(input: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isProcessingTask = true)
            
            try {
                val processedResult = mlEngine.processNaturalLanguageInput(input)
                
                val newTask = Task(
                    title = processedResult.title,
                    description = processedResult.description,
                    priority = processedResult.priority,
                    emotion = processedResult.emotion,
                    reminderAt = processedResult.reminderAt,
                    deadlineAt = processedResult.deadlineAt,
                    tags = processedResult.tags,
                    naturalLanguageInput = input
                )
                
                addTask(newTask)
                
                _uiState.value = _uiState.value.copy(
                    isProcessingTask = false,
                    lastProcessedTask = newTask
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isProcessingTask = false,
                    error = e.message
                )
            }
        }
    }
    
    private fun loadTasks() {
        viewModelScope.launch {
            firebaseManager.fetchTasks()
                .onSuccess { tasks ->
                    _tasks.value = tasks
                }
                .onFailure { error ->
                    _uiState.value = _uiState.value.copy(error = error.message)
                }
        }
    }
    
    private fun loadCurrentMood() {
        viewModelScope.launch {
            firebaseManager.fetchMoodEntries()
                .onSuccess { entries ->
                    if (entries.isNotEmpty()) {
                        _currentMood.value = entries.first().mood
                    }
                }
        }
    }
    
    private fun generateAIRecommendations() {
        viewModelScope.launch {
            try {
                val recommendations = mlEngine.generateRecommendations(
                    currentMood = _currentMood.value,
                    existingTasks = _tasks.value.filter { !it.isCompleted },
                    completedTasks = _tasks.value.filter { it.isCompleted }
                )
                _aiRecommendations.value = recommendations
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(error = e.message)
            }
        }
    }
    
    val todayTasks: StateFlow<List<Task>> = _tasks.map { tasks ->
        val now = Clock.System.now()
        val todayStart = now.toEpochMilliseconds() - (now.toEpochMilliseconds() % (24 * 60 * 60 * 1000))
        val todayEnd = todayStart + (24 * 60 * 60 * 1000)
        
        tasks.filter { task ->
            !task.isCompleted && (
                task.reminderAt?.toEpochMilliseconds() in todayStart..todayEnd ||
                task.deadlineAt?.toEpochMilliseconds() in todayStart..todayEnd ||
                (task.reminderAt == null && task.deadlineAt == null)
            )
        }.sortedBy { it.dynamicPriority.numericValue }.reversed()
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList()
    )
    
    fun clearError() {
        _uiState.value = _uiState.value.copy(error = null)
    }
}

data class HomeUiState(
    val isLoading: Boolean = false,
    val isProcessingTask: Boolean = false,
    val error: String? = null,
    val lastProcessedTask: Task? = null
)