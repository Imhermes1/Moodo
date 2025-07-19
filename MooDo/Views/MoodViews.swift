//
//  MoodViews.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Mood Check-in View

struct MoodLensMoodCheckinView: View {
    @State private var selectedMood: MoodType?
    @StateObject private var moodManager = MoodManager()
    @StateObject private var taskManager = TaskManager()
    @State private var bounceOffset: CGFloat = 0
    @State private var swayRotation: Double = 0
    
    let moodOptions: [(type: MoodType, icon: String, label: String)] = [
        (MoodType.positive, "face.smiling", "Positive"),
        (MoodType.calm, "leaf", "Calm"),
        (MoodType.focused, "brain.head.profile", "Focused"),
        (MoodType.stressed, "face.dashed", "Stressed"),
        (MoodType.creative, "lightbulb", "Creative")
    ]
    
    var body: some View {
        VStack(spacing: 18) {
            // Header (smaller and more compact)
            VStack(spacing: 6) {
                Text("How are you feeling?")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Log your mood to get personalized task recommendations")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Mood selection buttons (smaller and more compact)
            HStack(spacing: 12) {
                ForEach(moodOptions, id: \.type) { moodOption in
                    MoodIndicatorButton(
                        mood: moodOption.type,
                        icon: moodOption.icon,
                        label: moodOption.label,
                        isSelected: selectedMood == moodOption.type,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMood = moodOption.type
                            }
                        },
                        size: 48
                    )
                }
            }
            
            // Log mood button (matching web app style)
            Button(action: logMood) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("Log Mood")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                                        // Base glass layer for button
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                        
                        // Inner highlight for 3D effect
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.2),
                                        .white.opacity(0.06),
                                        .clear,
                                        .black.opacity(0.04)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Glass border
                        RoundedRectangle(cornerRadius: 25)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.5),
                                        .white.opacity(0.15),
                                        .white.opacity(0.05),
                                        .white.opacity(0.25)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
                .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
            }
            .disabled(selectedMood == nil)
            .opacity(selectedMood == nil ? 0.4 : 1.0)
            .scaleEffect(selectedMood == nil ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: selectedMood)
        }
        .padding(20)
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
        .offset(y: bounceOffset)
        .rotationEffect(.degrees(swayRotation))
        .onAppear {
            // Very slow, gentle bouncing animation (10% faster)
            withAnimation(.easeInOut(duration: 2.9).repeatForever(autoreverses: true)) {
                bounceOffset = -3
            }
            
            // Very slow, gentle swaying animation (10% faster)
            withAnimation(.easeInOut(duration: 4.3).repeatForever(autoreverses: true)) {
                swayRotation = 1.5
            }
        }
    }
    
    private func logMood() {
        guard let mood = selectedMood else { return }
        
        let entry = MoodEntry(mood: mood)
        moodManager.addMoodEntry(entry)
        
        // Trigger intelligent task optimization based on new mood
        taskManager.updateCurrentMood(mood)
        
        // Reset selection with animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            selectedMood = nil
        }
    }
}

// MARK: - Mood Indicator Button

struct MoodIndicatorButton: View {
    let mood: MoodType
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    let size: CGFloat
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(mood.color)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(isSelected ? 0.6 : 0.3), lineWidth: isSelected ? 3 : 1.5)
                    )
                    .shadow(
                        color: mood.color.opacity(isSelected ? 0.6 : 0.3),
                        radius: isSelected ? 16 : 8,
                        x: 0,
                        y: isSelected ? 8 : 4
                    )
                
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: size * 0.4, weight: .medium))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
            }
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
} 