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
    
    var body: some View {
        ZStack {
            // Lensflare animation behind all cards
            LensflareView()
                .offset(x: screenSize.width * 0.3, y: screenSize.height * 0.2)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: screenSize.height * 0.025) {
                    // Smart Insights
                    SmartInsightsView(insights: smartInsights.insights)
                    
                    // Smart Suggestions
                    SmartSuggestionsView(suggestions: smartSuggestions.suggestions)
                    
                    // Mood History with detailed view
                    MoodHistoryDetailedView(moodEntries: moodManager.moodEntries)
                    
                    // Voice Check-in History
                    VoiceCheckinHistoryView()
                    
                }
                .padding(.horizontal, max(screenSize.width * 0.04, 12))
                .padding(.top, max(screenSize.height * 0.08, 60))
                .padding(.bottom, 20)
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