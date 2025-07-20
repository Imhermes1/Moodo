//
//  SettingsViews.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var taskReminders = true
    @State private var moodReminders = true
    @State private var dailyCheckIns = true
    @State private var achievementNotifications = true
    @State private var hasNotificationPermission = false
    
    var body: some View {
        NavigationView {
            ZStack {
                UniversalBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.blue)
                            
                            Text("Notifications")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Stay on top of your tasks and wellbeing")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Notification Settings
                        VStack(spacing: 16) {
                            NotificationToggleCard(
                                title: "Task Reminders",
                                description: "Get notified about upcoming tasks and deadlines",
                                icon: "checkmark.circle",
                                color: .green,
                                isOn: $taskReminders,
                                onToggle: requestNotificationPermissionIfNeeded
                            )
                            
                            NotificationToggleCard(
                                title: "Mood Check-ins",
                                description: "Gentle reminders to log your mood throughout the day",
                                icon: "heart.fill",
                                color: .pink,
                                isOn: $moodReminders,
                                onToggle: requestNotificationPermissionIfNeeded
                            )
                            
                            NotificationToggleCard(
                                title: "Daily Check-ins",
                                description: "Daily prompts for reflection and goal setting",
                                icon: "sun.max.fill",
                                color: .orange,
                                isOn: $dailyCheckIns,
                                onToggle: requestNotificationPermissionIfNeeded
                            )
                            
                            NotificationToggleCard(
                                title: "Achievement Alerts",
                                description: "Celebrate your progress and completed goals",
                                icon: "star.fill",
                                color: .yellow,
                                isOn: $achievementNotifications,
                                onToggle: requestNotificationPermissionIfNeeded
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // Custom close button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.4)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                    Spacer()
                }
            )
        }
        .onAppear {
            checkNotificationPermission()
        }
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                hasNotificationPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func requestNotificationPermissionIfNeeded() {
        guard !hasNotificationPermission else { return }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                hasNotificationPermission = granted
                if let error = error {
                    print("Notification permission error: \(error)")
                }
            }
        }
    }
}

struct NotificationToggleCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool
    let onToggle: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: color))
                .scaleEffect(0.9)
                .onChange(of: isOn) { _, newValue in
                    if newValue {
                        onToggle?()
                    }
                }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var taskManager = TaskManager()
    @StateObject private var moodManager = MoodManager()
    @StateObject private var voiceManager = VoiceCheckinManager()
    @State private var iCloudSyncEnabled = false
    @State private var showingDataExport = false
    
    var body: some View {
        NavigationView {
            ZStack {
                UniversalBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            
                            Text("Settings")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Customize your MooDo experience")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Settings Sections
                        VStack(spacing: 20) {
                            // Cloud Sync Section
                            SettingsSection(title: "iCloud Sync", icon: "icloud.fill", color: .blue) {
                                VStack(spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Sync with iCloud")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            Text("Keep your tasks and moods in sync across devices")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        Toggle("", isOn: $iCloudSyncEnabled)
                                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                                            .scaleEffect(0.9)
                                    }
                                    
                                    if iCloudSyncEnabled {
                                        Button("Sync Now") {
                                            taskManager.syncWithCloud()
                                            moodManager.syncWithCloud()
                                            voiceManager.syncWithCloud()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.blue.opacity(0.2))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(.blue.opacity(0.4), lineWidth: 1)
                                                )
                                        )
                                        .foregroundColor(.blue)
                                    }
                                }
                            }
                            
                            // Data Management Section
                            SettingsSection(title: "Data", icon: "chart.bar.fill", color: .green) {
                                VStack(spacing: 16) {
                                    // Data Summary
                                    HStack(spacing: 20) {
                                        DataSummaryCard(title: "Tasks", count: taskManager.tasks.count, color: .blue)
                                        DataSummaryCard(title: "Moods", count: moodManager.moodEntries.count, color: .pink)
                                        DataSummaryCard(title: "Voice", count: voiceManager.voiceCheckins.count, color: .purple)
                                    }
                                    
                                    // Export Data
                                    Button("Export My Data") {
                                        showingDataExport = true
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.green.opacity(0.2))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.green.opacity(0.4), lineWidth: 1)
                                            )
                                    )
                                    .foregroundColor(.green)
                                }
                            }
                            
                            // App Info Section
                            SettingsSection(title: "About", icon: "info.circle.fill", color: .orange) {
                                VStack(spacing: 12) {
                                    SettingsRow(title: "Version", value: "1.0.0")
                                    SettingsRow(title: "Build", value: "2025.01")
                                    
                                    Button("Privacy Policy") {
                                        // Handle privacy policy
                                    }
                                    .foregroundColor(.orange)
                                    
                                    Button("Terms of Service") {
                                        // Handle terms
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // Custom close button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.4)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                    Spacer()
                }
            )
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView()
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                    )
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            // Section Content
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct DataSummaryCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct SettingsRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .foregroundColor(.white.opacity(0.6))
                .font(.caption)
        }
    }
}

struct DataExportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                UniversalBackground()
                
                VStack(spacing: 24) {
                    Text("Export Your Data")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Your data will be exported as a JSON file containing all your tasks, moods, and voice entries.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Button("Export Data") {
                        // Handle data export
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.green.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.green.opacity(0.5), lineWidth: 1)
                            )
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationBarHidden(true)
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.4)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                    Spacer()
                }
            )
        }
    }
}

struct SettingsViews: View {
    @ObservedObject var taskManager: TaskManager
    @State private var showingCompletedTasks = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                // Completed Tasks
                Button(action: { showingCompletedTasks = true }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Completed Tasks")
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(taskManager.getCompletedTasks().count)")
                            .foregroundColor(.white.opacity(0.6))
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding()
                    .background(
                        GlassPanelBackground()
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Other settings can go here
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingCompletedTasks) {
            CompletedTasksView(taskManager: taskManager)
        }
    }
}

struct CompletedTasksView: View {
    @ObservedObject var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    @State private var completedTasks: [Task] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Text("Completed Tasks")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    HStack {
                        Text("\(completedTasks.count) completed tasks")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
                .background(
                    GlassPanelBackground()
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 8)
                
                // Completed Tasks List
                if completedTasks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.4))
                        
                        Text("No completed tasks")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Completed tasks will appear here")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
                    .background(
                        GlassPanelBackground()
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 8)
                    .padding(.top, 12)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(completedTasks) { task in
                                CompletedTaskCard(
                                    task: task,
                                    onDelete: {
                                        taskManager.deleteCompletedTask(task)
                                        loadCompletedTasks()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 12)
                    }
                }
                
                Spacer()
            }
            .background(UniversalBackground())
        }
        .onAppear {
            loadCompletedTasks()
        }
    }
    
    private func loadCompletedTasks() {
        completedTasks = taskManager.getCompletedTasks().sorted { $0.createdAt > $1.createdAt }
    }
}

struct CompletedTaskCard: View {
    let task: Task
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Completed checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.green)
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .strikethrough()
                
                HStack(spacing: 8) {
                    // Emotion badge
                    HStack(spacing: 4) {
                        Image(systemName: task.emotion.icon)
                            .font(.caption2)
                        Text(task.emotion.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(task.emotion.color.opacity(0.7))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(task.emotion.color.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(task.emotion.color.opacity(0.2), lineWidth: 1)
                            )
                    )
                    
                    Spacer()
                    
                    // Completion date
                    Text("Completed \(task.createdAt, style: .relative) ago")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(.red.opacity(0.15))
                            .overlay(
                                Circle()
                                    .stroke(.red.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(16)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

 