package com.moodo.android.ui.screens.thoughts

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.moodo.android.data.model.Thought
import com.moodo.android.ui.components.AddThoughtDialog

@Composable
fun ThoughtsScreen(
    viewModel: ThoughtsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val showDialog by viewModel.showAddThoughtDialog.collectAsState()

    if (showDialog) {
        AddThoughtDialog(
            onDismissRequest = { viewModel.onDismissAddThoughtDialog() },
            onConfirm = { title, content -> viewModel.onAddThoughtConfirmed(title, content) }
        )
    }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Button(
            onClick = { viewModel.onAddThoughtClicked() },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Add New Thought")
        }
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(vertical = 16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(uiState.thoughts) { thought ->
                ThoughtItem(thought = thought)
            }
        }
    }
}

@Composable
fun ThoughtItem(thought: Thought) {
    Column {
        Text(text = thought.title)
        Text(text = thought.content)
    }
}
