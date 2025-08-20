package com.moodo.android.ui.screens.tasks

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.moodo.android.ui.components.AddTaskDialog
import com.moodo.android.ui.components.TaskCard

@Composable
fun TasksScreen(
    viewModel: TasksViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val showDialog by viewModel.showAddTaskDialog.collectAsState()

    if (showDialog) {
        AddTaskDialog(
            onDismissRequest = { viewModel.onDismissAddTaskDialog() },
            onConfirm = { title -> viewModel.onAddTaskConfirmed(title) }
        )
    }

    Scaffold(
        floatingActionButton = {
            FloatingActionButton(onClick = { viewModel.onAddTaskClicked() }) {
                Icon(Icons.Filled.Add, contentDescription = "Add Task")
            }
        }
    ) { paddingValues ->
        if (uiState.isLoading) {
            CircularProgressIndicator()
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = paddingValues,
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(uiState.tasks) { task ->
                    TaskCard(
                        task = task,
                        onTaskCompleted = { viewModel.onTaskCompleted(task) }
                    )
                }
            }
        }
    }
}
