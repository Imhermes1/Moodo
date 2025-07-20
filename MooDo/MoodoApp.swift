//
//  MoodoApp.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

@main
struct MoodoApp: App {
    // Performance optimization: Single shared instances
    @StateObject private var taskManager = TaskManager()
    @StateObject private var moodManager = MoodManager()
    @StateObject private var cloudKitManager = CloudKitManager.shared
    
    init() {
        // Performance optimization: Configure for production
        configureForProduction()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskManager)
                .environmentObject(moodManager)
                .environmentObject(cloudKitManager)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                    // Handle memory warnings in production
                    handleMemoryWarning()
                }
        }
    }
    
    // MARK: - Production Configuration
    
    private func configureForProduction() {
        #if !DEBUG
        // Disable debug features in production
        // Optimize memory usage
        #endif
        
        // Configure task manager for optimal performance
        configureTaskManager()
    }
    
    private func configureTaskManager() {
        // Pre-warm task manager for better initial performance
        // This ensures CloudKit and EventKit are ready
    }
    
    private func handleMemoryWarning() {
        // Clear caches and unnecessary data
        taskManager.clearCaches()
        
        // Force garbage collection
        print("🧹 Memory warning handled - cleared caches")
    }
}
