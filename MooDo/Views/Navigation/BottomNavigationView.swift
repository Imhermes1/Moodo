//
//  BottomNavigationView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct MoodLensBottomNavigationView: View {
    @Binding var selectedTab: Int
    let screenSize: CGSize
    
    var body: some View {
        HStack(spacing: 0) {
            // Home tab
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 0
                }
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 18, weight: .medium))
                    Text("Home")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == 0 ? .white : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 0 ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            
            // Tasks tab
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "checklist")
                        .font(.system(size: 18, weight: .medium))
                    Text("Tasks")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == 1 ? .white : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 1 ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            
            // Voice tab
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 2
                }
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "message.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                    Text("Voice")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == 2 ? .white : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 2 ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            
            // Insights tab
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 3
                }
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 18, weight: .medium))
                    Text("Insights")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == 3 ? .white : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 3 ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
        }
        .padding(.vertical, max(10, screenSize.height * 0.015))
        .background(
            ZStack {
                // Glass background with subtle frost effect matching the top navigation
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
                    .opacity(0.35) // Increased opacity for frost effect
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .opacity(0.15) // Added 15% frost layer (increased by 5% more)
                    )
                    .background(
                        // Subtle icy blue frost overlay
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.blue.opacity(0.25),
                                        Color.cyan.opacity(0.22),
                                        Color.white.opacity(0.30)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
            }
        )
        .padding(.horizontal, max(16, screenSize.width * 0.04))
        .padding(.bottom, max(8, screenSize.height * 0.01))
    }
}

#Preview {
    MoodLensBottomNavigationView(
        selectedTab: .constant(0),
        screenSize: CGSize(width: 390, height: 844)
    )
    .background(UniversalBackground())
} 