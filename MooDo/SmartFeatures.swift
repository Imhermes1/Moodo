//
//  SmartFeatures.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import Foundation
import SwiftUI
import Speech
import AVFoundation

// MARK: - Natural Language Processing

class NaturalLanguageProcessor: ObservableObject {
    @Published var isProcessing = false
    @Published var processedText = ""
    
    // Performance optimization: Reuse date components
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    func processNaturalLanguage(_ input: String) -> ProcessedTask {
        isProcessing = true
        
        // Reduced processing delay for better performance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isProcessing = false
            self.processedText = self.analyzeText(input)
        }
        
        return analyzeTextForTask(input)
    }
    
    private func analyzeText(_ input: String) -> String {
        let lowercased = input.lowercased()
        
        // Extract key information
        var analysis = "Analyzing: \"\(input)\"\n\n"
        
        // Detect urgency
        if lowercased.contains("urgent") || lowercased.contains("asap") || lowercased.contains("now") {
            analysis += "🔴 Detected: High urgency\n"
        } else if lowercased.contains("today") || lowercased.contains("tonight") {
            analysis += "🟡 Detected: Today's priority\n"
        } else if lowercased.contains("tomorrow") || lowercased.contains("next week") {
            analysis += "🟢 Detected: Future task\n"
        }
        
        // Detect emotion/context
        if lowercased.contains("creative") || lowercased.contains("brainstorm") || lowercased.contains("idea") {
            analysis += "💡 Detected: Creative task\n"
        } else if lowercased.contains("focus") || lowercased.contains("work") || lowercased.contains("project") {
            analysis += "🎯 Detected: Focused work\n"
        } else if lowercased.contains("calm") || lowercased.contains("relax") || lowercased.contains("peaceful") {
            analysis += "😌 Detected: Calm activity\n"
        }
        
        return analysis
    }
    
    func analyzeTextForTask(_ input: String) -> ProcessedTask {
        // Performance optimization: Early return for empty input
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ProcessedTask(title: input, description: nil, priority: .medium, emotion: .neutral, reminderAt: nil, deadlineAt: nil, tags: [])
        }
        
        let lowercased = input.lowercased()
        
        // Extract title (remove time and priority indicators)
        var cleanTitle = input
        let timePatterns = ["at \\d{1,2}(:\\d{2})?(am|pm)?", "in \\d+ (minutes?|hours?|days?)", "tomorrow", "today"]
        for pattern in timePatterns {
            cleanTitle = cleanTitle.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        cleanTitle = cleanTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Determine priority
        let priority: TaskPriority
        if lowercased.contains("urgent") || lowercased.contains("asap") || lowercased.contains("important") {
            priority = .high
        } else if lowercased.contains("later") || lowercased.contains("sometime") {
            priority = .low
        } else {
            priority = .medium
        }
        
        // Determine emotion based on context
        let emotion: EmotionType
        if lowercased.contains("urgent") || lowercased.contains("asap") || lowercased.contains("deadline") || lowercased.contains("emergency") {
            emotion = .urgent
        } else if lowercased.contains("creative") || lowercased.contains("brainstorm") || lowercased.contains("idea") || lowercased.contains("design") {
            emotion = .creative
        } else if lowercased.contains("focus") || lowercased.contains("work") || lowercased.contains("study") || lowercased.contains("concentrate") {
            emotion = .focused
        } else if lowercased.contains("calm") || lowercased.contains("relax") || lowercased.contains("peaceful") || lowercased.contains("meditation") {
            emotion = .calm
        } else if lowercased.contains("excited") || lowercased.contains("happy") || lowercased.contains("celebrate") || lowercased.contains("positive") {
            emotion = .positive
        } else if lowercased.contains("stressed") || lowercased.contains("worried") || lowercased.contains("pressure") || lowercased.contains("overwhelm") {
            emotion = .stressed
        } else {
            emotion = .neutral
        }
        
        // Extract reminder time
        let reminderTime = extractReminderTime(from: input)
        
        // Extract tags
        let tags = extractTags(from: input)
        
        return ProcessedTask(
            title: cleanTitle,
            description: input, // Keep the original input as description
            priority: priority,
            emotion: emotion,
            reminderAt: reminderTime,
            deadlineAt: nil,
            tags: tags
        )
    }
    
    private func extractReminderTime(from input: String) -> Date? {
        let now = Date()
        let lowercased = input.lowercased()
        
        #if DEBUG
        print("🔍 Extracting reminder time from: '\(input)'")
        print("🔍 Lowercased input: '\(lowercased)'")
        #endif
        
        // "in X minutes"
        if let minutesMatch = lowercased.range(of: "in (\\d+) minutes?", options: .regularExpression) {
            let minutesString = String(lowercased[minutesMatch])
            let components = minutesString.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
            if let minutes = Int(components.first ?? "") {
                let result = now.addingTimeInterval(TimeInterval(minutes * 60))
                #if DEBUG
                print("✅ Extracted time: \(result)")
                #endif
                return result
            }
        }
        
        // "in X hours"
        if let hoursMatch = lowercased.range(of: "in (\\d+) hours?", options: .regularExpression) {
            let hoursString = String(lowercased[hoursMatch])
            let components = hoursString.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
            if let hours = Int(components.first ?? "") {
                let result = now.addingTimeInterval(TimeInterval(hours * 3600))
                #if DEBUG
                print("✅ Extracted time: \(result)")
                #endif
                return result
            }
        }
        
        // Alternative simpler pattern for "at X AM/PM"
        #if DEBUG
        print("🔍 Checking alternative pattern for '\(lowercased)'")
        #endif
        
        if lowercased.contains(" at ") {
            let words = lowercased.components(separatedBy: " ")
            for (index, word) in words.enumerated() {
                if word == "at" && index + 1 < words.count {
                    let nextWord = words[index + 1]
                    #if DEBUG
                    print("🔍 Found 'at' followed by: '\(nextWord)'")
                    #endif
                    
                    // Check if next word contains time and AM/PM
                    if nextWord.contains("pm") || nextWord.contains("am") {
                        let timePart = nextWord.replacingOccurrences(of: "pm", with: "").replacingOccurrences(of: "am", with: "")
                        if let hour = Int(timePart) {
                            #if DEBUG
                            print("🔍 Extracted hour: \(hour)")
                            #endif
                            var adjustedHour = hour
                            let isPM = nextWord.contains("pm")
                            
                            // Handle AM/PM
                            if isPM && hour != 12 {
                                adjustedHour += 12
                            } else if !isPM && hour == 12 {
                                adjustedHour = 0
                            }
                            
                            var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
                            dateComponents.hour = adjustedHour
                            dateComponents.minute = 0
                            
                            // Check if the time has already passed today
                            let scheduledTime = calendar.date(from: dateComponents) ?? now
                            if scheduledTime <= now {
                                // If time has passed, schedule for tomorrow
                                dateComponents = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
                                dateComponents.hour = adjustedHour
                                dateComponents.minute = 0
                            }
                            
                            let result = calendar.date(from: dateComponents)
                            #if DEBUG
                            print("✅ Extracted time (alternative method): \(result?.description ?? "nil")")
                            #endif
                            return result
                        }
                    }
                }
            }
        }
        
        #if DEBUG
        print("❌ No time pattern matched for: '\(input)'")
        #endif
        return nil
    }
    
    private func extractTags(from input: String) -> [String] {
        var tags: [String] = []
        let lowercased = input.lowercased()
        
        // Look for hashtag-style tags (#tag)
        let hashtagPattern = "#(\\w+)"
        let hashtagRegex = try? NSRegularExpression(pattern: hashtagPattern, options: [])
        let hashtagMatches = hashtagRegex?.matches(in: input, options: [], range: NSRange(location: 0, length: input.count)) ?? []
        
        for match in hashtagMatches {
            if let range = Range(match.range(at: 1), in: input) {
                let tag = String(input[range])
                tags.append(tag)
            }
        }
        
        // Extract contextual tags based on keywords
        let contextualTags: [String: [String]] = [
            "work": ["work", "office", "meeting", "presentation", "project", "deadline", "client", "colleague"],
            "personal": ["personal", "family", "friend", "home", "private", "self"],
            "health": ["health", "doctor", "medicine", "exercise", "workout", "gym", "fitness", "diet"],
            "shopping": ["buy", "shop", "grocery", "store", "purchase", "order"],
            "learning": ["learn", "study", "course", "book", "education", "training", "practice"],
            "creative": ["creative", "design", "art", "music", "write", "brainstorm", "idea"],
            "urgent": ["urgent", "asap", "emergency", "immediately", "now"],
            "routine": ["daily", "weekly", "routine", "habit", "regular"],
            "travel": ["travel", "trip", "vacation", "flight", "hotel", "book"],
            "finance": ["money", "bank", "pay", "bill", "budget", "finance", "invest"]
        ]
        
        for (tag, keywords) in contextualTags {
            if keywords.contains(where: { lowercased.contains($0) }) {
                if !tags.contains(tag) {
                    tags.append(tag)
                }
            }
        }
        
        // Look for @mentions as potential location or person tags
        let mentionPattern = "@(\\w+)"
        let mentionRegex = try? NSRegularExpression(pattern: mentionPattern, options: [])
        let mentionMatches = mentionRegex?.matches(in: input, options: [], range: NSRange(location: 0, length: input.count)) ?? []
        
        for match in mentionMatches {
            if let range = Range(match.range(at: 1), in: input) {
                let mention = String(input[range])
                tags.append("@\(mention)")
            }
        }
        
        return tags
    }
}

