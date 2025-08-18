//
//  ConvertThoughtToTaskView.swift
//  Moodo
//
//  Created by Luke Fornieri on 11/8/2025.
//

import SwiftUI

struct ConvertThoughtToTaskView: View {
    let thought: Thought
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var thoughtsManager: ThoughtsManager
    @ObservedObject var moodManager: MoodManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var taskTitle = ""
    @State private var taskDescription: String
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedEmotion: TaskEmotion = .focused
    @State private var selectedCategory: TaskCategory = .personal
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    @State private var deleteOriginalThought = true
    
    init(thought: Thought,
         thoughtsManager: ThoughtsManager,
         taskManager: TaskManager,
         moodManager: MoodManager,
         deleteOriginalThoughtDefault: Bool = true) {
        self.thought = thought
        self.thoughtsManager = thoughtsManager
        self.taskManager = taskManager
        self.moodManager = moodManager
        // Extract content without title for task description
        let lines = thought.content.components(separatedBy: .newlines)
        var contentWithoutTitle = thought.content
        
        // If the first line matches the title (case insensitive), remove it
        if let firstLine = lines.first,
           firstLine.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == thought.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            let remainingLines = Array(lines.dropFirst())
            contentWithoutTitle = remainingLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        self._taskDescription = State(initialValue: contentWithoutTitle)
        
        // Smart title extraction - use the thought's title
        self._taskTitle = State(initialValue: thought.title)
        
        // Default emotion suggestion based on title analysis, fallback to mood compatibility
        let analysis = EmotionAnalyzer.shared.getEmotionAnalysis(from: thought.title)
        self._selectedEmotion = State(initialValue: analysis.suggestedEmotion)
        
        self._deleteOriginalThought = State(initialValue: deleteOriginalThoughtDefault)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Original thought preview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Original Thought")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text((try? AttributedString(markdown: thought.content)) ?? AttributedString(thought.content))
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                        }
                        
                        Divider()
                        
                        // Task details
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Task Details")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            // Task title
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Title")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Task title", text: $taskTitle)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                        // Task description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextEditor(text: $taskDescription)
                                .frame(height: 80)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            Text("Prefilled with your thought content (title removed). Edit or clear if not needed.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                            
                            // Priority
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Priority")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Picker("Priority", selection: $selectedPriority) {
                                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                                        HStack {
                                            Circle()
                                                .fill(priority.color)
                                                .frame(width: 12, height: 12)
                                            Text(priority.displayName)
                                        }
                                        .tag(priority)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            // Emotion
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Task Type")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Picker("Emotion", selection: $selectedEmotion) {
                                    ForEach(TaskEmotion.allCases, id: \.self) { emotion in
                                        HStack {
                                            Image(systemName: emotion.icon)
                                                .foregroundColor(emotion.color)
                                            Text(emotion.displayName)
                                        }
                                        .tag(emotion)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            // Reminder toggle
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle("Set Reminder", isOn: $hasReminder)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                if hasReminder {
                                    DatePicker("Reminder Time", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(CompactDatePickerStyle())
                                }
                            }
                            
                            // Delete original thought option
                            Toggle("Remove original note after creating task", isOn: $deleteOriginalThought)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(20)
                
                // Action buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    
                    Button("Create Task") {
                        createTask()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
                    .disabled(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Convert to Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func createTask() {
        let newTask = Task(
            title: taskTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: taskDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: selectedPriority,
            emotion: selectedEmotion,
            category: selectedCategory,
            reminderAt: hasReminder ? reminderDate : nil,
            sourceThoughtId: thought.id
        )
        
        // Add task to task manager
        taskManager.addTask(newTask)
        
        // Create bidirectional link - update thought with task ID
        var updatedThought = thought
        updatedThought.linkedTaskId = newTask.id
        thoughtsManager.updateThought(updatedThought)
        
        // Delete original thought if requested
        if deleteOriginalThought {
            thoughtsManager.deleteThought(thought)
        }
        
        // Haptic feedback
        HapticManager.shared.taskAdded()
        
        dismiss()
    }
    
    // Helper function to extract content without title
    private func extractContentWithoutTitle(from content: String, title: String) -> String {
        let lines = content.components(separatedBy: .newlines)
        
        // If the first line matches the title (case insensitive), remove it
        if let firstLine = lines.first,
           firstLine.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            let remainingLines = Array(lines.dropFirst())
            return remainingLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // If title doesn't match first line, return original content
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // FUTURE ENHANCEMENT: Bullet points to subtasks
    // When converting thoughts to tasks, parse markdown bullet points (lines starting with "- " or "* ")
    // and convert them into subtasks. This will allow users to create hierarchical task structures
    // directly from their thought notes. Example:
    // Thought content: "Project planning\n- Research competitors\n- Define requirements\n- Create timeline"
    // Would create a main task "Project planning" with 3 subtasks.
    // Implementation would involve:
    // 1. Scanning content for bullet point patterns
    // 2. Creating Task objects for each bullet point 
    // 3. Setting up parent-child relationships via subtasks array
}

struct ConvertThoughtToTaskView_Previews: PreviewProvider {
    static var previews: some View {
        ConvertThoughtToTaskView(
            thought: Thought(title: "Call Mom", content: "Need to call mom about dinner plans", mood: .calm),
            thoughtsManager: ThoughtsManager(),
            taskManager: TaskManager(),
            moodManager: MoodManager()
        )
    }
}
