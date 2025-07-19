//
//  TaskComponents.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Supporting Views

struct SmartListButton: View {
    let type: SmartListType
    let isSelected: Bool
    let taskCount: Int
    let isCompact: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: isCompact ? 4 : 6) {
                Image(systemName: type.icon)
                    .font(isCompact ? .caption2 : .caption)
                Text(type.rawValue)
                    .font(isCompact ? .caption2 : .caption)
                    .fontWeight(.medium)
                Text("(\(taskCount))")
                    .font(.caption2)
                    .opacity(0.7)
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, isCompact ? 10 : 12)
            .padding(.vertical, isCompact ? 6 : 8)
            .background(
                ZStack {
                                    // Base glass layer for smart list button
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                    
                    // Color overlay
                    Capsule()
                        .fill(isSelected ? type.color.opacity(0.25) : .white.opacity(0.08))
                    
                    // Inner highlight for 3D effect
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .white.opacity(0.15),
                                    .white.opacity(0.05),
                                    .clear,
                                    .black.opacity(0.03)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Glass border
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .white.opacity(0.4),
                                    .white.opacity(0.15),
                                    .white.opacity(0.05),
                                    .white.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 2)
            .shadow(color: .white.opacity(0.08), radius: 1, x: 0, y: -0.5)
        }
    }
}

struct TaskListButton: View {
    let list: TaskList
    let isSelected: Bool
    let taskCount: Int
    let isCompact: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: isCompact ? 4 : 6) {
                Image(systemName: list.icon)
                    .font(isCompact ? .caption2 : .caption)
                Text(list.name)
                    .font(isCompact ? .caption2 : .caption)
                    .fontWeight(.medium)
                Text("(\(taskCount))")
                    .font(.caption2)
                    .opacity(0.7)
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, isCompact ? 10 : 12)
            .padding(.vertical, isCompact ? 6 : 8)
            .background(
                ZStack {
                                    // Base glass layer for task list button
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                    
                    // Color overlay
                    Capsule()
                        .fill(isSelected ? list.color.opacity(0.25) : .white.opacity(0.08))
                    
                    // Inner highlight for 3D effect
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .white.opacity(0.15),
                                    .white.opacity(0.05),
                                    .clear,
                                    .black.opacity(0.03)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Glass border
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .white.opacity(0.4),
                                    .white.opacity(0.15),
                                    .white.opacity(0.05),
                                    .white.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 2)
            .shadow(color: .white.opacity(0.08), radius: 1, x: 0, y: -0.5)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.7))
            
            TextField("Search tasks...", text: $text)
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            ZStack {
                // Base glass layer for search bar
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
                
                // Inner highlight for 3D effect
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.15),
                                .white.opacity(0.05),
                                .clear,
                                .black.opacity(0.03)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Glass border
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.4),
                                .white.opacity(0.15),
                                .white.opacity(0.05),
                                .white.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        .shadow(color: .white.opacity(0.08), radius: 1, x: 0, y: -0.5)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.5))
            
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
            
            Text(message)
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.body)
                        .fontWeight(.medium)
                    Text(actionTitle)
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    ZStack {
                                        // Base glass layer for empty state button
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                        
                        // Inner highlight for 3D effect
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.2),
                                        .white.opacity(0.06),
                                        .clear,
                                        .black.opacity(0.04)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Glass border
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.5),
                                        .white.opacity(0.15),
                                        .white.opacity(0.05),
                                        .white.opacity(0.25)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
                .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 60)
    }
} 