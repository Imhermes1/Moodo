//
//  TagManagementView.swift
//  Moodo
//
//  Tag management interface
//

import SwiftUI

struct TagManagementView: View {
    @ObservedObject var tagManager = TagManager.shared
    @State private var showingAddTag = false
    @State private var searchText = ""
    @State private var selectedCategory: TagCategory? = nil
    @State private var editingTag: Tag? = nil
    @State private var showingEditView = false
    
    var filteredTags: [Tag] {
        var tags = tagManager.tags
        
        // Filter by search
        if !searchText.isEmpty {
            tags = tags.filter { tag in
                tag.name.localizedCaseInsensitiveContains(searchText) ||
                (tag.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Sort by usage
        return tags.sorted { $0.usageCount > $1.usageCount }
    }
    
    var body: some View {
        ZStack {
            UniversalBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Tags")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        showingAddTag = true
                        HapticManager.shared.impact(.light)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.calmingBlue)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.body)
                    
                    TextField("Search tags...", text: $searchText)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                // Tag statistics
                if searchText.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            TagStatCard(
                                title: "Total Tags",
                                value: "\(tagManager.tags.count)",
                                icon: "tag.fill",
                                color: .blue
                            )
                            
                            TagStatCard(
                                title: "Most Used",
                                value: tagManager.getMostUsedTags(limit: 1).first?.name ?? "None",
                                icon: "star.fill",
                                color: .yellow
                            )
                            
                            TagStatCard(
                                title: "Recent",
                                value: "\(tagManager.recentlyUsedTags.count)",
                                icon: "clock.fill",
                                color: .green
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 16)
                }
                
                // Tags list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if filteredTags.isEmpty {
                            EmptyTagsView(searchText: searchText)
                                .padding(.top, 40)
                        } else {
                            ForEach(filteredTags) { tag in
                                TagRowView(
                                    tag: tag,
                                    onEdit: {
                                        editingTag = tag
                                        showingEditView = true
                                        HapticManager.shared.impact(.light)
                                    },
                                    onDelete: {
                                        tagManager.deleteTag(tag)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showingAddTag) {
            AddTagView(tagManager: tagManager)
        }
        .sheet(item: $editingTag) { tag in
            EditTagView(tag: tag, tagManager: tagManager)
        }
    }
}

// MARK: - Tag Row View

struct TagRowView: View {
    let tag: Tag
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Tag icon and color
            ZStack {
                Circle()
                    .fill(tag.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: tag.icon)
                    .font(.body)
                    .foregroundColor(tag.color)
            }
            
            // Tag info
            VStack(alignment: .leading, spacing: 4) {
                Text(tag.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if let description = tag.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Usage count
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(tag.usageCount)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("uses")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Actions
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: {
                    showingDeleteConfirmation = true
                }) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 30, height: 30)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .confirmationDialog(
            "Delete Tag",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                withAnimation {
                    onDelete()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(tag.name)'? This will remove it from all tasks.")
        }
    }
}

// MARK: - Add Tag View

struct AddTagView: View {
    @ObservedObject var tagManager: TagManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var tagName = ""
    @State private var tagDescription = ""
    @State private var selectedColor = TagManager.tagColors[0]
    @State private var selectedIcon = TagManager.tagIcons[0]
    @State private var showingDuplicateAlert = false
    
    var body: some View {
        ZStack {
            UniversalBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("New Tag")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveTag()
                    }
                    .foregroundColor(tagName.isEmpty ? .white.opacity(0.5) : .peacefulGreen)
                    .disabled(tagName.isEmpty)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Tag name
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Tag Name", systemImage: "tag.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter tag name", text: $tagName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Description (Optional)", systemImage: "text.alignleft")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Add description", text: $tagDescription, axis: .vertical)
                                .textFieldStyle(CustomTextFieldStyle())
                                .lineLimit(2...4)
                        }
                        
                        // Color selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Color", systemImage: "paintpalette.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                                ForEach(TagManager.tagColors, id: \.self) { colorHex in
                                    Circle()
                                        .fill(Color(hex: colorHex))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == colorHex ? .white : .clear, lineWidth: 3)
                                        )
                                        .onTapGesture {
                                            selectedColor = colorHex
                                            HapticManager.shared.impact(.light)
                                        }
                                }
                            }
                        }
                        
                        // Icon selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Icon", systemImage: "star.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                                ForEach(TagManager.tagIcons, id: \.self) { icon in
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.2) : .white.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: icon)
                                            .font(.title3)
                                            .foregroundColor(selectedIcon == icon ? Color(hex: selectedColor) : .white.opacity(0.7))
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(selectedIcon == icon ? Color(hex: selectedColor) : .clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedIcon = icon
                                        HapticManager.shared.impact(.light)
                                    }
                                }
                            }
                        }
                        
                        // Preview
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Preview")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: selectedIcon)
                                    .font(.body)
                                    .foregroundColor(Color(hex: selectedColor))
                                
                                Text(tagName.isEmpty ? "Tag Name" : tagName)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(hex: selectedColor).opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(hex: selectedColor), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(24)
                }
            }
        }
        .alert("Duplicate Tag", isPresented: $showingDuplicateAlert) {
            Button("OK") { }
        } message: {
            Text("A tag with the name '\(tagName)' already exists.")
        }
    }
    
    private func saveTag() {
        let trimmedName = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for duplicates
        if tagManager.getTag(byName: trimmedName) != nil {
            showingDuplicateAlert = true
            return
        }
        
        let newTag = Tag(
            name: trimmedName,
            colorHex: selectedColor,
            icon: selectedIcon,
            description: tagDescription.isEmpty ? nil : tagDescription
        )
        
        tagManager.createTag(newTag)
        HapticManager.shared.notification(.success)
        dismiss()
    }
}

