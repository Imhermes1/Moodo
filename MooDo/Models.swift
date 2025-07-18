//
//  Models.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import Foundation
import SwiftUI
import _Concurrency

// MARK: - Data Models

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var notes: String?
    var isCompleted: Bool
    var priority: TaskPriority
    var emotion: EmotionType
    var reminderAt: Date?
    var naturalLanguageInput: String?
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, description: String? = nil, notes: String? = nil, isCompleted: Bool = false, priority: TaskPriority = .medium, emotion: EmotionType = .focused, reminderAt: Date? = nil, naturalLanguageInput: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.notes = notes
        self.isCompleted = isCompleted
        self.priority = priority
        self.emotion = emotion
        self.reminderAt = reminderAt
        self.naturalLanguageInput = naturalLanguageInput
        self.createdAt = Date()
    }
}

enum TaskPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return Color(red: 0.22, green: 0.69, blue: 0.42) // Green for low priority
        case .medium: return Color(red: 0.95, green: 0.61, blue: 0.07) // Orange for medium priority
        case .high: return Color(red: 0.91, green: 0.3, blue: 0.24) // Red for high priority
        }
    }
}

enum EmotionType: String, CaseIterable, Codable {
    case positive = "positive"
    case calm = "calm"
    case urgent = "urgent"
    case creative = "creative"
    case focused = "focused"
    
    var displayName: String {
        switch self {
        case .positive: return "Positive"
        case .calm: return "Calm"
        case .urgent: return "Urgent"
        case .creative: return "Creative"
        case .focused: return "Focused"
        }
    }
    
    var icon: String {
        switch self {
        case .positive: return "trophy"
        case .calm: return "leaf"
        case .urgent: return "exclamationmark.circle"
        case .creative: return "lightbulb"
        case .focused: return "brain.head.profile"
        }
    }
    
    var color: Color {
        switch self {
        case .positive: return Color(red: 0.22, green: 0.69, blue: 0.42) // mood-green
        case .calm: return Color(red: 0.22, green: 0.56, blue: 0.94) // mood-blue
        case .urgent: return Color(red: 0.91, green: 0.3, blue: 0.24) // mood-red
        case .creative: return Color(red: 0.56, green: 0.27, blue: 0.68) // mood-purple
        case .focused: return Color(red: 0.4, green: 0.49, blue: 0.92) // bluey-purple
        }
    }
}

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    var mood: MoodType
    var timestamp: Date
    
    init(id: UUID = UUID(), mood: MoodType) {
        self.id = id
        self.mood = mood
        self.timestamp = Date()
    }
}

enum MoodType: String, CaseIterable, Codable {
    case positive = "positive"
    case calm = "calm"
    case focused = "focused"
    case stressed = "stressed"
    case creative = "creative"
    
    var displayName: String {
        switch self {
        case .positive: return "Positive"
        case .calm: return "Calm"
        case .focused: return "Focused"
        case .stressed: return "Stressed"
        case .creative: return "Creative"
        }
    }
    
    var icon: String {
        switch self {
        case .positive: return "face.smiling"
        case .calm: return "leaf"
        case .focused: return "brain.head.profile"
        case .stressed: return "face.dashed"
        case .creative: return "lightbulb"
        }
    }
    
    var color: Color {
        switch self {
        case .positive: return Color(red: 0.22, green: 0.69, blue: 0.42) // mood-green
        case .calm: return Color(red: 0.22, green: 0.56, blue: 0.94) // mood-blue
        case .focused: return Color(red: 0.4, green: 0.49, blue: 0.92) // bluey-purple
        case .stressed: return Color(red: 0.91, green: 0.3, blue: 0.24) // mood-red
        case .creative: return Color(red: 0.56, green: 0.27, blue: 0.68) // mood-purple
        }
    }
}

struct VoiceCheckin: Identifiable, Codable {
    let id: UUID
    var transcript: String
    var mood: MoodType?
    var tasks: [String]
    var timestamp: Date
    var duration: TimeInterval
    
