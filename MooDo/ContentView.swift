//
//  ContentView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingAddTaskModal = false
    @State private var showingNotifications = false
    @State private var showingAccountSettings = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Liquid gradient background that matches the web app
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.34, green: 0.56, blue: 0.94), location: 0.0),
                        .init(color: Color(red: 0.56, green: 0.27, blue: 0.68), location: 0.5),
                        .init(color: Color(red: 0.76, green: 0.27, blue: 0.88), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: selectedTab)
                
                ZStack {
                    // Main content area (full screen)
                    TabView(selection: $selectedTab) {
                        HomeView(
                            showingAddTaskModal: $showingAddTaskModal,
                            showingNotifications: $showingNotifications,
                            showingAccountSettings: $showingAccountSettings,
                            screenSize: geometry.size
                        )
                        .tag(0)
                        
                        TasksView(
                            showingAddTaskModal: $showingAddTaskModal,
                            showingNotifications: $showingNotifications,
                            showingAccountSettings: $showingAccountSettings,
                            screenSize: geometry.size
                        )
                        .tag(1)
                        
                        VoiceView(
                            showingAddTaskModal: $showingAddTaskModal,
                            showingNotifications: $showingNotifications,
                            showingAccountSettings: $showingAccountSettings,
                            screenSize: geometry.size
                        )
                        .tag(2)
                        
                        InsightsView(
                            showingAddTaskModal: $showingAddTaskModal,
                            showingNotifications: $showingNotifications,
                            showingAccountSettings: $showingAccountSettings,
                            screenSize: geometry.size
                        )
                        .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab)
                    
                    // CloudKit sync status overlay
                    CloudSyncStatusView()
                    
                    // Bottom navigation overlay
                    VStack {
                        Spacer()
                        MoodLensBottomNavigationView(selectedTab: $selectedTab)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTaskModal) {
            AddTaskModalView()
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showingAccountSettings) {
            AccountSettingsView()
        }
    }
}

struct TopNavigationView: View {
    let onNotificationTap: () -> Void
    let onAccountTap: () -> Void
    let onAddTaskTap: () -> Void
    
    var body: some View {
        ZStack {
            // Glass background
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            HStack {
                // MoodLens logo and title
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("MoodLens")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("To-Do")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Add Task, Notification and profile icons
                HStack(spacing: 12) {
                    Button(action: onAddTaskTap) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Button(action: onNotificationTap) {
                        Image(systemName: "bell")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Button(action: onAccountTap) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
    }
}

struct HomeView: View {
    @Binding var showingAddTaskModal: Bool
    @Binding var showingNotifications: Bool
    @Binding var showingAccountSettings: Bool
    @StateObject private var taskManager = TaskManager()
    @StateObject private var moodManager = MoodManager()
    let screenSize: CGSize
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: screenSize.height * 0.025) {
                    // Spacer for fixed header (smaller since nav is smaller)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 70)
                    
                    // Mood Check-in (matches web app exactly)
                    MoodLensMoodCheckinView()
                    
                    // Task List (second position)
                    MoodLensTaskListView(tasks: taskManager.tasks) {
                        showingAddTaskModal = true
                    }
                    
                    // Body Scan feature
                    BodyScanView()
                    
                    // Today's Progress (animated counters like web app)
                    TodaysProgressView(tasks: taskManager.tasks, moodEntries: moodManager.moodEntries)
                    
                    // Mindful Moment
                    MindfulMomentView()
                    
                    // Extra spacing to ensure smooth endless scrolling
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 40)
                }
                .padding(.horizontal, max(screenSize.width * 0.04, 12))
                .padding(.bottom, 120)
            }
            
            // Fixed header overlay (moved higher)
            VStack {
                TopNavigationView(
                    onNotificationTap: { showingNotifications = true },
                    onAccountTap: { showingAccountSettings = true },
                    onAddTaskTap: { showingAddTaskModal = true }
                )
                .padding(.top, max(screenSize.height * 0.003, 0))
                Spacer()
            }
        }
    }
}

