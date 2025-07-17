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
            // Liquid gradient background matching MoodLensTracker
            LiquidGradientBackground()
            
            VStack(spacing: 0) {
                // Header with magnifying glass logo
                MoodLensHeaderView()
                
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
                MoodLensBottomNavigationView(selectedTab: $selectedTab, showingAddTaskModal: $showingAddTaskModal)
            }
        }
        .sheet(isPresented: $showingAddTaskModal) {
            AddTaskModalView()
        }
    }
}

struct LiquidGradientBackground: View {
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.49, blue: 0.92), // #667eea
                Color(red: 0.46, green: 0.29, blue: 0.64), // #764ba2
                Color(red: 0.56, green: 0.49, blue: 0.76), // #8e7cc3
                Color(red: 0.4, green: 0.49, blue: 0.92), // #667eea
                Color(red: 0.46, green: 0.29, blue: 0.64)  // #764ba2
            ]),
            startPoint: UnitPoint(x: 0.5 + 0.5 * cos(animationPhase), y: 0.5 + 0.5 * sin(animationPhase)),
            endPoint: UnitPoint(x: 0.5 + 0.5 * cos(animationPhase + .pi), y: 0.5 + 0.5 * sin(animationPhase + .pi))
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                animationPhase = 2 * .pi
            }
        }
    }
}

struct MoodLensHeaderView: View {
    var body: some View {
        VStack {
            HStack {
                // Magnifying glass logo with liquid effects
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .background(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.15),
                                            .white.opacity(0.05),
                                            .clear
                                        ]),
                                        center: .topLeading,
                                        startRadius: 0,
                                        endRadius: 24
                                    )
                                )
                        )
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.medium)
                }
                .overlay(
                    // Liquid shine effect
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .clear,
                                    .white.opacity(0.1),
                                    .clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .opacity(0.6)
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("MoodLens")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("To-Do")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Action buttons with glass effect
                HStack(spacing: 16) {
                    GlassButton(icon: "bell", action: {})
                    GlassButton(icon: "person", action: {})
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}

struct GlassButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(
                    GlassPanelBackground()
                )
                .clipShape(Circle())
        }
    }
}

struct GlassPanelBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0.03),
                        .white.opacity(0.08),
                        .white.opacity(0.03)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct HomeView: View {
    @Binding var showingAddTaskModal: Bool
    @StateObject private var taskManager = TaskManager()
    @StateObject private var moodManager = MoodManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Mood Check-in with original MoodLens design
                MoodLensMoodCheckinView()
                
                // Wellness Prompt
                WellnessPromptView()
                
                // Task List with emotion-based design
                MoodLensTaskListView(tasks: taskManager.tasks) {
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

struct MoodLensBottomNavigationView: View {
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
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    ContentView()
}
