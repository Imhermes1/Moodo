//
//  GlassPanelBackground.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct GlassPanelBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.19, green: 0.30, blue: 0.55, opacity: 0.25), location: 0.0),
                        .init(color: Color(red: 0.16, green: 0.38, blue: 0.71, opacity: 0.20), location: 0.4),
                        .init(color: Color(red: 0.60, green: 0.85, blue: 1.0, opacity: 0.18), location: 0.7),
                        .init(color: Color(red: 0.36, green: 0.17, blue: 0.89, opacity: 0.22), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(0.25)
            )
            .overlay(
                // Soft white frosting overlay for gentle enhancement
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                // Inner neon glass highlight with cool tones
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .cyan,
                                .blue.opacity(0.23),
                                .purple.opacity(0.17),
                                .white.opacity(0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .overlay(
                // Outer subtle glow for added depth and pop
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.08), lineWidth: 0.3)
                    .blur(radius: 4)
            )
            .overlay(
                // Soft cyan glow behind the glass for futuristic effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.cyan.opacity(0.06))
                    .blur(radius: 12)
            )
            .shadow(color: .white.opacity(0.03), radius: 2, x: 0, y: -1)
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

struct AnimatedGlassPanelBackground: View {
    @State private var lightSweepOffset: CGFloat = -200
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(0.18), location: 0.0),
                        .init(color: .black.opacity(0.08), location: 0.3),
                        .init(color: .black.opacity(0.05), location: 0.7),
                        .init(color: .black.opacity(0.12), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
                    .opacity(0.25)
            )
            .overlay(
                // Animated light sweep effect (more subtle)
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .black.opacity(0.05), location: 0.45),
                                .init(color: .black.opacity(0.08), location: 0.5),
                                .init(color: .black.opacity(0.05), location: 0.55),
                                .init(color: .clear, location: 1.0)
                            ]),
                            startPoint: .init(x: lightSweepOffset / 300, y: 0),
                            endPoint: .init(x: (lightSweepOffset + 100) / 300, y: 1)
                        )
                    )
                    .clipped()
            )
            .overlay(
                // Inner liquid glass highlight
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.18),
                                .white.opacity(0.08),
                                .white.opacity(0.05),
                                .white.opacity(0.12)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .overlay(
                // Outer subtle glow for depth
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.05), lineWidth: 0.3)
                    .blur(radius: 2)
            )
            .shadow(color: .white.opacity(0.03), radius: 2, x: 0, y: -1)
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
            .onAppear {
                // Animated light sweep that moves across the glass (much slower for performance)
                withAnimation(.linear(duration: 8.0).delay(Double.random(in: 0...2)).repeatForever(autoreverses: false)) {
                    lightSweepOffset = 400
                }
            }
    }
}

struct StaticGlassPanelBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(0.18), location: 0.0),
                        .init(color: .black.opacity(0.08), location: 0.3),
                        .init(color: .black.opacity(0.05), location: 0.7),
                        .init(color: .black.opacity(0.12), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
                    .opacity(0.25)
            )
            .overlay(
                // Inner liquid glass highlight
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.18),
                                .white.opacity(0.08),
                                .white.opacity(0.05),
                                .white.opacity(0.12)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .overlay(
                // Outer subtle glow for depth
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.05), lineWidth: 0.3)
                    .blur(radius: 2)
            )
            .shadow(color: .white.opacity(0.03), radius: 2, x: 0, y: -1)
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

#Preview {
    VStack(spacing: 20) {
        GlassPanelBackground()
            .frame(height: 200)
        
        AnimatedGlassPanelBackground()
            .frame(height: 200)
        
        StaticGlassPanelBackground()
            .frame(height: 200)
    }
    .padding()
    .background(UniversalBackground())
} 