struct TasksView: View {
    @Binding var showingAddTaskModal: Bool
    @Binding var showingNotifications: Bool
    @Binding var showingAccountSettings: Bool
    @StateObject private var taskManager = TaskManager()
    let screenSize: CGSize
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: screenSize.height * 0.025) {
                    // Spacer for fixed header
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 70)
                    
                    // All Tasks List
                    AllTasksListView(tasks: taskManager.tasks) {
                        showingAddTaskModal = true
                    }
                    
                    // Extra spacing to ensure smooth endless scrolling
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 40)
                }
                .padding(.horizontal, max(screenSize.width * 0.04, 12))
                .padding(.bottom, 120)
            }
            
            // Fixed header overlay
            VStack {
                TopNavigationView(
                    onNotificationTap: { showingNotifications = true },
                    onAccountTap: { showingAccountSettings = true },
                    onAddTaskTap: { showingAddTaskModal = true }
                )
                .padding(.top, max(screenSize.height * 0.003, 0))
                Spacer()
            }
        }
    }
}

struct VoiceView: View {
    @Binding var showingAddTaskModal: Bool
    @Binding var showingNotifications: Bool
    @Binding var showingAccountSettings: Bool
    @StateObject private var taskManager = TaskManager()
    let screenSize: CGSize
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: screenSize.height * 0.025) {
                    // Spacer for fixed header (smaller since nav is smaller)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 70)
                    
                    // Daily Voice Check-in (matches web app)
                    DailyVoiceCheckinView()
                    
                    // Voice Check-in History
                    VoiceCheckinHistoryView()
                    
                    // Extra spacing to ensure smooth endless scrolling
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 40)
                }
                .padding(.horizontal, max(screenSize.width * 0.04, 12))
                .padding(.bottom, 120)
            }
            
            // Fixed header overlay (moved higher)
            VStack {
                TopNavigationView(
                    onNotificationTap: { showingNotifications = true },
                    onAccountTap: { showingAccountSettings = true },
                    onAddTaskTap: { showingAddTaskModal = true }
                )
                .padding(.top, max(screenSize.height * 0.003, 0))
                Spacer()
            }
        }
    }
}

struct InsightsView: View {
    @Binding var showingAddTaskModal: Bool
    @Binding var showingNotifications: Bool
    @Binding var showingAccountSettings: Bool
    @StateObject private var moodManager = MoodManager()
    @StateObject private var taskManager = TaskManager()
    @StateObject private var smartInsights = SmartInsights()
    @StateObject private var smartSuggestions = SmartTaskSuggestions()
    let screenSize: CGSize
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: screenSize.height * 0.025) {
                    // Spacer for fixed header (smaller since nav is smaller)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 70)
                    
                    // Smart Insights
                    SmartInsightsView(insights: smartInsights.insights)
                    
                    // Smart Suggestions
                    SmartSuggestionsView(suggestions: smartSuggestions.suggestions)
                    
                    // Mood History with detailed view
                    MoodHistoryDetailedView(moodEntries: moodManager.moodEntries)
                    
                    // Voice Check-in History
                    VoiceCheckinHistoryView()
                    
                    // Extra spacing to ensure smooth endless scrolling
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 40)
                }
                .padding(.horizontal, max(screenSize.width * 0.04, 12))
                .padding(.bottom, 120)
            }
            
            // Fixed header overlay (moved higher)
            VStack {
                TopNavigationView(
                    onNotificationTap: { showingNotifications = true },
                    onAccountTap: { showingAccountSettings = true },
                    onAddTaskTap: { showingAddTaskModal = true }
                )
                .padding(.top, max(screenSize.height * 0.003, 0))
                Spacer()
            }
        }
        .onAppear {
            smartInsights.generateInsights(from: moodManager.moodEntries, tasks: taskManager.tasks)
            if let latestMood = moodManager.moodEntries.last {
                smartSuggestions.generateSuggestions(mood: latestMood.mood, timeOfDay: Date(), completedTasks: taskManager.tasks.filter { $0.isCompleted })
            }
        }
    }
}

