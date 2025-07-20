//
//  InsightsView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct InsightsView: View {
    @Binding var showingAddTaskModal: Bool
    @Binding var showingNotifications: Bool
    @Binding var showingAccountSettings: Bool
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    @ObservedObject var voiceManager: VoiceCheckinManager
    let screenSize: CGSize
    @StateObject private var smartInsights = SmartInsights()
    @StateObject private var smartSuggestions = SmartTaskSuggestions()
    @State private var hasInitialized = false
    @State private var selectedInsightType: InsightType = .smartInsights
    @State private var showingDropdown = false
    
    enum InsightType: String, CaseIterable {
        case smartInsights = "Smart Insights"
        case smartSuggestions = "Smart Suggestions"
        case moodInsights = "Mood Insights"
        
        var icon: String {
            switch self {
            case .smartInsights: return "brain.head.profile"
            case .smartSuggestions: return "lightbulb"
            case .moodInsights: return "chart.line.uptrend.xyaxis"
            }
        }
        
        var color: Color {
            switch self {
            case .smartInsights: return .purple
            case .smartSuggestions: return .yellow
            case .moodInsights: return .blue
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Lensflare animation behind all cards
            LensflareView()
                .offset(x: screenSize.width * 0.3, y: screenSize.height * 0.2)
            
            VStack(spacing: 0) {
                // Dropdown Header
                VStack(spacing: 16) {
                    HStack {
                        Text("Insights")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Dropdown Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingDropdown.toggle()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: selectedInsightType.icon)
                                    .foregroundColor(selectedInsightType.color)
                                    .font(.title3)
                                
                                Text(selectedInsightType.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                Image(systemName: showingDropdown ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.caption)
                                    .rotationEffect(.degrees(showingDropdown ? 180 : 0))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                ZStack {
                                    // Base glass layer
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.4)
                                    
                                    // Highlight layer
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .white.opacity(0.25),
                                                    .white.opacity(0.08),
                                                    .clear,
                                                    .black.opacity(0.05)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // Border
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .white.opacity(0.6),
                                                    .white.opacity(0.2),
                                                    .white.opacity(0.05),
                                                    .white.opacity(0.3)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                }
                            )
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                            .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
                        }
                    }
                    
                    // Dropdown Menu
                    if showingDropdown {
                        VStack(spacing: 0) {
                            ForEach(InsightType.allCases, id: \.self) { insightType in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedInsightType = insightType
                                        showingDropdown = false
                                    }
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: insightType.icon)
                                            .foregroundColor(insightType.color)
                                            .font(.title3)
                                            .frame(width: 24)
                                        
                                        Text(insightType.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        if selectedInsightType == insightType {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                                .font(.caption)
                                                .fontWeight(.bold)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedInsightType == insightType ?
                                        Color.white.opacity(0.15) :
                                        Color.clear
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if insightType != InsightType.allCases.last {
                                    Divider()
                                        .background(Color.white.opacity(0.2))
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                        .background(
                            ZStack {
                                // Base glass layer
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.4)
                                
                                // Highlight layer
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                .white.opacity(0.25),
                                                .white.opacity(0.08),
                                                .clear,
                                                .black.opacity(0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                // Border
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                .white.opacity(0.6),
                                                .white.opacity(0.2),
                                                .white.opacity(0.05),
                                                .white.opacity(0.3)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            }
                        )
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                        .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .scale(scale: 0.95).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal, max(screenSize.width * 0.04, 12))
                .padding(.top, max(screenSize.height * 0.08, 60))
                
                // Content Area
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: screenSize.height * 0.025) {
                        // Selected Insight Content
                        switch selectedInsightType {
                        case .smartInsights:
                            SmartInsightsView(insights: smartInsights.insights)
                        case .smartSuggestions:
                            SmartSuggestionsView(suggestions: smartSuggestions.suggestions, taskManager: taskManager)
                        case .moodInsights:
                            SimpleMoodInsightsView(moodEntries: moodManager.moodEntries, taskManager: taskManager)
                        }
                    }
                    .padding(.horizontal, max(screenSize.width * 0.04, 12))
                .padding(.bottom, max(screenSize.height * 0.12, 100))
                }
            }
        }
        .onAppear {
            // Only initialize once to prevent infinite loops
            if !hasInitialized {
                smartInsights.generateInsights(from: moodManager.moodEntries, tasks: taskManager.tasks)
                if let latestMood = moodManager.moodEntries.last {
                    smartSuggestions.generateSuggestions(mood: latestMood.mood, timeOfDay: Date(), completedTasks: taskManager.tasks.filter { $0.isCompleted })
                }
                hasInitialized = true
            }
        }
    }
}

#Preview {
    InsightsView(
        showingAddTaskModal: .constant(false),
        showingNotifications: .constant(false),
        showingAccountSettings: .constant(false),
        taskManager: TaskManager(),
        moodManager: MoodManager(),
        voiceManager: VoiceCheckinManager(),
        screenSize: CGSize(width: 390, height: 844)
    )
    .background(UniversalBackground())
} 