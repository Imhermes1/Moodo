//
//  TaskCompletionCard.swift
//  Moodo
//
//  Created by Claude on 18/8/2025.
//

import SwiftUI

struct TaskCompletionCard: View {
    let task: Task
    let onMoodSelected: (MoodType) -> Void
    let onDismiss: () -> Void
    @State private var selectedMood: MoodType? = nil
    @State private var showConfetti = false
    @State private var cardOffset: CGFloat = 300
    
    let moods: [MoodType] = [.energized, .focused, .calm, .creative, .anxious, .tired]
    
    var body: some View {
        VStack(spacing: 20) {
            // Celebration Header
            VStack(spacing: 12) {
                HStack {
                    Button("Skip") {
                        onMoodSelected(.calm) // Default mood
                        onDismiss()
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Button("Done") {
                        onDismiss()
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                }
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.green)
                    .scaleEffect(showConfetti ? 1.2 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showConfetti)
                
                Text("Task Completed!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(task.title)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // Mood Selection
            VStack(spacing: 16) {
                Text("How did it make you feel?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(moods, id: \.self) { mood in
                        Button(action: {
                            selectedMood = mood
                            HapticManager.shared.selection()
                            
                            // Auto-dismiss after selection
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                onMoodSelected(mood)
                                onDismiss()
                            }
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: mood.icon)
                                    .font(.title2)
                                    .foregroundColor(selectedMood == mood ? .white : mood.color)
                                
                                Text(mood.displayName)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedMood == mood ? .white : .white.opacity(0.8))
                            }
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedMood == mood ? mood.color.opacity(0.6) : mood.color.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedMood == mood ? Color.white.opacity(0.8) : mood.color.opacity(0.4), lineWidth: selectedMood == mood ? 2 : 1)
                                    )
                            )
                            .scaleEffect(selectedMood == mood ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedMood)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .offset(y: cardOffset)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: cardOffset)
        .onAppear {
            cardOffset = 0
            showConfetti = true
            HapticManager.shared.success()
        }
        .onDisappear {
            cardOffset = 300
        }
    }
}

#Preview {
    ZStack {
        UniversalBackground()
            .ignoresSafeArea()
        
        TaskCompletionCard(
            task: Task(
                title: "Complete the app design",
                description: "Finish the UI components and styling",
                priority: .medium,
                emotion: .focused
            ),
            onMoodSelected: { mood in
                print("Selected mood: \(mood)")
            },
            onDismiss: {
                print("Dismissed")
            }
        )
        .padding(.horizontal, 20)
    }
}