//
//  Components.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Mood Check-in Component

struct MoodCheckinView: View {
    @State private var selectedMood: MoodType?
    @State private var intensity: Double = 5
    @State private var notes: String = ""
    @State private var showingMoodPicker = false
    @StateObject private var moodManager = MoodManager()
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                    .font(.title2)
                
                Text("How are you feeling?")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            // Mood Selection
            VStack(spacing: 12) {
                if let selectedMood = selectedMood {
                    HStack {
                        Text(selectedMood.emoji)
                            .font(.title)
                        
                        Text(selectedMood.displayName)
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Change") {
                            showingMoodPicker = true
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                    }
                } else {
                    Button(action: { showingMoodPicker = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                            Text("Select your mood")
                                .font(.body)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            
            // Intensity Slider
            if selectedMood != nil {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Intensity: \(Int(intensity))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Slider(value: $intensity, in: 1...10, step: 1)
                        .accentColor(.white)
                }
                
                // Notes
                TextField("Add notes (optional)", text: $notes, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
            }
            
            // Save Button
            if selectedMood != nil {
                Button(action: saveMoodEntry) {
                    Text("Save Mood")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .sheet(isPresented: $showingMoodPicker) {
            MoodPickerView(selectedMood: $selectedMood)
        }
    }
    
    private func saveMoodEntry() {
        guard let mood = selectedMood else { return }
        
        let entry = MoodEntry(
            mood: mood,
            intensity: Int(intensity),
            notes: notes.isEmpty ? nil : notes
        )
        
        moodManager.addMoodEntry(entry)
        
        // Reset form
        selectedMood = nil
        intensity = 5
        notes = ""
    }
}

struct MoodPickerView: View {
    @Binding var selectedMood: MoodType?
    @Environment(\.dismiss) private var dismiss
    
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(MoodType.allCases, id: \.self) { mood in
                        Button(action: {
                            selectedMood = mood
                            dismiss()
                        }) {
                            VStack(spacing: 8) {
                                Text(mood.emoji)
                                    .font(.title)
                                
                                Text(mood.displayName)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Task List Component

struct TaskListView: View {
    let tasks: [Task]
    let onAddTask: () -> Void
    @StateObject private var taskManager = TaskManager()
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Tasks")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onAddTask) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.title3)
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            
            if tasks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("No tasks yet")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Tap the + button to add your first task")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(tasks.prefix(5)) { task in
                        TaskRowView(task: task) { updatedTask in
                            taskManager.updateTask(updatedTask)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct TaskRowView: View {
    let task: Task
    let onUpdate: (Task) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                var updatedTask = task
                updatedTask.isCompleted.toggle()
                onUpdate(updatedTask)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .white.opacity(0.6))
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .foregroundColor(.white)
                    .strikethrough(task.isCompleted)
                    .opacity(task.isCompleted ? 0.6 : 1.0)
                
                if let description = task.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Label(task.category.displayName, systemImage: task.category.icon)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Circle()
                        .fill(task.priority.color)
                        .frame(width: 8, height: 8)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
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
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
        let totalIntensity = moodEntries.reduce(0) { $0 + $1.intensity }
        return Double(totalIntensity) / Double(moodEntries.count)
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
                    color: .blue
                )
                
                StatCard(
                    title: "Mood",
                    value: String(format: "%.1f", averageMood),
                    subtitle: "Average",
                    color: .pink
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
        .padding()
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
            
            // Sample transcript (in a real app, this would be from speech recognition)
            if !transcript.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transcript:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(transcript)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func toggleRecording() {
        isRecording.toggle()
        
        if isRecording {
            recordingTime = 0
            transcript = ""
        } else {
            // Simulate transcript (in a real app, this would come from speech recognition)
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
                .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(voiceManager.voiceCheckins.prefix(3)) { checkin in
                        VoiceCheckinRowView(checkin: checkin)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
        .padding()
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
                .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(moodEntries.prefix(5)) { entry in
                        MoodEntryRowView(entry: entry)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct MoodEntryRowView: View {
    let entry: MoodEntry
    
    var body: some View {
        HStack(spacing: 12) {
            Text(entry.mood.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.mood.displayName)
                    .font(.body)
                    .foregroundColor(.white)
                
                if let notes = entry.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.intensity)/10")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(entry.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Add Task Modal

struct AddTaskModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    @State private var category: TaskCategory = .personal
    @State private var dueDate: Date = Date()
    @State private var hasDueDate = false
    @StateObject private var taskManager = TaskManager()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task title", text: $title)
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Label(priority.displayName, systemImage: "circle.fill")
                                .foregroundColor(priority.color)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due date", selection: $dueDate, displayedComponents: .date)
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
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil,
            category: category
        )
        
        taskManager.addTask(task)
        dismiss()
    }
} 