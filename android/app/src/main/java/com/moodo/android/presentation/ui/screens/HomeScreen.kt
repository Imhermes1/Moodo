package com.moodo.android.presentation.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.moodo.android.domain.model.*
import com.moodo.android.ml.AndroidMLTaskEngine
import com.moodo.android.presentation.viewmodel.HomeViewModel

/**
 * Home Screen for MooDo Android
 * Equivalent to HomeView.swift in iOS version
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    viewModel: HomeViewModel
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val currentMood by viewModel.currentMood.collectAsStateWithLifecycle()
    val todayTasks by viewModel.todayTasks.collectAsStateWithLifecycle()
    val aiRecommendations by viewModel.aiRecommendations.collectAsStateWithLifecycle()
    
    var showMoodPicker by remember { mutableStateOf(false) }
    var showQuickAdd by remember { mutableStateOf(false) }
    
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Welcome section
        item {
            WelcomeSection(
                currentMood = currentMood,
                onMoodClick = { showMoodPicker = true }
            )
        }
        
        // Quick add section
        item {
            QuickAddSection(
                isProcessing = uiState.isProcessingTask,
                onQuickAddClick = { showQuickAdd = true }
            )
        }
        
        // Today's tasks
        item {
            Text(
                text = "Today's Tasks",
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold
            )
        }
        
        if (todayTasks.isEmpty()) {
            item {
                EmptyTasksCard()
            }
        } else {
            items(todayTasks.take(5)) { task ->
                TaskCard(
                    task = task,
                    onToggleComplete = { viewModel.toggleTaskCompletion(task) }
                )
            }
        }
        
        // AI Recommendations
        if (aiRecommendations.isNotEmpty()) {
            item {
                Text(
                    text = "AI Suggestions",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold
                )
            }
            
            items(aiRecommendations.take(3)) { recommendation ->
                AIRecommendationCard(
                    recommendation = recommendation,
                    onAccept = { 
                        val task = Task(
                            title = recommendation.title,
                            description = recommendation.description,
                            emotion = recommendation.emotion,
                            priority = recommendation.priority,
                            category = recommendation.category,
                            isAIGenerated = true
                        )
                        viewModel.addTask(task)
                    }
                )
            }
        }
    }
    
    // Error handling
    uiState.error?.let { error ->
        LaunchedEffect(error) {
            // Show error snackbar
            viewModel.clearError()
        }
    }
    
    // Mood picker dialog
    if (showMoodPicker) {
        MoodPickerDialog(
            currentMood = currentMood,
            onMoodSelected = { mood ->
                viewModel.updateMood(mood)
                showMoodPicker = false
            },
            onDismiss = { showMoodPicker = false }
        )
    }
    
    // Quick add dialog
    if (showQuickAdd) {
        QuickAddDialog(
            onTaskInput = { input ->
                viewModel.processNaturalLanguageTask(input)
                showQuickAdd = false
            },
            onDismiss = { showQuickAdd = false }
        )
    }
}

@Composable
private fun WelcomeSection(
    currentMood: MoodType,
    onMoodClick: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp)
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = "Good morning! ✨",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold
            )
            
            Text(
                text = "How are you feeling today?",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            ElevatedButton(
                onClick = onMoodClick,
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(
                    imageVector = Icons.Default.Favorite,
                    contentDescription = null,
                    tint = currentMood.color
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text("I'm feeling ${currentMood.displayName}")
            }
        }
    }
}

@Composable
private fun QuickAddSection(
    isProcessing: Boolean,
    onQuickAddClick: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp)
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = "Quick Add",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )
            
            Text(
                text = "Add tasks using natural language",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            FilledTonalButton(
                onClick = onQuickAddClick,
                modifier = Modifier.fillMaxWidth(),
                enabled = !isProcessing
            ) {
                if (isProcessing) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(16.dp),
                        strokeWidth = 2.dp
                    )
                } else {
                    Icon(Icons.Default.Add, contentDescription = null)
                }
                Spacer(modifier = Modifier.width(8.dp))
                Text(if (isProcessing) "Processing..." else "Add Task")
            }
        }
    }
}

@Composable
private fun TaskCard(
    task: Task,
    onToggleComplete: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Checkbox(
                checked = task.isCompleted,
                onCheckedChange = { onToggleComplete() }
            )
            
            Spacer(modifier = Modifier.width(12.dp))
            
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = task.title,
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Medium
                )
                
                if (task.description != null) {
                    Text(
                        text = task.description,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Priority indicator
                    Surface(
                        shape = RoundedCornerShape(4.dp),
                        color = task.priority.color,
                        modifier = Modifier.clip(RoundedCornerShape(4.dp))
                    ) {
                        Text(
                            text = task.priority.displayName,
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.surface,
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                    
                    // Emotion indicator
                    Surface(
                        shape = RoundedCornerShape(4.dp),
                        color = task.emotion.color.copy(alpha = 0.2f),
                        modifier = Modifier.clip(RoundedCornerShape(4.dp))
                    ) {
                        Text(
                            text = task.emotion.displayName,
                            style = MaterialTheme.typography.labelSmall,
                            color = task.emotion.color,
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun EmptyTasksCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Icon(
                imageVector = Icons.Default.CheckCircle,
                contentDescription = null,
                modifier = Modifier.size(48.dp),
                tint = MaterialTheme.colorScheme.primary
            )
            Text(
                text = "No tasks for today",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Medium
            )
            Text(
                text = "You're all caught up! 🎉",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun AIRecommendationCard(
    recommendation: AndroidMLTaskEngine.AITaskRecommendation,
    onAccept: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.5f)
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.AutoAwesome,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "AI Suggestion",
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.primary
                )
            }
            
            Text(
                text = recommendation.title,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Medium
            )
            
            Text(
                text = recommendation.description,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            Text(
                text = recommendation.reasoning,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedButton(
                    onClick = { /* Dismiss */ },
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Maybe Later")
                }
                
                Button(
                    onClick = onAccept,
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Add Task")
                }
            }
        }
    }
}

@Composable
private fun MoodPickerDialog(
    currentMood: MoodType,
    onMoodSelected: (MoodType) -> Unit,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("How are you feeling?") },
        text = {
            LazyColumn {
                items(MoodType.values()) { mood ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = mood == currentMood,
                            onClick = { onMoodSelected(mood) }
                        )
                        Spacer(modifier = Modifier.width(12.dp))
                        Icon(
                            imageVector = Icons.Default.Favorite,
                            contentDescription = null,
                            tint = mood.color
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(mood.displayName)
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("Done")
            }
        }
    )
}

@Composable
private fun QuickAddDialog(
    onTaskInput: (String) -> Unit,
    onDismiss: () -> Unit
) {
    var input by remember { mutableStateOf("") }
    
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add Task") },
        text = {
            Column {
                Text("Use natural language to describe your task:")
                Spacer(modifier = Modifier.height(8.dp))
                OutlinedTextField(
                    value = input,
                    onValueChange = { input = it },
                    placeholder = { Text("e.g., 'Call mom at 3pm tomorrow'") },
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    if (input.isNotBlank()) {
                        onTaskInput(input)
                    }
                }
            ) {
                Text("Add")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}