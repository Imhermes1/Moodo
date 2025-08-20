//
//  ThoughtsView.swift
//  Moodo
//
//  Created by Luke Fornieri on 11/8/2025.
//

import SwiftUI
import Combine

struct ThoughtsView: View {
    @ObservedObject var thoughtsManager: ThoughtsManager
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    let screenSize: CGSize
    
    @State private var showingAddThought = false
    @State private var searchText = ""
    @State private var selectedMoodFilter: MoodType?
    @State private var showingMoodFilter = false
    @State private var keyboardHeight: CGFloat = 0
    
    private var filteredThoughts: [Thought] {
        var thoughts = thoughtsManager.recentThoughts
        
        // Apply search filter
        if !searchText.isEmpty {
            thoughts = thoughts.filter { 
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply mood filter
        if let moodFilter = selectedMoodFilter {
            thoughts = thoughts.filter { $0.mood == moodFilter }
        }
        
        return thoughts
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
            // Search and Filter Bar - Fixed position
            VStack(spacing: 12) {
                // Search Bar with Add Button
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.6))
                    
                    TextField("Search thoughts...", text: $searchText)
                        .foregroundColor(.white)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.black)
                        }
                    }
                    
                    // Add button inside search bar
                    Button(action: { showingAddThought = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.2))
                        
                        // Blue tint for search bar
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.06))
                        
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.4), lineWidth: 1.5)
                    }
                )
                    
                    // Mood Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // All filter
                            Button(action: { selectedMoodFilter = nil }) {
                                Text("All")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedMoodFilter == nil ? .blue : .white.opacity(0.7))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(selectedMoodFilter == nil ? Color.blue.opacity(0.7) : Color.blue.opacity(0.25))
                                            .overlay(
                                                Capsule()
                                                    .stroke(selectedMoodFilter == nil ? Color.black : Color.black.opacity(0.45), lineWidth: 1)
                                            )
                                    )
                            }
                            
                            ForEach(MoodType.allCases, id: \.self) { mood in
                                Button(action: {
                                    selectedMoodFilter = selectedMoodFilter == mood ? nil : mood
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: mood.icon)
                                            .font(.caption2)
                                        Text(mood.displayName)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(selectedMoodFilter == mood ? mood.color : .white.opacity(0.7))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(selectedMoodFilter == mood ? mood.color.opacity(0.7) : mood.color.opacity(0.25))
                                            .overlay(
                                                Capsule()
                                                    .stroke(selectedMoodFilter == mood ? Color.black : Color.black.opacity(0.45), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, max(geometry.size.height * 0.08, 60))
                .padding(.bottom, 16)
                .background(Color.clear) // Ensure stable background
                
                // Thoughts List
                if filteredThoughts.isEmpty {
                    VStack(spacing: 20) {
                        Spacer() // Push content to center
                        
                        Image(systemName: searchText.isEmpty ? "cloud.fill" : "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(searchText.isEmpty ? .blue.opacity(0.6) : .white.opacity(0.4))
                        
                        VStack(spacing: 8) {
                            Text(searchText.isEmpty ? "Your mind is limitless" : "No thoughts found")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            Text(searchText.isEmpty ? 
                                 "Every brilliant idea starts with a single thought." : 
                                 "Try refining your search or exploring different moods")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        
                        Spacer() // Push content to center
                        Spacer() // Extra spacer to account for bottom navigation
                    }
                    .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.6) // Ensure enough height for centering
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredThoughts) { thought in
                                FullThoughtRowView(
                                    thought: thought,
                                    thoughtsManager: thoughtsManager,
                                    taskManager: taskManager,
                                    moodManager: moodManager
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, max(100, keyboardHeight)) // Keyboard-aware padding
                    }
                }
                
                Spacer()
            }
        }
            .background(
                UniversalBackground()
                    .ignoresSafeArea(.all)
            )
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardHeight = 0
            }
            .animation(nil, value: selectedMoodFilter) // Disable layout animations
            .sheet(isPresented: $showingAddThought) {
                AddThoughtView(
                    thoughtsManager: thoughtsManager,
                    taskManager: taskManager,
                    moodManager: moodManager
                )
            }
    }
}

