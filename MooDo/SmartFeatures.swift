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
            return ProcessedTask(title: input, description: nil, priority: .medium, emotion: .routine, reminderAt: nil, deadlineAt: nil, tags: [])
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
        let emotion: TaskEmotion
        if lowercased.contains("urgent") || lowercased.contains("asap") || lowercased.contains("deadline") || lowercased.contains("emergency") {
            emotion = .stressful
        } else if lowercased.contains("creative") || lowercased.contains("brainstorm") || lowercased.contains("idea") || lowercased.contains("design") {
            emotion = .creative
        } else if lowercased.contains("focus") || lowercased.contains("work") || lowercased.contains("study") || lowercased.contains("concentrate") {
            emotion = .focused
        } else if lowercased.contains("calm") || lowercased.contains("relax") || lowercased.contains("peaceful") || lowercased.contains("meditation") {
            emotion = .calming
        } else if lowercased.contains("energy") || lowercased.contains("workout") || lowercased.contains("exercise") || lowercased.contains("project") {
            emotion = .energizing
        } else if lowercased.contains("routine") || lowercased.contains("organize") || lowercased.contains("clean") || lowercased.contains("simple") {
            emotion = .routine
        } else {
            emotion = .routine
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
        
        // Enhanced date patterns for days of week and specific dates
        if let smartDate = extractSmartDate(from: lowercased, now: now) {
            #if DEBUG
            print("✅ Extracted smart date: \(smartDate)")
            #endif
            return smartDate
        }
        
        return nil
    }
    
    // MARK: - Enhanced Date Extraction
    
    private func extractSmartDate(from input: String, now: Date) -> Date? {
        let words = input.components(separatedBy: " ")
        
        // Day names mapping
        let dayNames = [
            "monday": 2, "tuesday": 3, "wednesday": 4, "thursday": 5,
            "friday": 6, "saturday": 7, "sunday": 1,
            "mon": 2, "tue": 3, "wed": 4, "thu": 5, "fri": 6, "sat": 7, "sun": 1
        ]
        
        // Month names mapping
        let monthNames = [
            "january": 1, "february": 2, "march": 3, "april": 4, "may": 5, "june": 6,
            "july": 7, "august": 8, "september": 9, "october": 10, "november": 11, "december": 12,
            "jan": 1, "feb": 2, "mar": 3, "apr": 4, "jun": 6, "jul": 7, "aug": 8,
            "sep": 9, "oct": 10, "nov": 11, "dec": 12
        ]
        
        var targetDate: Date?
        var timeComponents: (hour: Int, minute: Int)?
        
        // Extract time (5pm, 3:30pm, etc.)
        for word in words {
            if word.contains("pm") || word.contains("am") {
                let isPM = word.contains("pm")
                let timeString = word.replacingOccurrences(of: "pm", with: "").replacingOccurrences(of: "am", with: "")
                
                if timeString.contains(":") {
                    let timeParts = timeString.components(separatedBy: ":")
                    if timeParts.count == 2, let hour = Int(timeParts[0]), let minute = Int(timeParts[1]) {
                        var adjustedHour = hour
                        if isPM && hour != 12 {
                            adjustedHour += 12
                        } else if !isPM && hour == 12 {
                            adjustedHour = 0
                        }
                        timeComponents = (adjustedHour, minute)
                    }
                } else if let hour = Int(timeString) {
                    var adjustedHour = hour
                    if isPM && hour != 12 {
                        adjustedHour += 12
                    } else if !isPM && hour == 12 {
                        adjustedHour = 0
                    }
                    timeComponents = (adjustedHour, 0)
                }
                break
            }
        }
        
        // Handle "tomorrow"
        if input.contains("tomorrow") {
            targetDate = calendar.date(byAdding: .day, value: 1, to: now)
        }
        
        // Handle "today"
        if input.contains("today") {
            targetDate = now
        }
        
        // Handle "next week" patterns
        if input.contains("next week") {
            targetDate = calendar.date(byAdding: .weekOfYear, value: 1, to: now)
        }
        
        // Handle day names (friday, next friday, etc.)
        for (dayName, dayNumber) in dayNames {
            if input.contains(dayName) {
                let currentWeekday = calendar.component(.weekday, from: now)
                var daysToAdd = dayNumber - currentWeekday
                
                // If it's the same day or earlier in the week, go to next week
                if daysToAdd <= 0 {
                    daysToAdd += 7
                }
                
                // Handle "next" modifier
                if input.contains("next \(dayName)") || input.contains("next week") {
                    daysToAdd += 7
                }
                
                targetDate = calendar.date(byAdding: .day, value: daysToAdd, to: now)
                break
            }
        }
        
        // Handle specific dates (august 15, 15th august, etc.)
        for (monthName, monthNumber) in monthNames {
            if input.contains(monthName) {
                // Look for day number near the month
                for word in words {
                    let cleanWord = word.replacingOccurrences(of: "th", with: "")
                        .replacingOccurrences(of: "st", with: "")
                        .replacingOccurrences(of: "nd", with: "")
                        .replacingOccurrences(of: "rd", with: "")
                        .replacingOccurrences(of: ",", with: "")
                    
                    if let day = Int(cleanWord), day >= 1 && day <= 31 {
                        var dateComponents = calendar.dateComponents([.year], from: now)
                        dateComponents.month = monthNumber
                        dateComponents.day = day
                        
                        // If the date is in the past this year, assume next year
                        let potentialDate = calendar.date(from: dateComponents)
                        if let date = potentialDate, date < now {
                            dateComponents.year = (dateComponents.year ?? 0) + 1
                        }
                        
                        targetDate = calendar.date(from: dateComponents)
                        break
                    }
                }
                break
            }
        }
        
        // Combine date and time if both found
        if let date = targetDate, let time = timeComponents {
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            dateComponents.hour = time.hour
            dateComponents.minute = time.minute
            
            let finalDate = calendar.date(from: dateComponents)
            
            // If time has passed today, and we're setting for "today", move to tomorrow
            if input.contains("today"), let result = finalDate, result <= now {
                var tomorrowComponents = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
                tomorrowComponents.hour = time.hour
                tomorrowComponents.minute = time.minute
                return calendar.date(from: tomorrowComponents)
            }
            
            return finalDate
        }
        
        // If we found a date but no time, default to 9 AM
        if let date = targetDate {
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            dateComponents.hour = 9
            dateComponents.minute = 0
            return calendar.date(from: dateComponents)
        }
        
        return nil
    }
    
    private func extractTags(from input: String) -> [String] {
        var tags: [String] = []
        
        // Look for hashtag-style tags (#tag) - this is the only way to add tags
        let hashtagPattern = "#(\\w+)"
        let hashtagRegex = try? NSRegularExpression(pattern: hashtagPattern, options: [])
        let hashtagMatches = hashtagRegex?.matches(in: input, options: [], range: NSRange(location: 0, length: input.count)) ?? []
        
        for match in hashtagMatches {
            if let range = Range(match.range(at: 1), in: input) {
                let tag = String(input[range])
                if !tags.contains(tag) {
                    tags.append(tag)
                }
                // Limit to 3 tags maximum
                if tags.count >= 3 {
                    break
                }
            }
        }
        
        return tags
    }
}

