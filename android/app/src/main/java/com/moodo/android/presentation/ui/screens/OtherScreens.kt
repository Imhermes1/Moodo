package com.moodo.android.presentation.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.moodo.android.presentation.viewmodel.*

/**
 * Placeholder screens for other tabs
 * These would be fully implemented in a complete app
 */

@Composable
fun TasksScreen(viewModel: TasksViewModel) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                text = "Tasks Screen",
                style = MaterialTheme.typography.headlineMedium
            )
            Text("Complete task management interface would go here")
        }
    }
}

@Composable
fun ThoughtsScreen(viewModel: ThoughtsViewModel) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                text = "Thoughts Screen",
                style = MaterialTheme.typography.headlineMedium
            )
            Text("Journaling and thought capture interface would go here")
        }
    }
}

@Composable
fun WellnessScreen(viewModel: WellnessViewModel) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                text = "Wellness Screen",
                style = MaterialTheme.typography.headlineMedium
            )
            Text("Wellness activities and mindfulness features would go here")
        }
    }
}

@Composable
fun InsightsScreen(viewModel: InsightsViewModel) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                text = "Insights Screen",
                style = MaterialTheme.typography.headlineMedium
            )
            Text("AI-powered insights and analytics would go here")
        }
    }
}