//
//  CalmingColors.swift
//  Moodo
//
//  Created by Luke Fornieri on 4/8/2025.
//

import SwiftUI

extension Color {
    // MARK: - Calming Color Palette
    
    /// Soft, peaceful blue - primary accent color
    static let calmingBlue = Color(red: 0.4, green: 0.7, blue: 0.9)
    
    /// Gentle, nurturing green - success and completion
    static let peacefulGreen = Color(red: 0.5, green: 0.8, blue: 0.6)
    
    /// Warm, encouraging yellow - today/current focus
    static let gentleYellow = Color(red: 1.0, green: 0.85, blue: 0.4)
    
    /// Soft pink-violet - emotions and important items
    static let softViolet = Color(red: 0.85, green: 0.6, blue: 0.85)
    
    /// Muted lavender - secondary accent
    static let mutedLavender = Color(red: 0.75, green: 0.7, blue: 0.9)
    
    /// Sage green - alternative green for variety
    static let sageGreen = Color(red: 0.7, green: 0.8, blue: 0.7)
    
    /// Dusty rose - warm, comforting pink
    static let dustyRose = Color(red: 0.9, green: 0.75, blue: 0.8)
    
    /// Misty grey - neutral, calming
    static let mistyGrey = Color(red: 0.8, green: 0.8, blue: 0.85)
    
    /// Soft cream - alternative to white
    static let softCream = Color(red: 0.98, green: 0.96, blue: 0.94)
    
    // MARK: - Semantic Colors
    
    /// Primary button and accent color
    static let primaryAccent = Color.black
    
    /// Success states (completed tasks, positive actions)
    static let successAccent = peacefulGreen
    
    /// Warning/attention (today's tasks, priorities)
    static let warningAccent = gentleYellow
    
    /// Emotional/important content
    static let emotionalAccent = softViolet
    
    /// Secondary accent for variety
    static let secondaryAccent = mutedLavender
    
    // MARK: - Mental Health Focused Colors
    
    /// Calming meditation blue
    static let meditationBlue = Color(red: 0.35, green: 0.6, blue: 0.8)
    
    /// Grounding earth green
    static let groundingGreen = Color(red: 0.45, green: 0.7, blue: 0.55)
    
    /// Uplifting sunrise yellow
    static let sunriseYellow = Color(red: 0.95, green: 0.8, blue: 0.35)
    
    /// Nurturing lavender
    static let nurturingLavender = Color(red: 0.7, green: 0.65, blue: 0.85)
    
    /// Peaceful twilight
    static let peacefulTwilight = Color(red: 0.6, green: 0.55, blue: 0.75)
}

// MARK: - Calming Gradients

extension LinearGradient {
    /// Peaceful blue-to-green gradient
    static let peacefulFlow = LinearGradient(
        colors: [Color.calmingBlue, Color.peacefulGreen],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Sunset calming gradient
    static let sunsetCalm = LinearGradient(
        colors: [Color.gentleYellow, Color.dustyRose, Color.softViolet],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Meditation gradient
    static let meditation = LinearGradient(
        colors: [Color.meditationBlue, Color.nurturingLavender],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Earth grounding gradient
    static let earthGrounding = LinearGradient(
        colors: [Color.sageGreen, Color.groundingGreen, Color.peacefulGreen],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Mental Health Color Themes

struct CalmingTheme {
    let primary: Color
    let secondary: Color
    let accent: Color
    let background: Color
    let text: Color
    
    static let peaceful = CalmingTheme(
        primary: .calmingBlue,
        secondary: .peacefulGreen,
        accent: .softViolet,
        background: .softCream,
        text: .primary
    )
    
    static let grounding = CalmingTheme(
        primary: .groundingGreen,
        secondary: .sageGreen,
        accent: .gentleYellow,
        background: .mistyGrey,
        text: .primary
    )
    
    static let uplifting = CalmingTheme(
        primary: .sunriseYellow,
        secondary: .dustyRose,
        accent: .calmingBlue,
        background: .softCream,
        text: .primary
    )
}
