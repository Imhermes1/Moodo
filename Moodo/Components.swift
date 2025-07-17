//
//  Components.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - MoodLens Mood Check-in Component

struct MoodLensMoodCheckinView: View {
    @State private var selectedMood: MoodType?
    @StateObject private var moodManager = MoodManager()
    
    let moodOptions: [(type: MoodType, icon: String, label: String)] = [
        (.positive, "face.smiling", "Positive"),
        (.calm, "leaf", "Calm"),
        (.focused, "brain.head.profile", "Focused"),
        (.stressed, "face.dashed", "Stressed"),
        (.creative, "lightbulb", "Creative")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("How are you feeling?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Start your day with a mood check-in")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Mood selection buttons
            HStack(spacing: 16) {
                ForEach(moodOptions, id: \.type) { moodOption in
                    MoodIndicatorButton(
                        mood: moodOption.type,
                        icon: moodOption.icon,
                        label: moodOption.label,
                        isSelected: selectedMood == moodOption.type
                    ) {
                        selectedMood = moodOption.type
                    }
                }
            }
            
            // Log mood button
            Button(action: logMood) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.body)
                    Text("Log Mood")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    GlassPanelBackground()
                )
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .disabled(selectedMood == nil)
            .opacity(selectedMood == nil ? 0.5 : 1.0)
        }
        .padding(32)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            // Magnifying glass effect
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.15),
                            .white.opacity(0.05),
                            .clear
                        ]),
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .opacity(0.6)
        )
    }
    
    private func logMood() {
        guard let mood = selectedMood else { return }
        
        let entry = MoodEntry(mood: mood)
        moodManager.addMoodEntry(entry)
        
        // Reset selection
        selectedMood = nil
    }
}

struct MoodIndicatorButton: View {
    let mood: MoodType
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(mood.color)
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                    )
                    .shadow(
                        color: mood.color.opacity(0.4),
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: isSelected ? 6 : 4
                    )
                
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.medium)
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - MoodLens Task List Component