    init(id: UUID = UUID(), transcript: String, mood: MoodType? = nil, tasks: [String] = [], duration: TimeInterval = 0) {
        self.id = id
        self.transcript = transcript
        self.mood = mood
        self.tasks = tasks
        self.timestamp = Date()
        self.duration = duration
    }
}



// MARK: - Data Managers

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    let taskScheduler = TaskScheduler()
    
    var currentMood: MoodType {
        return taskScheduler.currentMood
    }
    
    init() {
        loadSampleData()
        loadFromCloud()
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        
        // Apply intelligent scheduling
        let optimizedTasks = taskScheduler.optimizeTaskSchedule(tasks: tasks)
        tasks = optimizedTasks
        
        saveTasks()
        saveToCloud()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
            saveToCloud()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
        deleteFromCloud(task.id)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updateTask(updatedTask)
    }
    
    func updateCurrentMood(_ mood: MoodType) {
        taskScheduler.updateCurrentMood(mood)
        
        // Re-optimize all tasks based on new mood
        let optimizedTasks = taskScheduler.optimizeTaskSchedule(tasks: tasks)
        tasks = optimizedTasks
        
        saveTasks()
        saveToCloud()
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "SavedTasks")
        }
    }
    
    // MARK: - CloudKit Integration
    
    private func saveToCloud() {
        _Concurrency.Task {
            await CloudKitManager.shared.saveTasks(tasks)
        }
    }
    
    private func loadFromCloud() {
        _Concurrency.Task {
            let cloudTasks = await CloudKitManager.shared.fetchTasks()
            await MainActor.run {
                // Merge cloud tasks with local tasks, avoiding duplicates
                let localTaskIds = Set(tasks.map { $0.id })
                let newCloudTasks = cloudTasks.filter { !localTaskIds.contains($0.id) }
                tasks.append(contentsOf: newCloudTasks)
                saveTasks() // Save merged data locally
            }
        }
    }
    
    private func deleteFromCloud(_ taskId: UUID) {
        _Concurrency.Task {
            await CloudKitManager.shared.deleteTask(taskId)
        }
    }
    
    func syncWithCloud() {
        loadFromCloud()
    }
    
    private func loadSampleData() {
        tasks = [
            Task(
                title: "Complete project presentation",
                description: "Finish the slides for tomorrow's meeting",
                notes: "Focus on key metrics and outcomes",
                priority: .high,
                emotion: .focused,
                reminderAt: Calendar.current.date(byAdding: .hour, value: 2, to: Date())
            ),
            Task(
                title: "Go for a walk",
                description: "30 minutes in the park",
                priority: .medium,
                emotion: .calm
            ),
            Task(
                title: "Brainstorm new ideas",
                description: "Creative session for the new campaign",
                priority: .low,
                emotion: .creative
            ),
            Task(
                title: "Call mom",
                description: "Check in and catch up",
                priority: .medium,
                emotion: .positive
            ),
            Task(
                title: "Pay bills",
                description: "Electricity and internet",
                priority: .high,
                emotion: .urgent,
                reminderAt: Calendar.current.date(byAdding: .day, value: 1, to: Date())
            )
        ]
    }
}

class MoodManager: ObservableObject {
    @Published var moodEntries: [MoodEntry] = []
    
    init() {
        loadSampleData()
        loadFromCloud()
    }
    
    func addMoodEntry(_ entry: MoodEntry) {
        moodEntries.append(entry)
        saveMoodEntries()
        saveToCloud()
    }
    
    func updateMoodEntry(_ entry: MoodEntry) {
        if let index = moodEntries.firstIndex(where: { $0.id == entry.id }) {
            moodEntries[index] = entry
            saveMoodEntries()
            saveToCloud()
        }
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) {
        moodEntries.removeAll { $0.id == entry.id }
        saveMoodEntries()
        deleteFromCloud(entry.id)
    }
    
    private func saveMoodEntries() {
        if let encoded = try? JSONEncoder().encode(moodEntries) {
            UserDefaults.standard.set(encoded, forKey: "SavedMoodEntries")
        }
    }
    
    // MARK: - CloudKit Integration
    
    private func saveToCloud() {
        _Concurrency.Task {
            await CloudKitManager.shared.saveMoodEntries(moodEntries)
        }
    }
    
