//
//  TasksView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI
import Combine

struct TasksView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    @State private var selectedFilter: TaskFilter = .today
    @State private var showingAddModal = false
    @State private var searchText = ""
    @State private var selectedTag: String? = nil
    @State private var keyboardHeight: CGFloat = 0
    let screenSize: CGSize
    
    // MARK: - Debug Screen Tracking
    init(taskManager: TaskManager, moodManager: MoodManager, screenSize: CGSize) {
        self.taskManager = taskManager
        self.moodManager = moodManager
        self.screenSize = screenSize
    }
    
    enum TaskFilter: String, CaseIterable {
        case today = "Today"
        case thisWeek = "This Week"
        case important = "Important"
        case completed = "Completed"
        
        var icon: String {
            switch self {
            case .today: return "sun.max"
            case .thisWeek: return "calendar.badge.clock"
            case .important: return "star"
            case .completed: return "checkmark.circle"
            }
        }
        
        var accentColor: Color {
            switch self {
            case .today: return .gentleYellow
            case .thisWeek: return .calmingBlue
            case .important: return .softViolet
            case .completed: return .peacefulGreen
            }
        }
    }
    
    var availableTags: [String] {
        let allTags = taskManager.tasks.flatMap { $0.tags }
        return Array(Set(allTags)).sorted()
    }
    
    var filteredTasks: [Task] {
        var tasks = getTasksForFilter()
        
        // Apply tag filter first
        if let selectedTag = selectedTag {
            tasks = tasks.filter { $0.tags.contains(selectedTag) }
        }
        
        // Then apply search filter
        if !searchText.isEmpty {
            tasks = tasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                (task.description?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                task.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return tasks
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Search and Filter Bar - Fixed position with keyboard awareness
                VStack(spacing: 12) {
                    // Search Bar with Add Button
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.6))
                        
                        TextField("Search tasks...", text: $searchText)
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        // Add button inside search bar
                        Button(action: { showingAddModal = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.calmingBlue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    
                    // Task Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TaskFilter.allCases, id: \.self) { filter in
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        selectedFilter = filter
                                    }
                                    HapticManager.shared.selection()
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: filter.icon)
                                            .font(.caption2)
                                            .foregroundColor(selectedFilter == filter ? filter.accentColor : .white.opacity(0.7))
                                        
                                        Text(filter.rawValue)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(selectedFilter == filter ? .white : .white.opacity(0.7))
                                        
                                        Text("(\(getTaskCount(for: filter)))")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(selectedFilter == filter ? filter.accentColor.opacity(0.2) : Color.clear)
                                            .overlay(
                                                Capsule()
                                                    .stroke(selectedFilter == filter ? filter.accentColor : Color.white.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    // Tag Filter Pills (if tags exist)
                    if !availableTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // All tags filter
                                Button(action: {
                                    selectedTag = nil
                                    HapticManager.shared.selection()
                                }) {
                                    Text("All Tags")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedTag == nil ? .blue : .white.opacity(0.7))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(selectedTag == nil ? Color.blue.opacity(0.2) : Color.clear)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(selectedTag == nil ? Color.blue : Color.white.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                }
                                
                                ForEach(availableTags, id: \.self) { tag in
                                    Button(action: {
                                        selectedTag = selectedTag == tag ? nil : tag
                                        HapticManager.shared.selection()
                                    }) {
                                        let isAITag = tag.hasPrefix("ai-")
                                        let tagColor: Color = isAITag ? .orange : .blue
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "tag.fill")
                                                .font(.caption2)
                                                .foregroundColor(selectedTag == tag ? tagColor : .white.opacity(0.7))
                                            
                                            Text(tag)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(selectedTag == tag ? .white : .white.opacity(0.7))
                                            
                                            Text("(\(getTaskCount(for: selectedFilter, tag: tag)))")
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(selectedTag == tag ? tagColor.opacity(0.2) : Color.clear)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(selectedTag == tag ? tagColor : Color.white.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, max(geometry.size.height * 0.08, 60))
                .padding(.bottom, 16)
                .background(Color.clear)
                
                // Tasks List
                if filteredTasks.isEmpty {
                    VStack(spacing: 24) {
                        Spacer()
                        
                        EmptyTasksView(filter: selectedFilter)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTasks) { task in
                                TaskCard(
                                    task: task,
                                    isExpanded: false,
                                    onToggleExpand: {},
                                    onToggleComplete: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                            taskManager.toggleTaskCompletion(task)
                                        }
                                        
                                        if !task.isCompleted {
                                            HapticManager.shared.success()
                                        } else {
                                            HapticManager.shared.impact(.light)
                                        }
                                    },
                                    onTaskUpdate: { updatedTask in
                                        taskManager.updateTask(updatedTask)
                                        HapticManager.shared.impact(.light)
                                    },
                                    onDelete: { taskToDelete in
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            taskManager.deleteTask(taskToDelete)
                                        }
                                        HapticManager.shared.notification(.success)
                                    },
                                    taskManager: taskManager
                                )
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                                    removal: .scale(scale: 0.95).combined(with: .opacity)
                                ))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, max(100, keyboardHeight)) // Keyboard-aware bottom padding
                    }
                }
                
                Spacer()
            }
            .background(
                UniversalBackground()
                    .ignoresSafeArea(.all)
            )
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardHeight = 0
            }
            .animation(nil, value: selectedFilter) // Prevent layout animations
            .animation(nil, value: selectedTag) // Prevent layout animations for tag changes
            .sheet(isPresented: $showingAddModal) {
                QuickAddTaskView(taskManager: taskManager, moodManager: moodManager)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(false)
            }
            .sheet(item: $taskManager.moodPickerTask, onDismiss: {
                if let task = taskManager.moodPickerTask {
                    taskManager.finalizeTaskCompletion(task, mood: nil)
                }
            }) { task in
                MoodPicker { mood in
                    taskManager.finalizeTaskCompletion(task, mood: mood)
                }
            }
            .onChange(of: selectedFilter) { oldFilter, newFilter in
                selectedTag = nil // Reset tag filter when main filter changes
                HapticManager.shared.impact(.light)
            }
        }
    }
    
    private func getTasksForFilter() -> [Task] {
        switch selectedFilter {
        case .today:
            return taskManager.tasks.filter { task in
                !task.isCompleted && (
                    Calendar.current.isDateInToday(task.createdAt) ||
                    (task.reminderAt != nil && Calendar.current.isDateInToday(task.reminderAt!)) ||
                    (task.deadlineAt != nil && Calendar.current.isDateInToday(task.deadlineAt!))
                )
            }
        case .thisWeek:
            let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
            let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek) ?? Date()
            return taskManager.tasks.filter { task in
                !task.isCompleted && (
                    (task.reminderAt != nil && task.reminderAt! >= startOfWeek && task.reminderAt! < endOfWeek) ||
                    (task.deadlineAt != nil && task.deadlineAt! >= startOfWeek && task.deadlineAt! < endOfWeek)
                )
            }
        case .important:
            return taskManager.tasks.filter { !$0.isCompleted && $0.priority == .high }
        case .completed:
            return taskManager.tasks.filter { $0.isCompleted }
        }
    }
    
    private func getTaskCount(for filter: TaskFilter) -> Int {
        switch filter {
        case .today:
            return taskManager.tasks.filter { task in
                !task.isCompleted && (
                    Calendar.current.isDateInToday(task.createdAt) ||
                    (task.reminderAt != nil && Calendar.current.isDateInToday(task.reminderAt!)) ||
                    (task.deadlineAt != nil && Calendar.current.isDateInToday(task.deadlineAt!))
                )
            }.count
        case .thisWeek:
            let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
            let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek) ?? Date()
            return taskManager.tasks.filter { task in
                !task.isCompleted && (
                    (task.reminderAt != nil && task.reminderAt! >= startOfWeek && task.reminderAt! < endOfWeek) ||
                    (task.deadlineAt != nil && task.deadlineAt! >= startOfWeek && task.deadlineAt! < endOfWeek)
                )
            }.count
        case .important:
            return taskManager.tasks.filter { !$0.isCompleted && $0.priority == .high }.count
        case .completed:
            return taskManager.tasks.filter { $0.isCompleted }.count
        }
    }
    
    private func getTaskCount(for filter: TaskFilter, tag: String) -> Int {
        let baseTasks = getTasksForFilter()
        return baseTasks.filter { $0.tags.contains(tag) }.count
    }
}