struct ProcessedTask {
    let title: String
    let description: String?
    let priority: TaskPriority
    let emotion: TaskEmotion
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
        case .energized:
            return "Great energy! Perfect time to tackle challenging tasks."
        case .calm:
            return "Peaceful state. Ideal for focused, detailed work."
        case .focused:
            return "Sharp focus detected. Use this energy for complex projects."
        case .stressed:
            return "Feeling overwhelmed? Try breaking tasks into smaller steps."
        case .creative:
            return "Creative flow! Great time for brainstorming and ideation."
        case .tired:
            return "Feeling tired? Take a short break or focus on simple, restorative tasks."
        case .anxious:
            return "Feeling anxious? Try some deep breathing or gentle, comforting tasks."
        }
    }
}

struct Insight: Identifiable {
    var id = UUID()
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

 
// MARK: - Smart Task Suggestions System

struct TaskSuggestion {
    let title: String
    let description: String
    let emotion: TaskEmotion
    let priority: TaskPriority
}

class SmartTaskSuggestions: ObservableObject {
    @Published var suggestions: [TaskSuggestion] = []
    
    // Performance optimization: Cache suggestions to avoid regenerating
    private var cachedSuggestions: [TaskSuggestion] = []
    private var lastMood: MoodType?
    private var lastGenerationTime: Date?
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes
    
