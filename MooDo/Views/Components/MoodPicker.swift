import SwiftUI

struct MoodPicker: View {
    var onSelect: (MoodType) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood: MoodType? = nil
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // Universal background
            UniversalBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Button("Skip") {
                        onSelect(.calm) // Default to calm if skipped
                        dismiss()
                    }
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("Task Completion")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Done") {
                        if let mood = selectedMood {
                            onSelect(mood)
                        } else {
                            onSelect(.calm) // Default fallback
                        }
                        dismiss()
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(selectedMood != nil ? .peacefulGreen : .white.opacity(0.5))
                    .disabled(selectedMood == nil)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Celebration message
                        VStack(spacing: 16) {
                            // Celebration icon with animation
                            Image(systemName: "star.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.yellow)
                                .scaleEffect(animateGradient ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateGradient)
                                .onAppear {
                                    animateGradient = true
                                }
                            
                            VStack(spacing: 8) {
                                Text("Great job!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("How did completing this task make you feel?")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        // Mood selection grid
                        VStack(spacing: 20) {
                            // Row 1 - Positive moods
                            HStack(spacing: 16) {
                                MoodSelectionCard(
                                    mood: .energized,
                                    isSelected: selectedMood == .energized,
                                    onTap: {
                                        HapticManager.shared.impact(.medium)
                                        selectedMood = .energized
                                    }
                                )
                                
                                MoodSelectionCard(
                                    mood: .focused,
                                    isSelected: selectedMood == .focused,
                                    onTap: {
                                        HapticManager.shared.impact(.medium)
                                        selectedMood = .focused
                                    }
                                )
                                
                                MoodSelectionCard(
                                    mood: .creative,
                                    isSelected: selectedMood == .creative,
                                    onTap: {
                                        HapticManager.shared.impact(.medium)
                                        selectedMood = .creative
                                    }
                                )
                            }
                            
                            // Row 2 - Neutral moods
                            HStack(spacing: 16) {
                                MoodSelectionCard(
                                    mood: .calm,
                                    isSelected: selectedMood == .calm,
                                    onTap: {
                                        HapticManager.shared.impact(.medium)
                                        selectedMood = .calm
                                    }
                                )
                                
                                // Empty spacer for centered alignment
                                Spacer()
                                    .frame(maxWidth: .infinity)
                                
                                Spacer()
                                    .frame(maxWidth: .infinity)
                            }
                            
                            // Row 3 - Challenging moods
                            HStack(spacing: 16) {
                                MoodSelectionCard(
                                    mood: .tired,
                                    isSelected: selectedMood == .tired,
                                    onTap: {
                                        HapticManager.shared.impact(.medium)
                                        selectedMood = .tired
                                    }
                                )
                                
                                MoodSelectionCard(
                                    mood: .stressed,
                                    isSelected: selectedMood == .stressed,
                                    onTap: {
                                        HapticManager.shared.impact(.medium)
                                        selectedMood = .stressed
                                    }
                                )
                                
                                MoodSelectionCard(
                                    mood: .anxious,
                                    isSelected: selectedMood == .anxious,
                                    onTap: {
                                        HapticManager.shared.impact(.medium)
                                        selectedMood = .anxious
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Helper text
                        if selectedMood != nil {
                            VStack(spacing: 8) {
                                Text("Selected: \(selectedMood?.displayName ?? "")")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                Text("This helps us recommend better tasks for your mood")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut(duration: 0.3), value: selectedMood)
                        } else {
                            VStack(spacing: 8) {
                                Text("Tap a mood to continue")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text("This helps us learn and improve your experience")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: selectedMood)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
}

struct MoodSelectionCard: View {
    let mood: MoodType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Mood icon with glow effect
                ZStack {
                    // Glow effect when selected
                    if isSelected {
                        Circle()
                            .fill(mood.color.opacity(0.4))
                            .frame(width: 70, height: 70)
                            .blur(radius: 8)
                            .scaleEffect(1.2)
                    }
                    
                    // Main circle
                    Circle()
                        .fill(isSelected ? mood.color.opacity(0.3) : .white.opacity(0.1))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? mood.color : .white.opacity(0.3),
                                    lineWidth: isSelected ? 3 : 1
                                )
                        )
                    
                    // Icon
                    Image(systemName: mood.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? mood.color : .white.opacity(0.8))
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                
                // Mood name
                Text(mood.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? mood.color.opacity(0.6) : .white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? mood.color.opacity(0.3) : .black.opacity(0.1),
                        radius: isSelected ? 8 : 2,
                        x: 0,
                        y: isSelected ? 4 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MoodPicker { mood in
        print("Selected mood: \(mood)")
    }
}
