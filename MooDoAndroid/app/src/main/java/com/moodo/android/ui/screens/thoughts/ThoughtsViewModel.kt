package com.moodo.android.ui.screens.thoughts

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.moodo.android.data.model.Thought
import com.moodo.android.data.repository.MooDoRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class ThoughtsViewModel @Inject constructor(
    private val repository: MooDoRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ThoughtsUiState())
    val uiState: StateFlow<ThoughtsUiState> = _uiState.asStateFlow()

    init {
        repository.getAllThoughts().onEach { thoughts ->
            _uiState.value = ThoughtsUiState(thoughts = thoughts, isLoading = false)
        }.launchIn(viewModelScope)
    }

    private val _showAddThoughtDialog = MutableStateFlow(false)
    val showAddThoughtDialog: StateFlow<Boolean> = _showAddThoughtDialog.asStateFlow()

    fun onAddThoughtClicked() {
        _showAddThoughtDialog.value = true
    }

    fun onDismissAddThoughtDialog() {
        _showAddThoughtDialog.value = false
    }

    fun onAddThoughtConfirmed(title: String, content: String) {
        viewModelScope.launch {
            repository.insertThought(Thought(title = title, content = content))
        }
        _showAddThoughtDialog.value = false
    }
}

data class ThoughtsUiState(
    val thoughts: List<Thought> = emptyList(),
    val isLoading: Boolean = true
)
