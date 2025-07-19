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
            let granted = try await eventStore.requestFullAccessToEvents()
            isAuthorized = granted
            authorizationStatus = EKEventStore.authorizationStatus(for: .reminder)
        } catch {
            print("Failed to request EventKit authorization: \(error)")
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Failed to request notification permissions: \(error)")
            }
        }
    }
    
    // MARK: - Reminder Management
    
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
            
            // Schedule local notification as backup
            await scheduleLocalNotification(for: task, eventKitIdentifier: reminder.calendarItemIdentifier)
            
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
            
            // Update local notification
            await updateLocalNotification(for: task)
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
            
            // Remove local notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eventKitIdentifier])
        } catch {
            print("Failed to delete reminder: \(error)")
        }
    }
    
    // MARK: - Local Notifications (Backup)
    
    private func scheduleLocalNotification(for task: Task, eventKitIdentifier: String) async {
        guard let reminderDate = task.reminderAt, reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = task.description ?? "Task reminder"
        content.sound = .default
        content.categoryIdentifier = "TASK_REMINDER"
        
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
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }
    
    private func updateLocalNotification(for task: Task) async {
        guard let eventKitID = task.eventKitIdentifier else { return }
        
        // Remove existing notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eventKitID])
        
        // Schedule new one if needed
        await scheduleLocalNotification(for: task, eventKitIdentifier: eventKitID)
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
            identifier: "COMPLETE_TASK",
            title: "Mark Complete",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_TASK",
            title: "Snooze 15min",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
} 