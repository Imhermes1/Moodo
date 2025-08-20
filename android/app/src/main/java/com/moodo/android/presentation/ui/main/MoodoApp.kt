package com.moodo.android.presentation.ui.main

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.moodo.android.presentation.ui.screens.*
import com.moodo.android.presentation.viewmodel.*

/**
 * Main MooDo app composable
 * Equivalent to ContentView.swift in iOS version
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MoodoApp() {
    val navController = rememberNavController()
    var showAddTaskDialog by remember { mutableStateOf(false) }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("MooDo") },
                actions = {
                    IconButton(onClick = { showAddTaskDialog = true }) {
                        Icon(Icons.Default.Add, contentDescription = "Add Task")
                    }
                    IconButton(onClick = { /* Notifications */ }) {
                        Icon(Icons.Default.Notifications, contentDescription = "Notifications")
                    }
                    IconButton(onClick = { /* Settings */ }) {
                        Icon(Icons.Default.Settings, contentDescription = "Settings")
                    }
                }
            )
        },
        bottomBar = {
            NavigationBar {
                val navBackStackEntry by navController.currentBackStackEntryAsState()
                val currentDestination = navBackStackEntry?.destination
                
                bottomNavItems.forEach { item ->
                    NavigationBarItem(
                        icon = { Icon(item.icon, contentDescription = null) },
                        label = { Text(item.label) },
                        selected = currentDestination?.hierarchy?.any { it.route == item.route } == true,
                        onClick = {
                            navController.navigate(item.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = "home",
            modifier = Modifier.padding(innerPadding)
        ) {
            composable("home") {
                val homeViewModel: HomeViewModel = hiltViewModel()
                HomeScreen(viewModel = homeViewModel)
            }
            composable("tasks") {
                val tasksViewModel: TasksViewModel = hiltViewModel()
                TasksScreen(viewModel = tasksViewModel)
            }
            composable("thoughts") {
                val thoughtsViewModel: ThoughtsViewModel = hiltViewModel()
                ThoughtsScreen(viewModel = thoughtsViewModel)
            }
            composable("wellness") {
                val wellnessViewModel: WellnessViewModel = hiltViewModel()
                WellnessScreen(viewModel = wellnessViewModel)
            }
            composable("insights") {
                val insightsViewModel: InsightsViewModel = hiltViewModel()
                InsightsScreen(viewModel = insightsViewModel)
            }
        }
        
        if (showAddTaskDialog) {
            QuickAddTaskDialog(
                onDismiss = { showAddTaskDialog = false },
                onTaskAdded = { 
                    showAddTaskDialog = false
                    // Handle task added
                }
            )
        }
    }
}

private data class BottomNavItem(
    val route: String,
    val icon: androidx.compose.ui.graphics.vector.ImageVector,
    val label: String
)

private val bottomNavItems = listOf(
    BottomNavItem("home", Icons.Default.Home, "Home"),
    BottomNavItem("tasks", Icons.Default.CheckCircle, "Tasks"),
    BottomNavItem("thoughts", Icons.Default.Create, "Thoughts"),
    BottomNavItem("wellness", Icons.Default.Favorite, "Wellness"),
    BottomNavItem("insights", Icons.Default.Analytics, "Insights")
)

@Composable
fun QuickAddTaskDialog(
    onDismiss: () -> Unit,
    onTaskAdded: () -> Unit
) {
    var taskText by remember { mutableStateOf("") }
    
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Quick Add Task") },
        text = {
            Column {
                Text("Enter your task using natural language:")
                Spacer(modifier = Modifier.height(8.dp))
                OutlinedTextField(
                    value = taskText,
                    onValueChange = { taskText = it },
                    placeholder = { Text("e.g., 'Call mom at 3pm tomorrow'") },
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    if (taskText.isNotBlank()) {
                        // TODO: Process task with ML engine
                        onTaskAdded()
                    }
                }
            ) {
                Text("Add Task")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}