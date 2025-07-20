//
//  TaskViews.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - All Tasks List View

struct AllTasksListView: View {
    let tasks: [Task]
    let onAddTask: () -> Void
    let taskManager: TaskManager
    @State private var expandedTaskId: UUID?
    @State private var selectedFilter: TaskFilter = .all
    @State private var selectedTag: String? = nil
    @State private var showingFilterDropdown = false
    @State private var showingTagDropdown = false
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case highPriority = "High Priority"
        case completed = "Completed"
        case pending = "Pending"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .today: return "calendar"
            case .highPriority: return "exclamationmark.triangle"
            case .completed: return "checkmark.circle"
            case .pending: return "clock"
            }
        }
    }
    
    var allTags: [String] {
        Array(Set(tasks.flatMap { $0.tags })).sorted()
    }
    
    var filteredTasks: [Task] {
        var filtered = tasks
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .today:
            filtered = filtered.filter { task in
                if let reminderAt = task.reminderAt {
                    return Calendar.current.isDateInToday(reminderAt)
                } else if let deadlineAt = task.deadlineAt {
                    return Calendar.current.isDateInToday(deadlineAt)
                } else {
                    return Calendar.current.isDateInToday(task.createdAt)
                }
            }
        case .highPriority:
            filtered = filtered.filter { $0.priority == .high }
        case .completed:
            filtered = filtered.filter { $0.isCompleted }
        case .pending:
            filtered = filtered.filter { !$0.isCompleted }
        }
        
        // Apply tag filter
        if let selectedTag = selectedTag {
            filtered = filtered.filter { $0.tags.contains(selectedTag) }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                // Header
                HStack {
                    Text("All Tasks")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: onAddTask) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.caption)
                                .fontWeight(.medium)
                            Text("Add")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                                ZStack {
                                    // Base glass layer
                            Capsule()
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.4)
                                    
                                    // Highlight layer
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .white.opacity(0.25),
                                                    .white.opacity(0.08),
                                                    .clear,
                                                    .black.opacity(0.05)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // Border
                                    Capsule()
                                        .strokeBorder(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .white.opacity(0.6),
                                                    .white.opacity(0.2),
                                                    .white.opacity(0.05),
                                                    .white.opacity(0.3)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                }
                            )
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                            .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Task Count and Filter Info
                HStack {
                    Text("\(filteredTasks.count) tasks")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                        if selectedFilter != .all || selectedTag != nil {
                            HStack(spacing: 4) {
                    if selectedFilter != .all {
                        Text("• \(selectedFilter.rawValue)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                                }
                                if selectedTag != nil {
                                    Text("• #\(selectedTag!)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                
                    // Filter Dropdowns
                    HStack(spacing: 12) {
                        // Filter Dropdown
                        VStack {
                            Button(action: { showingFilterDropdown.toggle() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: selectedFilter.icon)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    
                                    Text(selectedFilter.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.7))
                                        .rotationEffect(.degrees(showingFilterDropdown ? 180 : 0))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    ZStack {
                                        Capsule()
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.4)
                                        
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        .white.opacity(0.25),
                                                        .white.opacity(0.08),
                                                        .clear,
                                                        .black.opacity(0.05)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        
                                        Capsule()
                                            .strokeBorder(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        .white.opacity(0.6),
                                                        .white.opacity(0.2),
                                                        .white.opacity(0.05),
                                                        .white.opacity(0.3)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    }
                                )
                                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                                .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
                            }
                            .clipShape(Capsule())
                            
                            // Dropdown Menu
                            if showingFilterDropdown {
                                VStack(spacing: 0) {
                        ForEach(TaskFilter.allCases, id: \.self) { filter in
                                        Button(action: {
                                            selectedFilter = filter
                                            showingFilterDropdown = false
                                        }) {
                                            HStack(spacing: 8) {
                                    Image(systemName: filter.icon)
                                        .font(.caption)
                                                    .foregroundColor(.white)
                                                
                                    Text(filter.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                                
                                                if selectedFilter == filter {
                                                    Image(systemName: "checkmark")
                                                        .font(.caption2)
                                                        .foregroundColor(.green)
                                                }
                                            }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                                filter == selectedFilter ? 
                                                Color.white.opacity(0.1) : 
                                                Color.clear
                                            )
                                        }
                                    }
                                }
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.4)
                                        
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        .white.opacity(0.6),
                                                        .white.opacity(0.2),
                                                        .white.opacity(0.05),
                                                        .white.opacity(0.3)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    }
                                )
                                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: showingFilterDropdown)
                        
                        // Tags Dropdown
                        VStack {
                            Button(action: { showingTagDropdown.toggle() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "tag")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    
                                    Text(selectedTag ?? "All Tags")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.7))
                                        .rotationEffect(.degrees(showingTagDropdown ? 180 : 0))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    ZStack {
                                    Capsule()
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.4)
                                        
                                            Capsule()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        .white.opacity(0.25),
                                                        .white.opacity(0.08),
                                                        .clear,
                                                        .black.opacity(0.05)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        
                                        Capsule()
                                            .strokeBorder(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        .white.opacity(0.6),
                                                        .white.opacity(0.2),
                                                        .white.opacity(0.05),
                                                        .white.opacity(0.3)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    }
                                )
                                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                                .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
                            }
                            .clipShape(Capsule())
                            
                            // Dropdown Menu
                            if showingTagDropdown {
                                VStack(spacing: 0) {
                                    // All Tags option
                                    Button(action: {
                                        selectedTag = nil
                                        showingTagDropdown = false
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "tag")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                            
                                            Text("All Tags")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                            
                                            if selectedTag == nil {
                                                Image(systemName: "checkmark")
                                                    .font(.caption2)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedTag == nil ? 
                                            Color.white.opacity(0.1) : 
                                            Color.clear
                                        )
                                    }
                                    
                                    // Individual tags
                                    ForEach(allTags, id: \.self) { tag in
                                        Button(action: {
                                            selectedTag = tag
                                            showingTagDropdown = false
                                        }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "tag.fill")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                                
                                                Text("#\(tag)")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                                
                                                if selectedTag == tag {
                                                    Image(systemName: "checkmark")
                                                        .font(.caption2)
                                                        .foregroundColor(.green)
                                                }
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                tag == selectedTag ? 
                                                Color.white.opacity(0.1) : 
                                                Color.clear
                                            )
                                        }
                                    }
                                }
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.4)
                                        
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        .white.opacity(0.6),
                                                        .white.opacity(0.2),
                                                        .white.opacity(0.05),
                                                        .white.opacity(0.3)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    }
                                )
                                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: showingTagDropdown)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(
                    ZStack {
                        // Base glass layer with 3D depth
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .opacity(0.4)
                        
                        // Inner highlight layer for 3D effect
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.25),
                                        .white.opacity(0.08),
                                        .clear,
                                        .black.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Outer stroke with glass shimmer
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.2),
                                        .white.opacity(0.05),
                                        .white.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                        
                        // Inner stroke for depth
                        RoundedRectangle(cornerRadius: 19)
                            .strokeBorder(
                                .white.opacity(0.1),
                                lineWidth: 0.5
                            )
                    }
                )
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
                .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 8)
            
            // Performance optimized task list with LazyVStack
            if !filteredTasks.isEmpty {
                LazyVStack(spacing: 12) {
                    ForEach(filteredTasks.indices, id: \.self) { index in
                        let task = filteredTasks[index]
                        StreamlinedTaskCard(
                            task: task,
                            onToggleComplete: {
                                taskManager.toggleTaskCompletion(task)
                            },
                            onTaskUpdate: { updatedTask in
                                taskManager.updateTask(updatedTask)
                            },
                            onTaskTap: {
                                // TODO: Navigate to task detail view
                                // For now, we'll just print the task title
                                print("Tapped on task: \(task.title)")
                            },
                            taskManager: taskManager
                        )
                        .id(task.id) // Stable identity for performance
                        .onAppear {
                            // Preload next tasks for smooth scrolling
                            if index == filteredTasks.count - 5 && filteredTasks.count > 10 {
                                // Trigger preload if needed
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 12)
            } else {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: emptyStateIcon)
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text(emptyStateTitle)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(emptyStateMessage)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.vertical, 40)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        // Base glass layer with 3D depth
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .opacity(0.4)
                        
                        // Inner highlight layer for 3D effect
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.25),
                                        .white.opacity(0.08),
                                        .clear,
                                        .black.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Outer stroke with glass shimmer
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.2),
                                        .white.opacity(0.05),
                                        .white.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                        
                        // Inner stroke for depth
                        RoundedRectangle(cornerRadius: 19)
                            .strokeBorder(
                                .white.opacity(0.1),
                                lineWidth: 0.5
                            )
                    }
                )
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
                .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 8)
                .padding(.top, 12)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var emptyStateIcon: String {
        switch selectedFilter {
        case .all: return "checkmark.circle.fill"
        case .today: return "calendar"
        case .highPriority: return "exclamationmark.triangle"
        case .completed: return "checkmark.circle"
        case .pending: return "clock"
        }
    }
    
    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all: return "No tasks yet"
        case .today: return "No tasks for today"
        case .highPriority: return "No high priority tasks"
        case .completed: return "No completed tasks"
        case .pending: return "No pending tasks"
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all: return "Tap 'Add' to create your first task"
        case .today: return "No tasks scheduled for today"
        case .highPriority: return "All caught up on high priority items!"
        case .completed: return "Complete some tasks to see them here"
        case .pending: return "All tasks are completed!"
        }
    }
}

