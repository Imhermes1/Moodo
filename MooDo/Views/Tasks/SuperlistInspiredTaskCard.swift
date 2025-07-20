//
//  SuperlistInspiredTaskCard.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Superlist-Inspired Compact Task Card

struct SuperlistTaskCard: View {
    let task: Task
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onToggleComplete: () -> Void
    let onTaskUpdate: (Task) -> Void
    
    @State private var descriptionText: String
    @State private var reminderDate: Date
    @State private var deadlineDate: Date
    @State private var showingReminderPicker = false
    @State private var showingDeadlinePicker = false
    @State private var editingTitle: String
    @State private var selectedPriority: TaskPriority
    @State private var selectedEmotion: EmotionType
    @State private var tagText: String = ""
    @State private var editedTags: [String]
    @State private var showingActionButtons = false
    @State private var longPressTimer: Timer?
    @ObservedObject var taskManager: TaskManager
    
    // Performance optimization: Cache computed values
    private var hasReminder: Bool { task.reminderAt != nil }
    private var hasDeadline: Bool { task.deadlineAt != nil }
    private var priorityColor: Color {
        switch task.priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    init(task: Task, isExpanded: Bool, onToggleExpand: @escaping () -> Void, onToggleComplete: @escaping () -> Void, onTaskUpdate: @escaping (Task) -> Void, taskManager: TaskManager) {
        self.task = task
        self.isExpanded = isExpanded
        self.onToggleExpand = onToggleExpand
        self.onToggleComplete = onToggleComplete
        self.onTaskUpdate = onTaskUpdate
        self.taskManager = taskManager
        self._descriptionText = State(initialValue: task.description ?? "")
        self._reminderDate = State(initialValue: task.reminderAt ?? Date().addingTimeInterval(3600))
        self._deadlineDate = State(initialValue: task.deadlineAt ?? Date().addingTimeInterval(86400)) // Default to tomorrow
        self._editingTitle = State(initialValue: task.title)
        self._selectedPriority = State(initialValue: task.priority)
        self._selectedEmotion = State(initialValue: task.emotion)
        self._editedTags = State(initialValue: task.tags)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Background tap to dismiss action buttons
            if showingActionButtons {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingActionButtons = false
                        }
                    }
            }
            
            // Main card content - always visible
            VStack(spacing: 8) {
                // Row 1: Completion + Title + Priority
                HStack(spacing: 12) {
                    // Completion button
                    Button(action: onToggleComplete) {
                        ZStack {
                            Circle()
                                .stroke(task.isCompleted ? task.emotion.color : .white.opacity(0.4), lineWidth: 2)
                                .frame(width: 22, height: 22)
                            
                            if task.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(task.emotion.color)
                            }
                        }
                    }
                    
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
                    
                    // Priority indicator
                    priorityIndicator
                }
                
