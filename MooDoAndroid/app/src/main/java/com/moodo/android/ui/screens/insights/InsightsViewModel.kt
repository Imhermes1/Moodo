package com.moodo.android.ui.screens.insights

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class InsightsViewModel @Inject constructor() : ViewModel() {

    private val _uiState = MutableStateFlow(InsightsUiState())
    val uiState: StateFlow<InsightsUiState> = _uiState.asStateFlow()

    init {
        loadInsights()
    }

    private fun loadInsights() {
        val insights = listOf(
            "You are most productive on Mondays.",
            "You tend to feel more energized after completing creative tasks.",
            "Your mood is generally calmer in the evenings."
        )
        _uiState.value = InsightsUiState(insights = insights)
    }
}

data class InsightsUiState(
    val insights: List<String> = emptyList()
)