// MARK: - Task List View

struct MoodLensTaskListView: View {
    let tasks: [Task]
    let onAddTask: () -> Void
    @ObservedObject var taskManager: TaskManager
    @State private var expandedTasks: Set<UUID> = []
    @State private var showingMoodSelector = false
    
    var moodOptimizedTasks: [Task] {
        // Get optimal task count based on current mood
        let optimalCount = taskManager.taskScheduler.getOptimalTaskCount(for: taskManager.currentMood)
        
        // Get mood-optimized tasks with adaptive count
        return taskManager.taskScheduler.optimizeTaskSchedule(tasks: tasks, maxTasks: optimalCount)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with mood indicator and optimization
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mood-Adaptive Tasks")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: taskManager.currentMood.icon)
                            .foregroundColor(taskManager.currentMood.color)
                            .font(.caption)
                        
                        Text("Tasks tailored for your \(taskManager.currentMood.displayName.lowercased()) energy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        taskManager.autoOptimizeTasks()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.primary)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    
                    Button(action: onAddTask) {
                        Image(systemName: "plus")
                            .foregroundColor(.primary)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                }
            }
            
            // Task list (matches web app layout)
            if moodOptimizedTasks.isEmpty {
                VStack(spacing: 16) {
                    Text("No tasks for today")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Button(action: onAddTask) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.body)
                                .fontWeight(.medium)
                            Text("Add a task")
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.1))
                                .background(.thinMaterial)
                        )
                    }
                }
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(moodOptimizedTasks) { task in
                        CompactTaskRowView(
                            task: task,
                            onToggleComplete: {
                                taskManager.toggleTaskCompletion(task)
                            },
                            taskManager: taskManager
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .opacity(0.2)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .white.opacity(0.5),
                                    .white.opacity(0.15),
                                    .white.opacity(0.08),
                                    .white.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .animation(.easeInOut(duration: 0.4), value: expandedTasks)
    }
}

