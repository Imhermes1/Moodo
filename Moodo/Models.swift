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
    var isCompleted: Bool
    var priority: TaskPriority
    var dueDate: Date?
    var createdAt: Date
    var category: TaskCategory
    
    init(id: UUID = UUID(), title: String, description: String? = nil, isCompleted: Bool = false, priority: TaskPriority = .medium, dueDate: Date? = nil, category: TaskCategory = .personal) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = Date()
        self.category = category
    }
}

enum TaskPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable {
    case personal = "personal"
    case work = "work"
    case health = "health"
    case finance = "finance"
    case education = "education"
    
    var displayName: String {
        switch self {
        case .personal: return "Personal"
        case .work: return "Work"
        case .health: return "Health"
        case .finance: return "Finance"
        case .education: return "Education"
        }
    }
    
    var icon: String {
        switch self {
        case .personal: return "person"
        case .work: return "briefcase"
        case .health: return "heart"
        case .finance: return "dollarsign"
        case .education: return "book"
        }
    }
}

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    var mood: MoodType
    var intensity: Int // 1-10
    var notes: String?
    var activities: [String]
    var timestamp: Date
    
    init(id: UUID = UUID(), mood: MoodType, intensity: Int, notes: String? = nil, activities: [String] = []) {
        self.id = id
        self.mood = mood
        self.intensity = max(1, min(10, intensity))
        self.notes = notes
        self.activities = activities
        self.timestamp = Date()
    }
}

enum MoodType: String, CaseIterable, Codable {
    case veryHappy = "very_happy"
    case happy = "happy"
    case neutral = "neutral"
    case sad = "sad"
    case verySad = "very_sad"
    case anxious = "anxious"
    case excited = "excited"
    case calm = "calm"
    case frustrated = "frustrated"
    case grateful = "grateful"
    
    var displayName: String {
        switch self {
        case .veryHappy: return "Very Happy"
        case .happy: return "Happy"
        case .neutral: return "Neutral"
        case .sad: return "Sad"
        case .verySad: return "Very Sad"
        case .anxious: return "Anxious"
        case .excited: return "Excited"
        case .calm: return "Calm"
        case .frustrated: return "Frustrated"
        case .grateful: return "Grateful"
        }
    }
    
    var emoji: String {
        switch self {
        case .veryHappy: return "😄"
        case .happy: return "🙂"
        case .neutral: return "😐"
        case .sad: return "😔"
        case .verySad: return "😢"
        case .anxious: return "😰"
        case .excited: return "🤩"
        case .calm: return "😌"
        case .frustrated: return "😤"
        case .grateful: return "🙏"
        }
    }
    
    var color: Color {
        switch self {
        case .veryHappy: return .yellow
        case .happy: return .green
        case .neutral: return .gray
        case .sad: return .blue
        case .verySad: return .purple
        case .anxious: return .orange
        case .excited: return .pink
        case .calm: return .mint
        case .frustrated: return .red
        case .grateful: return .teal
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
            Task(title: "Complete project presentation", description: "Finish the slides for tomorrow's meeting", priority: .high, category: .work),
            Task(title: "Go for a walk", description: "30 minutes in the park", priority: .medium, category: .health),
            Task(title: "Read a book", description: "Continue reading 'Atomic Habits'", priority: .low, category: .education),
            Task(title: "Call mom", description: "Check in and catch up", priority: .medium, category: .personal),
            Task(title: "Pay bills", description: "Electricity and internet", priority: .high, category: .finance)
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
            MoodEntry(mood: .happy, intensity: 8, notes: "Had a great workout this morning", activities: ["exercise", "meditation"]),
            MoodEntry(mood: .calm, intensity: 6, notes: "Productive work session", activities: ["work", "coffee"]),
            MoodEntry(mood: .excited, intensity: 9, notes: "Finished the big project!", activities: ["work", "celebration"]),
            MoodEntry(mood: .neutral, intensity: 5, notes: "Regular day", activities: ["routine"]),
            MoodEntry(mood: .grateful, intensity: 7, notes: "Spent time with family", activities: ["family", "dinner"])
        ]
        
        // Set different timestamps for the last 5 days
        for (index, entry) in moodEntries.enumerated() {
            let daysAgo = 4 - index
            if calendar.date(byAdding: .day, value: -daysAgo, to: now) != nil {
                moodEntries[index] = MoodEntry(
                    id: entry.id,
                    mood: entry.mood,
                    intensity: entry.intensity,
                    notes: entry.notes,
                    activities: entry.activities
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
            VoiceCheckin(transcript: "I'm feeling really good today. I completed my morning workout and I'm ready to tackle the day ahead.", mood: .happy, tasks: ["morning workout", "prepare for meeting"], duration: 45),
            VoiceCheckin(transcript: "Today was a bit stressful at work, but I managed to stay focused and get things done.", mood: .neutral, tasks: ["work tasks", "stress management"], duration: 32),
            VoiceCheckin(transcript: "I'm feeling grateful for my family and friends. They always support me when I need it.", mood: .grateful, tasks: ["call family", "plan weekend"], duration: 28)
        ]
    }
} 