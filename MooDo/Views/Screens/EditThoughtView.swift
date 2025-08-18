//
//  EditThoughtView.swift
//  Moodo
//
//  Created by Luke Fornieri on 11/8/2025.
//

import SwiftUI

struct EditThoughtView: View {
    let thought: Thought
    @ObservedObject var thoughtsManager: ThoughtsManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var thoughtTitle: String
    @State private var thoughtContent: String
    @State private var selectedMood: MoodType?
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isContentFocused: Bool
    
    init(thought: Thought, thoughtsManager: ThoughtsManager) {
        self.thought = thought
        self.thoughtsManager = thoughtsManager
        self._thoughtTitle = State(initialValue: thought.title)
        self._thoughtContent = State(initialValue: thought.content)
        self._selectedMood = State(initialValue: thought.mood)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                // Title input area
                VStack(alignment: .leading, spacing: 6) {
                    Text("Title")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    TextField("What's on your mind?", text: $thoughtTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                        .focused($isTitleFocused)
                }
                
                // Divider
                Divider()
                    .background(Color(.systemGray4))
                
                // Content input area with markdown support
                VStack(alignment: .leading, spacing: 8) {
                    Text("Content (supports Markdown)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    // Markdown formatting toolbar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(markdownButtons, id: \.title) { button in
                                Button(action: {
                                    insertMarkdown(button.markdown)
                                }) {
                                    VStack(spacing: 2) {
                                        Image(systemName: button.icon)
                                            .font(.caption)
                                        Text(button.title)
                                            .font(.caption2)
                                    }
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(.systemGray5))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    TextEditor(text: $thoughtContent)
                        .font(.body)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                        .frame(minHeight: 120)
                        .focused($isContentFocused)
                }
                
                // Mood selector (optional)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current mood (optional)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(MoodType.allCases, id: \.self) { mood in
                                Button(action: {
                                    selectedMood = selectedMood == mood ? nil : mood
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: mood.icon)
                                            .font(.title2)
                                            .foregroundColor(selectedMood == mood ? mood.color : .secondary)
                                        
                                        Text(mood.displayName)
                                            .font(.caption2)
                                            .foregroundColor(selectedMood == mood ? mood.color : .secondary)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedMood == mood ? mood.color.opacity(0.2) : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedMood == mood ? mood.color : Color.secondary.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Edit Thought")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveThought()
                    }
                    .disabled(thoughtTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                isTitleFocused = true
            }
        }
    }
    
    // Markdown formatting buttons
    private var markdownButtons: [(title: String, icon: String, markdown: String)] {
        [
            ("Bold", "bold", "**text**"),
            ("Italic", "italic", "*text*"),
            ("Heading", "textformat.size.larger", "## "),
            ("List", "list.bullet", "- "),
            ("Link", "link", "[text](url)"),
            ("Code", "chevron.left.forwardslash.chevron.right", "`code`")
        ]
    }
    
    private func insertMarkdown(_ markdown: String) {
        // Simple insertion for now - could be enhanced to wrap selected text
        if markdown.contains("text") {
            // For templates with placeholder, insert at cursor
            thoughtContent += markdown
        } else {
            // For prefix patterns (like ## or -), insert at cursor
            thoughtContent += markdown
        }
    }
    
    // Auto-detection functions for URLs only (phone numbers removed due to SwiftUI limitations)
    private func autoDetectAndFormat(_ text: String) -> String {
        var formattedText = text
        
        // Only detect and format URLs
        formattedText = detectAndShortenURLs(in: formattedText)
        
        return formattedText
    }
    
    // Phone number detection removed - SwiftUI doesn't support tel: links in markdown
    // Keep phone numbers as plain text for now
    
    private func detectAndShortenURLs(in text: String) -> String {
        // URL detection pattern
        let urlPattern = "https?://[^\\s<>\"'{}|\\\\^`\\[\\]]+"
        
        guard let regex = try? NSRegularExpression(pattern: urlPattern, options: .caseInsensitive) else {
            return text
        }
        
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        var result = text
        
        // Process matches in reverse order to maintain string indices
        for match in matches.reversed() {
            let fullURL = (text as NSString).substring(with: match.range)
            let shortURL = shortenURL(fullURL)
            let markdownLink = "[🔗 \(shortURL)](\(fullURL))"
            
            result = (result as NSString).replacingCharacters(in: match.range, with: markdownLink)
        }
        
        return result
    }
    
    private func shortenURL(_ url: String) -> String {
        // Remove protocol and www
        var shortened = url
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")
        
        // Keep only domain and top-level path
        let components = shortened.components(separatedBy: "/")
        if let domain = components.first {
            // If there's a path, show domain + /...
            if components.count > 1 {
                return "\(domain)/..."
            } else {
                return domain
            }
        }
        
        return shortened
    }
    
    private func saveThought() {
        let trimmedTitle = thoughtTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = thoughtContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else { return }
        
        // Apply auto-detection and formatting to both title and content
        let formattedTitle = autoDetectAndFormat(trimmedTitle)
        let formattedContent = autoDetectAndFormat(trimmedContent)
        
        var updatedThought = thought
        updatedThought.title = formattedTitle
        updatedThought.content = formattedContent
        updatedThought.mood = selectedMood ?? .calm
        
        thoughtsManager.updateThought(updatedThought)
        dismiss()
    }
    
}

struct EditThoughtView_Previews: PreviewProvider {
    static var previews: some View {
        EditThoughtView(
            thought: Thought(title: "Test", content: "Test thought", mood: .calm),
            thoughtsManager: ThoughtsManager()
        )
    }
}
