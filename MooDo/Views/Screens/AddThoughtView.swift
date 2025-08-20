//
//  AddThoughtView.swift
//  Moodo
//
//  Created by Luke Fornieri on 11/8/2025.
//

import SwiftUI
import PhotosUI

struct AddThoughtView: View {
    @ObservedObject var thoughtsManager: ThoughtsManager
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var thoughtTitle = ""
    @State private var attributedContent: NSAttributedString = NSAttributedString(string: "")
    @State private var isEditingContent: Bool = false
    @State private var selectedMood: MoodType?
    @State private var photoPickerItem: PhotosPickerItem?
    
    @StateObject private var formattingController = TextFormattingController()
    @FocusState private var isTitleFocused: Bool
    
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
                        Text("Current mood (optional)")
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
                    
                    Spacer(minLength: 50)
                }
                .padding()
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
                    .fontWeight(.semibold)
                    .disabled(thoughtTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                // Focus on title field when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTitleFocused = true
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
        
        let newThought = Thought(
            title: trimmedTitle,
            content: plainContent,
            dateCreated: Date(),
            mood: selectedMood ?? .calm,
            richRTF: rtfData
        )
        
        thoughtsManager.addThought(newThought)
        dismiss()
    }
}

// MARK: - Mood Button Component
struct MoodButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: mood.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? mood.color : .secondary)
                
                Text(mood.displayName)
                    .font(.caption2)
                    .foregroundColor(isSelected ? mood.color : .secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? mood.color.opacity(0.15) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? mood.color : Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct AddThoughtView_Previews: PreviewProvider {
    static var previews: some View {
        AddThoughtView(
            thoughtsManager: ThoughtsManager(),
            taskManager: TaskManager(),
            moodManager: MoodManager()
        )
    }
}
