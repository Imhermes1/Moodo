//
//  SmartSuggestionsView.swift
//  Moodo
//
//  Created by Luke Fornieri on 21/07/2025.
//

import SwiftUI

struct SmartSuggestionsView: View {
    @ObservedObject var taskManager: TaskManager
    @StateObject private var smartTaskSuggestions = SmartTaskSuggestions()
    @State private var isRefreshing = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.title3)
                
                Text("Smart Suggestions")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: refreshSuggestions) {
                    Image(systemName: isRefreshing ? "arrow.clockwise" : "arrow.triangle.2.circlepath")
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(.yellow.opacity(0.3))
                                .overlay(
                                    Circle()
                                        .stroke(.yellow.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                        .animation(.linear(duration: 1).repeatCount(isRefreshing ? .max : 1, autoreverses: false), value: isRefreshing)
                }
            }
            
            // Mood-based context
            HStack {
                Image(systemName: taskManager.currentMood.icon)
                    .foregroundColor(taskManager.currentMood.color)
                    .font(.caption)
                
                Text("Suggestions for when you're feeling \(taskManager.currentMood.displayName.lowercased())")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                GlassPanelBackground()
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Suggestions
            if smartTaskSuggestions.suggestions.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(smartTaskSuggestions.suggestions) { suggestion in
                        SuggestionCard(
                            suggestion: suggestion,
                            onAdd: {
                                addTaskFromSuggestion(suggestion)
                            }
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .background(
            ZStack {
                // Base glass layer with 3D depth
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                
                // Inner highlight layer for 3D effect
                RoundedRectangle(cornerRadius: 20)
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
                
                // Outer stroke with glass shimmer
                RoundedRectangle(cornerRadius: 20)
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
                
                // Inner stroke for depth
                RoundedRectangle(cornerRadius: 19)
                    .strokeBorder(
                        .white.opacity(0.1),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
        .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            refreshSuggestions()
        }
        .onChange(of: taskManager.currentMood) { 
            print("🔄 SmartSuggestionsView: Current mood changed to: \(taskManager.currentMood)")
            refreshSuggestions() 
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "lightbulb")
                .font(.title)
                .foregroundColor(.yellow.opacity(0.7))
            
            Text("No suggestions available")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Change your mood or refresh to see new suggestions")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 24)
    }
    
    private func refreshSuggestions() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isRefreshing = true
        }
        
        // Generate suggestions based on current mood and time of day
        smartTaskSuggestions.generateSuggestions(
            mood: taskManager.currentMood,
            timeOfDay: Date(),
            completedTasks: taskManager.tasks.filter { $0.isCompleted }
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isRefreshing = false
            }
        }
    }
    
    private func addTaskFromSuggestion(_ suggestion: TaskSuggestion) {
        let task = Task(
            title: suggestion.title,
            description: suggestion.description,
            priority: suggestion.priority,
            emotion: suggestion.emotion
        )
        
        taskManager.addTask(task)
        
        // Refresh suggestions after adding a task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            refreshSuggestions()
        }
    }
}

struct SuggestionCard: View {
    let suggestion: TaskSuggestion
    let onAdd: () -> Void
    @State private var glowEffect: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Emotion icon
            Image(systemName: suggestion.emotion.icon)
                .foregroundColor(suggestion.emotion.color)
                .font(.title3)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(suggestion.emotion.color.opacity(0.15))
                        .overlay(
                            Circle()
                                .stroke(suggestion.emotion.color.opacity(0.3), lineWidth: 1)
                        )
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(suggestion.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Add button
            Button(action: onAdd) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(.green.opacity(0.3))
                            .overlay(
                                Circle()
                                    .stroke(.green.opacity(0.5), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(glowEffect ? 0.6 : 0.4),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowEffect.toggle()
            }
        }
    }
}

// Extension to make TaskSuggestion conform to Identifiable
extension TaskSuggestion: Identifiable {
    var id: UUID {
        UUID() // This is a simple implementation; ideally, TaskSuggestion would have a proper id field
    }
}

#Preview {
    SmartSuggestionsView(taskManager: TaskManager())
        .background(UniversalBackground().ignoresSafeArea())
        .preferredColorScheme(.dark)
}