    func generateSuggestions(mood: MoodType, timeOfDay: Date, completedTasks: [Task]) {
        var newSuggestions: [TaskSuggestion] = []
        
        // Get mood-compatible task emotions
        let compatibleEmotions = mood.compatibleTaskEmotions
        
        // Generate suggestions based on mood and time of day
        let hour = Calendar.current.component(.hour, from: timeOfDay)
        
        if hour < 12 {
            // Morning suggestions
            newSuggestions.append(contentsOf: getMorningSuggestions(for: mood, compatibleEmotions: compatibleEmotions))
        } else if hour < 17 {
            // Afternoon suggestions
            newSuggestions.append(contentsOf: getAfternoonSuggestions(for: mood, compatibleEmotions: compatibleEmotions))
        } else {
            // Evening suggestions
            newSuggestions.append(contentsOf: getEveningSuggestions(for: mood, compatibleEmotions: compatibleEmotions))
        }
        
        // Add mood-specific suggestions
        newSuggestions.append(contentsOf: getMoodSpecificSuggestions(for: mood))
        
        // Analyze completed tasks to provide personalized suggestions
        if !completedTasks.isEmpty {
            newSuggestions.append(contentsOf: getPersonalizedSuggestions(from: completedTasks, mood: mood))
        }
        
        suggestions = newSuggestions
    }
    
    private func getMorningSuggestions(for mood: MoodType, compatibleEmotions: [TaskEmotion]) -> [TaskSuggestion] {
        var suggestions: [TaskSuggestion] = []
        
        switch mood {
        case .energized:
            suggestions.append(TaskSuggestion(
                title: "Tackle important project",
                description: "Use your high energy for complex work",
                emotion: .energizing,
                priority: .high
            ))
        case .focused:
            suggestions.append(TaskSuggestion(
                title: "Plan your day",
                description: "Set clear priorities and goals",
                emotion: .focused,
                priority: .medium
            ))
        case .calm:
            suggestions.append(TaskSuggestion(
                title: "Morning meditation",
                description: "Start your day with mindfulness",
                emotion: .calming,
                priority: .low
            ))
        case .creative:
            suggestions.append(TaskSuggestion(
                title: "Creative brainstorming",
                description: "Capture fresh morning ideas",
                emotion: .creative,
                priority: .medium
            ))
        case .stressed:
            suggestions.append(TaskSuggestion(
                title: "Take a gentle walk",
                description: "Start with something calming",
                emotion: .calming,
                priority: .low
            ))
        case .tired:
            suggestions.append(TaskSuggestion(
                title: "Light organizing",
                description: "Simple tasks to ease into the day",
                emotion: .routine,
                priority: .low
            ))
        case .anxious:
            suggestions.append(TaskSuggestion(
                title: "Breathing exercise",
                description: "Start with calming breathwork",
                emotion: .calming,
                priority: .high
            ))
        }
        
        return suggestions
    }
    
