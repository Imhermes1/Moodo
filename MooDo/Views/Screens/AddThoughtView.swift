//
//  AddThoughtView.swift
//  Moodo
//
//  Created by Luke Fornieri on 11/8/2025.
//

import SwiftUI

struct AddThoughtView: View {
    @ObservedObject var thoughtsManager: ThoughtsManager
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    @Environment(\.dismiss) private var dismiss
    @State private var thoughtTitle = ""
    @State private var thoughtContent = ""
    @State private var selectedMood: MoodType?
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isContentFocused: Bool
    
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
                
                // Content input area
                VStack(alignment: .leading, spacing: 8) {
                    Text("Content")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
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
            .navigationTitle("New Thought")
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
            .toolbar { keyboardToolbar }
            .onAppear {
                isTitleFocused = true
            }
        }
    }
    
    // Apple Notes–style keyboard toolbar
    @ToolbarContentBuilder
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Menu {
                Button("Title") { insertHeadingPrefix("# ") }
                Button("Heading") { insertHeadingPrefix("## ") }
                Button("Subheading") { insertHeadingPrefix("### ") }
                Divider()
                Button("Bold") { insertSurrounding("**") }
                Button("Italic") { insertSurrounding("*") }
                Button("Monospace") { insertSurrounding("`") }
            } label: {
                Label("Format", systemImage: "textformat.size")
            }
            Button {
                insertChecklist()
            } label: {
                Label("Checklist", systemImage: "checklist")
            }
            Button {
                insertBullet()
            } label: {
                Label("Bullet", systemImage: "list.bullet")
            }
            Button {
                insertTablePlaceholder()
            } label: {
                Label("Table", systemImage: "tablecells")
            }
            .disabled(true) // Placeholder until rich text/tables are implemented
            Button {
                insertAttachmentPlaceholder()
            } label: {
                Label("Attachment", systemImage: "paperclip")
            }
            .disabled(true) // Placeholder until attachments are implemented
            Spacer()
            Button("Done") {
                isContentFocused = false
                isTitleFocused = false
            }
        }
    }
    
    // Attach keyboard toolbar to the view
    init(thoughtsManager: ThoughtsManager, taskManager: TaskManager, moodManager: MoodManager) {
        self._thoughtsManager = ObservedObject(initialValue: thoughtsManager)
        self._taskManager = ObservedObject(initialValue: taskManager)
        self._moodManager = ObservedObject(initialValue: moodManager)
    }
    
    // Helper insertions (TextEditor has no selection API; append or line-start prefixes)
    private func insertHeadingPrefix(_ prefix: String) {
        if thoughtContent.isEmpty { thoughtContent = prefix; return }
        if thoughtContent.hasSuffix("\n") { thoughtContent += prefix } else { thoughtContent += "\n" + prefix }
    }
    private func insertSurrounding(_ token: String) {
        let placeholder = token + "text" + token
        if thoughtContent.isEmpty { thoughtContent = placeholder; return }
        if thoughtContent.hasSuffix("\n") { thoughtContent += placeholder } else { thoughtContent += " " + placeholder }
    }
    private func insertBullet() {
        if thoughtContent.isEmpty { thoughtContent = "• "; return }
        if thoughtContent.hasSuffix("\n") { thoughtContent += "• " } else { thoughtContent += "\n• " }
    }
    private func insertChecklist() {
        if thoughtContent.isEmpty { thoughtContent = "- [ ] "; return }
        if thoughtContent.hasSuffix("\n") { thoughtContent += "- [ ] " } else { thoughtContent += "\n- [ ] " }
    }
    private func insertTablePlaceholder() {
        let table = "\n[Table]\n| Column 1 | Column 2 |\n|---------:|:--------:|\n|   Cell   |   Cell   |\n"
        thoughtContent += table
    }
    private func insertAttachmentPlaceholder() {
        thoughtContent += "\n[Attachment]\n"
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
        
        let newThought = Thought(
            title: formattedTitle,
            content: formattedContent,
            mood: selectedMood ?? .calm
        )
        
        thoughtsManager.addThought(newThought)
        dismiss()
    }
}

struct AddThoughtView_Previews: PreviewProvider {
    static var previews: some View {
        AddThoughtView(
            thoughtsManager: ThoughtsManager(),
            taskManager: TaskManager(),
            moodManager: MoodManager()
        )
    }
}
