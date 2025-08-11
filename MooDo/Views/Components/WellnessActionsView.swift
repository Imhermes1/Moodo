//
//  WellnessActionsView.swift
//  Moodo
//
//  Created by OpenAI ChatGPT on 15/8/2025.
//

import SwiftUI

struct WellnessAction: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let duration: String
    let mood: MoodType?
    
    init(title: String, description: String, icon: String, duration: String, mood: MoodType? = nil) {
        self.title = title
        self.description = description
        self.icon = icon
        self.duration = duration
        self.mood = mood
    }
}

struct WellnessActionsView: View {
    @ObservedObject var moodManager: MoodManager
    @State private var selectedAction: WellnessAction?
    @State private var completedActions: Set<UUID> = []
    
    private var allActions: [WellnessAction] {
        [
            // Stress/Anxiety Relief
            WellnessAction(
                title: "Deep Breathing",
                description: "Take 4 deep breaths: inhale for 4 counts, hold for 4, exhale for 6. This helps activate your calm response.",
                icon: "lungs.fill",
                duration: "1 min",
                mood: .stressed
            ),
            WellnessAction(
                title: "Quick Stretch",
                description: "Stand up, reach your arms overhead, and gently stretch side to side. Roll your shoulders back.",
                icon: "figure.arms.open",
                duration: "2 min",
                mood: .tired
            ),
            WellnessAction(
                title: "Gratitude Moment",
                description: "Think of one specific thing you're grateful for right now. Really focus on why it matters to you.",
                icon: "heart.fill",
                duration: "30 sec",
                mood: .stressed
            ),
            
            // Energy & Focus Boosters
            WellnessAction(
                title: "Energy Reset",
                description: "Do 10 jumping jacks or shake out your hands and feet to get your energy flowing.",
                icon: "bolt.fill",
                duration: "1 min",
                mood: .tired
            ),
            WellnessAction(
                title: "Focus Check",
                description: "Close your eyes for 30 seconds and just listen to the sounds around you. Then refocus on your task.",
                icon: "brain.head.profile",
                duration: "30 sec",
                mood: .energized
            ),
            
            // Calm & Creative
            WellnessAction(
                title: "Mindful Pause",
                description: "Place your hand on your heart. Feel it beating. Take 3 slow breaths and notice how you feel.",
                icon: "hand.raised.fill",
                duration: "1 min",
                mood: .anxious
            ),
            WellnessAction(
                title: "Creative Spark",
                description: "Look around and find 3 things that inspire you or spark joy. Notice what draws your attention.",
                icon: "lightbulb.fill",
                duration: "2 min",
                mood: .creative
            )
        ]
    }
    
    private var recommendedActions: [WellnessAction] {
        let currentMood = moodManager.currentMood
        let moodSpecific = allActions.filter { $0.mood == currentMood }
        let general = allActions.filter { $0.mood == nil || $0.mood != currentMood }
        
        // Return mood-specific first, then others
        return Array((moodSpecific + general).prefix(4))
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Wellness")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Simple actions to support your wellbeing")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Completion indicator
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(completedActions.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Actions Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(recommendedActions) { action in
                    WellnessActionCard(
                        action: action,
                        isCompleted: completedActions.contains(action.id),
                        onTap: { selectedAction = action },
                        onComplete: { 
                            withAnimation(Animation.easeInOut) {
                                _ = completedActions.insert(action.id)
                            }
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(GlassPanelBackground())
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .sheet(item: $selectedAction) { action in
            WellnessActionDetailView(
                action: action,
                isCompleted: completedActions.contains(action.id),
                onComplete: {
                    withAnimation(Animation.easeInOut) {
                        _ = completedActions.insert(action.id)
                    }
                }
            )
        }
    }
}

struct WellnessActionCard: View {
    let action: WellnessAction
    let isCompleted: Bool
    let onTap: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: action.icon)
                        .font(.title2)
                        .foregroundColor(isCompleted ? .green : .blue)
                    
                    Spacer()
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    } else {
                        Text(action.duration)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(action.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(action.description.prefix(40) + "...")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isCompleted ? Color.green.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WellnessActionDetailView: View {
    let action: WellnessAction
    let isCompleted: Bool
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Icon and title
                VStack(spacing: 16) {
                    Image(systemName: action.icon)
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    Text(action.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(action.duration)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Description
                Text(action.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    if !isCompleted {
                        Button(action: {
                            HapticManager.shared.buttonPressed()
                            onComplete()
                            dismiss()
                        }) {
                            Text("Mark as Done")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Completed!")
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 16)
                    }
                    
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WellnessActionsView_Previews: PreviewProvider {
    static var previews: some View {
        WellnessActionsView(moodManager: MoodManager())
            .padding()
            .background(UniversalBackground())
    }
}
