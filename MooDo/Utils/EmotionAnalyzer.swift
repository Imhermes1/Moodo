//
//  EmotionAnalyzer.swift
//  Moodo
//
//  Created by AI Assistant on 4/8/2025.
//

import Foundation

class EmotionAnalyzer {
    static let shared = EmotionAnalyzer()
    
    private init() {}
    
    // Comprehensive emotion keyword mapping
    private let emotionKeywords: [TaskEmotion: [String]] = [
        .creative: [
            // Core creative words
            "design", "create", "write", "brainstorm", "art", "music", "draw", "paint", "compose",
            "creative", "innovate", "imagine", "craft", "build", "make", "develop", "invent",
            // Creative activities
            "blog", "story", "poem", "video", "photo", "sketch", "prototype", "logo", "website",
            "presentation", "mockup", "wireframe", "concept", "idea", "vision", "script",
            // Creative verbs
            "express", "inspire", "visualise", "conceptualise", "ideate", "collaborate"
        ],
        
        .energizing: [
            // Physical activities
            "workout", "run", "exercise", "gym", "jog", "swim", "bike", "hike", "walk", "dance",
            "sport", "train", "fitness", "cardio", "strength", "yoga", "pilates", "stretch",
            // High-energy tasks
            "clean", "organise", "declutter", "rearrange", "sort", "tidy", "vacuum", "wash",
            "move", "pack", "unpack", "renovate", "repair", "fix", "install", "setup",
            // Action words
            "go", "do", "active", "energetic", "power", "boost", "pump", "intense", "dynamic"
        ],
        
        .calming: [
            // Relaxation activities
            "meditate", "read", "journal", "reflect", "breathe", "relax", "rest", "sleep", "nap",
            "unwind", "decompress", "chill", "peaceful", "quiet", "serene", "tranquil",
            // Mindful activities
            "contemplate", "ponder", "think", "consider", "observe", "listen", "watch", "view",
            "nature", "garden", "plants", "tea", "coffee", "bath", "massage", "spa",
            // Gentle words
            "gentle", "slow", "soft", "easy", "simple", "minimal", "light", "calm", "zen", "colour"
        ],
        
        .focused: [
            // Work and study
            "study", "work", "analyse", "review", "research", "examine", "investigate", "learn",
            "code", "program", "develop", "debug", "test", "solve", "calculate", "compute",
            // Mental tasks
            "focus", "concentrate", "think", "plan", "strategy", "organise", "schedule", "prepare",
            "meeting", "call", "email", "report", "document", "spreadsheet", "data", "analysis",
            // Professional activities
            "business", "project", "task", "deadline", "goal", "objective", "target", "milestone",
            "complete", "finish", "accomplish", "achieve", "deliver", "submit", "present"
        ],
        
        .routine: [
            // Daily tasks
            "check", "update", "review", "scan", "browse", "sort", "file", "backup", "sync",
            "maintenance", "routine", "regular", "daily", "weekly", "monthly", "schedule",
            // Simple activities
            "pay", "bill", "invoice", "receipt", "form", "paperwork", "admin", "basic", "simple",
            "quick", "easy", "straightforward", "normal", "standard", "usual", "typical"
        ],

        .stressful: [
            // Deadline pressure
            "deadline", "urgent", "asap", "rush", "hurry", "pressure", "stress", "crisis", "emergency",
            "important", "critical", "priority", "must", "need", "required", "essential",
            // Challenging tasks
            "difficult", "hard", "complex", "complicated", "challenging", "tough", "demanding",
            "interview", "presentation", "meeting", "exam", "test", "evaluation", "review",
            // Anxiety-inducing
            "tax", "taxes", "legal", "doctor", "medical", "finance", "budget", "money", "debt"
        ],

        .anxious: [
            // Anxiety-related terms
            "anxious", "anxiety", "nervous", "worry", "worried", "uneasy", "fear", "scared",
            "concern", "panic", "apprehensive"
        ]
    ]
    
    // Action words that might indicate energy level
    private let energyIndicators: [String: Float] = [
        "urgent": 0.8, "asap": 0.9, "rush": 0.9, "quick": 0.7, "fast": 0.7,
        "slow": 0.2, "later": 0.3, "eventually": 0.2, "someday": 0.1,
        "important": 0.6, "critical": 0.8, "priority": 0.7
    ]
    
    func analyzeEmotion(from title: String) -> (emotion: TaskEmotion, confidence: Float) {
        let lowercaseTitle = title.lowercased()
        let words = lowercaseTitle.components(separatedBy: CharacterSet.whitespaces.union(.punctuationCharacters))
        
        var emotionScores: [TaskEmotion: Float] = [
            .creative: 0,
            .energizing: 0,
            .calming: 0,
            .focused: 0,
            .routine: 0,
            .stressful: 0,
            .anxious: 0
        ]
        
        // Analyze each word in the title
        for word in words {
            guard !word.isEmpty else { continue }
            
            // Check for exact matches in emotion keywords
            for (emotion, keywords) in emotionKeywords {
                if keywords.contains(word) {
                    emotionScores[emotion, default: 0] += 1.0
                }
                
                // Check for partial matches (word contains keyword or vice versa)
                for keyword in keywords {
                    if word.contains(keyword) || keyword.contains(word) {
                        emotionScores[emotion, default: 0] += 0.5
                    }
                }
            }
        }
        
        // Apply energy level modifiers
        for word in words {
            if let energyLevel = energyIndicators[word] {
                if energyLevel > 0.6 {
                    emotionScores[.energizing, default: 0] += energyLevel
                    emotionScores[.focused, default: 0] += energyLevel * 0.5
                    emotionScores[.stressful, default: 0] += energyLevel * 0.3
                } else if energyLevel < 0.4 {
                    emotionScores[.calming, default: 0] += (1.0 - energyLevel)
                    emotionScores[.routine, default: 0] += (1.0 - energyLevel) * 0.5
                }
            }
        }
        
        // Special patterns
        analyzeSpecialPatterns(title: lowercaseTitle, scores: &emotionScores)
        
        // Find the highest scoring emotion
        let sortedEmotions = emotionScores.sorted { $0.value > $1.value }
        
        guard let topEmotion = sortedEmotions.first, topEmotion.value > 0 else {
            // No matches found, default to focused with low confidence
            return (.focused, 0.1)
        }
        
        // Calculate confidence based on score difference
        let topScore = topEmotion.value
        let secondScore = sortedEmotions.count > 1 ? sortedEmotions[1].value : 0
        let confidence = min(1.0, topScore / max(1.0, topScore + secondScore))
        
        return (topEmotion.key, confidence)
    }
    
