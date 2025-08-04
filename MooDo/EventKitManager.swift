//
//  EventKitManager.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import Foundation
import EventKit
import UserNotifications

@MainActor
class EventKitManager: ObservableObject {
    init() {
        self.eventStore = EKEventStore()
    }
    
    private let eventStore: EKEventStore
    @Published var isAuthorized = false
    
    // MARK: - Authorization
    
    func requestAuthorization() async {
        // Only request notification permissions since we're not using Apple Reminders
        await requestNotificationPermissionsAsync()
        isAuthorized = true // Always authorized since we only need notifications
    }
    
    private func requestNotificationPermissions() async {
        await requestNotificationPermissionsAsync()
    }
    
    private func requestNotificationPermissionsAsync() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            print("🔔 Notification permissions granted: \(granted)")
            
            if granted {
                // Setup notification categories for interactive notifications
                EventKitManager.setupNotificationActions()
            }
        } catch {
            print("❌ Failed to request notification permissions: \(error)")
        }
    }
    
    // MARK: - Notification Management
    // Note: We use only MooDo notifications for user alerts
    
    func createReminder(for task: Task) async -> String? {
        // Generate a unique identifier for this task notification
        let notificationID = "moodo-task-\(task.id.uuidString)"
        
        // Schedule MooDo notification
        await scheduleMooDoNotification(for: task, eventKitIdentifier: notificationID)
        
        return notificationID
    }
    
    func updateReminder(for task: Task) async {
        // Update MooDo notification
        await updateMooDoNotification(for: task)
    }
    
    func deleteReminder(eventKitIdentifier: String) {
        // Remove MooDo notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eventKitIdentifier])
    }
    
    // MARK: - MooDo Notifications (Primary)
    
    private func scheduleMooDoNotification(for task: Task, eventKitIdentifier: String) async {
        guard let reminderDate = task.reminderAt, reminderDate > Date() else {
            print("🔔 Notification: Reminder date is in the past or nil")
            return
        }
        
        print("🔔 Scheduling notification for task: \(task.title)")
        print("🔔 Reminder date: \(reminderDate)")
        
        let content = UNMutableNotificationContent()
        content.title = "🎯 MooDo: Time for your task!"
        content.subtitle = task.title
        content.body = "Based on your mood, this is perfect timing for: \(task.description ?? "your task")"
        content.sound = .default
        content.categoryIdentifier = "MOODO_TASK_REMINDER"
        
        // Add action buttons
        content.userInfo = [
            "taskID": task.id.uuidString,
            "eventKitID": eventKitIdentifier
        ]
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: eventKitIdentifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Notification scheduled successfully for: \(task.title)")
        } catch {
            print("❌ Failed to schedule notification: \(error)")
        }
    }
    
    private func updateMooDoNotification(for task: Task) async {
        guard let eventKitID = task.eventKitIdentifier else { return }
        
        // Remove existing notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eventKitID])
        
        // Schedule new one if needed
        await scheduleMooDoNotification(for: task, eventKitIdentifier: eventKitID)
    }
    
    // MARK: - Testing Functions
    
    func testMooDoNotification() async {
        print("🧪 Testing MooDo notification...")
        
        let content = UNMutableNotificationContent()
        content.title = "MooDo Task Reminder"
        content.subtitle = "Test Task"
        content.body = "This is a test notification from MooDo!"
        content.sound = .default
        content.categoryIdentifier = "MOODO_TASK_REMINDER"
        
        // Add test user info
        content.userInfo = [
            "taskID": UUID().uuidString,
            "eventKitID": "test-notification",
            "isTest": true
        ]
        
        // Trigger immediately (5 seconds from now)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "test-moodo-notification",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Test notification scheduled! It will appear in 5 seconds.")
        } catch {
            print("❌ Failed to schedule test notification: \(error)")
        }
    }
    
    // MARK: - Bulk Operations
    
    func syncAllTasks(_ tasks: [Task]) async {
        for task in tasks {
            if task.eventKitIdentifier != nil {
                await updateReminder(for: task)
            } else if task.reminderAt != nil {
                _ = await createReminder(for: task)
                // Note: You would need to update the task with the new eventKitID in your TaskManager
            }
        }
    }
}

// MARK: - Extensions

extension TaskPriority {
    var eventKitPriority: Int {
        switch self {
        case .low: return 1
        case .medium: return 5
        case .high: return 9
        }
    }
}

// MARK: - Notification Actions

extension EventKitManager {
    static func setupNotificationActions() {
        let completeAction = UNNotificationAction(
            identifier: "MOODO_COMPLETE_TASK",
            title: "✅ Complete",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "MOODO_SNOOZE_TASK",
            title: "⏰ Snooze 15min",
            options: []
        )
        
        let openAction = UNNotificationAction(
            identifier: "MOODO_OPEN_TASK",
            title: "📱 Open in MooDo",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: "MOODO_TASK_REMINDER",
            actions: [completeAction, snoozeAction, openAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}

