package com.moodo.android.ui.screens.wellness

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class WellnessViewModel @Inject constructor() : ViewModel() {

    private val _uiState = MutableStateFlow(WellnessUiState())
    val uiState: StateFlow<WellnessUiState> = _uiState.asStateFlow()

    init {
        loadWellnessActions()
    }

    private fun loadWellnessActions() {
        val actions = listOf(
            "Take a 5-minute breathing break.",
            "Go for a short walk outside.",
            "Write down three things you are grateful for.",
            "Listen to a calming song.",
            "Stretch your body for 10 minutes."
        )
        _uiState.value = WellnessUiState(wellnessActions = actions)
    }
}

data class WellnessUiState(
    val wellnessActions: List<String> = emptyList()
)
