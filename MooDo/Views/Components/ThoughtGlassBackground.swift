//
//  ThoughtGlassBackground.swift
//  MooDo
//
//  Created by Code Assistant on 20/8/2025.
//

import SwiftUI

// A light, translucent grey glass effect for Thought cards
struct ThoughtGlassBackground: View {
    var cornerRadius: CGFloat = 16

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.ultraThinMaterial)
            .overlay(
                // Soft highlight for glass sheen
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.10),
                                Color.white.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
            )
            .background(
                // Subtle neutral grey tint
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemGray5).opacity(0.18))
            )
            // Border provided by GlassThinBorder overlay where used
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        ThoughtGlassBackground(cornerRadius: 12)
            .frame(height: 100)
        ThoughtGlassBackground(cornerRadius: 20)
            .frame(height: 160)
    }
    .padding()
    .background(UniversalBackground())
}