struct MoodLensBottomNavigationView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            // Home tab
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 0
                }
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 18, weight: .medium))
                    Text("Home")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == 0 ? .white : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 0 ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            
            // Tasks tab
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "checklist")
                        .font(.system(size: 18, weight: .medium))
                    Text("Tasks")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == 1 ? .white : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 1 ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            
            // Voice tab
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 2
                }
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "message.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                    Text("Voice")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == 2 ? .white : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 2 ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            
            // Insights tab
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 3
                }
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 18, weight: .medium))
                    Text("Insights")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == 3 ? .white : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 3 ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
        }
        .padding(.vertical, 10)
        .background(
            ZStack {
                // Glass background matching the top navigation
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(0.85)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            }
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

struct GlassPanelBackground: View {
    @State private var lightSweepOffset: CGFloat = -200
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .white.opacity(0.35), location: 0.0),
                        .init(color: .white.opacity(0.15), location: 0.3),
                        .init(color: .white.opacity(0.08), location: 0.7),
                        .init(color: .white.opacity(0.25), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .opacity(0.4)
            )
            .overlay(
                // Animated light sweep effect (more subtle)
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .white.opacity(0.15), location: 0.45),
                                .init(color: .white.opacity(0.25), location: 0.5),
                                .init(color: .white.opacity(0.15), location: 0.55),
                                .init(color: .clear, location: 1.0)
                            ]),
                            startPoint: .init(x: lightSweepOffset / 300, y: 0),
                            endPoint: .init(x: (lightSweepOffset + 100) / 300, y: 1)
                        )
                    )
                    .clipped()
            )
            .overlay(
                // Inner liquid glass highlight
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.8),
                                .white.opacity(0.3),
                                .white.opacity(0.1),
                                .white.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .overlay(
                // Outer subtle glow for depth
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.15), lineWidth: 0.5)
                    .blur(radius: 1)
            )
            .shadow(color: .white.opacity(0.15), radius: 3, x: 0, y: -2)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .onAppear {
                // Animated light sweep that moves across the glass (slower)
                withAnimation(.linear(duration: 5.0).delay(Double.random(in: 0...3)).repeatForever(autoreverses: false)) {
                    lightSweepOffset = 400
                }
            }
    }
}

struct StaticGlassPanelBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .white.opacity(0.35), location: 0.0),
                        .init(color: .white.opacity(0.15), location: 0.3),
                        .init(color: .white.opacity(0.08), location: 0.7),
                        .init(color: .white.opacity(0.25), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .opacity(0.4)
            )
            .overlay(
                // Inner liquid glass highlight
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.8),
                                .white.opacity(0.3),
                                .white.opacity(0.1),
                                .white.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .overlay(
                // Outer subtle glow for depth
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.15), lineWidth: 0.5)
                    .blur(radius: 1)
            )
            .shadow(color: .white.opacity(0.15), radius: 3, x: 0, y: -2)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

struct CloudSyncStatusView: View {
    @StateObject private var cloudKitManager = CloudKitManager.shared
    
    var body: some View {
        VStack {
            if case .syncing = cloudKitManager.syncStatus {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.7)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    Text("Syncing to iCloud...")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .opacity(0.8)
                )
                .padding(.top, 120)
                .animation(.easeInOut(duration: 0.3), value: cloudKitManager.syncStatus)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Notifications")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    SettingsRowView(
                        icon: "bell.fill",
                        title: "Push Notifications",
                        description: "Receive reminders and updates",
                        color: .blue
                    )
                    
                    SettingsRowView(
                        icon: "clock.fill",
                        title: "Task Reminders",
                        description: "Get notified about upcoming tasks",
                        color: .green
                    )
                    
                    SettingsRowView(
                        icon: "heart.fill",
                        title: "Mood Check-ins",
                        description: "Daily mood tracking reminders",
                        color: .pink
                    )
                }
                
                Spacer()
            }
            .padding(24)
            .background(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.34, green: 0.56, blue: 0.94), location: 0.0),
                        .init(color: Color(red: 0.56, green: 0.27, blue: 0.68), location: 0.5),
                        .init(color: Color(red: 0.76, green: 0.27, blue: 0.88), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct AccountSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    SettingsRowView(
                        icon: "person.fill",
                        title: "Profile",
                        description: "Manage your profile information",
                        color: .blue
                    )
                    
                    SettingsRowView(
                        icon: "icloud.fill",
                        title: "Data Sync",
                        description: "CloudKit synchronization",
                        color: .cyan
                    )
                    
                    SettingsRowView(
                        icon: "lock.fill",
                        title: "Privacy",
                        description: "Data privacy and security",
                        color: .orange
                    )
                    
                    SettingsRowView(
                        icon: "gear",
                        title: "App Settings",
                        description: "General app preferences",
                        color: .gray
                    )
                    
                    SettingsRowView(
                        icon: "questionmark.circle.fill",
                        title: "Help & Support",
                        description: "Get help and contact support",
                        color: .green
                    )
                }
                
                Spacer()
            }
            .padding(24)
            .background(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.34, green: 0.56, blue: 0.94), location: 0.0),
                        .init(color: Color(red: 0.56, green: 0.27, blue: 0.68), location: 0.5),
                        .init(color: Color(red: 0.76, green: 0.27, blue: 0.88), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct SettingsRowView: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.6)
        )
    }
}

#Preview {
    ContentView()
}
