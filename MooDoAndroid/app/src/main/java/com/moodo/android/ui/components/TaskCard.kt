package com.moodo.android.ui.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.Checkbox
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.moodo.android.data.model.Task
import com.moodo.android.util.haptics.HapticManager

@Composable
fun TaskCard(
    task: Task,
    onTaskCompleted: (Task) -> Unit
) {
    val context = LocalContext.current
    val hapticManager = HapticManager(context)

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Checkbox(
                checked = task.isCompleted,
                onCheckedChange = {
                    onTaskCompleted(task)
                    if (it) {
                        hapticManager.performSuccess()
                    } else {
                        hapticManager.performClick()
                    }
                }
            )
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(text = task.title, style = MaterialTheme.typography.bodyLarge)
                Text(text = "Priority: ${task.priority}", style = MaterialTheme.typography.bodySmall)
                Text(text = "Emotion: ${task.emotion}", style = MaterialTheme.typography.bodySmall)
            }
        }
    }
}
