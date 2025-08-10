//
//  TasksView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct TasksView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    @State private var selectedFilter: TaskFilter = .today
    @State private var showingAddModal = false
    @State private var searchText = ""
    @State private var isSearching = false
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
    
    var filteredTasks: [Task] {
        let tasks = getTasksForFilter()
        
        if searchText.isEmpty {
            return tasks
        } else {
            return tasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                (task.description?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                task.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // ScrollView for tasks
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    if filteredTasks.isEmpty {
                        EmptyTasksView(filter: selectedFilter)
                            .frame(maxWidth: .infinity)
                    } else {
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
                                        // Completing a task
                                        HapticManager.shared.success()
                                    } else {
                                        // Uncompleting a task
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
                }
                .padding(.horizontal, 20)
                .padding(.top, isSearching ? 135 : 95) // Increased by 10 more points for better clearance
                .padding(.bottom, 100) // Space for floating button
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Header (search bar, filter pills) floating above scrollview
            VStack(spacing: 0) {
                if isSearching {
                    SearchBarView(text: $searchText, isSearching: $isSearching)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Search button
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isSearching.toggle()
                                if !isSearching {
                                    searchText = ""
                                }
                            }
                            HapticManager.shared.impact(.light)
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.caption)
                                .foregroundColor(isSearching ? .calmingBlue : .white.opacity(0.7))
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(Color.clear)
                                        .overlay(
                                            Circle()
                                                .stroke(isSearching ? Color.calmingBlue : .clear, lineWidth: 1.5)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black, lineWidth: 0.8)
                                        )
                                )
                        }
                        ForEach(TaskFilter.allCases, id: \.self) { filter in
                            FilterPillView(
                                filter: filter,
                                isSelected: selectedFilter == filter,
                                taskCount: getTaskCount(for: filter)
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedFilter = filter
                                }
                                HapticManager.shared.selection()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .padding(.top, max(screenSize.height * 0.05, 30)) // Move filters up a bit more
            // No background here, transparent so UniversalBackground shows through
            
            // Floating Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingAddButton {
                        HapticManager.shared.impact(.medium)
                        showingAddModal = true
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 90) // Above bottom nav
                }
            }
        }
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
            HapticManager.shared.impact(.light)
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
            let completedTasks = taskManager.getCompletedTasks()
            return completedTasks
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
    
    // MARK: - Filter Pill View
    
    struct FilterPillView: View {
        let filter: TasksView.TaskFilter
        let isSelected: Bool
        let taskCount: Int
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 6) {
                    Image(systemName: filter.icon)
                        .font(.caption2)
                        .foregroundColor(isSelected ? filter.accentColor : .white.opacity(0.7))
                    
                    Text(filter.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    
                    Text("(\(taskCount))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.clear)
                        .overlay(
                            Capsule()
                                .stroke(
                                    isSelected ? filter.accentColor : .white.opacity(0.3),
                                    lineWidth: 1.5
                                )
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.black, lineWidth: 0.8)
                        )
                )
            }
        }
    }
    
    // MARK: - Search Bar View
    
    struct SearchBarView: View {
        @Binding var text: String
        @Binding var isSearching: Bool
        
        var body: some View {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.caption)
                
                TextField("Search your tasks...", text: $text)
                    .foregroundColor(.white)
                    .font(.body)
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        HapticManager.shared.impact(.light)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.calmingBlue.opacity(0.5), lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 0.9)
                    )
            )
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
            case .today: return "Your day looks peaceful"
            case .thisWeek: return "Week ahead is clear"
            case .important: return "All caught up!"
            case .completed: return "Ready to celebrate?"
            }
        }
        
        private var emptyStateMessage: String {
            switch filter {
            case .today: return "Take a moment to breathe. Add a task when you're ready."
            case .thisWeek: return "No pressure! Plan your week at your own pace."
            case .important: return "You're on top of your priorities. Well done!"
            case .completed: return "Complete some tasks to see your accomplishments here."
            }
        }
    }
    
    // MARK: - Floating Add Button
    
    struct FloatingAddButton: View {
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Image(systemName: "plus")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color.calmingBlue)
                            .overlay(
                                Circle()
                                    .stroke(Color.calmingBlue.opacity(0.3), lineWidth: 2)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 1.0)
                            )
                            .shadow(color: Color.calmingBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
            }
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: 1.0)
        }
    }
    
    /*
     #Preview {
     TasksView(
     taskManager: TaskManager(),
     moodManager: MoodManager(),
     screenSize: CGSize(width: 390, height: 844)
     )
     }
     */
}