    private func getAfternoonSuggestions(for mood: MoodType, compatibleEmotions: [TaskEmotion]) -> [TaskSuggestion] {
        var suggestions: [TaskSuggestion] = []
        
        switch mood {
        case .energized:
            suggestions.append(TaskSuggestion(
                title: "Handle important calls",
                description: "Use your energy for communication",
                emotion: .energizing,
                priority: .high
            ))
        case .focused:
            suggestions.append(TaskSuggestion(
                title: "Deep work session",
                description: "Perfect time for concentrated tasks",
                emotion: .focused,
                priority: .high
            ))
        case .calm:
            suggestions.append(TaskSuggestion(
                title: "Review and organize notes",
                description: "A calm mind is great for organizing",
                emotion: .calming,
                priority: .medium
            ))
        case .creative:
            suggestions.append(TaskSuggestion(
                title: "Work on a creative project",
                description: "Channel your afternoon creativity",
                emotion: .creative,
                priority: .medium
            ))
        case .stressed:
            suggestions.append(TaskSuggestion(
                title: "Practice a quick mindfulness exercise",
                description: "Take a short break to reset",
                emotion: .calming,
                priority: .high
            ))
        case .tired:
            suggestions.append(TaskSuggestion(
                title: "Handle simple emails or routine tasks",
                description: "Low-energy tasks are perfect for now",
                emotion: .routine,
                priority: .low
            ))
        case .anxious:
            suggestions.append(TaskSuggestion(
                title: "Gentle grounding exercise",
                description: "Focus on calming activities",
                emotion: .calming,
                priority: .high
            ))
        }
        
        return suggestions
    }
    
    private func getEveningSuggestions(for mood: MoodType, compatibleEmotions: [TaskEmotion]) -> [TaskSuggestion] {
        var suggestions: [TaskSuggestion] = []
        
        switch mood {
        case .energized:
            suggestions.append(TaskSuggestion(
                title: "Exercise or workout",
                description: "Use your energy positively",
                emotion: .energizing,
                priority: .medium
            ))
        case .focused:
            suggestions.append(TaskSuggestion(
                title: "Plan tomorrow",
                description: "Set up for success",
                emotion: .focused,
                priority: .medium
            ))
        case .calm:
            suggestions.append(TaskSuggestion(
                title: "Relaxing activities",
                description: "Wind down peacefully",
                emotion: .calming,
                priority: .low
            ))
        case .creative:
            suggestions.append(TaskSuggestion(
                title: "Creative journaling",
                description: "Capture today's insights",
                emotion: .creative,
                priority: .low
            ))
        case .stressed:
            suggestions.append(TaskSuggestion(
                title: "Stress relief routine",
                description: "Focus on self-care",
                emotion: .calming,
                priority: .high
            ))
        case .tired:
            suggestions.append(TaskSuggestion(
                title: "Prepare for rest",
                description: "Simple evening routine",
                emotion: .routine,
                priority: .low
            ))
        case .anxious:
            suggestions.append(TaskSuggestion(
                title: "Calming evening routine",
                description: "Focus on soothing activities",
                emotion: .calming,
                priority: .high
            ))
        }
        
        return suggestions
    }
    
