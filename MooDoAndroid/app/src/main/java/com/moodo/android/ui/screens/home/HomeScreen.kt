package com.moodo.android.ui.screens.home

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.moodo.android.data.model.MoodType
import com.moodo.android.data.model.Task
import com.moodo.android.domain.recommendation.AITaskRecommendation
import com.moodo.android.ui.components.MoodPicker
import com.moodo.android.ui.components.TaskCard

@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    if (uiState.isLoading) {
        CircularProgressIndicator()
    } else {
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                Header(name = "User") // Placeholder name
            }
            item {
                MoodSection(
                    mood = uiState.mood.name,
                    onMoodSelected = { mood -> viewModel.onMoodSelected(mood) }
                )
            }
            item {
                TasksSection(
                    tasks = uiState.tasks,
                    onTaskCompleted = { task -> viewModel.onTaskCompleted(task) }
                )
            }
            item {
                RecommendationsSection(recommendations = uiState.recommendations)
            }
        }
    }
}

@Composable
fun Header(name: String) {
    Text(
        text = "Hello, $name!",
        style = MaterialTheme.typography.headlineMedium
    )
}

@Composable
fun MoodSection(
    mood: String,
    onMoodSelected: (MoodType) -> Unit
) {
    Column {
        Text(
            text = "Your current mood: $mood",
            style = MaterialTheme.typography.titleMedium
        )
        MoodPicker(onMoodSelected = onMoodSelected)
    }
}

@Composable
fun TasksSection(
    tasks: List<Task>,
    onTaskCompleted: (Task) -> Unit
) {
    Column {
        Text(
            text = "Today's Tasks",
            style = MaterialTheme.typography.titleMedium
        )
        tasks.forEach { task ->
            TaskCard(task = task, onTaskCompleted = onTaskCompleted)
        }
    }
}

@Composable
fun RecommendationsSection(recommendations: List<AITaskRecommendation>) {
    Column {
        Text(
            text = "Smart Suggestions",
            style = MaterialTheme.typography.titleMedium
        )
        recommendations.forEach { recommendation ->
            RecommendationItem(recommendation = recommendation)
        }
    }
}

@Composable
fun RecommendationItem(recommendation: AITaskRecommendation) {
    Column(modifier = Modifier.padding(vertical = 4.dp)) {
        Text(text = recommendation.title, style = MaterialTheme.typography.bodyLarge)
        Text(text = recommendation.description, style = MaterialTheme.typography.bodySmall)
    }
}
