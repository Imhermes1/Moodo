package com.moodo.android

import com.moodo.android.domain.model.*
import kotlinx.datetime.Clock
import org.junit.Test
import org.junit.Assert.*

/**
 * Example unit test for MooDo Android
 * Tests core domain model functionality
 */
class MoodoUnitTest {
    
    @Test
    fun task_dynamicPriority_escalatesCorrectly() {
        val now = Clock.System.now()
        val tomorrow = now.plus(kotlinx.datetime.DateTimeUnit.DAY, 1, kotlinx.datetime.TimeZone.UTC)
        
        val task = Task(
            title = "Test Task",
            priority = TaskPriority.LOW,
            reminderAt = tomorrow
        )
        
        // Task due tomorrow should escalate to HIGH priority
        assertEquals(TaskPriority.HIGH, task.dynamicPriority)
        assertTrue(task.isEscalated)
    }
    
    @Test
    fun moodType_compatibleEmotions_returnCorrectList() {
        val energizedMood = MoodType.ENERGIZED
        val compatibleEmotions = energizedMood.compatibleTaskEmotions
        
        assertTrue(compatibleEmotions.contains(TaskEmotion.ENERGIZING))
        assertTrue(compatibleEmotions.contains(TaskEmotion.FOCUSED))
        assertTrue(compatibleEmotions.contains(TaskEmotion.CREATIVE))
        assertFalse(compatibleEmotions.contains(TaskEmotion.CALMING))
    }
    
    @Test
    fun task_priorityDescription_showsEscalation() {
        val now = Clock.System.now()
        val overdue = now.minus(kotlinx.datetime.DateTimeUnit.DAY, 1, kotlinx.datetime.TimeZone.UTC)
        
        val task = Task(
            title = "Overdue Task",
            priority = TaskPriority.MEDIUM,
            reminderAt = overdue
        )
        
        assertEquals("High (Due Soon)", task.priorityDescription)
    }
    
    @Test
    fun thought_initialization_setsCorrectDefaults() {
        val thought = Thought(
            title = "Test Thought",
            content = "This is a test thought"
        )
        
        assertEquals(MoodType.CALM, thought.mood)
        assertNull(thought.linkedTaskId)
        assertNotNull(thought.id)
        assertNotNull(thought.dateCreated)
    }
    
    @Test
    fun taskPriority_numericValues_areCorrect() {
        assertEquals(1, TaskPriority.LOW.numericValue)
        assertEquals(2, TaskPriority.MEDIUM.numericValue)
        assertEquals(3, TaskPriority.HIGH.numericValue)
    }
    
    @Test
    fun moodType_numericValues_areLogical() {
        assertTrue(MoodType.ENERGIZED.numericValue > MoodType.TIRED.numericValue)
        assertTrue(MoodType.FOCUSED.numericValue > MoodType.STRESSED.numericValue)
        assertTrue(MoodType.CALM.numericValue > MoodType.ANXIOUS.numericValue)
    }
}