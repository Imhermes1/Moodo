//
//  RecentThoughtsView.swift
//  Moodo
//
//  Created by Luke Fornieri on 11/8/2025.
//

import SwiftUI

struct RecentThoughtsView: View {
    @ObservedObject var thoughtsManager: ThoughtsManager
    @State private var showingAddThought = false
    @State private var showingAllThoughts = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Recent Thoughts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showingAddThought = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            // Thoughts content
            if thoughtsManager.thoughts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cloud")
                        .font(.system(size: 48))
                        .foregroundColor(.primary.opacity(0.4))
                    
                    VStack(spacing: 8) {
                        Text("Ready to capture brilliance?")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Text("Think. Capture. Flourish.")
                            .font(.body)
                            .foregroundColor(.primary.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.vertical, 32)
            } else {
                VStack(spacing: 12) {
                    ForEach(thoughtsManager.recentThoughts.prefix(3)) { thought in
                        ThoughtRowView(thought: thought)
                    }
                    
                    if thoughtsManager.thoughts.count > 3 {
                        Button("View All Thoughts") {
                            showingAllThoughts = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                    }
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                // Base glass layer with 3D depth
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                
                // Inner highlight layer for 3D effect
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.25),
                                .white.opacity(0.08),
                                .clear,
                                .black.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Outer stroke with glass shimmer
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.2),
                                .white.opacity(0.05),
                                .white.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                
                // Inner stroke for depth
                RoundedRectangle(cornerRadius: 23)
                    .strokeBorder(
                        .white.opacity(0.1),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
        .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .sheet(isPresented: $showingAddThought) {
            AddThoughtView(thoughtsManager: thoughtsManager)
        }
        .sheet(isPresented: $showingAllThoughts) {
            AllThoughtsListView(thoughtsManager: thoughtsManager)
        }
    }
    
    
    struct ThoughtRowView: View {
        let thought: Thought
        
        private var timeAgo: String {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return formatter.localizedString(for: thought.dateCreated, relativeTo: Date())
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(thought.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(timeAgo)
                        .font(.caption2)
                        .foregroundColor(.primary.opacity(0.6))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: thought.mood.icon)
                            .font(.caption2)
                            .foregroundColor(thought.mood.color)
                        Text(thought.mood.displayName)
                            .font(.caption2)
                            .foregroundColor(.primary.opacity(0.7))
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    struct RecentThoughtsView_Previews: PreviewProvider {
        static var previews: some View {
            RecentThoughtsView(thoughtsManager: ThoughtsManager())
                .padding()
                .background(UniversalBackground())
        }
    }
}