struct ProcessedTask {
    let title: String
    let description: String?
    let priority: TaskPriority
    let emotion: EmotionType
    let reminderAt: Date?
    let deadlineAt: Date?
    let tags: [String]
}

// MARK: - Smart Insights

class SmartInsights: ObservableObject {
    @Published var insights: [Insight] = []
    
    func generateInsights(from moodEntries: [MoodEntry], tasks: [Task]) {
        var newInsights: [Insight] = []
        
        // Mood pattern analysis
        if let moodInsight = analyzeMoodPatterns(moodEntries) {
            newInsights.append(moodInsight)
        }
        
        // Task completion analysis
        if let taskInsight = analyzeTaskCompletion(tasks) {
            newInsights.append(taskInsight)
        }
        
        // Productivity patterns
        if let productivityInsight = analyzeProductivityPatterns(tasks) {
            newInsights.append(productivityInsight)
        }
        
        // Wellness recommendations
        if let wellnessInsight = generateWellnessRecommendations(moodEntries, tasks) {
            newInsights.append(wellnessInsight)
        }
        
        insights = newInsights
    }
    
    private func analyzeMoodPatterns(_ entries: [MoodEntry]) -> Insight? {
        guard entries.count >= 3 else { return nil }
        
        let recentEntries = Array(entries.suffix(7))
        let moodCounts = Dictionary(grouping: recentEntries, by: { $0.mood })
            .mapValues { $0.count }
        
        let mostCommonMood = moodCounts.max(by: { $0.value < $1.value })?.key
        
        if let dominantMood = mostCommonMood {
            let percentage = Double(moodCounts[dominantMood] ?? 0) / Double(recentEntries.count) * 100
            
            if percentage >= 60 {
                return Insight(
                    type: .mood,
                    title: "Mood Pattern Detected",
                    description: "You've been feeling \(dominantMood.displayName.lowercased()) \(Int(percentage))% of the time this week.",
                    recommendation: getMoodRecommendation(for: dominantMood),
                    icon: dominantMood.icon,
                    color: dominantMood.color
                )
            }
        }
        
        return nil
    }
    