    private func loadFromCloud() {
        _Concurrency.Task {
            let cloudEntries = await CloudKitManager.shared.fetchMoodEntries()
            await MainActor.run {
                // Merge cloud entries with local entries, avoiding duplicates
                let localEntryIds = Set(moodEntries.map { $0.id })
                let newCloudEntries = cloudEntries.filter { !localEntryIds.contains($0.id) }
                moodEntries.append(contentsOf: newCloudEntries)
                saveMoodEntries() // Save merged data locally
            }
        }
    }
    
    private func deleteFromCloud(_ entryId: UUID) {
        _Concurrency.Task {
            await CloudKitManager.shared.deleteMoodEntry(entryId)
        }
    }
    
    func syncWithCloud() {
        loadFromCloud()
    }
    
    private func loadSampleData() {
        let calendar = Calendar.current
        let now = Date()
        
        moodEntries = [
            MoodEntry(mood: .positive),
            MoodEntry(mood: .calm),
            MoodEntry(mood: .focused),
            MoodEntry(mood: .creative),
            MoodEntry(mood: .stressed)
        ]
        
        // Set different timestamps for the last 5 days
        for (index, entry) in moodEntries.enumerated() {
            let daysAgo = 4 - index
            if calendar.date(byAdding: .day, value: -daysAgo, to: now) != nil {
                moodEntries[index] = MoodEntry(
                    id: entry.id,
                    mood: entry.mood
                )
            }
        }
    }
}

class VoiceCheckinManager: ObservableObject {
    @Published var voiceCheckins: [VoiceCheckin] = []
    
    init() {
        loadSampleData()
        loadFromCloud()
    }
    
    func addVoiceCheckin(_ checkin: VoiceCheckin) {
        voiceCheckins.append(checkin)
        saveVoiceCheckins()
        saveToCloud()
    }
    
    func deleteVoiceCheckin(_ checkin: VoiceCheckin) {
        voiceCheckins.removeAll { $0.id == checkin.id }
        saveVoiceCheckins()
        deleteFromCloud(checkin.id)
    }
    
    private func saveVoiceCheckins() {
        if let encoded = try? JSONEncoder().encode(voiceCheckins) {
            UserDefaults.standard.set(encoded, forKey: "SavedVoiceCheckins")
        }
    }
    
    // MARK: - CloudKit Integration
    
    private func saveToCloud() {
        _Concurrency.Task {
            await CloudKitManager.shared.saveVoiceCheckins(voiceCheckins)
        }
    }
    
    private func loadFromCloud() {
        _Concurrency.Task {
            let cloudCheckins = await CloudKitManager.shared.fetchVoiceCheckins()
            await MainActor.run {
                // Merge cloud checkins with local checkins, avoiding duplicates
                let localCheckinIds = Set(voiceCheckins.map { $0.id })
                let newCloudCheckins = cloudCheckins.filter { !localCheckinIds.contains($0.id) }
                voiceCheckins.append(contentsOf: newCloudCheckins)
                saveVoiceCheckins() // Save merged data locally
            }
        }
    }
    
    private func deleteFromCloud(_ checkinId: UUID) {
        _Concurrency.Task {
            // Note: You may want to add a delete method for voice checkins in CloudKitManager
            // await CloudKitManager.shared.deleteVoiceCheckin(checkinId)
        }
    }
    
    func syncWithCloud() {
        loadFromCloud()
    }
    
    private func loadSampleData() {
        voiceCheckins = [
            VoiceCheckin(transcript: "I'm feeling really good today. I completed my morning workout and I'm ready to tackle the day ahead.", mood: .positive, tasks: ["morning workout", "prepare for meeting"], duration: 45),
            VoiceCheckin(transcript: "Today was a bit stressful at work, but I managed to stay focused and get things done.", mood: .focused, tasks: ["work tasks", "stress management"], duration: 32),
            VoiceCheckin(transcript: "I'm feeling grateful for my family and friends. They always support me when I need it.", mood: .positive, tasks: ["call family", "plan weekend"], duration: 28)
        ]
    }
} 