package com.moodo.android.ui.screens.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.moodo.android.data.model.MoodType
import com.moodo.android.data.model.Task
import com.moodo.android.data.repository.MooDoRepository
import com.moodo.android.domain.recommendation.AITaskRecommendation
import com.moodo.android.domain.recommendation.RecommendationEngine
import com.moodo.android.domain.recommendation.createUserContext
import com.moodo.android.domain.scheduler.TaskScheduler
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val repository: MooDoRepository,
    private val taskScheduler: TaskScheduler,
    private val recommendationEngine: RecommendationEngine
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    private fun loadData() {
        repository.getAllTasks().onEach { tasks ->
            val mood = repository.getAllMoodEntries().onEach { moods ->
                val latestMood = moods.firstOrNull()?.mood ?: MoodType.CALM
                taskScheduler.currentMood = latestMood
                val optimizedTasks = taskScheduler.optimizeTaskSchedule(tasks)
                val recommendations = recommendationEngine.generateRecommendations(createUserContext(latestMood))
                _uiState.value = HomeUiState(
                    tasks = optimizedTasks,
                    mood = latestMood,
                    recommendations = recommendations,
                    isLoading = false
                )
            }.launchIn(viewModelScope)
        }.launchIn(viewModelScope)
    }

    fun onTaskCompleted(task: Task) {
        viewModelScope.launch {
            repository.updateTask(task.copy(isCompleted = !task.isCompleted))
        }
    }

    fun onMoodSelected(mood: MoodType) {
        viewModelScope.launch {
            repository.insertMoodEntry(com.moodo.android.data.model.MoodEntry(mood = mood))
        }
    }
}

data class HomeUiState(
    val tasks: List<Task> = emptyList(),
    val mood: MoodType = MoodType.CALM,
    val recommendations: List<AITaskRecommendation> = emptyList(),
    val isLoading: Boolean = true
)