    private func getMoodSpecificSuggestions(for mood: MoodType) -> [TaskSuggestion] {
        switch mood {
        case .energized:
            return [
                TaskSuggestion(title: "Tackle taxes or finances", description: "Use high energy for complex tasks", emotion: .energizing, priority: .high),
                TaskSuggestion(title: "Important phone calls", description: "Handle challenging conversations", emotion: .energizing, priority: .medium)
            ]
        case .focused:
            return [
                TaskSuggestion(title: "Write or analyze", description: "Perfect for detailed work", emotion: .focused, priority: .high),
                TaskSuggestion(title: "Plan projects", description: "Strategic thinking time", emotion: .focused, priority: .medium)
            ]
        case .calm:
            return [
                TaskSuggestion(title: "Cut the grass", description: "Peaceful outdoor activity", emotion: .routine, priority: .low),
                TaskSuggestion(title: "Call a friend", description: "Gentle social connection", emotion: .calming, priority: .low)
            ]
        case .creative:
            return [
                TaskSuggestion(title: "Design or art work", description: "Channel your creativity", emotion: .creative, priority: .medium),
                TaskSuggestion(title: "Brainstorm new ideas", description: "Let inspiration flow", emotion: .creative, priority: .medium)
            ]
        case .stressed:
            return [
                TaskSuggestion(title: "Take a walk", description: "Simple, calming movement", emotion: .calming, priority: .high),
                TaskSuggestion(title: "Deep breathing exercise", description: "Reduce stress with mindfulness", emotion: .calming, priority: .medium)
            ]
        case .tired:
            return [
                TaskSuggestion(title: "Rest and recharge", description: "Take a short nap if possible", emotion: .calming, priority: .high),
                TaskSuggestion(title: "Simple organization", description: "Low-energy tasks to feel productive", emotion: .routine, priority: .low)
            ]
        case .anxious:
            return [
                TaskSuggestion(title: "Deep breathing exercise", description: "Calm your nervous system", emotion: .calming, priority: .high),
                TaskSuggestion(title: "Comfort activities", description: "Do something familiar and soothing", emotion: .routine, priority: .medium)
            ]
        }
    }
    
    private func getPersonalizedSuggestions(from completedTasks: [Task], mood: MoodType) -> [TaskSuggestion] {
        var suggestions: [TaskSuggestion] = []
        
        // Analyze patterns in completed tasks
        let taskTypes = Dictionary(grouping: completedTasks, by: { $0.emotion })
            .mapValues { $0.count }
        
        // Find most common task type
        if let mostCommonType = taskTypes.max(by: { $0.value < $1.value })?.key {
            // Suggest similar tasks based on user's history and current mood
            if mood.compatibleTaskEmotions.contains(mostCommonType) {
                switch mostCommonType {
                case .energizing:
                    suggestions.append(TaskSuggestion(
                        title: "Another energizing activity",
                        description: "You seem to enjoy these types of tasks",
                        emotion: .energizing,
                        priority: .medium
                    ))
                case .focused:
                    suggestions.append(TaskSuggestion(
                        title: "Focus session",
                        description: "Based on your productivity patterns",
                        emotion: .focused,
                        priority: .medium
                    ))
                case .calming:
                    suggestions.append(TaskSuggestion(
                        title: "Mindfulness break",
                        description: "You benefit from these moments",
                        emotion: .calming,
                        priority: .medium
                    ))
                case .creative:
                    suggestions.append(TaskSuggestion(
                        title: "Creative exploration",
                        description: "Tap into your creative side",
                        emotion: .creative,
                        priority: .medium
                    ))
                case .routine:
                    suggestions.append(TaskSuggestion(
                        title: "Quick organization task",
                        description: "You're good at completing these",
                        emotion: .routine,
                        priority: .medium
                    ))
                case .anxious:
                    suggestions.append(TaskSuggestion(
                        title: "Take a wellness break",
                        description: "A short breathing or stretch break can ease anxiety",
                        emotion: .calming,
                        priority: .medium
                    ))
                case .stressful:
                    // Don't suggest stressful tasks based on history
                    break
                }
            }
        }
        
        // Look for recurring task patterns
        let taskTitles = completedTasks.map { $0.title.lowercased() }
        if taskTitles.contains(where: { $0.contains("exercise") || $0.contains("workout") || $0.contains("gym") }) {
            suggestions.append(TaskSuggestion(
                title: "Exercise session",
                description: "Stay consistent with your fitness",
                emotion: .energizing,
                priority: .medium
            ))
        }
        
        if taskTitles.contains(where: { $0.contains("meditate") || $0.contains("mindfulness") || $0.contains("breathing") }) {
            suggestions.append(TaskSuggestion(
                title: "Meditation practice",
                description: "Continue your mindfulness routine",
                emotion: .calming,
                priority: .medium
            ))
        }
        
        return suggestions
    }
}

