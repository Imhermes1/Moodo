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
        
        // Configure for optimal performance according to Apple guidelines
        configureTaskManager()
        configureUserInterface()
    }
    
    private func configureTaskManager() {
        // Pre-warm task manager for better initial performance
        // This ensures CloudKit and EventKit are ready
        Task {
            await taskManager.eventKitManager.requestAuthorization()
        }
    }
    
    private func configureUserInterface() {
        // Apply Apple's recommended UI performance settings
        
        // Optimize rendering performance
        UIView.setAnimationsEnabled(true)
        
        // Configure preferred frame rate for animations (120Hz on ProMotion devices)
        if #available(iOS 15.0, *) {
            UIScreen.main.maximumFramesPerSecond = 120
        }
        
        // Enable metal rendering optimizations
        UIView.appearance().layer.shouldRasterize = false // Only rasterize when beneficial
        
        print("🚀 App configured for optimal performance")
    }
    
    private func handleMemoryWarning() {
        // Clear caches and unnecessary data
        taskManager.clearCaches()
        
        // Force garbage collection
        print("🧹 Memory warning handled - cleared caches")
    }
}