struct MoodLensTaskListView: View {
    let tasks: [Task]
    let onAddTask: () -> Void
    @StateObject private var taskManager = TaskManager()
    @State private var expandedTasks: Set<UUID> = []
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("Today's Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onAddTask) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.title3)
                        .frame(width: 40, height: 40)
                        .background(
                            GlassPanelBackground()
                        )
                        .clipShape(Circle())
                }
            }
            
            // Task list
            if tasks.isEmpty {
                VStack(spacing: 16) {
                    Text("No tasks yet")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Button(action: onAddTask) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.body)
                            Text("Add your first task")
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            GlassPanelBackground()
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                }
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(tasks) { task in
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
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct MoodLensTaskRowView: View {
    let task: Task
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onToggleComplete: () -> Void
    
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
                                .foregroundColor(.white)
                                .font(.caption)
                                .fontWeight(.bold)
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
                    
                    HStack(spacing: 8) {
                        Text(task.isCompleted ? "Completed • Great job!" : "\(task.priority.displayName) priority • \(task.emotion.displayName)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        if let reminderAt = task.reminderAt, !task.isCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "bell")
                                    .font(.caption2)
                                Text(formatReminderTime(reminderAt))
                                    .font(.caption2)
                            }
                            .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                
                Spacer()
                
                // Expand button and emotion indicator
                HStack(spacing: 8) {
                    if hasDetails {
                        Button(action: onToggleExpand) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.white)
                                .font(.caption)
                                .frame(width: 24, height: 24)
                                .background(
                                    GlassPanelBackground()
                                )
                                .clipShape(Circle())
                        }
                    }
                    
                    // Emotion color dot
                    Circle()
                        .fill(task.emotion.color)
                        .frame(width: 12, height: 12)
                    
                    // Emotion icon
                    Image(systemName: task.emotion.icon)
                        .foregroundColor(task.emotion.color)
                        .font(.caption)
                }
            }
            .padding(16)
            .background(
                GlassPanelBackground()
            )
            .overlay(
                Rectangle()
                    .fill(task.emotion.color)
                    .frame(width: 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .opacity(task.isCompleted ? 0.75 : 1.0)
            
            // Expanded details
            if isExpanded && hasDetails {
                VStack(spacing: 12) {
                    if let description = task.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if let notes = task.notes {
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
                            
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(12)
                        .background(
                            GlassPanelBackground()
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    if let reminderAt = task.reminderAt {
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
                            
                            Text(formatFullReminderTime(reminderAt))
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                            
                            if let naturalLanguageInput = task.naturalLanguageInput {
                                Text("Original: \"\(naturalLanguageInput)\"")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(12)
                        .background(
                            GlassPanelBackground()
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(
                    GlassPanelBackground()
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
    
    private var hasDetails: Bool {
        task.description != nil || task.notes != nil || task.reminderAt != nil
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
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatFullReminderTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Wellness Prompt Component

struct WellnessPromptView: View {
    @State private var currentPrompt = "What's one thing you're grateful for today?"
    
    let prompts = [
        "What's one thing you're grateful for today?",
        "How can you be kinder to yourself today?",
        "What's a small win you had recently?",
        "What would make today feel successful?",
        "How are you taking care of yourself today?"
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Text("Wellness Prompt")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: changePrompt) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                }
            }
            
            Text(currentPrompt)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private func changePrompt() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPrompt = prompts.randomElement() ?? currentPrompt
        }
    }
}

// MARK: - Quick Stats Component

struct QuickStatsView: View {
    let tasks: [Task]
    let moodEntries: [MoodEntry]
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var totalTasksCount: Int {
        tasks.count
    }
    
    var averageMood: Double {
        guard !moodEntries.isEmpty else { return 0 }
        let moodValues = moodEntries.map { moodValue(for: $0.mood) }
        return Double(moodValues.reduce(0, +)) / Double(moodEntries.count)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Quick Stats")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Tasks",
                    value: "\(completedTasksCount)/\(totalTasksCount)",
                    subtitle: "Completed",
                    color: Color(red: 0.22, green: 0.56, blue: 0.94) // mood-blue
                )
                
                StatCard(
                    title: "Mood",
                    value: String(format: "%.1f", averageMood),
                    subtitle: "Average",
                    color: Color(red: 0.22, green: 0.69, blue: 0.42) // mood-green
                )
            }
        }
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private func moodValue(for mood: MoodType) -> Int {
        switch mood {
        case .positive: return 5
        case .calm: return 4
        case .focused: return 3
        case .stressed: return 2
        case .creative: return 4
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(color.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Voice Check-in Components

struct VoiceCheckinView: View {
    let tasks: [Task]
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    @State private var transcript = ""
    @StateObject private var voiceManager = VoiceCheckinManager()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "mic")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text("Voice Check-in")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Recording button
                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? .red : .white.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .foregroundColor(isRecording ? .white : .white)
                            .font(.title)
                    }
                }
                
                // Recording time
                if isRecording {
                    Text(timeString(from: recordingTime))
                        .font(.title2)
                        .foregroundColor(.white)
                        .onReceive(timer) { _ in
                            recordingTime += 1
                        }
                }
                
                // Instructions
                Text(isRecording ? "Tap to stop recording" : "Tap to start recording")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Sample transcript
            if !transcript.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transcript:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(transcript)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private func toggleRecording() {
        isRecording.toggle()
        
        if isRecording {
            recordingTime = 0
            transcript = ""
        } else {
            // Simulate transcript
            transcript = "I'm feeling good today. I completed my morning workout and I'm ready to tackle the day ahead."
            
            // Save voice check-in
            let checkin = VoiceCheckin(
                transcript: transcript,
                duration: recordingTime
            )
            voiceManager.addVoiceCheckin(checkin)
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct VoiceCheckinHistoryView: View {
    @StateObject private var voiceManager = VoiceCheckinManager()
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Voice History")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if voiceManager.voiceCheckins.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "mic.slash")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("No voice check-ins yet")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(voiceManager.voiceCheckins.prefix(3)) { checkin in
                        VoiceCheckinRowView(checkin: checkin)
                    }
                }
            }
        }
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct VoiceCheckinRowView: View {
    let checkin: VoiceCheckin
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(checkin.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("\(Int(checkin.duration))s")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text(checkin.transcript)
                .font(.body)
                .foregroundColor(.white)
                .lineLimit(3)
        }
        .padding(16)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Mood History Component

struct MoodHistoryView: View {
    let moodEntries: [MoodEntry]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.mint)
                    .font(.title2)
                
                Text("Mood History")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if moodEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("No mood entries yet")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(moodEntries.prefix(5)) { entry in
                        MoodEntryRowView(entry: entry)
                    }
                }
            }
        }
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct MoodEntryRowView: View {
    let entry: MoodEntry
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.mood.icon)
                .foregroundColor(entry.mood.color)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.mood.displayName)
                    .font(.body)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Add Task Modal

struct AddTaskModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var notes = ""
    @State private var priority: TaskPriority = .medium
    @State private var emotion: EmotionType = .focused
    @State private var reminderAt: Date = Date()
    @State private var hasReminder = false
    @StateObject private var taskManager = TaskManager()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task title", text: $title)
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Emotion") {
                    Picker("Emotion", selection: $emotion) {
                        ForEach(EmotionType.allCases, id: \.self) { emotion in
                            Label(emotion.displayName, systemImage: emotion.icon)
                                .foregroundColor(emotion.color)
                                .tag(emotion)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Reminder") {
                    Toggle("Set reminder", isOn: $hasReminder)
                    
                    if hasReminder {
                        DatePicker("Reminder time", selection: $reminderAt, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        let task = Task(
            title: title,
            description: description.isEmpty ? nil : description,
            notes: notes.isEmpty ? nil : notes,
            priority: priority,
            emotion: emotion,
            reminderAt: hasReminder ? reminderAt : nil
        )
        
        taskManager.addTask(task)
        dismiss()
    }
} 