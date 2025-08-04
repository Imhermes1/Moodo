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
            // Frosted transparent white background
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.8), lineWidth: 1.5)
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            HStack {
                // MoodLens logo and title
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("MooDo")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("Feel. Plan. Do.")
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
            .padding(.horizontal, 12)
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
} 
