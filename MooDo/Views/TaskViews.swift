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
    @StateObject private var taskManager = TaskManager()
    @State private var expandedTasks: Set<UUID> = []
    @State private var selectedFilter: TaskFilter = .all
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case highPriority = "High Priority"
        case completed = "Completed"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .today: return "calendar"
            case .highPriority: return "exclamationmark.triangle"
            case .completed: return "checkmark.circle"
            }
        }
    }
    
    var filteredTasks: [Task] {
        switch selectedFilter {
        case .all:
            return tasks
        case .today:
            return tasks.filter { Calendar.current.isDateInToday($0.reminderAt ?? Date()) }
        case .highPriority:
            return tasks.filter { $0.priority == .high }
        case .completed:
            return tasks.filter { $0.isCompleted }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("All Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onAddTask) {
                    Image(systemName: "plus")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.title3)
                        .fontWeight(.medium)
                }
            }
            
            // Filter tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        Button(action: { selectedFilter = filter }) {
                            HStack(spacing: 6) {
                                Image(systemName: filter.icon)
                                    .font(.caption)
                                Text(filter.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(selectedFilter == filter ? .white : .white.opacity(0.7))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == filter ? .white.opacity(0.3) : .white.opacity(0.15))
                                    .background(.regularMaterial)
                                    .opacity(0.6)
                                    .overlay(
                                        Capsule()
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // Task list
            if filteredTasks.isEmpty {
                VStack(spacing: 16) {
                    Text(emptyStateMessage)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                    
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
                                .fill(.white.opacity(0.1))
                                .background(.ultraThinMaterial)
                        )
                    }
                }
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(filteredTasks) { task in
                        MoodLensTaskRowView(
                            task: task,
                            isExpanded: expandedTasks.contains(task.id),
                            onToggleExpand: {
                                if expandedTasks.contains(task.id) {
                                    expandedTasks.remove(task.id)
                                } else {
                                    expandedTasks.insert(task.id)
                                }
                            },
                            onToggleComplete: {
                                taskManager.toggleTaskCompletion(task)
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
        .animation(.easeInOut(duration: 0.4), value: selectedFilter)
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all: return "No tasks yet"
        case .today: return "No tasks for today"
        case .highPriority: return "No high priority tasks"
        case .completed: return "No completed tasks"
        }
    }
}

// MARK: - Task List View

struct MoodLensTaskListView: View {
    let tasks: [Task]
    let onAddTask: () -> Void
    @StateObject private var taskManager = TaskManager()
    @State private var expandedTasks: Set<UUID> = []
    
    var moodOptimizedTasks: [Task] {
        // Update the task scheduler with current mood
        taskManager.taskScheduler.updateCurrentMood(taskManager.currentMood)
        
        // Get mood-optimized tasks for today
        let optimizedTasks = taskManager.taskScheduler.optimizeTaskSchedule(tasks: tasks)
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return optimizedTasks.filter { task in
            // Show tasks scheduled for today
            let isToday = task.reminderAt != nil && 
                         task.reminderAt! >= today && 
                         task.reminderAt! < tomorrow
            // Also show high priority tasks that aren't completed
            let isHighPriority = task.priority == .high && !task.isCompleted
            
            return isToday || isHighPriority
        }.sorted { task1, task2 in
            // Sort by priority first, then by reminder time
            if task1.priority == .high && task2.priority != .high {
                return true
            } else if task1.priority != .high && task2.priority == .high {
                return false
            } else {
                return (task1.reminderAt ?? Date.distantFuture) < (task2.reminderAt ?? Date.distantFuture)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header (matches web app)
            HStack {
                Text("Optimized Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onAddTask) {
                    Image(systemName: "plus")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.title3)
                        .fontWeight(.medium)
                }
            }
            
            // Task list (matches web app layout)
            if moodOptimizedTasks.isEmpty {
                VStack(spacing: 16) {
                    Text("No tasks for today")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Button(action: onAddTask) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.body)
                                .fontWeight(.medium)
                            Text("Add a task")
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.1))
                                .background(.ultraThinMaterial)
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Main compact row - tappable to expand
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
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
                                        .fill(.regularMaterial)
                                        .opacity(0.8)
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
                        .foregroundColor(.white)
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
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.regularMaterial)
                            .opacity(0.8)
                            .overlay(
                                Capsule()
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    
                    // Expand indicator
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.regularMaterial)
                        .opacity(0.8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded details
            if isExpanded {
                VStack(spacing: 12) {
                    // Description
                    if let description = task.description, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                    }
                    
                    // Notes
                    if let notes = task.notes, !notes.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "note.text")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.caption)
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Reminder info
                    if let reminderAt = task.reminderAt {
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.caption)
                            Text("Reminder: \(formatReminderTime(reminderAt))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                        .opacity(0.6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
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
}

// MARK: - Task Row View

struct MoodLensTaskRowView: View {
    let task: Task
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onToggleComplete: () -> Void
    @State private var notesText: String
    @State private var reminderDate: Date
    @State private var foldAnimation: CGFloat = 0.0
    @State private var contentOpacity: Double = 0.0
    @StateObject private var taskManager = TaskManager()
    
    init(task: Task, isExpanded: Bool, onToggleExpand: @escaping () -> Void, onToggleComplete: @escaping () -> Void) {
        self.task = task
        self.isExpanded = isExpanded
        self.onToggleExpand = onToggleExpand
        self.onToggleComplete = onToggleComplete
        self._notesText = State(initialValue: task.notes ?? "")
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
                                            .fill(.regularMaterial)
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
                                        .fill(.regularMaterial)
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
                                        .background(.regularMaterial)
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
                                    .background(.regularMaterial)
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
                                    .background(.regularMaterial)
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
                                    .fill(.white.opacity(0.15))
                                    .background(.regularMaterial)
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
                        .fill(.regularMaterial)
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
                                    Text("Notes")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                                
                                TextEditor(text: $notesText)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .background(Color.clear)
                                    .frame(minHeight: 60)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.regularMaterial)
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
                                            .fill(.regularMaterial)
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
                                        .fill(.regularMaterial)
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
                                .fill(.regularMaterial)
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
                    .fill(.ultraThinMaterial)
                    .opacity(0.15)
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
        updatedTask.notes = notesText.isEmpty ? nil : notesText
        updatedTask.reminderAt = reminderDate
        taskManager.updateTask(updatedTask)
        
        // Visual feedback
        withAnimation(.easeInOut(duration: 0.3)) {
            // The task will be updated through the TaskManager
        }
    }
} 

