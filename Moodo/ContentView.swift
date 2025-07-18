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
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: selectedTab)
                
                VStack(spacing: 0) {
                    // Top navigation bar
                    TopNavigationView()
                        .padding(.top, geometry.safeAreaInsets.top)
                    
                    // Main content area
                    TabView(selection: $selectedTab) {
                        HomeView(showingAddTaskModal: $showingAddTaskModal, screenSize: geometry.size)
                            .tag(0)
                        
                        VoiceView(screenSize: geometry.size)
                            .tag(1)
                        
                        InsightsView(screenSize: geometry.size)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab)
                    
                    // Bottom navigation
                    MoodLensBottomNavigationView(selectedTab: $selectedTab, showingAddTaskModal: $showingAddTaskModal)
                }
            }
        }
        .sheet(isPresented: $showingAddTaskModal) {
            AddTaskModalView()
        }
    }
}

struct TopNavigationView: View {
    var body: some View {
        HStack {
            // MoodLens logo and title
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("MoodLens")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("To-Do")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Notification and profile icons
            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Button(action: {}) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

struct HomeView: View {
    @Binding var showingAddTaskModal: Bool
    @StateObject private var taskManager = TaskManager()
    @StateObject private var moodManager = MoodManager()
    let screenSize: CGSize
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: screenSize.height * 0.025) {
                // Mood Check-in (matches web app exactly)
                MoodLensMoodCheckinView()
                    .padding(.top, max(screenSize.height * 0.02, 10))
                
                // Body Scan feature
                BodyScanView()
                
                // Today's Progress (animated counters like web app)
                TodaysProgressView(tasks: taskManager.tasks, moodEntries: moodManager.moodEntries)
                
                // Mindful Moment
                MindfulMomentView()
                
                // Task List
                MoodLensTaskListView(tasks: taskManager.tasks) {
                    showingAddTaskModal = true
                }
            }
            .padding(.horizontal, max(screenSize.width * 0.04, 12))
            .padding(.bottom, screenSize.height * 0.12)
        }
    }
}

struct VoiceView: View {
    @StateObject private var taskManager = TaskManager()
    let screenSize: CGSize
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: screenSize.height * 0.025) {
                // Daily Voice Check-in (matches web app)
                DailyVoiceCheckinView()
                    .padding(.top, max(screenSize.height * 0.02, 10))
                
                // Voice Check-in History
                VoiceCheckinHistoryView()
            }
            .padding(.horizontal, max(screenSize.width * 0.04, 12))
            .padding(.bottom, screenSize.height * 0.12)
        }
    }
}

struct InsightsView: View {
    @StateObject private var moodManager = MoodManager()
    @StateObject private var taskManager = TaskManager()
    @StateObject private var smartInsights = SmartInsights()
    @StateObject private var smartSuggestions = SmartTaskSuggestions()
    let screenSize: CGSize
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: screenSize.height * 0.025) {
                // Today's Progress (same as home but focused view)
                TodaysProgressView(tasks: taskManager.tasks, moodEntries: moodManager.moodEntries)
                    .padding(.top, max(screenSize.height * 0.02, 10))
                
                // Mood History with detailed view
                MoodHistoryDetailedView(moodEntries: moodManager.moodEntries)
                
                // Voice Check-in History
                VoiceCheckinHistoryView()
            }
            .padding(.horizontal, max(screenSize.width * 0.04, 12))
            .padding(.bottom, screenSize.height * 0.12)
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
    @Binding var showingAddTaskModal: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // Home tab
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 0
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 20, weight: .medium))
                    Text("Home")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(selectedTab == 0 ? .white : .white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 0 ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            
            // Voice tab
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "message.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                    Text("Voice")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(selectedTab == 1 ? .white : .white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 1 ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            
            // Insights tab
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 2
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 20, weight: .medium))
                    Text("Insights")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(selectedTab == 2 ? .white : .white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 2 ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            
            // Add Task button
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showingAddTaskModal = true
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "plus.square.fill")
                        .font(.system(size: 20, weight: .medium))
                    Text("Add Task")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 16)
        .background(
            GlassPanelBackground()
                .opacity(0.9)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

struct GlassPanelBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.1),
                                .white.opacity(0.05),
                                .white.opacity(0.02)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ContentView()
}
