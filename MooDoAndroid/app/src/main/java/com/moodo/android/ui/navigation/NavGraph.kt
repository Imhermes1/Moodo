package com.moodo.android.ui.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.moodo.android.ui.screens.home.HomeScreen
import com.moodo.android.ui.screens.insights.InsightsScreen
import com.moodo.android.ui.screens.tasks.TasksScreen
import com.moodo.android.ui.screens.thoughts.ThoughtsScreen
import com.moodo.android.ui.screens.wellness.WellnessScreen

@Composable
fun NavGraph(navController: NavHostController) {
    NavHost(
        navController = navController,
        startDestination = Screen.Home.route
    ) {
        composable(Screen.Home.route) {
            HomeScreen()
        }
        composable(Screen.Tasks.route) {
            TasksScreen()
        }
        composable(Screen.Thoughts.route) {
            ThoughtsScreen()
        }
        composable(Screen.Wellness.route) {
            WellnessScreen()
        }
        composable(Screen.Insights.route) {
            InsightsScreen()
        }
    }
}
