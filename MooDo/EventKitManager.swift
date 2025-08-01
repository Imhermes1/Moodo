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
    private let eventStore = EKEventStore()
    @Published var isAuthorized = false
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    init() {
        checkAuthorizationStatus()
        requestNotificationPermissions()
    }
    
    // MARK: - Authorization
    
    private func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .reminder)
        isAuthorized = authorizationStatus == .fullAccess
    }
    
    func requestAuthorization() async {
        do {
            // Request reminders authorization for proper task notifications
            let granted = try await eventStore.requestFullAccessToReminders()
            isAuthorized = granted
            authorizationStatus = EKEventStore.authorizationStatus(for: .reminder)
            
            // Also ensure notification permissions are granted
            await requestNotificationPermissionsAsync()
        } catch {
            print("Failed to request EventKit authorization: \(error)")
        }
    }
    
    private func requestNotificationPermissions() {
        Task {
            await requestNotificationPermissionsAsync()
        }
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
    
    // MARK: - Reminder Management
    // Note: We use EventKit for calendar sync but MooDo notifications for user alerts
    
    func createReminder(for task: Task) async -> String? {
        if !isAuthorized {
            await requestAuthorization()
            if !isAuthorized {
                return nil
            }
        }
        
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = task.title
        reminder.notes = task.description
        reminder.priority = task.priority.eventKitPriority
        
        if let reminderDate = task.reminderAt {
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            
            // Create an alarm for the reminder
            let alarm = EKAlarm(absoluteDate: reminderDate)
            reminder.addAlarm(alarm)
        }
        
        // Set the calendar (default reminders list)
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        do {
            try eventStore.save(reminder, commit: true)
            
            // Schedule MooDo notification as primary
            await scheduleMooDoNotification(for: task, eventKitIdentifier: reminder.calendarItemIdentifier)
            
            return reminder.calendarItemIdentifier
        } catch {
            print("Failed to save reminder: \(error)")
            return nil
        }
    }
    
    func updateReminder(for task: Task) async {
        guard let eventKitID = task.eventKitIdentifier,
              let reminder = eventStore.calendarItem(withIdentifier: eventKitID) as? EKReminder else {
            // Create new reminder if it doesn't exist
            _ = await createReminder(for: task)
            return
        }
        
        reminder.title = task.title
        reminder.notes = task.description
        reminder.priority = task.priority.eventKitPriority
        reminder.isCompleted = task.isCompleted
        
        if let reminderDate = task.reminderAt {
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            
            // Update alarm
            reminder.alarms?.forEach { reminder.removeAlarm($0) }
            let alarm = EKAlarm(absoluteDate: reminderDate)
            reminder.addAlarm(alarm)
        }
        
        do {
            try eventStore.save(reminder, commit: true)
            
            // Update MooDo notification
            await updateMooDoNotification(for: task)
        } catch {
            print("Failed to update reminder: \(error)")
        }
    }
    
    func deleteReminder(eventKitIdentifier: String) {
        guard let reminder = eventStore.calendarItem(withIdentifier: eventKitIdentifier) as? EKReminder else {
            return
        }
        
        do {
            try eventStore.remove(reminder, commit: true)
            
            // Remove MooDo notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eventKitIdentifier])
        } catch {
            print("Failed to delete reminder: \(error)")
        }
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
        content.title = "MooDo Task Reminder"
        content.subtitle = task.title
        content.body = task.description ?? "Time to complete your task!"
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