    private func analyzeTaskCompletion(_ tasks: [Task]) -> Insight? {
        let completedTasks = tasks.filter { $0.isCompleted }
        let totalTasks = tasks.count
        
        guard totalTasks > 0 else { return nil }
        
        let completionRate = Double(completedTasks.count) / Double(totalTasks) * 100
        
        if completionRate >= 80 {
            return Insight(
                type: .productivity,
                title: "Excellent Progress!",
                description: "You've completed \(Int(completionRate))% of your tasks. Keep up the great work!",
                recommendation: "Consider setting more challenging goals for tomorrow.",
                icon: "trophy",
                color: .green
            )
        } else if completionRate <= 30 {
            return Insight(
                type: .productivity,
                title: "Need a Boost?",
                description: "You've completed \(Int(completionRate))% of your tasks. Let's get back on track!",
                recommendation: "Try breaking down larger tasks into smaller, manageable steps.",
                icon: "lightbulb",
                color: .orange
            )
        }
        
        return nil
    }
    
    private func analyzeProductivityPatterns(_ tasks: [Task]) -> Insight? {
        let emotionCounts = Dictionary(grouping: tasks, by: { $0.emotion })
            .mapValues { $0.count }
        
        if let mostCommonEmotion = emotionCounts.max(by: { $0.value < $1.value })?.key {
            return Insight(
                type: .productivity,
                title: "Task Energy Pattern",
                description: "Most of your tasks are \(mostCommonEmotion.displayName.lowercased()).",
                recommendation: "Consider balancing your task types for better energy management.",
                icon: mostCommonEmotion.icon,
                color: mostCommonEmotion.color
            )
        }
        
        return nil
    }
    
