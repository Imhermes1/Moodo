package com.moodo.android.ui.navigation

sealed class Screen(val route: String) {
    object Home : Screen("home")
    object Tasks : Screen("tasks")
    object Thoughts : Screen("thoughts")
    object Wellness : Screen("wellness")
    object Insights : Screen("insights")
}
