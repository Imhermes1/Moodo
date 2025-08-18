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
                // White base background
                Color.white
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Top-left corner - Yellow glow
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 1.0, green: 0.95, blue: 0.5).opacity(0.75), location: 0.0),
                        .init(color: Color(red: 1.0, green: 0.95, blue: 0.5).opacity(0.6), location: 0.4),
                        .init(color: Color(red: 1.0, green: 0.95, blue: 0.5).opacity(0.4), location: 0.7),
                        .init(color: Color(red: 1.0, green: 0.95, blue: 0.5).opacity(0.15), location: 0.9),
                        .init(color: Color.clear, location: 1.0)
                    ]),
                    center: UnitPoint(x: 0, y: 0),
                    startRadius: 0,
                    endRadius: geometry.size.width * 1.2
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Top-right corner - Pink glow
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 1.0, green: 0.7, blue: 0.85).opacity(0.75), location: 0.0),
                        .init(color: Color(red: 1.0, green: 0.7, blue: 0.85).opacity(0.6), location: 0.4),
                        .init(color: Color(red: 1.0, green: 0.7, blue: 0.85).opacity(0.4), location: 0.7),
                        .init(color: Color(red: 1.0, green: 0.7, blue: 0.85).opacity(0.15), location: 0.9),
                        .init(color: Color.clear, location: 1.0)
                    ]),
                    center: UnitPoint(x: 1, y: 0),
                    startRadius: 0,
                    endRadius: geometry.size.width * 1.2
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Bottom-left corner - Green glow
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.6, green: 0.9, blue: 0.6).opacity(0.75), location: 0.0),
                        .init(color: Color(red: 0.6, green: 0.9, blue: 0.6).opacity(0.6), location: 0.4),
                        .init(color: Color(red: 0.6, green: 0.9, blue: 0.6).opacity(0.4), location: 0.7),
                        .init(color: Color(red: 0.6, green: 0.9, blue: 0.6).opacity(0.15), location: 0.9),
                        .init(color: Color.clear, location: 1.0)
                    ]),
                    center: UnitPoint(x: 0, y: 1),
                    startRadius: 0,
                    endRadius: geometry.size.width * 1.2
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Bottom-right corner - Sky blue glow
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.5, green: 0.8, blue: 1.0).opacity(0.75), location: 0.0),
                        .init(color: Color(red: 0.5, green: 0.8, blue: 1.0).opacity(0.6), location: 0.4),
                        .init(color: Color(red: 0.5, green: 0.8, blue: 1.0).opacity(0.4), location: 0.7),
                        .init(color: Color(red: 0.5, green: 0.8, blue: 1.0).opacity(0.15), location: 0.9),
                        .init(color: Color.clear, location: 1.0)
                    ]),
                    center: UnitPoint(x: 1, y: 1),
                    startRadius: 0,
                    endRadius: geometry.size.width * 1.2
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Gentle floating particles for subtle animation
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: CGFloat.random(in: 1.5...2.5))
                        .position(
                            x: (CGFloat(index * 120 + 50) + sin(animationOffset * 0.3 + Double(index)) * 30).truncatingRemainder(dividingBy: geometry.size.width),
                            y: (CGFloat(index * 100 + 80) + cos(animationOffset * 0.2 + Double(index) * 0.7) * 40).truncatingRemainder(dividingBy: geometry.size.height)
                        )
                        .opacity(sin(Double(animationOffset) * 0.5 + Double(index) * 0.8) * 0.2 + 0.5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .all)
            .onAppear {
                withAnimation(.linear(duration: 30.0).repeatForever(autoreverses: false)) {
                    animationOffset = .pi * 6
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    UniversalBackground()
}

// MARK: - Alternative Calming Backgrounds

struct MeditationBackground: View {
    @State private var breathingScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Deep meditation gradient
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.meditationBlue.opacity(0.8), location: 0.0),
                        .init(color: Color.nurturingLavender.opacity(0.6), location: 0.5),
                        .init(color: Color.peacefulTwilight.opacity(0.7), location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Breathing circle
                Circle()
                    .fill(Color.white.opacity(0.02))
                    .scaleEffect(breathingScale)
                    .frame(width: geometry.size.width * 0.6)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.4)
                    .animation(
                        .easeInOut(duration: 6.0).repeatForever(autoreverses: true),
                        value: breathingScale
                    )
                    .onAppear {
                        breathingScale = 1.2
                    }
            }
        }
    }
}

struct GroundingBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Earth-toned grounding gradient
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.groundingGreen.opacity(0.6), location: 0.0),
                        .init(color: Color.sageGreen.opacity(0.5), location: 0.4),
                        .init(color: Color.peacefulGreen.opacity(0.4), location: 0.8),
                        .init(color: Color.mistyGrey.opacity(0.3), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Gentle wave pattern
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.7))
                    path.addQuadCurve(
                        to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.6),
                        control: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                    )
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(Color.sageGreen.opacity(0.1))
            }
        }
    }
}

struct UpliftingBackground: View {
    @State private var sunriseOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sunrise gradient
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.sunriseYellow.opacity(0.3), location: 0.0),
                        .init(color: Color.dustyRose.opacity(0.4), location: 0.3),
                        .init(color: Color.calmingBlue.opacity(0.5), location: 0.7),
                        .init(color: Color.softViolet.opacity(0.4), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Gentle sun rays
                ForEach(0..<5, id: \.self) { index in
                    Rectangle()
                        .fill(Color.sunriseYellow.opacity(0.05))
                        .frame(width: 2, height: geometry.size.height)
                        .rotationEffect(.degrees(Double(index) * 15 + Double(sunriseOffset)))
                        .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.3)
                }
                .animation(
                    .linear(duration: 30).repeatForever(autoreverses: false),
                    value: sunriseOffset
                )
                .onAppear {
                    sunriseOffset = 360
                }
            }
        }
    }
}

