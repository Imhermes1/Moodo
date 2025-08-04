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

    @State private var hasInitialized = false
    @State private var selectedInsightType: InsightType = .taskInsights
    @State private var showingDropdown = false
    
    enum InsightType: String, CaseIterable {
        case taskInsights = "Task Insights"
        case moodInsights = "Mood Insights"
        
        var icon: String {
            switch self {
            case .taskInsights: return "chart.bar"
            case .moodInsights: return "chart.line.uptrend.xyaxis"
            }
        }
        
        var color: Color {
            switch self {
            case .taskInsights: return .yellow
            case .moodInsights: return .blue
            }
        }
    }
    
    // Filtered productivity insights for task insights view
    private var productivityInsights: [Insight] {
        smartInsights.insights.filter { $0.type == .productivity }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // ScrollView stretches to top, behind header
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: screenSize.height * 0.025) {
                    // Add top padding equal to header height to prevent content underlapping tap targets
                    Color.clear.frame(height: max(screenSize.height * 0.08 + 64, 120)) // approx header height
                    
                    // Selected Insight Content
                    switch selectedInsightType {
                    case .taskInsights:
                        SmartInsightsView(insights: productivityInsights)
                    case .moodInsights:
                        SimpleMoodInsightsView(moodEntries: moodManager.moodEntries, taskManager: taskManager)
                    }
                }
                .padding(.horizontal, max(screenSize.width * 0.04, 12))
                .padding(.bottom, max(screenSize.height * 0.12, 100))
            }
            
            // Header VStack with no background
            VStack(spacing: 16) {
                HStack {
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
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black, lineWidth: 2)
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
                    // Removed all background layers here to ensure transparency
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
            // No background here, fully transparent
        }
        .ignoresSafeArea(edges: [.top, .bottom])
        .onAppear {
            // Only initialize once to prevent infinite loops
            if !hasInitialized {
                smartInsights.generateInsights(from: moodManager.moodEntries, tasks: taskManager.tasks)
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
