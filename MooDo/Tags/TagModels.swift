//
//  TagModels.swift
//  Moodo
//
//  Created for improved tag management system
//

import Foundation
import SwiftUI

// MARK: - Tag Model

struct Tag: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var colorHex: String
    var icon: String
    var description: String?
    var createdAt: Date
    var usageCount: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#007AFF",
        icon: String = "tag.fill",
        description: String? = nil,
        createdAt: Date = Date(),
        usageCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
        self.description = description
        self.createdAt = createdAt
        self.usageCount = usageCount
    }
    
    var color: Color {
        Color(hex: colorHex)
    }
    
    // Convenience initializer for quick creation
    static func quickTag(name: String) -> Tag {
        let colors = ["#007AFF", "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7", "#DDA0DD", "#98D8C8"]
        let randomColor = colors.randomElement() ?? "#007AFF"
        return Tag(name: name, colorHex: randomColor)
    }
}

// MARK: - Tag Category (for organization)

enum TagCategory: String, CaseIterable, Codable {
    case work = "Work"
    case personal = "Personal"
    case project = "Project"
    case context = "Context"
    case priority = "Priority"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .project: return "folder.fill"
        case .context: return "location.fill"
        case .priority: return "flag.fill"
        case .custom: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .work: return .blue
        case .personal: return .green
        case .project: return .purple
        case .context: return .orange
        case .priority: return .red
        case .custom: return .gray
        }
    }
}

// MARK: - Tag Group (for organizing tags)

struct TagGroup: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: TagCategory
    var tagIds: [UUID]
    
    init(
        id: UUID = UUID(),
        name: String,
        category: TagCategory = .custom,
        tagIds: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.tagIds = tagIds
    }
}

// MARK: - Tag Statistics

struct TagStatistics {
    let tag: Tag
    let totalUsage: Int
    let recentUsage: Int // Last 7 days
    let associatedTasks: Int
    let lastUsed: Date?
    
    var popularityScore: Double {
        // Calculate popularity based on usage patterns
        let recencyWeight = 0.6
        let totalWeight = 0.4
        
        let recencyScore = Double(recentUsage) * recencyWeight
        let totalScore = Double(min(totalUsage, 100)) / 100.0 * totalWeight
        
        return recencyScore + totalScore
    }
}

// MARK: - Predefined Tags

struct PredefinedTags {
    static let workTags = [
        Tag(name: "meeting", colorHex: "#007AFF", icon: "person.3.fill", description: "Work meetings and calls"),
        Tag(name: "email", colorHex: "#FF9500", icon: "envelope.fill", description: "Email-related tasks"),
        Tag(name: "deadline", colorHex: "#FF3B30", icon: "clock.fill", description: "Tasks with deadlines"),
        Tag(name: "review", colorHex: "#5856D6", icon: "checkmark.circle.fill", description: "Review and approval tasks")
    ]
    
    static let personalTags = [
        Tag(name: "health", colorHex: "#FF2D55", icon: "heart.fill", description: "Health and wellness"),
        Tag(name: "fitness", colorHex: "#00C7BE", icon: "figure.run", description: "Exercise and fitness"),
        Tag(name: "shopping", colorHex: "#FFCC00", icon: "cart.fill", description: "Shopping lists"),
        Tag(name: "home", colorHex: "#30B0C7", icon: "house.fill", description: "Home-related tasks")
    ]
    
    static let contextTags = [
        Tag(name: "urgent", colorHex: "#FF3B30", icon: "exclamationmark.triangle.fill", description: "Urgent tasks"),
        Tag(name: "quick", colorHex: "#34C759", icon: "bolt.fill", description: "Quick tasks (< 5 min)"),
        Tag(name: "focus", colorHex: "#5856D6", icon: "brain.head.profile", description: "Requires deep focus"),
        Tag(name: "waiting", colorHex: "#8E8E93", icon: "hourglass", description: "Waiting for someone/something")
    ]
    
    static var allPredefined: [Tag] {
        workTags + personalTags + contextTags
    }
}