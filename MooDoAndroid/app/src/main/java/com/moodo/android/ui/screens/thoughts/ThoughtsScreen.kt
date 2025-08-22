package com.moodo.android.ui.screens.thoughts

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.moodo.android.data.model.Thought
import com.moodo.android.ui.components.*
import com.moodo.android.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ThoughtsScreen(
    viewModel: ThoughtsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val showDialog by viewModel.showAddThoughtDialog.collectAsState()
    var searchText by remember { mutableStateOf("") }

    if (showDialog) {
        AddThoughtDialog(
            onDismissRequest = { viewModel.onDismissAddThoughtDialog() },
            onConfirm = { title, content -> viewModel.onAddThoughtConfirmed(title, content) }
        )
    }

    Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Search and Filter Bar - Fixed position
            Column(
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Search Bar with Add Button
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = CalmingBlue.copy(alpha = 0.1f)
                    )
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 12.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                    Icon(
                        imageVector = Icons.Default.Search,
                        contentDescription = "Search",
                        tint = Color.White.copy(alpha = 0.6f)
                    )
                    
                    OutlinedTextField(
                        value = searchText,
                        onValueChange = { searchText = it },
                        placeholder = { 
                            Text(
                                "Search thoughts...", 
                                color = Color.White.copy(alpha = 0.6f)
                            ) 
                        },
                        modifier = Modifier.weight(1f),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedBorderColor = Color.Transparent,
                            unfocusedBorderColor = Color.Transparent,
                            cursorColor = Color.White
                        ),
                        singleLine = true
                    )
                    
                    // Add button
                    FloatingActionButton(
                        onClick = { viewModel.onAddThoughtClicked() },
                        modifier = Modifier.size(40.dp),
                        containerColor = CalmingBlue,
                        contentColor = Color.White
                    ) {
                        Icon(
                            imageVector = Icons.Default.Add,
                            contentDescription = "Add Thought",
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }
            
            // Thoughts content
            if (uiState.thoughts.isEmpty()) {
                // Empty state with iOS-style design
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MistyGrey.copy(alpha = 0.1f)
                    )
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(32.dp),
                        contentAlignment = Alignment.Center
                    ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Add, // Using Add as cloud icon not available
                            contentDescription = "No thoughts",
                            modifier = Modifier.size(48.dp),
                            tint = Color.White.copy(alpha = 0.4f)
                        )
                        
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Text(
                                text = "Ready to capture brilliance?",
                                style = MaterialTheme.typography.headlineSmall.copy(
                                    fontWeight = FontWeight.SemiBold
                                ),
                                color = Color.White.copy(alpha = 0.8f),
                                textAlign = TextAlign.Center
                            )
                            
                            Text(
                                text = "Think. Capture. Flourish.",
                                style = MaterialTheme.typography.bodyLarge,
                                color = Color.White.copy(alpha = 0.6f),
                                textAlign = TextAlign.Center
                            )
                        }
                    }
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(vertical = 8.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(uiState.thoughts.filter { 
                        searchText.isEmpty() || it.content.contains(searchText, ignoreCase = true) 
                    }) { thought ->
                        ThoughtCard(thought = thought)
                    }
                }
            }
        }
    }
}

@Composable
fun ThoughtCard(
    thought: Thought,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = PeacefulGreen.copy(alpha = 0.1f)
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Thought title if available
            if (thought.title.isNotBlank()) {
                Text(
                    text = thought.title,
                    style = MaterialTheme.typography.titleMedium.copy(
                        fontWeight = FontWeight.Bold,
                        fontSize = 18.sp
                    ),
                    color = Color.White
                )
            }
            
            // Thought content
            Text(
                text = thought.content,
                style = MaterialTheme.typography.bodyLarge.copy(
                    lineHeight = 24.sp
                ),
                color = Color.White.copy(alpha = 0.9f)
            )
            
            // Metadata row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Mood indicator
                Box(
                    modifier = Modifier
                        .background(
                            CalmingBlue.copy(alpha = 0.2f),
                            RoundedCornerShape(8.dp)
                        )
                        .border(
                            1.dp, 
                            CalmingBlue.copy(alpha = 0.4f),
                            RoundedCornerShape(8.dp)
                        )
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                ) {
                    Text(
                        text = thought.mood.name,
                        style = MaterialTheme.typography.labelSmall.copy(
                            fontWeight = FontWeight.Medium,
                            fontSize = 11.sp
                        ),
                        color = Color.White
                    )
                }
                
                // Timestamp - using a placeholder since createdAt doesn't exist yet
                Text(
                    text = "Just now", // formatThoughtTime(thought.createdAt)
                    style = MaterialTheme.typography.labelSmall,
                    color = Color.White.copy(alpha = 0.6f)
                )
            }
        }
    }
}

// Helper function for formatting time (you may want to move this to a utils file)
private fun formatThoughtTime(timestamp: Long): String {
    val now = System.currentTimeMillis()
    val diff = now - timestamp
    
    return when {
        diff < 60_000 -> "Just now"
        diff < 3600_000 -> "${diff / 60_000}m ago"
        diff < 86400_000 -> "${diff / 3600_000}h ago"
        else -> "${diff / 86400_000}d ago"
    }
}
