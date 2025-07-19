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
    var isCompleted: Bool
    var isFlagged: Bool
    var isRecurring: Bool
    var priority: TaskPriority
    var emotion: EmotionType
    var reminderAt: Date?
    var deadlineAt: Date? // Separate deadline date from reminder
    var naturalLanguageInput: String?
    var createdAt: Date
    var list: TaskList?
    var tags: [String]
    var subtasks: [Task]?
    var eventKitIdentifier: String? // For linking to EventKit reminder
    
    init(id: UUID = UUID(), title: String, description: String? = nil, isCompleted: Bool = false, isFlagged: Bool = false, isRecurring: Bool = false, priority: TaskPriority = .medium, emotion: EmotionType = .focused, reminderAt: Date? = nil, deadlineAt: Date? = nil, naturalLanguageInput: String? = nil, list: TaskList? = nil, tags: [String] = [], subtasks: [Task]? = nil, eventKitIdentifier: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.isFlagged = isFlagged
        self.isRecurring = isRecurring
        self.priority = priority
        self.emotion = emotion
        self.reminderAt = reminderAt
        self.deadlineAt = deadlineAt
        self.naturalLanguageInput = naturalLanguageInput
        self.createdAt = Date()
        self.list = list
        self.tags = tags
        self.subtasks = subtasks
        self.eventKitIdentifier = eventKitIdentifier
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

@MainActor
class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var taskLists: [TaskList] = []
    let taskScheduler = TaskScheduler()
    let eventKitManager = EventKitManager()
    
    var currentMood: MoodType {
        return taskScheduler.currentMood
    }
    
    init() {
        loadSampleData()
        loadFromCloud()
        
        // Setup notification actions
        EventKitManager.setupNotificationActions()
    }
    
    func addTask(_ task: Task) {
        var newTask = task
        
        // Create EventKit reminder if task has a reminder date
        if task.reminderAt != nil {
            _Concurrency.Task {
                let eventKitID = await eventKitManager.createReminder(for: task)
                await MainActor.run {
                    newTask.eventKitIdentifier = eventKitID
                    self.tasks.append(newTask)
                    
                    // Apply intelligent scheduling
                    let optimizedTasks = self.taskScheduler.optimizeTaskSchedule(tasks: self.tasks)
                    self.tasks = optimizedTasks
                    
                    self.saveTasks()
                    self.saveToCloud()
                }
            }
        } else {
            tasks.append(newTask)
            
            // Apply intelligent scheduling
            let optimizedTasks = taskScheduler.optimizeTaskSchedule(tasks: tasks)
            tasks = optimizedTasks
            
            saveTasks()
            saveToCloud()
        }
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            
            // Update EventKit reminder if it exists
            _Concurrency.Task {
                await eventKitManager.updateReminder(for: task)
            }
            
            saveTasks()
            saveToCloud()
        }
    }
    
    func deleteTask(_ task: Task) {
        // Delete EventKit reminder if it exists
        if let eventKitID = task.eventKitIdentifier {
            eventKitManager.deleteReminder(eventKitIdentifier: eventKitID)
        }
        
        tasks.removeAll { $0.id == task.id }
        saveTasks()
        deleteFromCloud(task.id)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updateTask(updatedTask)
    }
    
    func addTaskList(_ list: TaskList) {
        taskLists.append(list)
        // Save task lists to UserDefaults
        if let encoded = try? JSONEncoder().encode(taskLists) {
            UserDefaults.standard.set(encoded, forKey: "SavedTaskLists")
        }
    }
    
    // MARK: - Computed Properties
    
    var todayTasks: [Task] {
        // Use adaptive optimization for today's tasks
        let optimalCount = taskScheduler.getOptimalTaskCount(for: taskScheduler.currentMood)
        return taskScheduler.optimizeTaskSchedule(tasks: tasks, maxTasks: optimalCount)
    }
    
    var upcomingTasks: [Task] {
        let today = Calendar.current.startOfDay(for: Date())
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        return tasks.filter { task in
            guard let reminderAt = task.reminderAt else { return false }
            return reminderAt >= today && reminderAt < nextWeek && !task.isCompleted
        }
    }
    
    var importantTasks: [Task] {
        return tasks.filter { $0.priority == .high && !$0.isCompleted }
    }
    
    var completedTasks: [Task] {
        return tasks.filter { $0.isCompleted }
    }
    
    func toggleTaskFlag(_ task: Task) {
        var updatedTask = task
        updatedTask.isFlagged.toggle()
        updateTask(updatedTask)
    }
    
    func updateCurrentMood(_ mood: MoodType) {
        taskScheduler.updateCurrentMood(mood)
        
        // Auto-optimize tasks based on new mood
        autoOptimizeTasks()
    }
    
    func autoOptimizeTasks() {
        // Get optimal task count based on current mood
        let optimalCount = taskScheduler.getOptimalTaskCount(for: taskScheduler.currentMood)
        
        // Optimize tasks with mood-based filtering and count limit
        let optimizedTasks = taskScheduler.optimizeTaskSchedule(tasks: tasks, maxTasks: optimalCount)
        
        // Update tasks with optimized order
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
                description: "Finish the slides for tomorrow's meeting. Focus on key metrics and outcomes.",
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

// MARK: - Missing Types

class TaskScheduler: ObservableObject {
    @Published var currentMood: MoodType = .positive
    
    func updateCurrentMood(_ mood: MoodType) {
        currentMood = mood
    }
    
    func optimizeTaskSchedule(tasks: [Task], maxTasks: Int? = nil) -> [Task] {
        // Advanced mood-based optimization system
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let incompleTasks = tasks.filter { !$0.isCompleted }
        
        // Get mood-specific task preferences
        let moodPreferences = getMoodTaskPreferences(for: currentMood)
        
        // Calculate mood compatibility scores for all tasks
        let scoredTasks = incompleTasks.map { task in
            (task: task, score: calculateMoodCompatibilityScore(task: task, preferences: moodPreferences))
        }
        
        // Filter and prioritize based on multiple criteria
        let prioritizedTasks = scoredTasks.filter { scoredTask in
            let task = scoredTask.task
            let score = scoredTask.score
            
                    // Always include high-priority tasks and tasks due today
        let isHighPriority = task.priority == .high
        let isDueToday = (task.reminderAt != nil && 
                         task.reminderAt! >= today && 
                         task.reminderAt! < tomorrow) ||
                        (task.deadlineAt != nil && 
                         task.deadlineAt! >= today && 
                         task.deadlineAt! < tomorrow)
        let hasGoodMoodMatch = score >= 0.6
        
        return isHighPriority || isDueToday || hasGoodMoodMatch
        }
        
        // Sort by comprehensive scoring system
        let optimizedTasks = prioritizedTasks.sorted { scored1, scored2 in
            let task1 = scored1.task
            let task2 = scored2.task
            let score1 = scored1.score
            let score2 = scored2.score
            
            // 1. Urgent tasks first (due today + high priority)
            let urgent1 = isUrgent(task: task1, today: today, tomorrow: tomorrow)
            let urgent2 = isUrgent(task: task2, today: today, tomorrow: tomorrow)
            
            if urgent1 && !urgent2 { return true }
            if !urgent1 && urgent2 { return false }
            
            // 2. Mood compatibility score
            if abs(score1 - score2) > 0.1 {
                return score1 > score2
            }
            
            // 3. Priority level
            if task1.priority != task2.priority {
                return task1.priority.numericValue > task2.priority.numericValue
            }
            
            // 4. Time sensitivity
            let time1 = task1.reminderAt ?? Date.distantFuture
            let time2 = task2.reminderAt ?? Date.distantFuture
            
            return time1 < time2
        }
        
        // Apply mood-specific task count limits
        let optimalCount = maxTasks ?? getOptimalTaskCount(for: currentMood)
        let finalTasks = Array(optimizedTasks.prefix(optimalCount).map { $0.task })
        
        return finalTasks
    }
    
    private func getMoodTaskPreferences(for mood: MoodType) -> MoodTaskPreferences {
        switch mood {
        case .positive:
            return MoodTaskPreferences(
                preferredEmotions: [.positive, .creative, .focused],
                preferredPriorities: [.high, .medium],
                timePreference: .flexible,
                creativityBoost: 1.3,
                focusCapacity: 1.2
            )
        case .calm:
            return MoodTaskPreferences(
                preferredEmotions: [.calm, .positive],
                preferredPriorities: [.low, .medium],
                timePreference: .morning,
                creativityBoost: 0.8,
                focusCapacity: 1.0
            )
        case .focused:
            return MoodTaskPreferences(
                preferredEmotions: [.focused, .positive],
                preferredPriorities: [.high, .medium],
                timePreference: .concentrated,
                creativityBoost: 0.9,
                focusCapacity: 1.5
            )
        case .stressed:
            return MoodTaskPreferences(
                preferredEmotions: [.calm, .positive],
                preferredPriorities: [.low],
                timePreference: .gentle,
                creativityBoost: 0.5,
                focusCapacity: 0.7
            )
        case .creative:
            return MoodTaskPreferences(
                preferredEmotions: [.creative, .positive, .focused],
                preferredPriorities: [.medium, .high],
                timePreference: .flexible,
                creativityBoost: 1.5,
                focusCapacity: 1.1
            )
        }
    }
    
    private func calculateMoodCompatibilityScore(task: Task, preferences: MoodTaskPreferences) -> Double {
        var score: Double = 0.0
        
        // Emotion compatibility (40% weight)
        if preferences.preferredEmotions.contains(task.emotion) {
            score += 0.4
        } else {
            score += 0.1 // Partial credit for non-conflicting emotions
        }
        
        // Priority alignment (30% weight)
        if preferences.preferredPriorities.contains(task.priority) {
            score += 0.3
        } else if task.priority == .high && currentMood != .stressed {
            score += 0.2 // High priority tasks get partial credit unless stressed
        }
        
        // Time sensitivity (20% weight) - consider both reminder and deadline
        if let deadlineAt = task.deadlineAt {
            let timeScore = calculateTimeCompatibilityScore(reminderAt: deadlineAt, preference: preferences.timePreference)
            score += timeScore * 0.2
        } else if let reminderAt = task.reminderAt {
            let timeScore = calculateTimeCompatibilityScore(reminderAt: reminderAt, preference: preferences.timePreference)
            score += timeScore * 0.15
        } else {
            score += 0.1 // No deadline gives moderate flexibility
        }
        
        // Special boosts (10% weight)
        if task.emotion == .creative {
            score += (preferences.creativityBoost - 1.0) * 0.05
        }
        if task.emotion == .focused {
            score += (preferences.focusCapacity - 1.0) * 0.05
        }
        
        return max(0.0, min(1.0, score))
    }
    
    private func calculateTimeCompatibilityScore(reminderAt: Date, preference: TimePreference) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminderAt)
        
        switch preference {
        case .morning:
            return hour < 12 ? 1.0 : 0.3
        case .concentrated:
            return (hour >= 9 && hour <= 11) || (hour >= 14 && hour <= 16) ? 1.0 : 0.5
        case .gentle:
            return hour < 10 || hour > 18 ? 1.0 : 0.4
        case .flexible:
            return 0.8 // Generally good at any time
        }
    }
    
    private func isUrgent(task: Task, today: Date, tomorrow: Date) -> Bool {
        let isDueToday = (task.reminderAt != nil && 
                         task.reminderAt! >= today && 
                         task.reminderAt! < tomorrow) ||
                        (task.deadlineAt != nil && 
                         task.deadlineAt! >= today && 
                         task.deadlineAt! < tomorrow)
        let isHighPriority = task.priority == .high
        
        return isDueToday && isHighPriority
    }
    
    // Get optimal number of tasks based on mood with time-of-day adjustment
    func getOptimalTaskCount(for mood: MoodType) -> Int {
        let baseCount: Int
        
        switch mood {
        case .positive:
            baseCount = 8 // High energy, can handle more tasks
        case .calm:
            baseCount = 5 // Peaceful state, fewer tasks
        case .focused:
            baseCount = 6 // Good focus, moderate task count
        case .stressed:
            baseCount = 3 // Lower capacity, fewer tasks
        case .creative:
            baseCount = 7 // Creative flow, can handle variety
        }
        
        // Adjust based on time of day
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        
        let timeMultiplier: Double
        if hour < 9 {
            timeMultiplier = 0.8 // Early morning - fewer tasks
        } else if hour < 12 {
            timeMultiplier = 1.0 // Morning peak
        } else if hour < 14 {
            timeMultiplier = 0.9 // Post-lunch dip
        } else if hour < 17 {
            timeMultiplier = 1.0 // Afternoon focus
        } else if hour < 20 {
            timeMultiplier = 0.8 // Evening wind-down
        } else {
            timeMultiplier = 0.6 // Night - minimal tasks
        }
        
        return max(2, Int(Double(baseCount) * timeMultiplier))
    }
}

