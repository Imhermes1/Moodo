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
    
    func processNaturalLanguage(_ input: String) -> ProcessedTask {
        isProcessing = true
        
        // Simulate AI processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
        
        // Detect time references
        if let timeMatch = extractTime(from: input) {
            analysis += "⏰ Detected: Time reference - \(timeMatch)\n"
        }
        
        return analysis
    }
    
    private func analyzeTextForTask(_ input: String) -> ProcessedTask {
        let lowercased = input.lowercased()
        
        // Extract title (first sentence or key phrase)
        let title = extractTitle(from: input)
        
        // Determine priority
        let priority: TaskPriority = if lowercased.contains("urgent") || lowercased.contains("asap") {
            .high
        } else if lowercased.contains("important") || lowercased.contains("today") {
            .medium
        } else {
            .low
        }
        
        // Determine emotion
        let emotion: EmotionType = if lowercased.contains("creative") || lowercased.contains("brainstorm") {
            .creative
        } else if lowercased.contains("focus") || lowercased.contains("work") {
            .focused
        } else if lowercased.contains("urgent") || lowercased.contains("asap") {
            .urgent
        } else if lowercased.contains("calm") || lowercased.contains("relax") {
            .calm
        } else {
            .positive
        }
        
        // Extract reminder time
        let reminderAt = extractReminderTime(from: input)
        
        return ProcessedTask(
            title: title,
            description: extractDescription(from: input),
            priority: priority,
            emotion: emotion,
            reminderAt: reminderAt,
            naturalLanguageInput: input
        )
    }
    
    private func extractTitle(from input: String) -> String {
        // Take the first sentence or key phrase
        let sentences = input.components(separatedBy: [".", "!", "?"])
        let firstSentence = sentences.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? input
        
        // Clean up common prefixes
        let cleaned = firstSentence
            .replacingOccurrences(of: "I need to ", with: "")
            .replacingOccurrences(of: "I want to ", with: "")
            .replacingOccurrences(of: "I should ", with: "")
            .replacingOccurrences(of: "I have to ", with: "")
            .replacingOccurrences(of: "Remind me to ", with: "")
            .replacingOccurrences(of: "Don't forget to ", with: "")
        
        return cleaned.isEmpty ? input : cleaned
    }
    
    private func extractDescription(from input: String) -> String? {
        let sentences = input.components(separatedBy: [".", "!", "?"])
        if sentences.count > 1 {
            return sentences.dropFirst().joined(separator: ". ").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }
    
    private func extractTime(from input: String) -> String? {
        let lowercased = input.lowercased()
        
        // Common time patterns
        let timePatterns = [
            "in (\\d+) minutes": "in $1 minutes",
            "in (\\d+) hours": "in $1 hours",
            "in (\\d+) days": "in $1 days",
            "at (\\d{1,2}):(\\d{2})": "at $1:$2",
            "at (\\d{1,2}) (am|pm)": "at $1 $2",
            "tomorrow at (\\d{1,2}):(\\d{2})": "tomorrow at $1:$2",
            "today at (\\d{1,2}):(\\d{2})": "today at $1:$2"
        ]
        
        for pattern in timePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern.key) {
                let range = NSRange(lowercased.startIndex..<lowercased.endIndex, in: lowercased)
                if regex.firstMatch(in: lowercased, range: range) != nil {
                    return pattern.value
                }
            }
        }
        
        return nil
    }
    
    private func extractReminderTime(from input: String) -> Date? {
        let lowercased = input.lowercased()
        let now = Date()
        let calendar = Calendar.current
        
        // "in X minutes"
        if let minutesMatch = lowercased.range(of: "in (\\d+) minutes", options: .regularExpression) {
            let minutes = Int(lowercased[minutesMatch].components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
            return calendar.date(byAdding: .minute, value: minutes, to: now)
        }
        
        // "in X hours"
        if let hoursMatch = lowercased.range(of: "in (\\d+) hours", options: .regularExpression) {
            let hours = Int(lowercased[hoursMatch].components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
            return calendar.date(byAdding: .hour, value: hours, to: now)
        }
        
        // "tomorrow"
        if lowercased.contains("tomorrow") {
            return calendar.date(byAdding: .day, value: 1, to: now)
        }
        
        // "today at X:XX"
        if let timeMatch = lowercased.range(of: "today at (\\d{1,2}):(\\d{2})", options: .regularExpression) {
            let timeString = String(lowercased[timeMatch])
            let components = timeString.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
            if components.count >= 2 {
                let hour = Int(components[0]) ?? 0
                let minute = Int(components[1]) ?? 0
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
                dateComponents.hour = hour
                dateComponents.minute = minute
                return calendar.date(from: dateComponents)
            }
        }
        
        return nil
    }
}

struct ProcessedTask {
    let title: String
    let description: String?
    let priority: TaskPriority
    let emotion: EmotionType
    let reminderAt: Date?
    let naturalLanguageInput: String
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