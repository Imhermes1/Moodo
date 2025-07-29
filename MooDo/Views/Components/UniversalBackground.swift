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
                // Base deep, futuristic vertical gradient background (static for better performance)
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.10, green: 0.13, blue: 0.24), location: 0.0), // Midnight blue
                        .init(color: Color(red: 0.19, green: 0.28, blue: 0.50), location: 0.4), // Deep navy
                        .init(color: Color(red: 0.10, green: 0.43, blue: 0.70), location: 0.7), // Cyber blue
                        .init(color: Color(red: 0.25, green: 0.11, blue: 0.49), location: 1.0)  // Vivid purple
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Electric shimmer overlay with blue/cyan/purple hues
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.cyan.opacity(0.18), location: 0.0),
                        .init(color: Color.purple.opacity(0.13), location: 0.4),
                        .init(color: Color.blue.opacity(0.18), location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Glassy shine overlay
                Rectangle()
                    .fill(Color.white.opacity(0.012))
                    .blendMode(.plusLighter)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    UniversalBackground()
}
