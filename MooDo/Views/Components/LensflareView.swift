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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Single optimized liquid layer for better performance
                liquidShineLayer
                    .frame(width: geometry.size.width * 2, height: geometry.size.height * 2)
                    .offset(x: -geometry.size.width * 0.5, y: -geometry.size.height * 0.5)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animationPhase = .pi * 2
            }
        }
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
            .scaleEffect(1.5 + Foundation.sin(animationPhase) * 0.3)
            .rotationEffect(.degrees(Foundation.sin(animationPhase * 0.1) * 30))
            .offset(
                x: Foundation.sin(animationPhase * 0.5) * 150,
                y: Foundation.cos(animationPhase * 0.3) * 100
            )
            .blur(radius: 30)
    }
}

#Preview {
    LensflareView()
        .frame(width: 300, height: 300)
        .background(UniversalBackground())
} 