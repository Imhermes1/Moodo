//
//  LensflareView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI
import Foundation

// Liquid shine animation component
struct LensflareView: View {
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Liquid shine effect that fills the entire screen
                liquidShineLayer
                    .frame(width: geometry.size.width * 3, height: geometry.size.height * 3)
                    .offset(x: -geometry.size.width, y: -geometry.size.height)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4)) {
                animationPhase = .pi * 2
            }
        }
    }
    
    private var liquidShineLayer: some View {
        ZStack {
            // Multiple liquid layers for depth
            ForEach(0..<3, id: \.self) { layer in
                liquidLayer(for: layer)
            }
        }
    }
    
    @ViewBuilder
    private func liquidLayer(for layer: Int) -> some View {
        let layerOffset = CGFloat(layer) * 0.3
        let layerSpeed = 1.0 + CGFloat(layer) * 0.2
        
                        RoundedRectangle(cornerRadius: 400)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.7, green: 0.8, blue: 1.0, opacity: 0.12), // Fixed green value
                                Color(red: 0.7, green: 0.8, blue: 1.0, opacity: 0.06),
                                Color(red: 0.7, green: 0.8, blue: 1.0, opacity: 0.02),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            .scaleEffect(2.0 + Foundation.sin(animationPhase * layerSpeed) * 0.8)
            .rotationEffect(.degrees(Foundation.sin(animationPhase * layerSpeed * 0.2) * 90))
            .offset(
                x: Foundation.sin(animationPhase * layerSpeed + layerOffset) * 300,
                y: Foundation.cos(animationPhase * layerSpeed * 0.4 + layerOffset) * 250
            )
            .blur(radius: 40 + CGFloat(layer) * 20)
    }
}

#Preview {
    LensflareView()
        .frame(width: 300, height: 300)
        .background(UniversalBackground())
} 