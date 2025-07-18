//
//  TaskScheduler.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import Foundation
import SwiftUI

// MARK: - Task Scheduling Intelligence

class TaskScheduler {
    var currentMood: MoodType = .focused
    var isOptimizing = false
    
    // Mood-task compatibility matrix
    private let moodTaskCompatibility: [MoodType: [EmotionType]] = [
        .positive: [.positive, .creative, .focused],
        .calm: [.calm, .positive, .creative],
        .focused: [.focused, .urgent, .positive],
        .stressed: [.calm, .positive], // Avoid creative/urgent when stressed
        .creative: [.creative, .positive, .focused]
    ]
    
    // Task complexity estimates (in hours)
    private let taskComplexity: [String: Double] = [
        "brainstorm": 2.0,
        "creative": 1.5,
        "presentation": 4.0,
        "project": 8.0,
        "meeting": 1.0,
        "call": 0.5,
        "email": 0.25,
        "review": 1.0,
        "plan": 2.0,
        "research": 3.0
    ]
    
    func optimizeTaskSchedule(tasks: [Task]) -> [Task] {
        isOptimizing = true
        
        var optimizedTasks = tasks
        
        // 1. Identify incompatible tasks for current mood
        let incompatibleTasks = tasks.filter { task in
            !isTaskCompatibleWithMood(task.emotion, currentMood: currentMood)
        }
        
        // 2. Reschedule incompatible tasks
        for task in incompatibleTasks {
            if let optimizedTask = rescheduleTask(task, tasks: tasks) {
                if let index = optimizedTasks.firstIndex(where: { $0.id == task.id }) {
                    optimizedTasks[index] = optimizedTask
                }
            }
        }
        
        // 3. Ensure deadlines are met
        optimizedTasks = ensureDeadlinesMet(optimizedTasks)
        
        isOptimizing = false
        return optimizedTasks
    }
    
    private func isTaskCompatibleWithMood(_ taskEmotion: EmotionType, currentMood: MoodType) -> Bool {
        guard let compatibleEmotions = moodTaskCompatibility[currentMood] else { return true }
        return compatibleEmotions.contains(taskEmotion)
    }
    
    private func rescheduleTask(_ task: Task, tasks: [Task]) -> Task? {
        var updatedTask = task
        
        // Calculate when this task should be done based on mood patterns
        let optimalTime = calculateOptimalTime(for: task, currentMood: currentMood)
        
        // If the task has a deadline, ensure we have enough time
        if let deadline = task.reminderAt {
            let requiredTime = estimateTaskDuration(task)
            let deadlineTime = deadline.timeIntervalSinceNow
            
            // If we don't have enough time before deadline, move it earlier
            if deadlineTime < requiredTime * 3600 { // Convert hours to seconds
                let newReminderTime = Date().addingTimeInterval(requiredTime * 3600)
                updatedTask.reminderAt = newReminderTime
            }
        } else {
            // No deadline, schedule based on mood optimization
            updatedTask.reminderAt = optimalTime
        }
        
        return updatedTask
    }
    
    private func calculateOptimalTime(for task: Task, currentMood: MoodType) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Different scheduling strategies based on mood
        switch currentMood {
        case .stressed:
            // When stressed, schedule calming tasks soon, delay complex ones
            if task.emotion == .calm || task.emotion == .positive {
                return calendar.date(byAdding: .hour, value: 1, to: now) ?? now
            } else {
                return calendar.date(byAdding: .day, value: 1, to: now) ?? now
            }
            
        case .creative:
            // When creative, prioritize creative tasks
            if task.emotion == .creative {
                return calendar.date(byAdding: .hour, value: 2, to: now) ?? now
            } else {
                return calendar.date(byAdding: .hour, value: 6, to: now) ?? now
            }
            
        case .focused:
            // When focused, good for most tasks
            return calendar.date(byAdding: .hour, value: 3, to: now) ?? now
            
        case .positive:
            // When positive, good for all tasks
            return calendar.date(byAdding: .hour, value: 2, to: now) ?? now
            
        case .calm:
            // When calm, good for thoughtful tasks
            if task.emotion == .creative || task.emotion == .calm {
                return calendar.date(byAdding: .hour, value: 1, to: now) ?? now
            } else {
                return calendar.date(byAdding: .hour, value: 4, to: now) ?? now
            }
        }
    }
    
    private func estimateTaskDuration(_ task: Task) -> Double {
        let title = task.title.lowercased()
        let description = task.description?.lowercased() ?? ""
        let combinedText = "\(title) \(description)"
        
        // Check for specific keywords
        for (keyword, duration) in taskComplexity {
            if combinedText.contains(keyword) {
                return duration
            }
        }
        
        // Default estimates based on priority
        switch task.priority {
        case .high: return 2.0
        case .medium: return 1.0
        case .low: return 0.5
        }
    }
    
    private func ensureDeadlinesMet(_ tasks: [Task]) -> [Task] {
        var optimizedTasks = tasks
        
        // Sort tasks by deadline
        let tasksWithDeadlines = tasks.filter { $0.reminderAt != nil }
            .sorted { ($0.reminderAt ?? Date.distantFuture) < ($1.reminderAt ?? Date.distantFuture) }
        
        var currentTime = Date()
        
        for task in tasksWithDeadlines {
            guard let deadline = task.reminderAt else { continue }
            
            let requiredTime = estimateTaskDuration(task)
            let deadlineTime = deadline.timeIntervalSinceNow
            
            // If we don't have enough time, move the task earlier
            if deadlineTime < requiredTime * 3600 {
                let newReminderTime = currentTime.addingTimeInterval(requiredTime * 3600)
                
                if let index = optimizedTasks.firstIndex(where: { $0.id == task.id }) {
                    optimizedTasks[index].reminderAt = newReminderTime
                }
                
                currentTime = newReminderTime
            } else {
                currentTime = deadline
            }
        }
        
        return optimizedTasks
    }
    
    func updateCurrentMood(_ mood: MoodType) {
        currentMood = mood
    }
} 