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
    @State private var moodGlow: Bool = false
    @StateObject private var moodManager = MoodManager()
    @ObservedObject var taskManager: TaskManager
    @State private var bounceOffset: CGFloat = 0
    @State private var swayRotation: Double = 0
    
    let moodOptions: [(type: MoodType, icon: String, label: String)] = [
        (MoodType.energized, "bolt.fill", "Energized"),
        (MoodType.focused, "brain.head.profile", "Focused"),
        (MoodType.calm, "leaf", "Calm"),
        (MoodType.creative, "lightbulb", "Creative"),
        (MoodType.stressed, "face.dashed", "Stressed"),
        (MoodType.tired, "bed.double", "Tired"),
        (MoodType.anxious, "heart.circle", "Anxious")
    ]
    
    var body: some View {
        VStack(spacing: 12) { // Reduced from 18
            // Header (streamlined - removed subtitle)
            Text("How are you feeling?")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Mood selection buttons (smaller padding) wrapped in horizontal ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(moodOptions, id: \.type) { moodOption in
                        MoodIndicatorButton(
                            mood: moodOption.type,
                            icon: moodOption.icon,
                            label: moodOption.label,
                            isSelected: selectedMood == moodOption.type,
                            action: {
                                // Add haptic feedback and smoother animation
                                HapticManager.shared.buttonPressed()
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedMood = moodOption.type
                                }
                            },
                            size: 48
                        )
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 4)
            }
            .frame(maxWidth: 370)
            .padding(.vertical, 8)
            
            // Log mood button (matching web app style)
            Button(action: logMood) {
                ZStack {
                    if let mood = selectedMood {
                        Circle()
                            .fill(mood.color)
                            .frame(width: moodGlow ? 136 : 98, height: moodGlow ? 136 : 98)
                            .blur(radius: 32)
                            .opacity(moodGlow ? 0.48 : 0.28)
                            .animation(.easeOut(duration: 0.38), value: moodGlow)
                            .position(x: 90, y: 24) // Centered for 180x48 frame
                            .zIndex(-1)
                            .allowsHitTesting(false)
                    }
                    
                    HStack(spacing: 6) {
                        if let selectedMood = selectedMood {
                            // Show mood icon and "Feeling (Mood)" when mood is selected
                            Image(systemName: selectedMood.icon)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedMood.color)
                            Text("Feeling \(selectedMood.displayName)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        } else {
                            // Show plus icon and "Log Mood" when no mood is selected
                            Image(systemName: "plus")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Log Mood")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .foregroundColor(.black)
                    .fontWeight(.medium)
                }
                .frame(width: 180, height: 48)
                .background(
                    ZStack {
                        // Base glass layer for button
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.thinMaterial)
                            .opacity(0.5)
                        
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
                        
                        // Glass border with black outline
                        RoundedRectangle(cornerRadius: 25)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.black.opacity(0.4),
                                        Color.black.opacity(0.2),
                                        Color.black.opacity(0.1),
                                        Color.black.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
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
        .padding(14) // Reduced from 20 for slimmer card
        .background(
            ZStack {
                // Base glass layer with 3D depth
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
                    .opacity(0.5)
                
                // Blue tint for consistency with other cards
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue.opacity(0.08))
                
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
                
                // Consistent blue outline
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.blue.opacity(0.4), lineWidth: 1.5)
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
        .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            // Removed idle animations for better performance
            // Animations only on user interaction
        }
    }
    
    private func logMood() {
        guard let mood = selectedMood else { return }
        
        print("😊 Logging mood: \(mood.displayName)")
        
        let entry = MoodEntry(mood: mood)
        moodManager.addMoodEntry(entry)
        
        // Update both managers with the unified mood system
        moodManager.updateCurrentMood(mood)
        taskManager.updateCurrentMood(mood)
        
        print("🔄 Updated MoodManager current mood to: \(mood)")
        print("🔄 Updated TaskManager current mood to: \(mood)")
        print("📊 Mood saved to history - Total entries: \(moodManager.moodEntries.count)")
        
        // Enhanced haptic feedback with achievement animation
        HapticManager.shared.moodSelected()
        
        moodGlow = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            moodGlow = false
        }
        
        // Achievement-like animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            // Brief scaling animation to show success
            selectedMood = mood
        }
        
        // Reset selection with animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                selectedMood = nil
            }
            
            // Show success message (you could add a toast notification here)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                print("✅ Mood logged successfully: \(mood.displayName)")
            }
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
                            .stroke(.white.opacity(isSelected ? 0.6 : 0.4), lineWidth: isSelected ? 3 : 1.5)
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
