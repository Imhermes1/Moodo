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
            // Header (matches web app exactly)
            VStack(spacing: 8) {
                Text("How are you feeling?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Start your day with a mood check-in")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Mood selection buttons (matches web app layout)
            HStack(spacing: 16) {
                ForEach(moodOptions, id: \.type) { moodOption in
                    MoodIndicatorButton(
                        mood: moodOption.type,
                        icon: moodOption.icon,
                        label: moodOption.label,
                        isSelected: selectedMood == moodOption.type,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedMood = moodOption.type
                            }
                        },
                        size: 56
                    )
                }
            }
            
            // Log mood button (matches web app style)
            Button(action: logMood) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.body)
                        .fontWeight(.medium)
                    Text("Log Mood")
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
            .disabled(selectedMood == nil)
            .opacity(selectedMood == nil ? 0.5 : 1.0)
            .scaleEffect(selectedMood == nil ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
        }
        .padding(28)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private func logMood() {
        guard let mood = selectedMood else { return }
        
        let entry = MoodEntry(mood: mood)
        moodManager.addMoodEntry(entry)
        
        // Reset selection with animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            selectedMood = nil
        }
    }
}

struct MoodIndicatorButton: View {
    let mood: MoodType
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    let size: CGFloat
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(mood.color)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(isSelected ? 0.6 : 0.3), lineWidth: isSelected ? 3 : 1.5)
                    )
                    .shadow(
                        color: mood.color.opacity(isSelected ? 0.6 : 0.3),
                        radius: isSelected ? 16 : 8,
                        x: 0,
                        y: isSelected ? 8 : 4
                    )
                
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: size * 0.4, weight: .medium))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
            }
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
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
        VStack(spacing: 20) {
            // Header (matches web app)
            HStack {
                Text("Today's Tasks")
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
            if tasks.isEmpty {
                VStack(spacing: 16) {
                    Text("No tasks yet")
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
        VStack(spacing: 20) {
            HStack {
                Text("Check-in History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if voiceManager.voiceCheckins.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "message.circle")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 64, weight: .light))
                    
                    VStack(spacing: 8) {
                        Text("No voice check-ins yet")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Start your first daily check-in to see your conversation history here")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(voiceManager.voiceCheckins.prefix(3)) { checkin in
                        VoiceCheckinRowView(checkin: checkin)
                    }
                }
            }
        }
        .padding(28)
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
    @State private var naturalLanguageInput = ""
    @State private var showingSmartInput = false
    @StateObject private var taskManager = TaskManager()
    @StateObject private var nlpProcessor = NaturalLanguageProcessor()
    @StateObject private var voiceRecognition = VoiceRecognitionManager()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Smart Input") {
                    Button(action: { showingSmartInput = true }) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.purple)
                            Text("Use Smart Input")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    if !naturalLanguageInput.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Natural Language Input:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(naturalLanguageInput)
                                .font(.body)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                
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
            .sheet(isPresented: $showingSmartInput) {
                SmartInputView(
                    naturalLanguageInput: $naturalLanguageInput,
                    processedTask: Binding(
                        get: { nil },
                        set: { processedTask in
                            if let task = processedTask {
                                title = task.title
                                description = task.description ?? ""
                                priority = task.priority
                                emotion = task.emotion
                                if let reminder = task.reminderAt {
                                    reminderAt = reminder
                                    hasReminder = true
                                }
                            }
                        }
                    ),
                    voiceRecognition: voiceRecognition,
                    nlpProcessor: nlpProcessor
                )
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
            reminderAt: hasReminder ? reminderAt : nil,
            naturalLanguageInput: naturalLanguageInput.isEmpty ? nil : naturalLanguageInput
        )
        
        taskManager.addTask(task)
        dismiss()
    }
}

// In SmartInputView, wrap main VStack in ScrollView for better fit
struct SmartInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var naturalLanguageInput: String
    @Binding var processedTask: ProcessedTask?
    @StateObject var voiceRecognition: VoiceRecognitionManager
    @StateObject var nlpProcessor: NaturalLanguageProcessor
    @State private var textInput = ""
    @State private var showingVoiceInput = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    // Header
                    VStack(spacing: 6) {
                        Image(systemName: "brain.head.profile")
                            .font(.title)
                            .foregroundColor(.purple)
                        
                        Text("Smart Task Creation")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Describe your task naturally and let AI help you organize it")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity)
                    
                    // Input methods
                    VStack(spacing: 10) {
                        // Text input
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Type your task:")
                                .font(.subheadline)
                            
                            TextField("e.g., 'Remind me to call mom tomorrow at 3pm'", text: $textInput, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(2...4)
                                .font(.footnote)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Voice input
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Or use voice:")
                                .font(.subheadline)
                            
                            Button(action: {
                                if voiceRecognition.isRecording {
                                    voiceRecognition.stopRecording()
                                } else {
                                    voiceRecognition.startRecording()
                                }
                            }) {
                                HStack {
                                    Image(systemName: voiceRecognition.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                        .font(.title3)
                                    Text(voiceRecognition.isRecording ? "Stop Recording" : "Start Voice Input")
                                        .font(.footnote)
                                }
                                .foregroundColor(voiceRecognition.isRecording ? .red : .blue)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(8)
                            }
                            .disabled(!voiceRecognition.isAuthorized)
                            
                            if !voiceRecognition.transcript.isEmpty {
                                Text("Transcript: \(voiceRecognition.transcript)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(6)
                                    .background(Color.gray.opacity(0.08))
                                    .cornerRadius(6)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity)
                    
                    // Process button
                    Button(action: processInput) {
                        HStack {
                            if nlpProcessor.isProcessing {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text(nlpProcessor.isProcessing ? "Processing..." : "Process with AI")
                                .font(.footnote)
                        }
                        .foregroundColor(.white)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(8)
                    }
                    .disabled(textInput.isEmpty && voiceRecognition.transcript.isEmpty || nlpProcessor.isProcessing)
                    .padding(.horizontal, 4)
                    
                    // Processing results
                    if !nlpProcessor.processedText.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("AI Analysis:")
                                    .font(.subheadline)
                                
                                Text(nlpProcessor.processedText)
                                    .font(.footnote)
                                    .padding(6)
                                    .background(Color.gray.opacity(0.08))
                                    .cornerRadius(6)
                            }
                            .padding(.horizontal, 4)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Spacer(minLength: 10)
                }
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Smart Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Use This") {
                        useProcessedTask()
                    }
                    .disabled(processedTask == nil)
                }
            }
        }
    }
    
    private func processInput() {
        let input = textInput.isEmpty ? voiceRecognition.transcript : textInput
        guard !input.isEmpty else { return }
        
        naturalLanguageInput = input
        let task = nlpProcessor.processNaturalLanguage(input)
        processedTask = task
    }
    
    private func useProcessedTask() {
        dismiss()
    }
}

