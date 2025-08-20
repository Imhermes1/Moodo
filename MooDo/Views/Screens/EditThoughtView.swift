//
//  EditThoughtView.swift
//  Moodo
//
//  Created by Luke Fornieri on 11/8/2025.
//

import SwiftUI
import PhotosUI

struct EditThoughtView: View {
    let thought: Thought
    @ObservedObject var thoughtsManager: ThoughtsManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var thoughtTitle: String
    @State private var attributedContent: NSAttributedString
    @State private var isEditingContent: Bool = false
    @State private var selectedMood: MoodType?
    @State private var photoPickerItem: PhotosPickerItem?
    
    @StateObject private var formattingController = TextFormattingController()
    @FocusState private var isTitleFocused: Bool
    
    init(thought: Thought, thoughtsManager: ThoughtsManager) {
        self.thought = thought
        self.thoughtsManager = thoughtsManager
        self._thoughtTitle = State(initialValue: thought.title)
        self._selectedMood = State(initialValue: thought.mood)
        
        // Load rich text if available, otherwise create from plain text
        if let rtfData = thought.richRTF,
           let attributedText = NSAttributedString.fromRTFData(rtfData) {
            self._attributedContent = State(initialValue: attributedText)
        } else {
            self._attributedContent = State(initialValue: NSAttributedString(string: thought.content))
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        TextField("What's on your mind?", text: $thoughtTitle)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))
                            )
                            .focused($isTitleFocused)
                    }
                    
                    // Content Section with Rich Text Editor
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Content")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            if !attributedContent.string.isEmpty {
                                Text("\(attributedContent.string.count) characters")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        AppleNotesEditor(
                            attributedText: $attributedContent,
                            isEditing: $isEditingContent,
                            controller: formattingController,
                            placeholder: "Write your thoughts here..."
                        )
                        .frame(minHeight: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isEditingContent ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                    }
                    
                    // Photo Picker Integration
                    PhotosPicker(selection: $photoPickerItem, matching: .images) {
                        Label("Add Photo", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    .onChange(of: photoPickerItem) { newItem in
                        handlePickedPhoto(newItem)
                    }
                    
                    // Mood Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current mood")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(MoodType.allCases, id: \.self) { mood in
                                    MoodButton(mood: mood, isSelected: selectedMood == mood) {
                                        selectedMood = selectedMood == mood ? nil : mood
                                    }
                                }
                            }
                        }
                    }
                    
                    // Metadata
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("Created", systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(thought.dateCreated, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        /* if thought.dateCreated != thought.dateModified {
                            HStack {
                                Label("Modified", systemImage: "clock")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(thought.dateModified, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } */
                    }
                    .padding(.top, 10)
                    
                    Spacer(minLength: 50)
                }
                .padding()
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
                    .fontWeight(.semibold)
                    .disabled(thoughtTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handlePickedPhoto(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        _Concurrency.Task { @MainActor in
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                formattingController.insertImage(image)
            }
        }
    }
    
    private func saveThought() {
        let trimmedTitle = thoughtTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let plainContent = attributedContent.string.trimmingCharacters(in: .whitespacesAndNewlines)
        let rtfData = attributedContent.toRTFData()
        
        var updatedThought = thought
        updatedThought.title = trimmedTitle
        updatedThought.content = plainContent
        updatedThought.richRTF = rtfData
        updatedThought.mood = selectedMood ?? .calm
        
        
        thoughtsManager.updateThought(updatedThought)
        dismiss()
    }
}

// MARK: - Preview
struct EditThoughtView_Previews: PreviewProvider {
    static var previews: some View {
        EditThoughtView(
            thought: Thought(
                title: "Sample Thought",
                content: "This is a sample thought content for preview.",
                dateCreated: Date(),
                mood: .calm
            ),
            thoughtsManager: ThoughtsManager()
        )
    }
}
