//
//  LensflareView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI
import Foundation

// Optimized liquid shine animation component
struct LensflareView: View {
    @State private var animationPhase: CGFloat = 0
    
    // Performance optimization: Use fewer animation properties
    private let animationDuration: Double = 8.0 // Slightly slower for smoother performance
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Single optimized liquid layer for better performance
                liquidShineLayer
                    .frame(width: geometry.size.width * 1.8, height: geometry.size.height * 1.8) // Reduced multiplier for performance
                    .offset(x: -geometry.size.width * 0.4, y: -geometry.size.height * 0.4)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                animationPhase = .pi * 2
            }
        }
        .drawingGroup() // Performance optimization: GPU rendering
    }
    
    private var liquidShineLayer: some View {
        RoundedRectangle(cornerRadius: 300)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.7, green: 0.8, blue: 1.0, opacity: 0.08),
                        Color(red: 0.7, green: 0.8, blue: 1.0, opacity: 0.04),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .scaleEffect(1.4 + Foundation.sin(animationPhase) * 0.2) // Reduced scale range for performance
            .rotationEffect(.degrees(Foundation.sin(animationPhase * 0.08) * 25)) // Reduced rotation for performance
            .offset(
                x: Foundation.sin(animationPhase * 0.4) * 120, // Reduced movement range
                y: Foundation.cos(animationPhase * 0.25) * 80
            )
            .blur(radius: 25) // Slightly reduced blur for performance
    }
}

#Preview {
    LensflareView()
        .frame(width: 300, height: 300)
        .background(UniversalBackground())
} 