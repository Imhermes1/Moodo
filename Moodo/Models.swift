//
//  Models.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import Foundation
import SwiftUI

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
    
    init() {
        loadSampleData()
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updateTask(updatedTask)
    }
    
    private func saveTasks() {
        // In a real app, this would save to Core Data or UserDefaults
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
    }
    
    func addMoodEntry(_ entry: MoodEntry) {
        moodEntries.append(entry)
        saveMoodEntries()
    }
    
    func updateMoodEntry(_ entry: MoodEntry) {
        if let index = moodEntries.firstIndex(where: { $0.id == entry.id }) {
            moodEntries[index] = entry
            saveMoodEntries()
        }
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) {
        moodEntries.removeAll { $0.id == entry.id }
        saveMoodEntries()
    }
    
    private func saveMoodEntries() {
        // In a real app, this would save to Core Data or UserDefaults
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
    }
    
    func addVoiceCheckin(_ checkin: VoiceCheckin) {
        voiceCheckins.append(checkin)
        saveVoiceCheckins()
    }
    
    private func saveVoiceCheckins() {
        // In a real app, this would save to Core Data or UserDefaults
    }
    
    private func loadSampleData() {
        voiceCheckins = [
            VoiceCheckin(transcript: "I'm feeling really good today. I completed my morning workout and I'm ready to tackle the day ahead.", mood: .positive, tasks: ["morning workout", "prepare for meeting"], duration: 45),
            VoiceCheckin(transcript: "Today was a bit stressful at work, but I managed to stay focused and get things done.", mood: .focused, tasks: ["work tasks", "stress management"], duration: 32),
            VoiceCheckin(transcript: "I'm feeling grateful for my family and friends. They always support me when I need it.", mood: .positive, tasks: ["call family", "plan weekend"], duration: 28)
        ]
    }
} 