// MARK: - Empty Tasks View

struct EmptyTasksView: View {
    let filter: TasksView.TaskFilter
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer() // Push content to center
            
            Image(systemName: emptyStateIcon)
                .font(.system(size: 48))
                .foregroundColor(filter.accentColor.opacity(0.6))
            
            VStack(spacing: 8) {
                Text(emptyStateTitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(emptyStateMessage)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer() // Push content to center
            Spacer() // Extra spacer to account for bottom navigation
        }
        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.6) // Ensure enough height for centering
    }
    
    private var emptyStateIcon: String {
        switch filter {
        case .today: return "sun.max.fill"
        case .thisWeek: return "calendar"
        case .important: return "star.fill"
        case .completed: return "checkmark.circle.fill"
        }
    }
    
    private var emptyStateTitle: String {
        switch filter {
        case .today: return "Today is yours to shape"
        case .thisWeek: return "A fresh week awaits"
        case .important: return "You're crushing it!"
        case .completed: return "Time to celebrate wins"
        }
    }
    
    private var emptyStateMessage: String {
        switch filter {
        case .today: return "Every great day starts with intention. What will you create today?"
        case .thisWeek: return "The week is your canvas. Paint it with purpose and possibility."
        case .important: return "You've mastered what matters most. That's the mark of true focus."
        case .completed: return "Your accomplishments are waiting to inspire you. Complete some tasks to see them shine."
        }
    }
}
