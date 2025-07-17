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
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.4),
                    Color.purple.opacity(0.5),
                    Color.purple.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HeaderView()
                
                // Main content
                TabView(selection: $selectedTab) {
                    HomeView(showingAddTaskModal: $showingAddTaskModal)
                        .tag(0)
                    
                    VoiceView()
                        .tag(1)
                    
                    InsightsView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom navigation
                BottomNavigationView(selectedTab: $selectedTab, showingAddTaskModal: $showingAddTaskModal)
            }
        }
        .sheet(isPresented: $showingAddTaskModal) {
            AddTaskModalView()
        }
    }
}

struct HeaderView: View {
    var body: some View {
        VStack {
            HStack {
                // Logo and title
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("MoodLens")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("To-Do")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .foregroundColor(.white)
                            .font(.title3)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "person")
                            .foregroundColor(.white)
                            .font(.title3)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}

struct HomeView: View {
    @Binding var showingAddTaskModal: Bool
    @StateObject private var taskManager = TaskManager()
    @StateObject private var moodManager = MoodManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Mood Check-in
                MoodCheckinView()
                
                // Wellness Prompt
                WellnessPromptView()
                
                // Task List
                TaskListView(tasks: taskManager.tasks) {
                    showingAddTaskModal = true
                }
                
                // Quick Stats
                QuickStatsView(tasks: taskManager.tasks, moodEntries: moodManager.moodEntries)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100) // Space for bottom navigation
        }
    }
}

struct VoiceView: View {
    @StateObject private var taskManager = TaskManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Voice Check-in
                VoiceCheckinView(tasks: taskManager.tasks)
                
                // Voice Check-in History
                VoiceCheckinHistoryView()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }
}

struct InsightsView: View {
    @StateObject private var moodManager = MoodManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Mood History
                MoodHistoryView(moodEntries: moodManager.moodEntries)
                
                // Voice Check-in History
                VoiceCheckinHistoryView()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }
}

struct BottomNavigationView: View {
    @Binding var selectedTab: Int
    @Binding var showingAddTaskModal: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                // Home tab
                Button(action: { selectedTab = 0 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "house")
                            .font(.title2)
                        Text("Home")
                            .font(.caption2)
                    }
                    .foregroundColor(selectedTab == 0 ? .white : .white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                }
                
                // Voice tab
                Button(action: { selectedTab = 1 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "message.circle")
                            .font(.title2)
                        Text("Voice")
                            .font(.caption2)
                    }
                    .foregroundColor(selectedTab == 1 ? .white : .white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                }
                
                // Insights tab
                Button(action: { selectedTab = 2 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title2)
                        Text("Insights")
                            .font(.caption2)
                    }
                    .foregroundColor(selectedTab == 2 ? .white : .white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                }
                
                // Add Task button
                Button(action: { showingAddTaskModal = true }) {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.square")
                            .font(.title2)
                        Text("Add Task")
                            .font(.caption2)
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 16)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    ContentView()
}