// MARK: - Smart Insights Views

struct SmartInsightsView: View {
    let insights: [Insight]
    
    var body: some View {
        if !insights.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.purple)
                        .font(.title3)
                    Text("Smart Insights")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                LazyVStack(spacing: 8) {
                    ForEach(insights) { insight in
                        InsightCardView(insight: insight)
                    }
                }
            }
        }
    }
}

struct InsightCardView: View {
    let insight: Insight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: insight.icon)
                    .foregroundColor(insight.color)
                    .font(.title3)
                
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(insight.type.displayName)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(insight.color.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            Text(insight.description)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("💡 Recommendation:")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(insight.recommendation)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(12)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SmartSuggestionsView: View {
    let suggestions: [TaskSuggestion]
    
    var body: some View {
        if !suggestions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb")
                        .foregroundColor(.yellow)
                        .font(.title3)
                    Text("Smart Suggestions")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                LazyVStack(spacing: 8) {
                    ForEach(suggestions.prefix(3)) { suggestion in
                        TaskSuggestionCardView(suggestion: suggestion)
                    }
                }
            }
        }
    }
}

struct TaskSuggestionCardView: View {
    let suggestion: TaskSuggestion
    @StateObject private var taskManager = TaskManager()
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: suggestion.emotion.icon)
                .foregroundColor(suggestion.emotion.color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(suggestion.description)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {
                let task = Task(
                    title: suggestion.title,
                    description: suggestion.description,
                    notes: nil,
                    priority: suggestion.priority,
                    emotion: suggestion.emotion,
                    reminderAt: nil
                )
                taskManager.addTask(task)
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            }
        }
        .padding(12)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension InsightType {
    var displayName: String {
        switch self {
        case .mood:
            return "Mood"
        case .productivity:
            return "Productivity"
        case .wellness:
            return "Wellness"
        }
    }
}