    private func generateWellnessRecommendations(_ moodEntries: [MoodEntry], _ tasks: [Task]) -> Insight? {
        let recentMoods = Array(moodEntries.suffix(3))
        let stressedCount = recentMoods.filter { $0.mood == .stressed }.count
        
        if stressedCount >= 2 {
            return Insight(
                type: .wellness,
                title: "Stress Alert",
                description: "You've been feeling stressed recently. Time for some self-care!",
                recommendation: "Try a 5-minute meditation or take a short walk to clear your mind.",
                icon: "heart",
                color: .red
            )
        }
        
        let incompleteTasks = tasks.filter { !$0.isCompleted && $0.priority == .high }
        if incompleteTasks.count >= 3 {
            return Insight(
                type: .wellness,
                title: "High Priority Overload",
                description: "You have \(incompleteTasks.count) high-priority tasks pending.",
                recommendation: "Consider delegating or rescheduling some tasks to reduce stress.",
                icon: "exclamationmark.triangle",
                color: .orange
            )
        }
        
        return nil
    }
    
    private func getMoodRecommendation(for mood: MoodType) -> String {
        switch mood {
        case .positive:
            return "Great energy! Perfect time to tackle challenging tasks."
        case .calm:
            return "Peaceful state. Ideal for focused, detailed work."
        case .focused:
            return "Sharp focus detected. Use this energy for complex projects."
        case .stressed:
            return "Feeling overwhelmed? Try breaking tasks into smaller steps."
        case .creative:
            return "Creative flow! Great time for brainstorming and ideation."
        }
    }
}

struct Insight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let description: String
    let recommendation: String
    let icon: String
    let color: Color
}

enum InsightType {
    case mood, productivity, wellness
}

// MARK: - Voice Recognition

class VoiceRecognitionManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var transcript = ""
    @Published var isAuthorized = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override init() {
        super.init()
        requestAuthorization()
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.isAuthorized = status == .authorized
            }
        }
    }
    
    func startRecording() {
        guard isAuthorized else {
            requestAuthorization()
            return
        }
        
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to configure audio session: \(error)")
            return
        }
        
        // Create and configure recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self?.transcript = result.bestTranscription.formattedString
                }
                
                if error != nil || result?.isFinal == true {
                    self?.stopRecording()
                }
            }
        }
        
        // Configure audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start audio engine
        do {
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        isRecording = false
    }
}

// MARK: - Smart Task Suggestions

class SmartTaskSuggestions: ObservableObject {
    @Published var suggestions: [TaskSuggestion] = []
    
    func generateSuggestions(mood: MoodType, timeOfDay: Date, completedTasks: [Task]) {
        var newSuggestions: [TaskSuggestion] = []
        
        // Time-based suggestions
        let hour = Calendar.current.component(.hour, from: timeOfDay)
        
        if hour < 12 {
            // Morning suggestions
            newSuggestions.append(contentsOf: getMorningSuggestions(for: mood))
        } else if hour < 17 {
            // Afternoon suggestions
            newSuggestions.append(contentsOf: getAfternoonSuggestions(for: mood))
        } else {
            // Evening suggestions
            newSuggestions.append(contentsOf: getEveningSuggestions(for: mood))
        }
        
        // Mood-based suggestions
        newSuggestions.append(contentsOf: getMoodBasedSuggestions(for: mood))
        
        // Wellness suggestions
        newSuggestions.append(contentsOf: getWellnessSuggestions())
        
        suggestions = newSuggestions
    }
    
    private func getMorningSuggestions(for mood: MoodType) -> [TaskSuggestion] {
        var suggestions: [TaskSuggestion] = []
        
        switch mood {
        case .positive:
            suggestions.append(TaskSuggestion(
                title: "Plan your day",
                description: "Set intentions for a productive day ahead",
                emotion: .focused,
                priority: .medium
            ))
        case .calm:
            suggestions.append(TaskSuggestion(
                title: "Morning meditation",
                description: "Start your day with 10 minutes of mindfulness",
                emotion: .calm,
                priority: .medium
            ))
        case .focused:
            suggestions.append(TaskSuggestion(
                title: "Tackle important tasks",
                description: "Use your morning focus for high-priority work",
                emotion: .focused,
                priority: .high
            ))
        case .stressed:
            suggestions.append(TaskSuggestion(
                title: "Gentle morning routine",
                description: "Ease into your day with light activities",
                emotion: .calm,
                priority: .low
            ))
        case .creative:
            suggestions.append(TaskSuggestion(
                title: "Creative brainstorming",
                description: "Capture fresh morning ideas",
                emotion: .creative,
                priority: .medium
            ))
        }
        
        return suggestions
    }
    
