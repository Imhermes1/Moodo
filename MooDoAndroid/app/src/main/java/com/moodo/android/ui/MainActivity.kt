package com.moodo.android.ui

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.moodo.android.ui.components.BottomNavigationBar
import com.moodo.android.ui.components.MooDoTopAppBar
import com.moodo.android.ui.components.SimpleBackground
import com.moodo.android.ui.navigation.NavGraph
import com.moodo.android.ui.theme.MooDoTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MooDoTheme {
                MainScreen()
            }
        }
    }
}

@Composable
fun MainScreen() {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route ?: "Home"

    Box(modifier = Modifier.fillMaxSize()) {
        // Simple background for the entire app
        SimpleBackground()
        
        Scaffold(
            modifier = Modifier.fillMaxSize(),
            containerColor = Color.Transparent, // Make scaffold background transparent
            topBar = { MooDoTopAppBar(title = currentRoute.replaceFirstChar { it.uppercase() }) },
            bottomBar = { BottomNavigationBar(navController = navController) }
        ) { innerPadding ->
            Box(modifier = Modifier.padding(innerPadding)) {
                NavGraph(navController = navController)
            }
        }
    }
}