// MARK: - Compact Task Row View

struct CompactTaskRowView: View {
    let task: Task
    let onToggleComplete: () -> Void
    @State private var waveOffset: CGFloat = 0
    @State private var waveRotation: Double = 0
    @State private var isExpanded: Bool = false
    @State private var expandAnimation: CGFloat = 0
    @State private var showingActionButtons = false
    @State private var longPressTimer: Timer?
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Main compact row - tappable to expand
            Button(action: {
                if !showingActionButtons {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
            }) {
                HStack(spacing: 12) {
                    // Completion button
                    Button(action: onToggleComplete) {
                        ZStack {
                            Circle()
                                .stroke(task.emotion.color, lineWidth: 2)
                                .frame(width: 24, height: 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.thinMaterial)
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
                    .onTapGesture {
                        onToggleComplete()
                    }
                    
                    // Task title
                    Text(task.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .strikethrough(task.isCompleted)
                        .opacity(task.isCompleted ? 0.6 : 1.0)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // Priority badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(priorityColor)
                            .frame(width: 6, height: 6)
                        
                        Text(priorityText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        ZStack {
                                            // Base glass layer for priority badge
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
                            
                            // Highlight layer for 3D glass effect
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.2),
                                            .white.opacity(0.06),
                                            .clear,
                                            .black.opacity(0.04)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            // Glass border
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.5),
                                            .white.opacity(0.15),
                                            .white.opacity(0.05),
                                            .white.opacity(0.25)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                    )
                    .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
                    .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
                    
                    // Expand indicator
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                                        // Base glass layer with 3D depth
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                        
                        // Inner highlight layer for 3D effect
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.25),
                                        .white.opacity(0.08),
                                        .clear,
                                        .black.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Outer stroke with glass shimmer
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.2),
                                        .white.opacity(0.05),
                                        .white.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                        
                        // Inner stroke for depth
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(
                                .white.opacity(0.1),
                                lineWidth: 0.5
                            )
                    }
                )
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
                .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PlainButtonStyle())
            .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 50) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingActionButtons = true
                }
            } onPressingChanged: { isPressing in
                if isPressing {
                    // Start long press timer
                    longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingActionButtons = true
                        }
                    }
                } else {
                    // Cancel timer if released early
                    longPressTimer?.invalidate()
                    longPressTimer = nil
                }
            }
            .overlay(
                // Action buttons overlay
                Group {
                    if showingActionButtons {
                        HStack(spacing: 12) {
                            // Edit button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showingActionButtons = false
                                    isExpanded = true
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text("Edit")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.white.opacity(0.6),
                                                            Color.white.opacity(0.2)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            
                            // Delete button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showingActionButtons = false
                                    taskManager.deleteTask(task)
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "trash")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text("Delete")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.red.opacity(0.6),
                                                            Color.red.opacity(0.2)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .opacity(0.9)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.6),
                                                    Color.white.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                , alignment: .center
            )
            
            // Expanded details
            if isExpanded {
                VStack(spacing: 12) {
                    // Description
                    if let description = task.description, !description.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "note.text")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Reminder info
                    if let reminderAt = task.reminderAt {
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text("Reminder: \(formatReminderTime(reminderAt))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 12)
                .background(
                    ZStack {
                                        // Base glass layer for expanded content
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
                        
                        // Inner highlight for glass effect
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.15),
                                        .white.opacity(0.05),
                                        .clear,
                                        .black.opacity(0.03)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Subtle border with glass shimmer
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.4),
                                        .white.opacity(0.15),
                                        .white.opacity(0.05),
                                        .white.opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                .shadow(color: .white.opacity(0.08), radius: 1, x: 0, y: -0.5)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95, anchor: .top).combined(with: .opacity),
                    removal: .scale(scale: 0.95, anchor: .top).combined(with: .opacity)
                ))
            }
        }
        .offset(y: waveOffset)
        .rotationEffect(.degrees(waveRotation))
        .onAppear {
            // Create wave-like floating animation with different timing for each task
            let delay = Double.random(in: 0...2)
            let duration = Double.random(in: 2.5...4.0)
            
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true).delay(delay)) {
                waveOffset = -8
            }
            
            withAnimation(.easeInOut(duration: duration * 1.5).repeatForever(autoreverses: true).delay(delay)) {
                waveRotation = 2
            }
        }
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
    
    private var priorityText: String {
        switch task.priority {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
    
    private func formatReminderTime(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        
        let daysUntil = calendar.dateComponents([.day], from: now, to: date).day ?? 0
        if daysUntil <= 7 && daysUntil > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, HH:mm"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

// MARK: - Task Row View

struct MoodLensTaskRowView: View {
    let task: Task
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onToggleComplete: () -> Void
    @State private var descriptionText: String
    @State private var reminderDate: Date
    @State private var foldAnimation: CGFloat = 0.0
    @State private var contentOpacity: Double = 0.0
    @ObservedObject var taskManager: TaskManager
    
    init(task: Task, isExpanded: Bool, onToggleExpand: @escaping () -> Void, onToggleComplete: @escaping () -> Void, taskManager: TaskManager) {
        self.task = task
        self.isExpanded = isExpanded
        self.onToggleExpand = onToggleExpand
        self.onToggleComplete = onToggleComplete
        self.taskManager = taskManager
        self._descriptionText = State(initialValue: task.description ?? "")
        self._reminderDate = State(initialValue: task.reminderAt ?? Date())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main task row with fold animation
            VStack(spacing: 0) {
                // Main task row - sits on top of background (tappable to expand)
                VStack(spacing: 16) {
                    // Row 1: Task title and completion button
                    HStack(spacing: 12) {
                        // Completion button
                        Button(action: onToggleComplete) {
                            ZStack {
                                Circle()
                                    .stroke(task.emotion.color, lineWidth: 2)
                                    .frame(width: 28, height: 28)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(.thinMaterial)
                                            .opacity(0.5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                
                                if task.isCompleted {
                                    Circle()
                                        .fill(task.emotion.color)
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                            }
                            .clipShape(Circle())
                        }
                        .onTapGesture {
                            onToggleComplete()
                        }
                        
                        // Task title
                        Text(task.title)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .strikethrough(task.isCompleted)
                            .opacity(task.isCompleted ? 0.6 : 1.0)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        // Expand indicator (no button, just visual)
                        if hasDetails {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.caption)
                                .frame(width: 28, height: 28)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.thinMaterial)
                                        .opacity(0.5)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .clipShape(Circle())
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                .animation(.easeInOut(duration: 0.3), value: isExpanded)
                        }
                    }
                    
                    // Row 2: Priority, emotion, and optimization status
                    HStack(spacing: 12) {
                        // Priority and emotion info
                        HStack(spacing: 8) {
                            // Priority badge
                            Text(task.priority.displayName)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(task.priority.color.opacity(0.3))
                                        .background(.thinMaterial)
                                        .opacity(0.6)
                                        .overlay(
                                            Capsule()
                                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            
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
                                    .fill(task.emotion.color.opacity(0.25))
                                    .background(.thinMaterial)
                                    .opacity(0.6)
                                    .overlay(
                                        Capsule()
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        Spacer()
                        
                        // Optimization status (full width badge)
                        if let reminderAt = task.reminderAt, reminderAt > Date(), !task.isCompleted {
                            HStack(spacing: 6) {
                                Image(systemName: "brain.head.profile")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                                Text("Intelligently Optimized")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.yellow)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.yellow.opacity(0.25))
                                    .background(.thinMaterial)
                                    .opacity(0.6)
                                    .overlay(
                                        Capsule()
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    
                    // Row 3: Status and reminder info
                    HStack(spacing: 12) {
                        // Status text
                        Text(task.isCompleted ? "Completed • Great job!" : "Active task")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        // Reminder info
                        if let reminderAt = task.reminderAt, !task.isCompleted {
                            HStack(spacing: 6) {
                                Image(systemName: "bell")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                Text(formatReminderTime(reminderAt))
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.05))
                                    .background(.thinMaterial)
                                    .opacity(0.6)
                                    .overlay(
                                        Capsule()
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                .padding(20)
                .background(
                    // Frosted glass effect for task rows
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.thinMaterial)
                        .opacity(0.6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.8),
                                            .white.opacity(0.3),
                                            .white.opacity(0.1),
                                            .white.opacity(0.6)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                .blur(radius: 1)
                        )
                        .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .overlay(
                    Rectangle()
                        .fill(task.emotion.color)
                        .frame(width: 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .opacity(task.isCompleted ? 0.75 : 1.0)
                .onTapGesture {
                    if hasDetails {
                        onToggleExpand()
                    }
                }
                
                // Fold-out expanded content
                if isExpanded && hasDetails {
                    VStack(spacing: 16) {
                        if let description = task.description, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .opacity(contentOpacity)
                        }
                        
                        // Combined editable card for notes and reminder
                        VStack(spacing: 16) {
                            // Notes section
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "note.text")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                    Text("Description")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                                
                                TextEditor(text: $descriptionText)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .frame(minHeight: 60)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.thinMaterial)
                                            .opacity(0.5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // Reminder section
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "clock")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                    Text("Reminder")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                                
                                DatePicker("", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                                    .colorScheme(.dark)
                                    .accentColor(.white)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.thinMaterial)
                                            .opacity(0.5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // Save button
                            Button(action: saveChanges) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text("Save Changes")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.thinMaterial)
                                        .opacity(0.6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.white.opacity(0.4), lineWidth: 1)
                                        )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.thinMaterial)
                                .opacity(0.6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .white.opacity(0.8),
                                                    .white.opacity(0.3),
                                                    .white.opacity(0.1),
                                                    .white.opacity(0.6)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                                        .blur(radius: 1)
                                )
                                .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                        .opacity(contentOpacity)
                    }
                    .padding(.top, 12)
                    .scaleEffect(y: foldAnimation, anchor: .top)
                    .clipped()
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.thinMaterial)
                    .opacity(0.1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(y: isExpanded ? 1.0 : 1.0, anchor: .top)
            .animation(.easeInOut(duration: 0.5), value: isExpanded)
            .onChange(of: isExpanded) { _, newValue in
                if newValue {
                    // Start fold-out animation
                    withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                        foldAnimation = 1.0
                    }
                    withAnimation(.easeInOut(duration: 0.4).delay(0.2)) {
                        contentOpacity = 1.0
                    }
                } else {
                    // Start fold-in animation
                    withAnimation(.easeInOut(duration: 0.2)) {
                        contentOpacity = 0.0
                    }
                    withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                        foldAnimation = 0.0
                    }
                }
            }
        }
    }
    
    private var hasDetails: Bool {
        // Always allow expansion for editing notes and reminders
        true
    }
    
    private func formatReminderTime(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        
        let daysUntil = calendar.dateComponents([.day], from: now, to: date).day ?? 0
        if daysUntil <= 7 && daysUntil > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, HH:mm"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
    
    private func formatFullReminderTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func saveChanges() {
        var updatedTask = task
        updatedTask.description = descriptionText.isEmpty ? nil : descriptionText
        updatedTask.reminderAt = reminderDate
        taskManager.updateTask(updatedTask)
        
        // Visual feedback
        withAnimation(.easeInOut(duration: 0.3)) {
            // The task will be updated through the TaskManager
        }
    }
}

// MARK: - Streamlined Task Card (2-Row Design)

struct StreamlinedTaskCard: View {
    let task: Task
    let onToggleComplete: () -> Void
    let onTaskUpdate: (Task) -> Void
    let onTaskTap: () -> Void
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        Button(action: onTaskTap) {
            VStack(spacing: 8) { // Added spacing between rows
                // Row 1: Completion + Title + Priority
                HStack(spacing: 12) {
                    // Completion button
                    Button(action: onToggleComplete) {
                        ZStack {
                            Circle()
                                .stroke(task.isCompleted ? task.emotion.color : .white.opacity(0.4), lineWidth: 2)
                                .frame(width: 24, height: 24)
                            
                            if task.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(task.emotion.color)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle()) // Prevent tap propagation
                    
                    // Task title
                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .strikethrough(task.isCompleted)
                        .opacity(task.isCompleted ? 0.6 : 1.0)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Mood indicator
                    HStack(spacing: 4) {
                        Image(systemName: task.emotion.icon)
                            .font(.caption2)
                            .foregroundColor(task.emotion.color)
                        
                        Text(task.emotion.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .opacity(0.4)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.25),
                                            .white.opacity(0.08),
                                            .clear,
                                            .black.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.6),
                                            .white.opacity(0.2),
                                            .white.opacity(0.05),
                                            .white.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                    )
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
                    .clipShape(Capsule())
                }
                
                // Row 2: Metadata + Tags + Time info
                HStack(spacing: 12) {
                // Creation date badge
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    Text("Created \(formatCreationDate(task.createdAt))")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    ZStack {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .opacity(0.3)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.15),
                                        .white.opacity(0.05),
                                        .clear,
                                        .black.opacity(0.02)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.4),
                                        .white.opacity(0.1),
                                        .white.opacity(0.02),
                                        .white.opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
                .shadow(color: .white.opacity(0.05), radius: 1, x: 0, y: -0.25)
                .clipShape(Capsule())
                
                // Tags (if any)
                if !task.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(task.tags.prefix(3), id: \.self) { tag in
                                HStack(spacing: 3) {
                                    Image(systemName: "tag.fill")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                    Text("#\(tag)")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    ZStack {
                                        Capsule()
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.3)
                                        
                                        Capsule()
                                            .strokeBorder(.blue.opacity(0.4), lineWidth: 1)
                                    }
                                )
                                .clipShape(Capsule())
                            }
                            
                            if task.tags.count > 3 {
                                Text("+\(task.tags.count - 3)")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Time info (reminder/deadline) - enhanced glassy design
                if let reminderAt = task.reminderAt {
                    HStack(spacing: 3) {
                        Image(systemName: "bell.fill") // Changed from clock.fill to bell.fill
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text(formatReminderShort(reminderAt)) // Use new compact format
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .opacity(0.4)
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.25),
                                            .white.opacity(0.08),
                                            .clear,
                                            .black.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.6),
                                            .white.opacity(0.2),
                                            .white.opacity(0.05),
                                            .white.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                    )
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
                    .clipShape(Capsule())
                } else if let deadlineAt = task.deadlineAt {
                    HStack(spacing: 3) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.caption2)
                            .foregroundColor(.red)
                        Text(formatReminderTime(deadlineAt))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .opacity(0.4)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.25),
                                            .white.opacity(0.08),
                                            .clear,
                                            .black.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.6),
                                            .white.opacity(0.2),
                                            .white.opacity(0.05),
                                            .white.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                    )
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
                    .clipShape(Capsule())
                }
            }
        }
        }
        .buttonStyle(PlainButtonStyle()) // Prevent default button styling
        .padding(.horizontal, 16)
        .padding(.top, 12) // Reduced by 2 more points
        .padding(.bottom, 14) // Reduced by 2 points
        .background(
            ZStack {
                // Base glass layer with 3D depth
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                
                // Inner highlight layer for 3D effect
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.25),
                                .white.opacity(0.08),
                                .clear,
                                .black.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Outer stroke with glass shimmer
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.2),
                                .white.opacity(0.05),
                                .white.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                
                // Inner stroke for depth
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(
                        .white.opacity(0.1),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(task.isCompleted ? 0.75 : 1.0)
        .scaleEffect(task.isCompleted ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
    }
    
    private func formatCreationDate(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "today"
        } else if calendar.isDateInYesterday(date) {
            return "yesterday"
        } else {
            let daysAgo = calendar.dateComponents([.day], from: date, to: now).day ?? 0
            if daysAgo <= 7 {
                return "\(daysAgo) days ago"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return formatter.string(from: date)
            }
        }
    }
    
    private func formatReminderTime(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        
        let daysUntil = calendar.dateComponents([.day], from: now, to: date).day ?? 0
        if daysUntil <= 7 && daysUntil > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, HH:mm"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }

    // Add a new helper for compact date formatting
    private func formatReminderShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.M.d, h:mm a"
        return formatter.string(from: date)
    }
}
