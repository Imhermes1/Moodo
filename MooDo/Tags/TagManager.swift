//
//  TagManager.swift
//  Moodo
//
//  Centralized tag management system
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TagManager: ObservableObject {
    @Published var tags: [Tag] = []
    @Published var tagGroups: [TagGroup] = []
    @Published var recentlyUsedTags: [Tag] = []
    @Published var suggestedTags: [Tag] = []
    
    private let userDefaults = UserDefaults.standard
    private let tagsKey = "SavedTags"
    private let tagGroupsKey = "SavedTagGroups"
    private let maxRecentTags = 10
    
    // Singleton for global access
    static let shared = TagManager()
    
    init() {
        loadTags()
        loadTagGroups()
        setupPredefinedTagsIfNeeded()
    }
    
    // MARK: - Tag CRUD Operations
    
    func createTag(_ tag: Tag) {
        // Check for duplicate names
        guard !tags.contains(where: { $0.name.lowercased() == tag.name.lowercased() }) else {
            print("⚠️ Tag with name '\(tag.name)' already exists")
            return
        }
        
        tags.append(tag)
        saveTags()
        
        // Add haptic feedback
        HapticManager.shared.impact(.light)
    }
    
    func updateTag(_ tag: Tag) {
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            tags[index] = tag
            saveTags()
        }
    }
    
    func deleteTag(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
        
        // Remove from all groups
        for i in tagGroups.indices {
            tagGroups[i].tagIds.removeAll { $0 == tag.id }
        }
        
        saveTags()
        saveTagGroups()
        
        HapticManager.shared.impact(.light)
    }
    
    func getTag(byName name: String) -> Tag? {
        return tags.first { $0.name.lowercased() == name.lowercased() }
    }
    
    func getTag(byId id: UUID) -> Tag? {
        return tags.first { $0.id == id }
    }
    
    // MARK: - Tag Usage
    
    func recordTagUsage(_ tag: Tag) {
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            tags[index].usageCount += 1
            saveTags()
            
            // Update recently used
            updateRecentlyUsedTags(tag)
        }
    }
    
    private func updateRecentlyUsedTags(_ tag: Tag) {
        // Remove if already exists
        recentlyUsedTags.removeAll { $0.id == tag.id }
        
        // Add to front
        recentlyUsedTags.insert(tag, at: 0)
        
        // Keep only max recent
        if recentlyUsedTags.count > maxRecentTags {
            recentlyUsedTags = Array(recentlyUsedTags.prefix(maxRecentTags))
        }
    }
    
    // MARK: - Tag Suggestions
    
    func getSuggestedTags(for text: String, currentTags: [String] = []) -> [Tag] {
        let lowercasedText = text.lowercased()
        var suggestions: [Tag] = []
        
        // Filter out already selected tags
        let availableTags = tags.filter { tag in
            !currentTags.contains { $0.lowercased() == tag.name.lowercased() }
        }
        
        // 1. Exact prefix matches (highest priority)
        let prefixMatches = availableTags.filter { tag in
            tag.name.lowercased().hasPrefix(lowercasedText)
        }
        suggestions.append(contentsOf: prefixMatches)
        
        // 2. Contains matches (if not enough prefix matches)
        if suggestions.count < 5 {
            let containsMatches = availableTags.filter { tag in
                !prefixMatches.contains(tag) &&
                tag.name.lowercased().contains(lowercasedText)
            }
            suggestions.append(contentsOf: containsMatches)
        }
        
        // 3. Sort by usage count and limit
        suggestions.sort { $0.usageCount > $1.usageCount }
        return Array(suggestions.prefix(5))
    }
    
    func getAutocompleteSuggestions(for task: Task) -> [Tag] {
        var suggestions: [Tag] = []
        let taskText = (task.title + " " + (task.description ?? "")).lowercased()
        
        // Exclude already added tags
        let availableTags = tags.filter { tag in
            !task.tags.contains { $0.lowercased() == tag.name.lowercased() }
        }
        
        // 1. Recently used tags (if task is new)
        if task.tags.isEmpty {
            suggestions.append(contentsOf: recentlyUsedTags.prefix(2))
        }
        
        // 2. Context-based suggestions
        for tag in availableTags {
            if let description = tag.description?.lowercased() {
                // Check if task text contains keywords from tag description
                let keywords = description.split(separator: " ")
                if keywords.contains(where: { taskText.contains($0) }) {
                    suggestions.append(tag)
                }
            }
            
            // Check if tag name appears in task text
            if taskText.contains(tag.name.lowercased()) && !suggestions.contains(tag) {
                suggestions.append(tag)
            }
        }
        
        // 3. Limit and sort by relevance
        suggestions = Array(Set(suggestions)).sorted { $0.usageCount > $1.usageCount }
        return Array(suggestions.prefix(5))
    }
    
    // MARK: - Tag Groups
    
    func createTagGroup(_ group: TagGroup) {
        tagGroups.append(group)
        saveTagGroups()
    }
    
    func updateTagGroup(_ group: TagGroup) {
        if let index = tagGroups.firstIndex(where: { $0.id == group.id }) {
            tagGroups[index] = group
            saveTagGroups()
        }
    }
    
    func deleteTagGroup(_ group: TagGroup) {
        tagGroups.removeAll { $0.id == group.id }
        saveTagGroups()
    }
    
    func addTagToGroup(_ tag: Tag, group: TagGroup) {
        if let index = tagGroups.firstIndex(where: { $0.id == group.id }) {
            if !tagGroups[index].tagIds.contains(tag.id) {
                tagGroups[index].tagIds.append(tag.id)
                saveTagGroups()
            }
        }
    }
    
    func removeTagFromGroup(_ tag: Tag, group: TagGroup) {
        if let index = tagGroups.firstIndex(where: { $0.id == group.id }) {
            tagGroups[index].tagIds.removeAll { $0 == tag.id }
            saveTagGroups()
        }
    }
    
    // MARK: - Statistics
    
    func getTagStatistics(_ tag: Tag) -> TagStatistics {
        // This would typically query task data
        // For now, return mock statistics
        return TagStatistics(
            tag: tag,
            totalUsage: tag.usageCount,
            recentUsage: min(tag.usageCount, 5),
            associatedTasks: tag.usageCount,
            lastUsed: Date()
        )
    }
    
    func getMostUsedTags(limit: Int = 10) -> [Tag] {
        return tags.sorted { $0.usageCount > $1.usageCount }.prefix(limit).map { $0 }
    }
    
    // MARK: - Persistence
    
    private func saveTags() {
        if let encoded = try? JSONEncoder().encode(tags) {
            userDefaults.set(encoded, forKey: tagsKey)
        }
    }
    
    private func loadTags() {
        if let data = userDefaults.data(forKey: tagsKey),
           let decoded = try? JSONDecoder().decode([Tag].self, from: data) {
            tags = decoded
        }
    }
    
    private func saveTagGroups() {
        if let encoded = try? JSONEncoder().encode(tagGroups) {
            userDefaults.set(encoded, forKey: tagGroupsKey)
        }
    }
    
    private func loadTagGroups() {
        if let data = userDefaults.data(forKey: tagGroupsKey),
           let decoded = try? JSONDecoder().decode([TagGroup].self, from: data) {
            tagGroups = decoded
        }
    }
    
    // MARK: - Setup
    
    private func setupPredefinedTagsIfNeeded() {
        // Only add predefined tags if no tags exist
        if tags.isEmpty {
            // Add a subset of predefined tags
            let initialTags = [
                Tag(name: "work", colorHex: "#007AFF", icon: "briefcase.fill", description: "Work-related tasks"),
                Tag(name: "personal", colorHex: "#34C759", icon: "person.fill", description: "Personal tasks"),
                Tag(name: "urgent", colorHex: "#FF3B30", icon: "exclamationmark.triangle.fill", description: "Urgent tasks"),
                Tag(name: "quick", colorHex: "#FFCC00", icon: "bolt.fill", description: "Quick tasks"),
                Tag(name: "shopping", colorHex: "#FF9500", icon: "cart.fill", description: "Shopping lists"),
                Tag(name: "health", colorHex: "#FF2D55", icon: "heart.fill", description: "Health and wellness")
            ]
            
            tags = initialTags
            saveTags()
            
            // Create default groups
            let workGroup = TagGroup(name: "Work", category: .work)
            let personalGroup = TagGroup(name: "Personal", category: .personal)
            
            tagGroups = [workGroup, personalGroup]
            saveTagGroups()
        }
    }
    
    // MARK: - Migration from old string tags
    
    func migrateStringTags(from stringTags: [String]) -> [Tag] {
        var migratedTags: [Tag] = []
        
        for stringTag in stringTags {
            if let existingTag = getTag(byName: stringTag) {
                migratedTags.append(existingTag)
            } else {
                // Create new tag from string
                let newTag = Tag.quickTag(name: stringTag)
                createTag(newTag)
                migratedTags.append(newTag)
            }
        }
        
        return migratedTags
    }
    
    // MARK: - Tag Colors
    
    static let tagColors = [
        "#FF3B30", // Red
        "#FF9500", // Orange
        "#FFCC00", // Yellow
        "#34C759", // Green
        "#00C7BE", // Teal
        "#30B0C7", // Light Blue
        "#007AFF", // Blue
        "#5856D6", // Purple
        "#AF52DE", // Violet
        "#FF2D55", // Pink
        "#8E8E93", // Gray
        "#000000"  // Black
    ]
    
    static let tagIcons = [
        "tag.fill",
        "bookmark.fill",
        "flag.fill",
        "star.fill",
        "heart.fill",
        "bolt.fill",
        "flame.fill",
        "leaf.fill",
        "briefcase.fill",
        "house.fill",
        "cart.fill",
        "person.fill",
        "calendar",
        "clock.fill",
        "location.fill",
        "folder.fill"
    ]
}