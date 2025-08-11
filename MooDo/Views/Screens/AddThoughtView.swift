//
//  AddThoughtView.swift
//  Moodo
//
//  Created by Luke Fornieri on 11/8/2025.
//

import SwiftUI

struct AddThoughtView: View {
    @ObservedObject var thoughtsManager: ThoughtsManager
    @Environment(\.dismiss) private var dismiss
    @State private var thoughtText = ""
    @State private var selectedMood: MoodType?
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Text input area
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's on your mind?")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $thoughtText)
                        .font(.body)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .frame(minHeight: 120)
                        .focused($isTextFieldFocused)
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
            .padding(20)
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
                    .disabled(thoughtText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    private func saveThought() {
        let trimmedText = thoughtText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Extract title from first line or first few words
        let title = extractTitle(from: trimmedText)
        
        let newThought = Thought(
            title: title,
            content: trimmedText,
            mood: selectedMood ?? .calm
        )
        
        thoughtsManager.addThought(newThought)
        dismiss()
    }
    
    private func extractTitle(from text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        let firstLine = lines.first ?? ""
        
        // If first line is short enough, use it as title
        if firstLine.count <= 50 {
            return firstLine.isEmpty ? "Untitled Thought" : firstLine
        }
        
        // Otherwise, take first few words
        let words = firstLine.components(separatedBy: .whitespaces)
        let firstWords = Array(words.prefix(6)).joined(separator: " ")
        return firstWords.isEmpty ? "Untitled Thought" : firstWords + "..."
    }
}

struct AddThoughtView_Previews: PreviewProvider {
    static var previews: some View {
        AddThoughtView(thoughtsManager: ThoughtsManager())
    }
}
