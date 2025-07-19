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
                // Universal background
                UniversalBackground()
                
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
                            showingAddTaskModal: $showingAddTaskModal,
                            showingNotifications: $showingNotifications,
                            showingAccountSettings: $showingAccountSettings,
                            taskManager: taskManager,
                            screenSize: geometry.size
                        )
                        .tag(1)
                        
                        VoiceView(
                            showingAddTaskModal: $showingAddTaskModal,
                            showingNotifications: $showingNotifications,
                            showingAccountSettings: $showingAccountSettings,
                            taskManager: taskManager,
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
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    
                    // Bottom navigation overlay
                    VStack {
                        Spacer()
                        MoodLensBottomNavigationView(selectedTab: $selectedTab, screenSize: geometry.size)
                    }
                }
                
                // Top Navigation overlay
                VStack {
                    TopNavigationView(
                        onNotificationTap: { showingNotifications = true },
                        onAccountTap: { showingAccountSettings = true },
                        onAddTaskTap: { showingAddTaskModal = true },
                        screenSize: geometry.size
                    )
                    Spacer()
                }
                
                // CloudKit sync status overlay (positioned at top right)
                VStack {
                    HStack {
                        Spacer()
                        CloudSyncStatusView()
                            .padding(.top, max(50, geometry.size.height * 0.07))
                            .padding(.trailing, max(16, geometry.size.width * 0.04))
                    }
                    Spacer()
                }
            }
        }
        .background(Color.clear)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingAddTaskModal) {
            AddTaskModalView()
        }
        .sheet(isPresented: $showingNotifications) {
            SettingsView()
        }
        .sheet(isPresented: $showingAccountSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
}
