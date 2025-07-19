//
//  EnhancedTaskViews.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Enhanced Task List View

struct EnhancedTaskListView: View {
    @StateObject private var taskManager = TaskManager()
    @State private var selectedSmartList: SmartListType = .today
    @State private var selectedTaskList: TaskList?
    @State private var showingAddTaskModal = false
    @State private var showingAddListModal = false
    @State private var searchText = ""
    
    var filteredTasks: [Task] {
        let tasks = getTasksForCurrentView()
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
        NavigationView {
            VStack(spacing: 0) {
                // Top section with conditional height
                VStack(spacing: 0) {
                    // Search bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, selectedSmartList == .all ? 4 : 8)
                    
                    // Smart Lists
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(SmartListType.allCases, id: \.self) { smartList in
                                SmartListButton(
                                    type: smartList,
                                    isSelected: selectedSmartList == smartList,
                                    taskCount: getTaskCount(for: smartList),
                                    isCompact: selectedSmartList == .all
                                ) {
                                    selectedSmartList = smartList
                                    selectedTaskList = nil
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, selectedSmartList == .all ? 4 : 8)
                    
                    // Task Lists (if not in smart list)
                    if selectedSmartList == .all {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(taskManager.taskLists) { list in
                                    TaskListButton(
                                        list: list,
                                        isSelected: selectedTaskList?.id == list.id,
                                        taskCount: getTaskCount(for: list),
                                        isCompact: true
                                    ) {
                                        selectedTaskList = selectedTaskList?.id == list.id ? nil : list
                                    }
                                }
                                
                                // Add new list button
                                Button(action: { showingAddListModal = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus")
                                            .font(.caption2)
                                        Text("New List")
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(.white.opacity(0.1))
                                            .overlay(
                                                Capsule()
                                                    .stroke(.white.opacity(0.1), lineWidth: 0.5)
                                            )
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .frame(maxHeight: selectedSmartList == .all ? 100 : .infinity)
                
                // Task list
                if filteredTasks.isEmpty {
                    EmptyStateView(
                        title: getEmptyStateTitle(),
                        message: getEmptyStateMessage(),
                        actionTitle: "Add Task",
                        action: { showingAddTaskModal = true }
                    )
                    .frame(maxHeight: .infinity)
                    .padding(.vertical, selectedSmartList == .all ? 20 : 60)
                } else {
                    LazyVStack(spacing: selectedSmartList == .all ? 8 : 12) {
                        ForEach(filteredTasks) { task in
                            EnhancedTaskRowView(
                                task: task,
                                onToggleComplete: { taskManager.toggleTaskCompletion(task) },
                                onToggleFlag: { taskManager.toggleTaskFlag(task) },
                                onDelete: { taskManager.deleteTask(task) },
                                isAllTasksView: selectedSmartList == .all
                            )
                        }
                    }
                    .padding(.horizontal, selectedSmartList == .all ? 12 : 16)
                    .padding(.vertical, selectedSmartList == .all ? 4 : 8)
                    .frame(maxHeight: .infinity)
                }
                
                // Removed Spacer() to control layout precisely
            }
            .navigationTitle("Tasks")
            .navigationBarItems(trailing: Button(action: { showingAddTaskModal = true }) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
            })
        }
        .sheet(isPresented: $showingAddTaskModal) {
            AddTaskModalView()
        }
        .sheet(isPresented: $showingAddListModal) {
            AddTaskListView { list in
                taskManager.addTaskList(list)
            }
        }
    }
    
    private func getTasksForCurrentView() -> [Task] {
        switch selectedSmartList {
        case .today:
            return taskManager.todayTasks
        case .tomorrow:
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
            let dayAfter = Calendar.current.date(byAdding: .day, value: 2, to: Calendar.current.startOfDay(for: Date()))!
            return taskManager.tasks.filter { task in
                guard let reminderAt = task.reminderAt else { return false }
                return reminderAt >= tomorrow && reminderAt < dayAfter && !task.isCompleted
            }
        case .thisWeek:
            let today = Calendar.current.startOfDay(for: Date())
            let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!
            return taskManager.tasks.filter { task in
                guard let reminderAt = task.reminderAt else { return false }
                return reminderAt >= today && reminderAt < nextWeek && !task.isCompleted
            }
        case .upcoming:
            return taskManager.upcomingTasks
        case .important:
            return taskManager.importantTasks
        case .completed:
            return taskManager.completedTasks
        case .all:
            if let selectedList = selectedTaskList {
                return taskManager.tasks.filter { $0.list?.id == selectedList.id }
            } else {
                return taskManager.tasks.filter { !$0.isCompleted }
            }
        }
    }
    
    private func getTaskCount(for smartList: SmartListType) -> Int {
        switch smartList {
        case .today: return taskManager.todayTasks.count
        case .tomorrow:
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
            let dayAfter = Calendar.current.date(byAdding: .day, value: 2, to: Calendar.current.startOfDay(for: Date()))!
            return taskManager.tasks.filter { task in
                guard let reminderAt = task.reminderAt else { return false }
                return reminderAt >= tomorrow && reminderAt < dayAfter && !task.isCompleted
            }.count
        case .thisWeek:
            let today = Calendar.current.startOfDay(for: Date())
            let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!
            return taskManager.tasks.filter { task in
                guard let reminderAt = task.reminderAt else { return false }
                return reminderAt >= today && reminderAt < nextWeek && !task.isCompleted
            }.count
        case .upcoming: return taskManager.upcomingTasks.count
        case .important: return taskManager.importantTasks.count
        case .completed: return taskManager.completedTasks.count
        case .all: return taskManager.tasks.filter { !$0.isCompleted }.count
        }
    }
    
    private func getTaskCount(for list: TaskList) -> Int {
        return taskManager.tasks.filter { $0.list?.id == list.id && !$0.isCompleted }.count
    }
    
    private func getEmptyStateTitle() -> String {
        switch selectedSmartList {
        case .today: return "No tasks for today"
        case .tomorrow: return "No tasks for tomorrow"
        case .thisWeek: return "No tasks this week"
        case .upcoming: return "No upcoming tasks"
        case .important: return "No important tasks"
        case .completed: return "No completed tasks"
        case .all: return selectedTaskList != nil ? "No tasks in this list" : "No tasks yet"
        }
    }
    
    private func getEmptyStateMessage() -> String {
        switch selectedSmartList {
        case .today: return "Great job! You're all caught up for today."
        case .tomorrow: return "No tasks scheduled for tomorrow."
        case .thisWeek: return "No tasks scheduled for this week."
        case .upcoming: return "No tasks scheduled for the next 7 days."
        case .important: return "No tasks are marked as important."
        case .completed: return "Complete some tasks to see them here."
        case .all: return selectedTaskList != nil ? "Add some tasks to get started." : "Create your first task to get organized."
        }
    }
}

// MARK: - Enhanced Task Row View

struct EnhancedTaskRowView: View {
    let task: Task
    let onToggleComplete: () -> Void
    let onToggleFlag: () -> Void
    let onDelete: () -> Void
    let isAllTasksView: Bool
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main task row
            HStack(spacing: 12) {
                // Completion button
                Button(action: onToggleComplete) {
                    ZStack {
                        Circle()
                            .stroke(task.emotion.color, lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if task.isCompleted {
                            Circle()
                                .fill(task.emotion.color)
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // Task content
                VStack(alignment: .leading, spacing: isAllTasksView ? 2 : 4) {
                    HStack {
                        Text(task.title)
                            .font(isAllTasksView ? .subheadline : .body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .strikethrough(task.isCompleted)
                            .opacity(task.isCompleted ? 0.6 : 1.0)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Flag button
                        Button(action: onToggleFlag) {
                            Image(systemName: task.isFlagged ? "star.fill" : "star")
                                .foregroundColor(task.isFlagged ? .yellow : .white.opacity(0.5))
                                .font(.caption)
                        }
                    }
                    
                    // Task metadata
                    HStack(spacing: 8) {
                        // List indicator
                        if let list = task.list {
                            HStack(spacing: 4) {
                                Image(systemName: list.icon)
                                    .font(.caption2)
                                Text(list.name)
                                    .font(.caption2)
                            }
                            .foregroundColor(list.color)
                        }
                        
                        // Priority indicator
                        Circle()
                            .fill(task.priority.color)
                            .frame(width: 6, height: 6)
                        
                        // Emotion icon
                        Image(systemName: task.emotion.icon)
                            .font(.caption2)
                            .foregroundColor(task.emotion.color)
                        
                        // Tags
                        ForEach(task.tags.prefix(isAllTasksView ? 4 : 2), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(.white.opacity(0.1))
                                )
                        }
                        
                        // Recurring indicator
                        if task.isRecurring {
                            Image(systemName: "repeat")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        // Due date
                        if let reminderAt = task.reminderAt {
                            Text(formatReminderTime(reminderAt))
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    if isAllTasksView {
                        if let description = task.description, !description.isEmpty {
                            Text(description)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        if let notes = task.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                
                // Expand button (only if not in all tasks view or if there's more to show)
                if !isAllTasksView || (task.tags.count > 4 || (task.description?.count ?? 0) > 50) {
                    Button(action: { isExpanded.toggle() }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, isAllTasksView ? 8 : 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.thinMaterial)
                    .opacity(0.15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.15), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.05), radius: isAllTasksView ? 2 : 4, x: 0, y: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }
            
            // Expanded details
            if isExpanded {
                VStack(spacing: isAllTasksView ? 8 : 12) {
                    if let description = task.description, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Tags
                    if !task.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(task.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(.white.opacity(0.1))
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, isAllTasksView ? 8 : 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.thinMaterial)
                        .opacity(0.1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.1), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.02), radius: 2, x: 0, y: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
                .padding(.top, isAllTasksView ? 4 : 8)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95, anchor: .top).combined(with: .opacity),
                    removal: .scale(scale: 0.95, anchor: .top).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
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