    private func getAfternoonSuggestions(for mood: MoodType) -> [TaskSuggestion] {
        var suggestions: [TaskSuggestion] = []
        
        switch mood {
        case .positive:
            suggestions.append(TaskSuggestion(
                title: "Collaborate with others",
                description: "Use your positive energy for team projects",
                emotion: .positive,
                priority: .medium
            ))
        case .calm:
            suggestions.append(TaskSuggestion(
                title: "Deep work session",
                description: "Perfect time for focused, detailed tasks",
                emotion: .focused,
                priority: .high
            ))
        case .focused:
            suggestions.append(TaskSuggestion(
                title: "Complex problem solving",
                description: "Tackle challenging projects while focused",
                emotion: .focused,
                priority: .high
            ))
        case .stressed:
            suggestions.append(TaskSuggestion(
                title: "Take a short break",
                description: "Step away and recharge for 15 minutes",
                emotion: .calm,
                priority: .medium
            ))
        case .creative:
            suggestions.append(TaskSuggestion(
                title: "Creative project work",
                description: "Dive into your creative projects",
                emotion: .creative,
                priority: .medium
            ))
        }
        
        return suggestions
    }
    
    private func getEveningSuggestions(for mood: MoodType) -> [TaskSuggestion] {
        var suggestions: [TaskSuggestion] = []
        
        switch mood {
        case .positive:
            suggestions.append(TaskSuggestion(
                title: "Reflect on achievements",
                description: "Celebrate your daily wins",
                emotion: .positive,
                priority: .low
            ))
        case .calm:
            suggestions.append(TaskSuggestion(
                title: "Evening planning",
                description: "Plan tomorrow's priorities",
                emotion: .focused,
                priority: .medium
            ))
        case .focused:
            suggestions.append(TaskSuggestion(
                title: "Review and organize",
                description: "Clean up and prepare for tomorrow",
                emotion: .focused,
                priority: .medium
            ))
        case .stressed:
            suggestions.append(TaskSuggestion(
                title: "Relaxation routine",
                description: "Unwind with calming activities",
                emotion: .calm,
                priority: .high
            ))
        case .creative:
            suggestions.append(TaskSuggestion(
                title: "Creative journaling",
                description: "Capture today's creative insights",
                emotion: .creative,
                priority: .low
            ))
        }
        
        return suggestions
    }
    
    private func getMoodBasedSuggestions(for mood: MoodType) -> [TaskSuggestion] {
        switch mood {
        case .positive:
            return [
                TaskSuggestion(
                    title: "Help someone else",
                    description: "Share your positive energy",
                    emotion: .positive,
                    priority: .medium
                )
            ]
        case .calm:
            return [
                TaskSuggestion(
                    title: "Mindful activity",
                    description: "Practice presence in daily tasks",
                    emotion: .calm,
                    priority: .medium
                )
            ]
        case .focused:
            return [
                TaskSuggestion(
                    title: "Deep work block",
                    description: "Schedule uninterrupted work time",
                    emotion: .focused,
                    priority: .high
                )
            ]
        case .stressed:
            return [
                TaskSuggestion(
                    title: "Stress relief activity",
                    description: "Engage in calming activities",
                    emotion: .calm,
                    priority: .high
                )
            ]
        case .creative:
            return [
                TaskSuggestion(
                    title: "Creative exploration",
                    description: "Try something new and creative",
                    emotion: .creative,
                    priority: .medium
                )
            ]
        }
    }
    
    private func getWellnessSuggestions() -> [TaskSuggestion] {
        return [
            TaskSuggestion(
                title: "Hydration check",
                description: "Drink a glass of water",
                emotion: .calm,
                priority: .medium
            ),
            TaskSuggestion(
                title: "Stretch break",
                description: "Take 5 minutes to stretch",
                emotion: .calm,
                priority: .low
            ),
            TaskSuggestion(
                title: "Gratitude practice",
                description: "Write down 3 things you're grateful for",
                emotion: .positive,
                priority: .low
            )
        ]
    }
}

struct TaskSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let emotion: EmotionType
    let priority: TaskPriority
} 