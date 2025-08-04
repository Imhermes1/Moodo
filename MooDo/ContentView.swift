//
//  ContentView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI
import Foundation
import CloudKit

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingAddTaskModal = false
    @State private var showingNotifications = false
    @State private var showingAccountSettings = false
    @StateObject private var taskManager = TaskManager()
    @StateObject private var moodManager = MoodManager()
    @StateObject private var voiceManager = VoiceCheckinManager()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Universal background - extends to ALL edges including safe areas
                UniversalBackground()
                    .ignoresSafeArea(.all, edges: .all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                ZStack {
                    // Main content area (full screen)
                    TabView(selection: $selectedTab) {
                        HomeView(
                            showingAddTaskModal: $showingAddTaskModal,
                            showingNotifications: $showingNotifications,
                            showingAccountSettings: $showingAccountSettings,
                            taskManager: taskManager,
                            moodManager: moodManager,
                            screenSize: geometry.size
                        )
                        .tag(0)
                        
                        TasksView(
                            taskManager: taskManager,
                            moodManager: moodManager,
                            screenSize: geometry.size
                        )
                        .tag(1)
                        
                        VoiceView(
                            showingAddTaskModal: $showingAddTaskModal,
                            showingNotifications: $showingNotifications,
                            showingAccountSettings: $showingAccountSettings,
                            taskManager: taskManager,
                            moodManager: moodManager,
                            screenSize: geometry.size
                        )
                        .tag(2)
                        
                        InsightsView(
                            showingAddTaskModal: $showingAddTaskModal,
                            showingNotifications: $showingNotifications,
                            showingAccountSettings: $showingAccountSettings,
                            taskManager: taskManager,
                            moodManager: moodManager,
                            voiceManager: voiceManager,
                            screenSize: geometry.size
                        )
                        .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.linear(duration: 0.25), value: selectedTab) // Use linear animation for better performance
                    
                    // Top navigation overlay (transparent background)
                    VStack(spacing: 0) {
                        TopNavigationView(
                            onNotificationTap: { showingNotifications = true },
                            onAccountTap: { showingAccountSettings = true },
                            onAddTaskTap: { showingAddTaskModal = true },
                            screenSize: geometry.size
                        )
                        Spacer()
                    }
                    
                    // Bottom navigation overlay (transparent background)
                    VStack(spacing: 0) {
                        Spacer()
                        MoodLensBottomNavigationView(selectedTab: $selectedTab, screenSize: geometry.size)
                            .padding(.bottom, 25)
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
                
                // CloudKit sync status overlay (positioned at top right)
                VStack {
                    HStack {
                        Spacer()
                        CloudSyncStatusView()
                            .padding(.top, 10) // Minimal padding from top navigation
                            .padding(.trailing, max(16, geometry.size.width * 0.04))
                    }
                    Spacer()
                }
            }
        }
        .background(Color.clear)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingAddTaskModal) {
            QuickAddTaskView(taskManager: taskManager, moodManager: moodManager)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(false)
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationsView()
        }
        .sheet(isPresented: $showingAccountSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
}
