//
//  MoodBasedTasksView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Mood-Based Smart Tasks View (Main Screen)

struct MoodBasedTasksView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    let onAddTask: () -> Void
    let screenSize: CGSize
    @State private var currentMoodTasks: [Task] = []
    @State private var isRefreshing = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Smart Tasks Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Smart Tasks")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 6) {
                            Image(systemName: currentMood.icon)
                                .foregroundColor(currentMood.color)
                                .font(.caption)
                            
                            Text("Optimized for your \(currentMood.displayName.lowercased()) energy")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // Refresh smart tasks button
                        Button(action: refreshSmartTasks) {
                            Image(systemName: isRefreshing ? "arrow.clockwise" : "brain.head.profile")
                                .foregroundColor(.white)
                                .font(.title3)
                                .fontWeight(.medium)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(.purple.opacity(0.3))
                                        .overlay(
                                            Circle()
                                                .stroke(.purple.opacity(0.5), lineWidth: 1)
                                        )
                                )
                                .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                                .animation(.linear(duration: 1).repeatCount(isRefreshing ? .max : 1, autoreverses: false), value: isRefreshing)
                        }
                        
                        // Add task button
                        Button(action: onAddTask) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.title3)
                                .fontWeight(.medium)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(.green.opacity(0.3))
                                        .overlay(
                                            Circle()
                                                .stroke(.green.opacity(0.5), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
                
                // Mood insights
                moodInsightsSection
            }
            
            // Smart task list
            if currentMoodTasks.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(currentMoodTasks) { task in
                        SmartTaskCard(
                            task: task,
                            onToggleComplete: {
                                taskManager.toggleTaskCompletion(task)
                                refreshSmartTasks()
                            }
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .opacity(0.15) // Reduced opacity
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.clear, lineWidth: 0) // Removed visible border
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            refreshSmartTasks()
        }
        .onChange(of: moodManager.currentMood) { 
            print("🔄 MoodBasedTasksView: MoodManager currentMood changed to: \(moodManager.currentMood)")
            refreshSmartTasks() 
        }
        .onChange(of: taskManager.tasks) { 
            print("🔄 MoodBasedTasksView: TaskManager tasks changed, count: \(taskManager.tasks.count)")
            refreshSmartTasks() 
        }
    }
    
    // MARK: - Computed Properties
    
    private var currentMood: EmotionType {
        moodManager.currentMood
    }
    
    // MARK: - Subviews
    
    private var moodInsightsSection: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .foregroundColor(.purple)
                .font(.caption)
            
            Text("Showing \(currentMoodTasks.count) tasks optimized for your mood")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            if !currentMoodTasks.isEmpty {
                Text("\(currentMoodTasks.filter { !$0.isCompleted }.count) remaining")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.orange.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 40))
                .foregroundColor(.purple.opacity(0.7))
            
            Text("No smart tasks right now")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Add some tasks and I'll optimize them based on your \(currentMood.displayName.lowercased()) energy!")
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            Button(action: onAddTask) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.body)
                        .fontWeight(.medium)
                    Text("Add your first task")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.green.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.clear, lineWidth: 0)
                        )
                )
            }
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Methods
    
    private func refreshSmartTasks() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isRefreshing = true
        }
        
        print("🧠 MoodBasedTasksView: Refreshing tasks for mood: \(currentMood)")
        print("📋 Total available tasks: \(taskManager.tasks.count)")
        
        // Get mood-optimized tasks
        let optimizedTasks = taskManager.taskScheduler.getMoodOptimizedTasks(
            from: taskManager.tasks,
            for: currentMood,
            maxTasks: getOptimalTaskCount()
        )
        
        print("✨ Optimized tasks count: \(optimizedTasks.count)")
        print("📝 Optimized task titles: \(optimizedTasks.map { $0.title })")
        
        // Apply automatic emotion detection to tasks without emotions
        let tasksWithEmotions = optimizedTasks.map { task in
            var updatedTask = task
            if task.emotion == .neutral {
                updatedTask.emotion = detectEmotionForTask(task)
                taskManager.updateTask(updatedTask)
                print("🎯 Auto-assigned emotion \(updatedTask.emotion) to task: \(task.title)")
            }
            return updatedTask
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            currentMoodTasks = tasksWithEmotions
        }
        
        print("🎉 Final smart tasks count: \(tasksWithEmotions.count)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isRefreshing = false
            }
        }
    }
    
    private func getOptimalTaskCount() -> Int {
        switch currentMood {
        case .energetic, .focused: return 5
        case .calm, .content: return 3
        case .stressed, .overwhelmed: return 2
        case .anxious, .tired: return 1
        default: return 3
        }
    }
    
    private func detectEmotionForTask(_ task: Task) -> EmotionType {
        let title = task.title.lowercased()
        let description = task.description?.lowercased() ?? ""
        let content = title + " " + description
        
        // Priority-based emotion mapping with mood consideration
        switch task.priority {
        case .high:
            // For stressed users, high-priority tasks should be calming, not stressful
            if currentMood == .stressed || currentMood == .overwhelmed {
                if content.contains("relax") || content.contains("breathe") || content.contains("meditation") {
                    return .calm
                }
                if content.contains("walk") || content.contains("nature") || content.contains("fresh air") {
                    return .calm
                }
                // Default to focused for high-priority tasks when stressed
                return .focused
            } else {
                // Normal logic for non-stressed users
                if content.contains("deadline") || content.contains("urgent") || content.contains("important") {
                    return .focused  // Changed from .stressed to .focused
                }
                return .focused
            }
        case .medium:
            if content.contains("meeting") || content.contains("call") || content.contains("presentation") {
                return .focused
            }
            if content.contains("exercise") || content.contains("workout") || content.contains("run") {
                return .energetic
            }
            if content.contains("creative") || content.contains("brainstorm") || content.contains("design") {
                return .creative
            }
            return .content
        case .low:
            if content.contains("relax") || content.contains("read") || content.contains("meditation") {
                return .calm
            }
            if content.contains("creative") || content.contains("brainstorm") || content.contains("design") {
                return .creative
            }
            if content.contains("social") || content.contains("friend") || content.contains("family") {
                return .positive
            }
            return .content
        }
    }
}

