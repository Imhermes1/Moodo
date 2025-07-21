//
//  ViewModifiers.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Glass Background Modifier

struct GlassBackgroundModifier: ViewModifier {
    let cornerRadius: CGFloat
    let opacity: CGFloat
    
    init(cornerRadius: CGFloat = 16, opacity: CGFloat = 0.4) {
        self.cornerRadius = cornerRadius
        self.opacity = opacity
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
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
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
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
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
            .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Capsule Glass Background Modifier

struct CapsuleGlassBackgroundModifier: ViewModifier {
    let opacity: CGFloat
    
    init(opacity: CGFloat = 0.4) {
        self.opacity = opacity
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
                    .overlay(
                        Capsule()
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
                    )
                    .overlay(
                        Capsule()
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
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
            .clipShape(Capsule())
    }
}

// MARK: - Content Glass Background Modifier (simpler version)

struct ContentGlassBackgroundModifier: ViewModifier {
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 8) {
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

// MARK: - View Extensions

extension View {
    func glassBackground(cornerRadius: CGFloat = 16, opacity: CGFloat = 0.4) -> some View {
        modifier(GlassBackgroundModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
    
    func capsuleGlassBackground(opacity: CGFloat = 0.4) -> some View {
        modifier(CapsuleGlassBackgroundModifier(opacity: opacity))
    }
    
    func contentGlassBackground(cornerRadius: CGFloat = 8) -> some View {
        modifier(ContentGlassBackgroundModifier(cornerRadius: cornerRadius))
    }
} 