// MARK: - Mood-Based Task Preferences

struct MoodTaskPreferences {
    let preferredEmotions: [EmotionType]
    let preferredPriorities: [TaskPriority]
    let timePreference: TimePreference
    let creativityBoost: Double
    let focusCapacity: Double
}

enum TimePreference {
    case morning      // Best in morning hours
    case concentrated // Best in focused work blocks
    case gentle       // Best in low-energy times
    case flexible     // Good anytime
}

// MARK: - Enhanced TaskPriority

extension TaskPriority {
    var rawValue: String {
        switch self {
        case .low: return "low"
        case .medium: return "medium" 
        case .high: return "high"
        }
    }
    
    var numericValue: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        }
    }
}

enum SmartListType: String, CaseIterable {
    case today = "Today"
    case tomorrow = "Tomorrow"
    case thisWeek = "This Week"
    case upcoming = "Upcoming"
    case important = "Important"
    case completed = "Completed"
    case all = "All"
    
    var icon: String {
        switch self {
        case .today: return "calendar"
        case .tomorrow: return "calendar.badge.plus"
        case .thisWeek: return "calendar.badge.clock"
        case .upcoming: return "calendar.badge.clock"
        case .important: return "exclamationmark.triangle"
        case .completed: return "checkmark.circle"
        case .all: return "list.bullet"
        }
    }
    
    var color: Color {
        switch self {
        case .today: return .blue
        case .tomorrow: return .green
        case .thisWeek: return .orange
        case .upcoming: return .cyan
        case .important: return .red
        case .completed: return .gray
        case .all: return .purple
        }
    }
}

struct TaskList: Identifiable, Codable {
    var id = UUID()
    let name: String
    let colorName: String
    let icon: String
    
    var color: Color {
        switch colorName {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "cyan": return .cyan
        default: return .blue
        }
    }
    
    init(name: String, color: Color, icon: String) {
        self.name = name
        self.icon = icon
        self.colorName = Self.colorName(for: color)
    }
    
    private static func colorName(for color: Color) -> String {
        // Simple color mapping - you might want to expand this
        if color == .red { return "red" }
        if color == .blue { return "blue" }
        if color == .green { return "green" }
        if color == .orange { return "orange" }
        if color == .purple { return "purple" }
        if color == .pink { return "pink" }
        if color == .yellow { return "yellow" }
        if color == .cyan { return "cyan" }
        return "blue"
    }
} 