                // Row 2: Task metadata + Emotion badge
                HStack(spacing: 12) {
                    // Show creation date and list info instead of description
                    HStack(spacing: 8) {
                        Text("Created \(formatCreationDate(task.createdAt))")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                        
                        if let list = task.list {
                            Image(systemName: "folder")
                                .font(.caption2)
                                .foregroundColor(list.color.opacity(0.8))
                            Text(list.name)
                                .font(.caption2)
                                .foregroundColor(list.color.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Emotion badge
                    emotionBadge
                }
                
                // Row 3: Time info + Deadline + Tags + Actions
                HStack(spacing: 12) {
                    // Time info
                    timeInfoView
                    
                    // Deadline indicator (if exists)
                    if task.deadlineAt != nil {
                        deadlineIndicatorView
                    }
                    
                    Spacer()
                    
                    // Tags (if any)
                    if !task.tags.isEmpty {
                        tagView
                    }
                    
                    // Subtask indicator
                    if let subtasks = task.subtasks, !subtasks.isEmpty {
                        subtaskIndicator(count: subtasks.count)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.2),
                                        .white.opacity(0.1),
                                        .white.opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(task.isCompleted ? 0.75 : 1.0)
            .scaleEffect(task.isCompleted ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
            .onTapGesture {
                if !showingActionButtons {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        onToggleExpand()
                    }
                }
            }
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
                                    onToggleExpand()
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
            
            // Expanded content
            if isExpanded {
                expandedContent
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)).combined(with: .offset(y: -20)),
                        removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)).combined(with: .offset(y: -20))
                    ))
            }
        }
    }
    
    // MARK: - Subviews
    
    private var priorityIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(task.priority.color)
                .frame(width: 8, height: 8)
            
            Text(task.priority.displayName.prefix(1))
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(task.priority.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(task.priority.color.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(task.priority.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var emotionBadge: some View {
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
    }
    
    private var timeInfoView: some View {
        HStack(spacing: 6) {
            if let reminderAt = task.reminderAt {
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                
                Text(formatReminderTime(reminderAt))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            } else {
                Image(systemName: "calendar.badge.plus")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
                
                Text("No reminder")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(.white.opacity(0.05))
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var deadlineIndicatorView: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption2)
                .foregroundColor(isDeadlineOverdue(task.deadlineAt!) ? .red : .orange)
            
            Text(formatDeadlineTime(task.deadlineAt!))
                .font(.caption2)
                .foregroundColor(isDeadlineOverdue(task.deadlineAt!) ? .red : .orange)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(isDeadlineOverdue(task.deadlineAt!) ? .red.opacity(0.15) : .orange.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(isDeadlineOverdue(task.deadlineAt!) ? .red.opacity(0.3) : .orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var tagView: some View {
        HStack(spacing: 4) {
            Image(systemName: "tag")
                .font(.caption2)
            Text("\(task.tags.count)")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(.blue)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(.blue.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func subtaskIndicator(count: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "list.bullet.indent")
                .font(.caption2)
            Text("\(count)")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(.orange)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(.orange.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var expandedContent: some View {
        VStack(spacing: 16) {
            // Title editor
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "textformat")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                    Text("Title")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                TextField("Task title", text: $editingTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            
            // Description editor
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "text.alignleft")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                    Text("Description")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                TextField("Add a description...", text: $descriptionText, axis: .vertical)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .lineLimit(3...6)
            }
            
            // Priority and Emotion selectors
            HStack(spacing: 12) {
                // Priority selector
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                        Text("Priority")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 8, height: 8)
                                Text(priority.displayName)
                                    .foregroundColor(.white)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                
                // Emotion selector
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                        Text("Emotion")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Picker("Emotion", selection: $selectedEmotion) {
                        ForEach(EmotionType.allCases, id: \.self) { emotion in
                            HStack {
                                Image(systemName: emotion.icon)
                                    .foregroundColor(emotion.color)
                                Text(emotion.displayName)
                                    .foregroundColor(.white)
                            }
                            .tag(emotion)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
            
            // Tags editor
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "tag")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                    Text("Tags")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Current tags
                if !editedTags.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                        ForEach(editedTags, id: \.self) { tag in
                            HStack(spacing: 4) {
                                Text(tag)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                
                                Button(action: { removeTag(tag) }) {
                                    Image(systemName: "xmark")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(.blue.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(.blue.opacity(0.4), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                
                // Add new tag
                HStack {
                    TextField("Add tag", text: $tagText)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .onSubmit(addTag)
                    
                    Button(action: addTag) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .disabled(tagText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            
            // Reminder and Deadline section
            VStack(alignment: .leading, spacing: 12) {
                // Reminder section
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                        Text("Reminder")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    HStack {
                        Button(action: { showingReminderPicker.toggle() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                Text(formatFullReminderTime(reminderDate))
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        
                        if task.reminderAt != nil {
                            Button(action: clearReminder) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red.opacity(0.8))
                                    .font(.title3)
                            }
                        }
                    }
                    
                    if showingReminderPicker {
                        DatePicker("", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .colorScheme(.dark)
                            .accentColor(.white)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                }
                
                // Deadline section
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange.opacity(0.8))
                            .font(.caption)
                                                    Text("Due Date")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    HStack {
                        Button(action: { showingDeadlinePicker.toggle() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.caption)
                                Text(formatFullDeadlineTime(deadlineDate))
                                    .font(.subheadline)
                                    .foregroundColor(isDeadlineOverdue(deadlineDate) ? .red : .white)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isDeadlineOverdue(deadlineDate) ? .red.opacity(0.5) : .white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        
                        if task.deadlineAt != nil {
                            Button(action: clearDeadline) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red.opacity(0.8))
                                    .font(.title3)
                            }
                        }
                    }
                    
                    if showingDeadlinePicker {
                        DatePicker("", selection: $deadlineDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .colorScheme(.dark)
                            .accentColor(.white)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: saveChanges) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.caption)
                        Text("Save")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.green.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(.green.opacity(0.5), lineWidth: 1)
                            )
                    )
                }
                
                Button(action: { onToggleExpand() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.caption)
                        Text("Cancel")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.top, 8)
    }
    
    // MARK: - Helper Functions
    
    private func formatReminderTime(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Today \(formatter.string(from: date))"
        }
        
        let daysUntil = calendar.dateComponents([.day], from: now, to: date).day ?? 0
        if daysUntil == 1 {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Tomorrow \(formatter.string(from: date))"
        } else if daysUntil <= 7 && daysUntil > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "E HH:mm"
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
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func saveChanges() {
        var updatedTask = task
        updatedTask.title = editingTitle
        updatedTask.description = descriptionText.isEmpty ? nil : descriptionText
        updatedTask.reminderAt = reminderDate
        updatedTask.deadlineAt = deadlineDate
        updatedTask.priority = selectedPriority
        updatedTask.emotion = selectedEmotion
        updatedTask.tags = editedTags
        
        onTaskUpdate(updatedTask)
        showingReminderPicker = false
        showingDeadlinePicker = false
        onToggleExpand()
    }
    
    private func addTag() {
        let trimmedTag = tagText.trimmingCharacters(in: .whitespaces)
        if !trimmedTag.isEmpty && !editedTags.contains(trimmedTag) {
            editedTags.append(trimmedTag)
            tagText = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        editedTags.removeAll { $0 == tag }
    }
    
    private func formatCreationDate(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: now) {
            return "Today"
        }
        
        let daysAgo = calendar.dateComponents([.day], from: date, to: now).day ?? 0
        if daysAgo == 1 {
            return "Yesterday"
        } else if daysAgo <= 7 {
            return "\(daysAgo) days ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
    
    private func clearReminder() {
        var updatedTask = task
        updatedTask.reminderAt = nil
        onTaskUpdate(updatedTask)
    }
    
    private func clearDeadline() {
        var updatedTask = task
        updatedTask.deadlineAt = nil
        onTaskUpdate(updatedTask)
    }
    
    private func formatFullDeadlineTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDeadlineTime(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Today \(formatter.string(from: date))"
        }
        
        let daysUntil = calendar.dateComponents([.day], from: now, to: date).day ?? 0
        if daysUntil == 1 {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Tomorrow \(formatter.string(from: date))"
        } else if daysUntil <= 7 && daysUntil > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "E HH:mm"
            return formatter.string(from: date)
        } else if daysUntil < 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "Overdue \(formatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
    
    private func isDeadlineOverdue(_ date: Date) -> Bool {
        return date < Date()
    }
}

#Preview {
    VStack(spacing: 20) {
        SuperlistTaskCard(
            task: Task(
                title: "Design new app interface",
                description: "Create wireframes and mockups for the new dashboard",
                priority: .high,
                emotion: .creative,
                reminderAt: Date().addingTimeInterval(3600),
                tags: ["design", "urgent"]
            ),
            isExpanded: false,
            onToggleExpand: {},
            onToggleComplete: {},
            onTaskUpdate: { _ in },
            taskManager: TaskManager()
        )
        
        SuperlistTaskCard(
            task: Task(
                title: "Review pull requests",
                description: "Check and approve pending code reviews",
                isCompleted: true,
                priority: .medium,
                emotion: .focused,
                tags: ["code"]
            ),
            isExpanded: true,
            onToggleExpand: {},
            onToggleComplete: {},
            onTaskUpdate: { _ in },
            taskManager: TaskManager()
        )
    }
    .padding()
    .background(Color.black)
} 