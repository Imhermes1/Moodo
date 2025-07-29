//
//  TaskModals.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Edit Task Modal View

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var editedTask: Task
    @State private var tagText = ""
    let onSave: (Task) -> Void
    let onDelete: ((Task) -> Void)?
    
    init(task: Task, onSave: @escaping (Task) -> Void, onDelete: ((Task) -> Void)? = nil) {
        self._editedTask = State(initialValue: task)
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Universal background
                UniversalBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title Editor
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "textformat")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text("Task Title")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            
                            TextField("Enter task title", text: $editedTask.title, axis: .vertical)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(16)
                                .background(GlassPanelBackground())
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .lineLimit(2...4)
                        }
                        
                        // Description Editor
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text("Description")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            
                            TextField("Add description (optional)", text: Binding(
                                get: { editedTask.description ?? "" },
                                set: { editedTask.description = $0.isEmpty ? nil : $0 }
                            ), axis: .vertical)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(16)
                                .background(GlassPanelBackground())
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .lineLimit(3...6)
                        }
                        
                        // Priority and Emotion
                        HStack(spacing: 16) {
                            // Priority
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.caption)
                                    Text("Priority")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Picker("Priority", selection: $editedTask.priority) {
                                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                                        HStack {
                                            Circle()
                                                .fill(priority.color)
                                                .frame(width: 8, height: 8)
                                            Text(priority.displayName)
                                                .foregroundColor(.white)
                                        }
                                        .tag(priority)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .foregroundColor(.white)
                                .padding(12)
                                .background(GlassPanelBackground())
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // Task Characteristic
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "brain.head.profile")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.caption)
                                    Text("Task Type")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Picker("Task Type", selection: $editedTask.emotion) {
                                    ForEach(TaskEmotion.allCases, id: \.self) { emotion in
                                        HStack {
                                            Image(systemName: emotion.icon)
                                                .foregroundColor(emotion.color)
                                            Text(emotion.displayName)
                                                .foregroundColor(.white)
                                        }
                                        .tag(emotion)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .foregroundColor(.white)
                                .padding(12)
                                .background(GlassPanelBackground())
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                        }
                        
                        // Reminder Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "bell")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text("Reminder")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 12) {
                                Toggle("Set Reminder", isOn: Binding(
                                    get: { editedTask.reminderAt != nil },
                                    set: { enabled in
                                        if enabled {
                                            editedTask.reminderAt = Date().addingTimeInterval(3600) // 1 hour from now
                                        } else {
                                            editedTask.reminderAt = nil
                                        }
                                    }
                                ))
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                .foregroundColor(.white)
                                
                                if editedTask.reminderAt != nil {
                                    DatePicker("Reminder Time", selection: Binding(
                                        get: { editedTask.reminderAt ?? Date() },
                                        set: { editedTask.reminderAt = $0 }
                                    ), displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .colorScheme(.dark)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(16)
                            .background(GlassPanelBackground())
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // Deadline Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text("Deadline")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 12) {
                                Toggle("Set Deadline", isOn: Binding(
                                    get: { editedTask.deadlineAt != nil },
                                    set: { enabled in
                                        if enabled {
                                            editedTask.deadlineAt = Date().addingTimeInterval(86400) // 1 day from now
                                        } else {
                                            editedTask.deadlineAt = nil
                                        }
                                    }
                                ))
                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                                .foregroundColor(.white)
                                
                                if editedTask.deadlineAt != nil {
                                    DatePicker("Deadline", selection: Binding(
                                        get: { editedTask.deadlineAt ?? Date() },
                                        set: { editedTask.deadlineAt = $0 }
                                    ), displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .colorScheme(.dark)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(16)
                            .background(GlassPanelBackground())
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // Tags Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "tag")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text("Tags")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 12) {
                                // Add tag field
                                HStack {
                                    TextField("Add tag", text: $tagText)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .onSubmit {
                                            addTag()
                                        }
                                    
                                    Button("Add", action: addTag)
                                        .foregroundColor(.blue)
                                        .disabled(tagText.trimmingCharacters(in: .whitespaces).isEmpty)
                                }
                                .padding(12)
                                .background(GlassPanelBackground())
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                // Current tags
                                if !editedTask.tags.isEmpty {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                        ForEach(editedTask.tags, id: \.self) { tag in
                                            HStack {
                                                Text("#\(tag)")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                                
                                                Button(action: { removeTag(tag) }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.caption)
                                                        .foregroundColor(.red)
                                                }
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule()
                                                    .fill(.blue.opacity(0.3))
                                                    .background(.thinMaterial)
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(GlassPanelBackground())
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Save") {
                            onSave(editedTask)
                            dismiss()
                        }
                        
                        if let onDelete = onDelete {
                            Button("Delete Task", role: .destructive) {
                                onDelete(editedTask)
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Save")
                            .foregroundColor(.white)
                    }
                    .disabled(editedTask.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func addTag() {
        let trimmedTag = tagText.trimmingCharacters(in: .whitespaces)
        if !trimmedTag.isEmpty && !editedTask.tags.contains(trimmedTag) {
            editedTask.tags.append(trimmedTag)
            tagText = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        editedTask.tags.removeAll { $0 == tag }
    }
}

struct AddTaskListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var listName = ""
    @State private var selectedColor = "#007AFF"
    @State private var selectedIcon = "list.bullet"
    let onAdd: (TaskList) -> Void
    
    private let colors = ["#007AFF", "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7", "#DDA0DD", "#98D8C8"]
    private let icons = ["list.bullet", "person", "briefcase", "heart", "cart", "house", "book", "gamecontroller"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // List name
                VStack(alignment: .leading, spacing: 8) {
                    Text("List Name")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Enter list name", text: $listName)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.black)
                }
                
                // Color selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Color")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? .white : .clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
                
                // Icon selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Icon")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(selectedIcon == icon ? .white : .white.opacity(0.7))
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(selectedIcon == icon ? Color(hex: selectedColor) : .white.opacity(0.1))
                                )
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("New List")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let newList = TaskList(name: listName, color: Color(hex: selectedColor), icon: selectedIcon)
                        onAdd(newList)
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .disabled(listName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 