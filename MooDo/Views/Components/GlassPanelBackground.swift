//
//  GlassPanelBackground.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct GlassPanelBackground: View {
    @State private var lightSweepOffset: CGFloat = -200
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(0.15), location: 0.0),
                        .init(color: .black.opacity(0.05), location: 0.3),
                        .init(color: .black.opacity(0.02), location: 0.7),
                        .init(color: .black.opacity(0.08), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
                    .opacity(0.3)
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
                                .white.opacity(0.15),
                                .white.opacity(0.05),
                                .white.opacity(0.02),
                                .white.opacity(0.1)
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
                    .stroke(.white.opacity(0.02), lineWidth: 0.3)
                    .blur(radius: 2)
            )
            .shadow(color: .white.opacity(0.03), radius: 2, x: 0, y: -1)
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
            .onAppear {
                // Animated light sweep that moves across the glass (slower)
                withAnimation(.linear(duration: 5.0).delay(Double.random(in: 0...3)).repeatForever(autoreverses: false)) {
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
                        .init(color: .black.opacity(0.15), location: 0.0),
                        .init(color: .black.opacity(0.05), location: 0.3),
                        .init(color: .black.opacity(0.02), location: 0.7),
                        .init(color: .black.opacity(0.08), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
                    .opacity(0.3)
            )
            .overlay(
                // Inner liquid glass highlight
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.15),
                                .white.opacity(0.05),
                                .white.opacity(0.02),
                                .white.opacity(0.1)
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
                    .stroke(.white.opacity(0.02), lineWidth: 0.3)
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
        
        StaticGlassPanelBackground()
            .frame(height: 200)
    }
    .padding()
    .background(UniversalBackground())
} 