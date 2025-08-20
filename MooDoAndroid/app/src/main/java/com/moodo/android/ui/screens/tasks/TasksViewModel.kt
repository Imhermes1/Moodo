package com.moodo.android.ui.screens.tasks

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.moodo.android.data.model.Task
import com.moodo.android.data.repository.MooDoRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import javax.inject.Inject

@HiltViewModel
class TasksViewModel @Inject constructor(
    private val repository: MooDoRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(TasksUiState())
    val uiState: StateFlow<TasksUiState> = _uiState.asStateFlow()

    init {
        repository.getAllTasks().onEach { tasks ->
            _uiState.value = TasksUiState(tasks = tasks, isLoading = false)
        }.launchIn(viewModelScope)
    }

    private val _showAddTaskDialog = MutableStateFlow(false)
    val showAddTaskDialog: StateFlow<Boolean> = _showAddTaskDialog.asStateFlow()

    fun onTaskCompleted(task: Task) {
        viewModelScope.launch {
            repository.updateTask(task.copy(isCompleted = !task.isCompleted))
        }
    }

    fun onAddTaskClicked() {
        _showAddTaskDialog.value = true
    }

    fun onDismissAddTaskDialog() {
        _showAddTaskDialog.value = false
    }

    fun onAddTaskConfirmed(title: String) {
        viewModelScope.launch {
            repository.insertTask(Task(title = title))
        }
        _showAddTaskDialog.value = false
    }
}

data class TasksUiState(
    val tasks: List<Task> = emptyList(),
    val isLoading: Boolean = true
)