// MARK: - Body Scan Component (matches web app)

struct BodyScanView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.pink)
                    .font(.title2)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Body Scan")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Connect with yourself")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            
            Text("Starting from your toes, notice how each part of your body feels right now.")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                    Text("Start Body Scan")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.3)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Today's Progress Component (matches web app with animated counters)

struct TodaysProgressView: View {
    let tasks: [Task]
    let moodEntries: [MoodEntry]
    
    @State private var animatedTasksCount: Int = 0
    @State private var animatedMindfulCount: Int = 0
    @State private var animatedMoodCount: Int = 0
    @State private var animatedWellnessScore: Int = 0
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var mindfulMomentsCount: Int {
        3 // Mock data matching web app
    }
    
    var moodCheckinsCount: Int {
        moodEntries.count
    }
    
    var wellnessScore: Int {
        0 // Mock data matching web app
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Today's Progress")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ProgressCard(
                    title: "Tasks Done",
                    value: animatedTasksCount,
                    color: Color.green,
                    isPercentage: false
                )
                
                ProgressCard(
                    title: "Mindful Moments", 
                    value: animatedMindfulCount,
                    color: Color.blue,
                    isPercentage: false
                )
                
                ProgressCard(
                    title: "Mood Check-ins",
                    value: animatedMoodCount,
                    color: Color.purple,
                    isPercentage: false
                )
                
                ProgressCard(
                    title: "Wellness Score",
                    value: animatedWellnessScore,
                    color: Color.orange,
                    isPercentage: true
                )
            }
        }
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear {
            animateCounters()
        }
    }
    
    private func animateCounters() {
        withAnimation(.easeOut(duration: 1.0)) {
            animatedTasksCount = completedTasksCount
        }
        
        withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
            animatedMindfulCount = mindfulMomentsCount
        }
        
        withAnimation(.easeOut(duration: 1.4).delay(0.4)) {
            animatedMoodCount = moodCheckinsCount
        }
        
        withAnimation(.easeOut(duration: 1.6).delay(0.6)) {
            animatedWellnessScore = wellnessScore
        }
    }
}

struct ProgressCard: View {
    let title: String
    let value: Int
    let color: Color
    let isPercentage: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text("\(value)\(isPercentage ? "%" : "")")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .background(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Mindful Moment Component (matches web app)

struct MindfulMomentView: View {
    @State private var breathingScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mindful Moment")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Take a gentle break")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            
            Text("Take three deep breaths and notice the sounds around you. This moment is yours to enjoy.")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                        .scaleEffect(breathingScale)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: breathingScale)
                    Text("Start 2-min session")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.purple.opacity(0.3),
                            Color.pink.opacity(0.3)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear {
            breathingScale = 1.2
        }
    }
}

// MARK: - Daily Voice Check-in Component (matches web app)

struct DailyVoiceCheckinView: View {
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon and title
            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 64, weight: .medium))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .scaleEffect(pulseScale)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseScale)
                    )
                
                VStack(spacing: 8) {
                    Text("Daily Voice Check-in")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Start a 3-5 minute conversation with your AI therapist friend. Share how you're feeling and get personalized task recommendations.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }
            
            // Start button
            Button(action: {}) {
                HStack(spacing: 12) {
                    Image(systemName: "message.circle.fill")
                        .font(.title2)
                    Text("Start Daily Check-in")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.4),
                            Color.cyan.opacity(0.4)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .padding(32)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear {
            pulseScale = 1.1
        }
    }
}

// MARK: - Mood History Detailed Component (matches web app)

struct MoodHistoryDetailedView: View {
    let moodEntries: [MoodEntry]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Mood History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text("This Week")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("No entries yet")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Button(action: {}) {
                Text("View Detailed History")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.1))
                    )
            }
        }
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
} 