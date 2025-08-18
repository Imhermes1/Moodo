//
//  RecentThoughtsView.swift
//  Moodo
//
//  Created by Luke Fornieri on 11/8/2025.
//

import SwiftUI

struct RecentThoughtsView: View {
    @ObservedObject var thoughtsManager: ThoughtsManager
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
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
                        ThoughtRowView(thought: thought, thoughtsManager: thoughtsManager)
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
                    .fill(.thinMaterial)
                    .opacity(0.5)
                
                // Subtle blue tint layer
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.blue.opacity(0.08))
                
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
                
                // Consistent blue outline
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(Color.blue.opacity(0.4), lineWidth: 1.5)
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
        .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .sheet(isPresented: $showingAddThought) {
            AddThoughtView(
                thoughtsManager: thoughtsManager,
                taskManager: taskManager,
                moodManager: moodManager
            )
        }
        .sheet(isPresented: $showingAllThoughts) {
            AllThoughtsListView(
                thoughtsManager: thoughtsManager,
                taskManager: taskManager,
                moodManager: moodManager
            )
        }
    }
    
    
    struct ThoughtRowView: View {
        let thought: Thought
        @ObservedObject var thoughtsManager: ThoughtsManager
        @State private var showingEditSheet = false
        
        private var timeAgo: String {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return formatter.localizedString(for: thought.dateCreated, relativeTo: Date())
        }
        
        var body: some View {
            Button(action: { showingEditSheet = true }) {
                VStack(alignment: .leading, spacing: 8) {
                Text(renderMarkdownText(thought.title))
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
            }
            .buttonStyle(PlainButtonStyle())
            .padding(12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.thinMaterial)
                        .opacity(0.4)
                    
                    // Blue tint for thought cards
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.06))
                    
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                }
            )
            .sheet(isPresented: $showingEditSheet) {
                EditThoughtView(thought: thought, thoughtsManager: thoughtsManager)
            }
        }
        
        // Helper function to render markdown text properly
        private func renderMarkdownText(_ text: String) -> AttributedString {
            // Clean up any existing phone number markdown (not supported by SwiftUI)
            var cleanedText = text
            // Remove phone link syntax: [number](tel:number) -> number
            cleanedText = cleanedText.replacingOccurrences(
                of: "\\[([^\\]]+)\\]\\(tel:[^\\)]+\\)",
                with: "$1",
                options: .regularExpression
            )
            
            // Try to parse remaining markdown (for URLs, bold, italic, etc)
            if let attributedString = try? AttributedString(markdown: cleanedText) {
                return attributedString
            }
            
            // If markdown parsing fails, clean up any remaining link syntax
            cleanedText = cleanedText.replacingOccurrences(
                of: "\\[([^\\]]+)\\]\\([^\\)]+\\)",
                with: "$1",
                options: .regularExpression
            )
            return AttributedString(cleanedText)
        }
    }
    
    struct RecentThoughtsView_Previews: PreviewProvider {
        static var previews: some View {
            RecentThoughtsView(
                thoughtsManager: ThoughtsManager(),
                taskManager: TaskManager(),
                moodManager: MoodManager()
            )
            .padding()
            .background(UniversalBackground())
        }
    }
}
