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
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 0
                }
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 18, weight: .medium))
                    Text("Home")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == 0 ? .black : .black.opacity(0.7))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 0 ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            
            // Tasks tab
            Button(action: { 
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 1
                }
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "checklist")
                        .font(.system(size: 18, weight: .medium))
                    Text("Tasks")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == 1 ? .black : .black.opacity(0.7))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 1 ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            
            // Thoughts tab
            Button(action: { 
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 2
                }
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 18, weight: .medium))
                    Text("Thoughts")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == 2 ? .black : .black.opacity(0.7))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 2 ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            
            // Wellness tab
            Button(action: { 
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 3
                }
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                    Text("Wellness")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == 3 ? .black : .black.opacity(0.7))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 3 ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            
            // Insights tab
            Button(action: { 
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 4
                }
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 18, weight: .medium))
                    Text("Insights")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == 4 ? .black : .black.opacity(0.7))
                .frame(maxWidth: .infinity)
                .scaleEffect(selectedTab == 4 ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
        }
        .padding(.vertical, max(10, screenSize.height * 0.015))
        .background(
            ZStack {
                // Frosted transparent white background
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black.opacity(0.8), lineWidth: 1.5)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
            }
        )
        .padding(.horizontal, max(16, screenSize.width * 0.04))
    }
}

#Preview {
    MoodLensBottomNavigationView(
        selectedTab: .constant(0),
        screenSize: CGSize(width: 390, height: 844)
    )
} 