// MARK: - Edit Tag View

struct EditTagView: View {
    @State var tag: Tag
    @ObservedObject var tagManager: TagManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var tagName: String = ""
    @State private var tagDescription: String = ""
    @State private var selectedColor: String = ""
    @State private var selectedIcon: String = ""
    
    init(tag: Tag, tagManager: TagManager) {
        self._tag = State(initialValue: tag)
        self.tagManager = tagManager
        self._tagName = State(initialValue: tag.name)
        self._tagDescription = State(initialValue: tag.description ?? "")
        self._selectedColor = State(initialValue: tag.colorHex)
        self._selectedIcon = State(initialValue: tag.icon)
    }
    
    var body: some View {
        ZStack {
            UniversalBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("Edit Tag")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveTag()
                    }
                    .foregroundColor(.peacefulGreen)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Tag name
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Tag Name", systemImage: "tag.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter tag name", text: $tagName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Description (Optional)", systemImage: "text.alignleft")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Add description", text: $tagDescription, axis: .vertical)
                                .textFieldStyle(CustomTextFieldStyle())
                                .lineLimit(2...4)
                        }
                        
                        // Color selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Color", systemImage: "paintpalette.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                                ForEach(TagManager.tagColors, id: \.self) { colorHex in
                                    Circle()
                                        .fill(Color(hex: colorHex))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == colorHex ? .white : .clear, lineWidth: 3)
                                        )
                                        .onTapGesture {
                                            selectedColor = colorHex
                                            HapticManager.shared.impact(.light)
                                        }
                                }
                            }
                        }
                        
                        // Icon selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Icon", systemImage: "star.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                                ForEach(TagManager.tagIcons, id: \.self) { icon in
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.2) : .white.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: icon)
                                            .font(.title3)
                                            .foregroundColor(selectedIcon == icon ? Color(hex: selectedColor) : .white.opacity(0.7))
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(selectedIcon == icon ? Color(hex: selectedColor) : .clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedIcon = icon
                                        HapticManager.shared.impact(.light)
                                    }
                                }
                            }
                        }
                        
                        // Statistics
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Statistics")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                StatBadge(label: "Used", value: "\(tag.usageCount) times")
                                StatBadge(label: "Created", value: formatDate(tag.createdAt))
                            }
                        }
                    }
                    .padding(24)
                }
            }
        }
    }
    
    private func saveTag() {
        var updatedTag = tag
        updatedTag.name = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedTag.description = tagDescription.isEmpty ? nil : tagDescription
        updatedTag.colorHex = selectedColor
        updatedTag.icon = selectedIcon
        
        tagManager.updateTag(updatedTag)
        HapticManager.shared.notification(.success)
        dismiss()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct TagStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(width: 100, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct StatBadge: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.1))
        )
    }
}

struct EmptyTagsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: searchText.isEmpty ? "tag.slash" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))
            
            Text(searchText.isEmpty ? "No tags yet" : "No tags found")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            Text(searchText.isEmpty ? "Create your first tag to organize tasks" : "Try a different search term")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
    }
}