// MARK: - Smart Task Card Component

struct SmartTaskCard: View {
    let task: Task
    let onToggleComplete: () -> Void
    @State private var glowEffect: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion button
            Button(action: onToggleComplete) {
                ZStack {
                    Circle()
                        .stroke(task.emotion.color, lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .opacity(0.4)
                        )
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(task.emotion.color)
                    }
                }
            }
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .strikethrough(task.isCompleted)
                    .opacity(task.isCompleted ? 0.6 : 1.0)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    // Emotion badge
                    HStack(spacing: 4) {
                        Image(systemName: task.emotion.icon)
                            .font(.caption2)
                        Text(task.emotion.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(task.emotion.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(task.emotion.color.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(task.emotion.color.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Priority badge
                    Text(task.priority.displayName.prefix(1))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(task.priority.color)
                        .frame(width: 16, height: 16)
                        .background(
                            Circle()
                                .fill(task.priority.color.opacity(0.15))
                                .overlay(
                                    Circle()
                                        .stroke(task.priority.color.opacity(0.3), lineWidth: 1)
                                )
                        )
                    
                    Spacer()
                    
                    // AI optimized badge
                    HStack(spacing: 4) {
                        Image(systemName: "brain.head.profile")
                            .font(.caption2)
                        Text("AI")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(.purple.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(.purple.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(glowEffect ? 0.6 : 0.4),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(task.isCompleted ? 0.98 : 1.0)
        .opacity(task.isCompleted ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowEffect.toggle()
            }
        }
    }
} 