    private func analyzeSpecialPatterns(title: String, scores: inout [TaskEmotion: Float]) {
        // Time-based patterns
        if title.contains("morning") || title.contains("early") {
            scores[.energizing, default: 0] += 0.3
        }
        
        if title.contains("evening") || title.contains("night") || title.contains("before bed") {
            scores[.calming, default: 0] += 0.4
        }
        
        // Context patterns
        if title.contains("with") && (title.contains("team") || title.contains("friends") || title.contains("family")) {
            scores[.energizing, default: 0] += 0.2
        }
        
        // Question marks might indicate creative or analytical thinking
        if title.contains("?") {
            scores[.creative, default: 0] += 0.2
            scores[.focused, default: 0] += 0.2
        }
        
        // Numbers and data patterns
        if title.range(of: "\\d+", options: .regularExpression) != nil {
            scores[.focused, default: 0] += 0.3
        }
        
        // Routine indicators
        if title.contains("daily") || title.contains("weekly") || title.contains("monthly") || title.contains("check") {
            scores[.routine, default: 0] += 0.4
        }
        
        // Stress indicators
        if title.contains("!") || title.contains("urgent") || title.contains("asap") {
            scores[.stressful, default: 0] += 0.5
        }
    }
    
    // Public method for getting analysis with user-friendly description
    func getEmotionAnalysis(from title: String) -> EmotionAnalysis {
        let result = analyzeEmotion(from: title)
        
        let confidenceLevel: ConfidenceLevel
        switch result.confidence {
        case 0.8...1.0:
            confidenceLevel = .high
        case 0.5..<0.8:
            confidenceLevel = .medium
        case 0.2..<0.5:
            confidenceLevel = .low
        default:
            confidenceLevel = .veryLow
        }
        
        return EmotionAnalysis(
            suggestedEmotion: result.emotion,
            confidence: result.confidence,
            confidenceLevel: confidenceLevel,
            reasonText: generateReasonText(for: result.emotion, title: title)
        )
    }
    
    private func generateReasonText(for emotion: TaskEmotion, title: String) -> String {
        let lowercaseTitle = title.lowercased()
        
        switch emotion {
        case .creative:
            if lowercaseTitle.contains("design") || lowercaseTitle.contains("create") {
                return "Creative task detected"
            }
            return "Suggests creative thinking"
            
        case .energizing:
            if lowercaseTitle.contains("workout") || lowercaseTitle.contains("exercise") {
                return "Physical activity detected"
            }
            return "Requires active energy"
            
        case .calming:
            if lowercaseTitle.contains("read") || lowercaseTitle.contains("meditate") {
                return "Relaxing activity detected"
            }
            return "Peaceful task identified"
            
        case .focused:
            if lowercaseTitle.contains("work") || lowercaseTitle.contains("study") {
                return "Focus-intensive task"
            }
            return "Requires concentration"
            
        case .routine:
            if lowercaseTitle.contains("daily") || lowercaseTitle.contains("check") {
                return "Regular task detected"
            }
            return "Simple routine activity"

        case .stressful:
            if lowercaseTitle.contains("deadline") || lowercaseTitle.contains("urgent") {
                return "Time pressure detected"
            }
            return "Challenging task identified"

        case .anxious:
            if lowercaseTitle.contains("worry") || lowercaseTitle.contains("anxious") {
                return "Anxiety-inducing task"
            }
            return "May trigger anxiety"
        }
    }
}

// MARK: - Supporting Types

struct EmotionAnalysis {
    let suggestedEmotion: TaskEmotion
    let confidence: Float
    let confidenceLevel: ConfidenceLevel
    let reasonText: String
}

enum ConfidenceLevel: String, CaseIterable {
    case veryLow = "Not sure"
    case low = "Maybe"
    case medium = "Likely"
    case high = "Confident"
    
    var description: String {
        switch self {
        case .veryLow: return "AI isn't sure"
        case .low: return "AI thinks maybe"
        case .medium: return "AI suggests"
        case .high: return "AI is confident"
        }
    }
    
    var color: Color {
        switch self {
        case .veryLow: return .gray
        case .low: return .orange
        case .medium: return .blue
        case .high: return .green
        }
    }
}

import SwiftUI
extension Color {
    static let aiSuggestion = Color(red: 0.99, green: 0.75, blue: 0.22) // Example: a warm yellow
}
