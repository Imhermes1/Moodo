//
//  UniversalBackground.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct UniversalBackground: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base pink & purple gradient background
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.98, green: 0.45, blue: 0.65), location: 0.0), // Soft pink
                        .init(color: Color(red: 0.85, green: 0.35, blue: 0.75), location: 0.3), // Pink-purple
                        .init(color: Color(red: 0.70, green: 0.25, blue: 0.85), location: 0.7), // Purple
                        .init(color: Color(red: 0.55, green: 0.15, blue: 0.95), location: 1.0)  // Deep purple
                    ]),
                    startPoint: UnitPoint(x: 0.0 + animationOffset * 0.3, y: 0.0),
                    endPoint: UnitPoint(x: 1.0 + animationOffset * 0.3, y: 1.0)
                )
                .ignoresSafeArea(.all)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animationOffset)
                
                // Subtle animated overlay for depth
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.90, green: 0.30, blue: 0.80).opacity(0.3), location: 0.0),
                        .init(color: Color.clear, location: 0.5),
                        .init(color: Color(red: 0.60, green: 0.20, blue: 0.90).opacity(0.3), location: 1.0)
                    ]),
                    startPoint: UnitPoint(x: 1.0 - animationOffset * 0.5, y: 0.0),
                    endPoint: UnitPoint(x: 0.0 + animationOffset * 0.5, y: 1.0)
                )
                .ignoresSafeArea(.all)
                .animation(.easeInOut(duration: 12).repeatForever(autoreverses: true), value: animationOffset)
            }
        }
        .onAppear {
            animationOffset = 1.0
        }
    }
}

#Preview {
    UniversalBackground()
} 