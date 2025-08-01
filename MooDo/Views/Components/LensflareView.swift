//
//  LensflareView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI
import Foundation

// Ultra-optimized liquid shine animation component for ultimate performance
struct LensflareView: View {
    @State private var animationPhase: CGFloat = 0
    @State private var isVisible = false
    
    // Performance optimization: Minimal animation properties
    private let animationDuration: Double = 12.0 // Slower for better performance
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Conditionally render for performance
                if isVisible {
                    liquidShineLayer
                        .frame(width: geometry.size.width * 1.5, height: geometry.size.height * 1.5) // Further reduced multiplier
                        .offset(x: -geometry.size.width * 0.25, y: -geometry.size.height * 0.25)
                }
            }
        }
        .onAppear {
            // Delayed start for better initial app performance
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isVisible = true
                withAnimation(.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                    animationPhase = .pi * 2
                }
            }
        }
        .onDisappear {
            isVisible = false
        }
        .drawingGroup() // Performance optimization: GPU rendering
    }
    
    private var liquidShineLayer: some View {
        RoundedRectangle(cornerRadius: 200) // Reduced corner radius for performance
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.7, green: 0.8, blue: 1.0, opacity: 0.06), // Further reduced opacity
                        Color(red: 0.7, green: 0.8, blue: 1.0, opacity: 0.03),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .scaleEffect(1.2 + Foundation.sin(animationPhase) * 0.1) // Minimal scale animation
            .rotationEffect(.degrees(Foundation.sin(animationPhase * 0.05) * 15)) // Reduced rotation
            .offset(
                x: Foundation.sin(animationPhase * 0.3) * 80, // Reduced movement
                y: Foundation.cos(animationPhase * 0.2) * 60
            )
            .blur(radius: 20) // Reduced blur for better performance
    }
}

#Preview {
    LensflareView()
        .frame(width: 300, height: 300)
        .background(UniversalBackground())
} 