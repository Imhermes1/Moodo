//
//  CloudKitManager.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import Foundation
import CloudKit
import SwiftUI

@MainActor
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    private let database: CKDatabase
    
    @Published var isSignedIn = false
    @Published var syncStatus: SyncStatus = .idle
    
    // Performance optimization: Batch operations
    private var pendingSaveOperations: [CKRecord] = []
    private var saveTimer: Timer?
    
    enum SyncStatus: Equatable {
        case idle
        case syncing
        case success
        case error(String)
    }
    
    private init() {
        // Initialize CloudKit container with explicit identifier
        self.container = CKContainer(identifier: "iCloud.LumoraLabs.Moodo")
        self.database = container.privateCloudDatabase
    }
    
    // MARK: - Initialization
    
    func initialize() async {
        await checkAccountStatus()
    }
    
    // MARK: - Account Management
    
    func checkAccountStatus() async {
        do {
            let status = try await container.accountStatus()
            isSignedIn = status == .available
            if status != .available {
                syncStatus = .error("Please sign in to iCloud")
            }
        } catch {
            print("CloudKit account error: \(error)")
            isSignedIn = false
            syncStatus = .error("CloudKit not available")
        }
    }
    
    // MARK: - Optimized Task Operations
    
    func saveTasks(_ tasks: [Task]) async {
        guard isSignedIn else {
            syncStatus = .error("Not signed in to iCloud")
            return
        }
        
        syncStatus = .syncing
        
        do {
            let records = tasks.map { task in
                let record = CKRecord(recordType: "Task", recordID: CKRecord.ID(recordName: task.id.uuidString))
                record["title"] = task.title
                record["description"] = task.description
                record["isCompleted"] = task.isCompleted
                record["priority"] = task.priority.rawValue
                record["emotion"] = task.emotion.rawValue
                record["createdAt"] = task.createdAt
                record["reminderAt"] = task.reminderAt
                record["deadlineAt"] = task.deadlineAt
                record["naturalLanguageInput"] = task.naturalLanguageInput
                record["eventKitIdentifier"] = task.eventKitIdentifier
                record["tags"] = task.tags
                return record
            }
            
            // Performance optimization: Batch save in chunks
            let chunkSize = 400 // CloudKit limit
            for chunk in records.chunked(into: chunkSize) {
                _ = try await database.modifyRecords(saving: chunk, deleting: [])
            }
            
            syncStatus = .success
        } catch {
            syncStatus = .error("Failed to save tasks: \(error.localizedDescription)")
        }
    }
    
    func fetchTasks() async -> [Task] {
        guard isSignedIn else { return [] }
        
        do {
            let query = CKQuery(recordType: "Task", predicate: NSPredicate(value: true))
            let result = try await database.records(matching: query)
            
            return result.matchResults.compactMap { _, result in
                switch result {
                case .success(let record):
                    return Task(from: record)
                case .failure:
                    return nil
                }
            }
        } catch {
            syncStatus = .error("Failed to fetch tasks: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Mood Operations
    
    func saveMoodEntries(_ entries: [MoodEntry]) async {
        guard isSignedIn else {
            syncStatus = .error("Not signed in to iCloud")
            return
        }
        
        syncStatus = .syncing
        
        do {
            let records = entries.map { entry in
                let record = CKRecord(recordType: "MoodEntry", recordID: CKRecord.ID(recordName: entry.id.uuidString))
                record["mood"] = entry.mood.rawValue
                record["timestamp"] = entry.timestamp
                return record
            }
            
            _ = try await database.modifyRecords(saving: records, deleting: [])
            syncStatus = .success
        } catch {
            syncStatus = .error("Failed to save mood entries: \(error.localizedDescription)")
        }
    }
    
    func fetchMoodEntries() async -> [MoodEntry] {
        guard isSignedIn else { return [] }
        
        do {
            let query = CKQuery(recordType: "MoodEntry", predicate: NSPredicate(value: true))
            let result = try await database.records(matching: query)
            
            return result.matchResults.compactMap { _, result in
                switch result {
                case .success(let record):
                    return MoodEntry(from: record)
                case .failure:
                    return nil
                }
            }
        } catch {
            syncStatus = .error("Failed to fetch mood entries: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Voice Check-in Operations
    
    func saveVoiceCheckins(_ checkins: [VoiceCheckin]) async {
        guard isSignedIn else {
            syncStatus = .error("Not signed in to iCloud")
            return
        }
        
        syncStatus = .syncing
        
        do {
            let records = checkins.map { checkin in
                let record = CKRecord(recordType: "VoiceCheckin", recordID: CKRecord.ID(recordName: checkin.id.uuidString))
                record["transcript"] = checkin.transcript
                record["duration"] = checkin.duration
                record["timestamp"] = checkin.timestamp
                record["mood"] = checkin.mood?.rawValue
                record["tasks"] = checkin.tasks
                return record
            }
            
            _ = try await database.modifyRecords(saving: records, deleting: [])
            syncStatus = .success
        } catch {
            syncStatus = .error("Failed to save voice check-ins: \(error.localizedDescription)")
        }
    }
    
    func fetchVoiceCheckins() async -> [VoiceCheckin] {
        guard isSignedIn else { return [] }
        
        do {
            let query = CKQuery(recordType: "VoiceCheckin", predicate: NSPredicate(value: true))
            let result = try await database.records(matching: query)
            
            return result.matchResults.compactMap { _, result in
                switch result {
                case .success(let record):
                    return VoiceCheckin(from: record)
                case .failure:
                    return nil
                }
            }
        } catch {
            syncStatus = .error("Failed to fetch voice check-ins: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Delete Operations
    
    func deleteTask(_ taskId: UUID) async {
        guard isSignedIn else { return }
        
        do {
            let recordID = CKRecord.ID(recordName: taskId.uuidString)
            try await database.deleteRecord(withID: recordID)
        } catch {
            syncStatus = .error("Failed to delete task: \(error.localizedDescription)")
        }
    }
    
    func deleteMoodEntry(_ entryId: UUID) async {
        guard isSignedIn else { return }
        
        do {
            let recordID = CKRecord.ID(recordName: entryId.uuidString)
            try await database.deleteRecord(withID: recordID)
        } catch {
            syncStatus = .error("Failed to delete mood entry: \(error.localizedDescription)")
        }
    }
}

// MARK: - CloudKit Extensions

extension Task {
    init?(from record: CKRecord) {
        guard let title = record["title"] as? String,
              let priorityRaw = record["priority"] as? String,
              let emotionRaw = record["emotion"] as? String,
              let _ = record["createdAt"] as? Date,
              let priority = TaskPriority(rawValue: priorityRaw),
              let emotion = EmotionType(rawValue: emotionRaw),
              let id = UUID(uuidString: record.recordID.recordName) else {
            return nil
        }
        
        self.init(
            id: id,
            title: title,
            description: record["description"] as? String,
            isCompleted: record["isCompleted"] as? Bool ?? false,
            priority: priority,
            emotion: emotion,
            reminderAt: record["reminderAt"] as? Date,
            deadlineAt: record["deadlineAt"] as? Date,
            naturalLanguageInput: record["naturalLanguageInput"] as? String,
            tags: record["tags"] as? [String] ?? [],
            eventKitIdentifier: record["eventKitIdentifier"] as? String
        )
    }
}

extension MoodEntry {
    init?(from record: CKRecord) {
        guard let moodRaw = record["mood"] as? String,
              let _ = record["timestamp"] as? Date,
              let mood = MoodType(rawValue: moodRaw),
              let id = UUID(uuidString: record.recordID.recordName) else {
            return nil
        }
        
        self.init(
            id: id,
            mood: mood
        )
    }
}

extension VoiceCheckin {
    init?(from record: CKRecord) {
        guard let transcript = record["transcript"] as? String,
              let duration = record["duration"] as? TimeInterval,
              let _ = record["timestamp"] as? Date,
              let id = UUID(uuidString: record.recordID.recordName) else {
            return nil
        }
        
        let mood: MoodType?
        if let moodRaw = record["mood"] as? String {
            mood = MoodType(rawValue: moodRaw)
        } else {
            mood = nil
        }
        
        let tasks = record["tasks"] as? [String] ?? []
        
        self.init(
            id: id,
            transcript: transcript,
            mood: mood,
            tasks: tasks,
            duration: duration
        )
    }
} 

// MARK: - Performance Optimization Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
} 
