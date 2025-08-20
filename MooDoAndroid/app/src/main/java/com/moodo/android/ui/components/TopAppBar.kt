package com.moodo.android.ui.components

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MooDoTopAppBar(
    title: String
) {
    TopAppBar(
        title = { Text(text = title) },
        actions = {
            IconButton(onClick = { /* Handle notifications click */ }) {
                Icon(Icons.Filled.Notifications, contentDescription = "Notifications")
            }
            IconButton(onClick = { /* Handle account click */ }) {
                Icon(Icons.Filled.AccountCircle, contentDescription = "Account")
            }
        }
    )
}
