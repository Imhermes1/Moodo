//
//  TagPicker.swift
//  Moodo
//
//  Tag selection component for task creation/editing
//

import SwiftUI

struct TagPicker: View {
    @Binding var selectedTags: [String]
    @ObservedObject var tagManager = TagManager.shared
    @State private var searchText = ""
    @State private var showingAllTags = false
    @State private var showingCreateTag = false
    @FocusState private var isSearchFocused: Bool
    
    var suggestedTags: [Tag] {
        if !searchText.isEmpty {
            return tagManager.getSuggestedTags(for: searchText, currentTags: selectedTags)
        } else {
            // Show recently used tags when not searching
            return tagManager.recentlyUsedTags.filter { tag in
                !selectedTags.contains(tag.name)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(.white)
                    .font(.title3)
                Text("Tags")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showingAllTags.toggle()
                    HapticManager.shared.impact(.light)
                }) {
                    Text(showingAllTags ? "Hide" : "Show All")
                        .font(.caption)
                        .foregroundColor(.calmingBlue)
                }
            }
            
            // Selected tags
            if !selectedTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedTags, id: \.self) { tagName in
                            if let tag = tagManager.getTag(byName: tagName) {
                                SelectedTagChip(
                                    tag: tag,
                                    onRemove: {
                                        removeTag(tagName)
                                    }
                                )
                            } else {
                                // Fallback for string tags not yet migrated
                                SimpleTagChip(
                                    name: tagName,
                                    onRemove: {
                                        removeTag(tagName)
                                    }
                                )
                            }
                        }
                    }
                }
            }
            
            // Search/Add field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.caption)
                
                TextField("Search or add tag...", text: $searchText)
                    .font(.body)
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .focused($isSearchFocused)
                    .onSubmit {
                        addTagFromSearch()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.4))
                            .font(.caption)
                    }
                }
                
                Button(action: addTagFromSearch) {
                    Text("Add")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.calmingBlue)
                }
                .disabled(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.45), lineWidth: 1)
                    )
            )
            
            // Suggestions
            if !suggestedTags.isEmpty || showingAllTags {
                VStack(alignment: .leading, spacing: 8) {
                    if !searchText.isEmpty {
                        Text("Suggestions")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    } else if !showingAllTags {
                        Text("Recently Used")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if showingAllTags {
                                ForEach(tagManager.tags.filter { !selectedTags.contains($0.name) }) { tag in
                                    SuggestedTagChip(
                                        tag: tag,
                                        onSelect: {
                                            addTag(tag)
                                        }
                                    )
                                }
                            } else {
                                ForEach(suggestedTags) { tag in
                                    SuggestedTagChip(
                                        tag: tag,
                                        onSelect: {
                                            addTag(tag)
                                        }
                                    )
                                }
                            }
                            
                            // Create new tag button
                            if !searchText.isEmpty && tagManager.getTag(byName: searchText) == nil {
                                Button(action: {
                                    createNewTag()
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.caption)
                                        Text("Create '\(searchText)'")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(Color.peacefulGreen)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.peacefulGreen.opacity(0.2))
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.black, lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addTag(_ tag: Tag) {
        if !selectedTags.contains(tag.name) {
            selectedTags.append(tag.name)
            tagManager.recordTagUsage(tag)
            searchText = ""
            HapticManager.shared.impact(.light)
        }
    }
    
    private func removeTag(_ tagName: String) {
        selectedTags.removeAll { $0 == tagName }
        HapticManager.shared.impact(.light)
    }
    
    private func addTagFromSearch() {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearch.isEmpty else { return }
        
        if let existingTag = tagManager.getTag(byName: trimmedSearch) {
            addTag(existingTag)
        } else {
            createNewTag()
        }
    }
    
    private func createNewTag() {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearch.isEmpty else { return }
        
        let newTag = Tag.quickTag(name: trimmedSearch)
        tagManager.createTag(newTag)
        addTag(newTag)
    }
}

// MARK: - Tag Chip Components

struct SelectedTagChip: View {
    let tag: Tag
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: tag.icon)
                .font(.caption2)
                .foregroundColor(tag.color)
            
            Text(tag.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(tag.color.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(Color.black, lineWidth: 1)
                )
        )
    }
}

struct SimpleTagChip: View {
    let name: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "tag.fill")
                .font(.caption2)
                .foregroundColor(.blue)
            
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.blue.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(Color.black, lineWidth: 1)
                )
        )
    }
}

struct SuggestedTagChip: View {
    let tag: Tag
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 6) {
                Image(systemName: tag.icon)
                    .font(.caption2)
                    .foregroundColor(tag.color)
                
                Text(tag.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                if tag.usageCount > 0 {
                    Text("(\(tag.usageCount))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.white.opacity(0.12))
                    .overlay(
                        Capsule()
                            .stroke(Color.black.opacity(0.4), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Inline Tag Editor (for quick tag management)

struct InlineTagEditor: View {
    @Binding var tags: [String]
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
                HapticManager.shared.impact(.light)
            }) {
                HStack {
                    Image(systemName: "tag.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    if tags.isEmpty {
                        Text("Add tags")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(.blue.opacity(0.2))
                                        )
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                TagPicker(selectedTags: $tags)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.35), lineWidth: 1)
                )
        )
    }
}