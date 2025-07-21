//
//  SuperlistInspiredTaskCard.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Superlist-Inspired Compact Task Card

struct SuperlistInspiredTaskCard: View {
    let task: Task
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onToggleComplete: () -> Void
    let onTaskUpdate: (Task) -> Void
    @ObservedObject var taskManager: TaskManager
    @State private var showingEditView = false
    
    var body: some View {
        Button(action: {
            showingEditView = true
        }) {
            VStack(spacing: 12) {
                // Task title and completion
                HStack(spacing: 12) {
                    // Completion button
                    Button(action: onToggleComplete) {
                        ZStack {
                            Circle()
                                .stroke(task.emotion.color, lineWidth: 2)
                                .frame(width: 24, height: 24)
                            
                            if task.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(task.emotion.color)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Task title
                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .strikethrough(task.isCompleted)
                        .opacity(task.isCompleted ? 0.6 : 1.0)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Priority badge
                    Text(task.priority.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(task.priority.color.opacity(0.3))
                                .background(.thinMaterial)
                        )
                }
                
                // Task metadata
                HStack {
                    // Emotion indicator
                    HStack(spacing: 4) {
                        Image(systemName: task.emotion.icon)
                            .font(.caption2)
                            .foregroundColor(task.emotion.color)
                        
                        Text(task.emotion.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(task.emotion.color.opacity(0.2))
                            .background(.thinMaterial)
                    )
                    
                    Spacer()
                    
                    // Reminder time if exists
                    if let reminderAt = task.reminderAt {
                        HStack(spacing: 3) {
                            Image(systemName: "bell.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            Text(formatReminderTime(reminderAt))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.blue.opacity(0.2))
                                .background(.thinMaterial)
                        )
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .opacity(task.isCompleted ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingEditView) {
            EditTaskView(task: task, onSave: { updatedTask in
                onTaskUpdate(updatedTask)
            }, onDelete: { taskToDelete in
                taskManager.deleteTask(taskToDelete)
            })
        }
    }
    
    private func formatReminderTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.M.d, h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 20) {
        SuperlistInspiredTaskCard(
            task: Task(
                title: "Design new app interface",
                description: "Create wireframes and mockups for the new dashboard",
                priority: .high,
                emotion: .creative,
                reminderAt: Date().addingTimeInterval(3600),
                tags: ["design", "urgent"]
            ),
            isExpanded: false,
            onToggleExpand: {},
            onToggleComplete: {},
            onTaskUpdate: { _ in },
            taskManager: TaskManager()
        )
        
        SuperlistInspiredTaskCard(
            task: Task(
                title: "Review pull requests",
                description: "Check and approve pending code reviews",
                isCompleted: true,
                priority: .medium,
                emotion: .focused,
                tags: ["code"]
            ),
            isExpanded: true,
            onToggleExpand: {},
            onToggleComplete: {},
            onTaskUpdate: { _ in },
            taskManager: TaskManager()
        )
    }
    .padding()
    .background(Color.black)
} 