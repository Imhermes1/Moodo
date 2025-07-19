//
//  TopNavigationView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct TopNavigationView: View {
    let onNotificationTap: () -> Void
    let onAccountTap: () -> Void
    let onAddTaskTap: () -> Void
    let screenSize: CGSize
    
    var body: some View {
        ZStack {
            // Glass background with subtle frost effect
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .opacity(0.35) // Increased opacity for frost effect
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .opacity(0.05) // Added 5% frost layer
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
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
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            HStack {
                // MoodLens logo and title
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("MoodLens")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("To-Do")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Add Task, Notification and profile icons
                HStack(spacing: 12) {
                    Button(action: onAddTaskTap) {
                        Image(systemName: "plus")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    
                    Button(action: onNotificationTap) {
                        Image(systemName: "bell")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Button(action: onAccountTap) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(height: max(44, screenSize.height * 0.06))
        .padding(.horizontal, max(20, screenSize.width * 0.05))
    }
}

#Preview {
    TopNavigationView(
        onNotificationTap: {},
        onAccountTap: {},
        onAddTaskTap: {},
        screenSize: CGSize(width: 390, height: 844)
    )
    .background(UniversalBackground())
} 