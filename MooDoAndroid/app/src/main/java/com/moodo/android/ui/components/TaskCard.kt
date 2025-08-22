package com.moodo.android.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.moodo.android.data.model.Task
import com.moodo.android.ui.theme.*
import com.moodo.android.util.haptics.HapticManager
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TaskCard(
    task: Task,
    onTaskCompleted: (Task) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val hapticManager = HapticManager(context)
    
    // Animation for completion state
    val scale by animateFloatAsState(
        targetValue = if (task.isCompleted) 0.95f else 1f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessLow
        ),
        label = "task_completion_scale"
    )
    
    // Determine emotion color using enum
    val emotionColor = when (task.emotion) {
        com.moodo.android.data.model.TaskEmotion.ENERGIZING -> GentleYellow
        com.moodo.android.data.model.TaskEmotion.CALMING -> CalmingBlue
        com.moodo.android.data.model.TaskEmotion.FOCUSED -> PeacefulGreen
        com.moodo.android.data.model.TaskEmotion.CREATIVE -> SoftViolet
        com.moodo.android.data.model.TaskEmotion.ANXIOUS -> DustyRose
        com.moodo.android.data.model.TaskEmotion.STRESSFUL -> DustyRose
        com.moodo.android.data.model.TaskEmotion.ROUTINE -> MistyGrey
    }
    
    // Priority color using enum
    val priorityColor = when (task.priority) {
        com.moodo.android.data.model.TaskPriority.HIGH -> Color.Red.copy(alpha = 0.7f)
        com.moodo.android.data.model.TaskPriority.MEDIUM -> GentleYellow
        com.moodo.android.data.model.TaskPriority.LOW -> PeacefulGreen
    }

    Card(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp)
            .scale(scale),
        colors = CardDefaults.cardColors(
            containerColor = emotionColor.copy(alpha = 0.1f)
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Custom completion button with emotion color
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .clip(CircleShape)
                    .border(
                        width = 2.dp,
                        color = emotionColor,
                        shape = CircleShape
                    )
                    .clickable {
                        onTaskCompleted(task)
                        if (!task.isCompleted) {
                            hapticManager.performSuccess()
                        } else {
                            hapticManager.performClick()
                        }
                    },
                contentAlignment = Alignment.Center
            ) {
                if (task.isCompleted) {
                    Icon(
                        imageVector = Icons.Default.Check,
                        contentDescription = "Completed",
                        tint = emotionColor,
                        modifier = Modifier.size(14.dp)
                    )
                }
            }
            
            // Task content
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                // Task title
                Text(
                    text = task.title,
                    style = MaterialTheme.typography.bodyLarge.copy(
                        fontWeight = FontWeight.Medium,
                        fontSize = 16.sp
                    ),
                    color = if (task.isCompleted) 
                        Color.White.copy(alpha = 0.6f) 
                    else 
                        Color.White,
                    textDecoration = if (task.isCompleted) 
                        TextDecoration.LineThrough 
                    else 
                        TextDecoration.None,
                    maxLines = 2
                )
                
                // Task metadata row
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Emotion badge
                    Box(
                        modifier = Modifier
                            .background(
                                emotionColor.copy(alpha = 0.2f),
                                RoundedCornerShape(8.dp)
                            )
                            .border(
                                1.dp, 
                                emotionColor.copy(alpha = 0.4f),
                                RoundedCornerShape(8.dp)
                            )
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text(
                            text = task.emotion.name,
                            style = MaterialTheme.typography.labelSmall.copy(
                                fontWeight = FontWeight.Medium,
                                fontSize = 11.sp
                            ),
                            color = Color.White
                        )
                    }
                    
                    // Priority badge
                    Box(
                        modifier = Modifier
                            .background(
                                Color.White.copy(alpha = 0.1f),
                                RoundedCornerShape(8.dp)
                            )
                            .border(
                                1.dp, 
                                priorityColor.copy(alpha = 0.6f),
                                RoundedCornerShape(8.dp)
                            )
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text(
                            text = task.priority.name,
                            style = MaterialTheme.typography.labelSmall.copy(
                                fontWeight = FontWeight.Medium,
                                fontSize = 11.sp
                            ),
                            color = Color.White
                        )
                    }
                }
            }
        }
    }
}