struct FullThoughtRowView: View {
    let thought: Thought
    @ObservedObject var thoughtsManager: ThoughtsManager
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    
    @State private var showingEditSheet = false
    @State private var showingConvertSheet = false
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: thought.dateCreated, relativeTo: Date())
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: thought.dateCreated)
    }
    
    var body: some View {
        Button(action: { showingEditSheet = true }) {
            VStack(alignment: .leading, spacing: 8) {
            // Title (heading) on first row - now clickable for phone numbers
            ClickableText(
                text: thought.title,
                font: .headline,
                color: .white,
                linkColor: .blue.opacity(0.8),
                lineLimit: 1
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Content preview on second row (if content exists)
            if !thought.content.isEmpty {
                let firstLine = extractFirstLine(from: thought.content)
                ClickableText(
                    text: firstLine,
                    font: .body,
                    color: .white.opacity(0.8),
                    linkColor: .blue.opacity(0.8),
                    lineLimit: 1
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Metadata and action row - streamlined
            HStack {
                // Mood display
                let mood = thought.mood
                HStack(spacing: 4) {
                    Image(systemName: mood.icon)
                        .font(.caption2)
                        .foregroundColor(mood.color)
                    
                    Text(mood.displayName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Time in middle
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                // Convert to task button only
                Button(action: { showingConvertSheet = true }) {
                    Text("Convert to Task")
                        .font(.caption)
                        .foregroundColor(.black)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }

            // Linked task indicator (if exists)
            if let linkedId = thought.linkedTaskId,
               let linkedTask = taskManager.tasks.first(where: { $0.id == linkedId }) {
                HStack(spacing: 6) {
                    Image(systemName: "link")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("Linked: \(linkedTask.title)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(16)
        .background(ThoughtGlassBackground(cornerRadius: 16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(GlassThinBorder(cornerRadius: 16))
        .contextMenu {
            Button(action: { showingEditSheet = true }) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(action: { showingConvertSheet = true }) {
                Label("Convert to Task", systemImage: "arrow.right.circle")
            }
            
            Button(role: .destructive, action: { 
                thoughtsManager.deleteThought(thought) 
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditThoughtView(thought: thought, thoughtsManager: thoughtsManager)
        }
        .sheet(isPresented: $showingConvertSheet) {
            ConvertThoughtToTaskView(
                thought: thought,
                thoughtsManager: thoughtsManager,
                taskManager: taskManager,
                moodManager: moodManager,
                deleteOriginalThoughtDefault: false
            )
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
    
    // Helper function to extract first line of content for preview
    private func extractFirstLine(from content: String) -> String {
        // Remove markdown syntax for a clean preview
        let cleanContent = content
            .replacingOccurrences(of: "^#{1,6}\\s+", with: "", options: .regularExpression) // Remove heading markers
            .replacingOccurrences(of: "\\*\\*(.+?)\\*\\*", with: "$1", options: .regularExpression) // Remove bold
            .replacingOccurrences(of: "\\*(.+?)\\*", with: "$1", options: .regularExpression) // Remove italic
            .replacingOccurrences(of: "`(.+?)`", with: "$1", options: .regularExpression) // Remove code
            .replacingOccurrences(of: "\\[(.+?)\\]\\(.+?\\)", with: "$1", options: .regularExpression) // Keep link text only
            .replacingOccurrences(of: "^[\\-\\*\\+]\\s+", with: "", options: .regularExpression) // Remove bullet points
        
        // Get first line
        let lines = cleanContent.components(separatedBy: .newlines)
        let firstLine = lines.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Limit length for preview
        if firstLine.count > 60 {
            let index = firstLine.index(firstLine.startIndex, offsetBy: 57)
            return String(firstLine[..<index]) + "..."
        }
        
        return firstLine.isEmpty ? "No content" : firstLine
    }
}

struct ThoughtsView_Previews: PreviewProvider {
    static var previews: some View {
        ThoughtsView(
            thoughtsManager: ThoughtsManager(),
            taskManager: TaskManager(),
            moodManager: MoodManager(),
            screenSize: CGSize(width: 390, height: 844)
        )
    }
}
