//
//  TaskCard.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Task Card

struct TaskCard: View {
    let task: Task
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onToggleComplete: () -> Void
    let onTaskUpdate: (Task) -> Void
    let onDelete: (Task) -> Void
    @ObservedObject var taskManager: TaskManager
    @State private var showingEditView = false
    @State private var dragOffset = CGSize.zero
    @State private var isBeingDeleted = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            showingEditView = true
        }) {
            VStack(spacing: 12) {
                // Task title and completion
                HStack(spacing: 12) {
                    // Completion button with enhanced haptics
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            onToggleComplete()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .stroke(task.emotion.color, lineWidth: 2)
                                .frame(width: 24, height: 24)
                                .shadow(color: task.emotion.color.opacity(0.3), radius: 2, x: 0, y: 1)
                            
                            if task.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(task.emotion.color)
                                    .scaleEffect(1.0)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: task.isCompleted)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Task title with gentle styling
                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .strikethrough(task.isCompleted)
                        .opacity(task.isCompleted ? 0.6 : 1.0)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
                    
                    // Priority badge with subtle glow
                    Text(task.priority.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(task.priority.color.opacity(0.6), lineWidth: 1)
                                )
                                .shadow(color: task.priority.color.opacity(0.2), radius: 2, x: 0, y: 1)
                        )
                }
                
                // Task metadata with improved spacing
                HStack {
                    // Emotion indicator with enhanced visual feedback
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
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(task.emotion.color.opacity(0.4), lineWidth: 1)
                            )
                            .shadow(color: task.emotion.color.opacity(0.15), radius: 2, x: 0, y: 1)
                    )
                    
                    // AI tag if task is AI-generated
                    if task.isAIGenerated {
                        Text("AI")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.purple.opacity(0.9))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(.purple.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(.purple.opacity(0.4), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Spacer()
                    
                    // Reminder time with gentle styling
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
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(.blue.opacity(0.4), lineWidth: 1)
                                )
                                .shadow(color: .blue.opacity(0.15), radius: 2, x: 0, y: 1)
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
                            .stroke(
                                task.isAIGenerated ? 
                                LinearGradient(
                                    colors: [.red, .orange, .yellow, .green, .blue, .purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    colors: [.white.opacity(0.2), .white.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: task.isAIGenerated ? 1.5 : 1
                            )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                    .shadow(color: .white.opacity(0.05), radius: 1, x: 0, y: -1)
            )
            .opacity(task.isCompleted ? 0.7 : 1.0)
            .scaleEffect(task.isCompleted ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
        }
        .buttonStyle(PlainButtonStyle())
        .offset(x: dragOffset.width)
        .scaleEffect(isBeingDeleted ? 0.95 : 1.0)
        .opacity(isBeingDeleted ? 0.8 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
        .animation(.easeInOut(duration: 0.2), value: isBeingDeleted)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                showingDeleteConfirmation = true
                HapticManager.shared.notification(.warning)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .gesture(
            // Swipe gesture with confirmation - more restrictive to avoid conflicts
            DragGesture()
                .onChanged { value in
                    // Only allow left swipe (negative translation) and require minimum vertical accuracy
                    if value.translation.width < 0 && abs(value.translation.height) < 50 {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    // Require more significant swipe and better accuracy
                    if value.translation.width < -120 && abs(value.translation.height) < 80 {
                        // Swipe threshold met - show confirmation dialog
                        showingDeleteConfirmation = true
                        HapticManager.shared.notification(.warning)
                        
                        // Reset drag offset
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            dragOffset = .zero
                        }
                    } else {
                        // Snap back
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .confirmationDialog("Delete Task", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    isBeingDeleted = true
                }
                
                HapticManager.shared.notification(.warning)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDelete(task)
                }
            }
            Button("Cancel", role: .cancel) {
                // Do nothing, dialog dismisses automatically
            }
        } message: {
            Text("Are you sure you want to delete '\(task.title)'? This action cannot be undone.")
        }
        .sheet(isPresented: $showingEditView) {
            EditTaskView(task: task, onSave: { updatedTask in
                onTaskUpdate(updatedTask)
                HapticManager.shared.success()
            }, onDelete: { taskToDelete in
                taskManager.deleteTask(taskToDelete)
                HapticManager.shared.notification(.warning)
            })
        }
    }
    
    private func formatReminderTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // Get start of this week (Sunday)
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? now
        
        // Check if the date is within this week
        if date >= startOfWeek && date <= endOfWeek {
            // This week - show day name and time
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE" // Full day name
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a" // 5:00 PM format
            
            let dayName = dayFormatter.string(from: date)
            let timeString = timeFormatter.string(from: date)
            
            // Remove minutes if it's exactly on the hour (5:00 PM -> 5pm)
            let cleanTimeString = timeString.replacingOccurrences(of: ":00", with: "").lowercased()
            
            // Check if it's today or tomorrow
            if calendar.isDateInToday(date) {
                return "Today \(cleanTimeString)"
            } else if calendar.isDateInTomorrow(date) {
                return "Tomorrow \(cleanTimeString)"
            } else {
                return "\(dayName) \(cleanTimeString)"
            }
        } else {
            // Beyond this week - show date and time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM" // 15 Aug format
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a" // 5:00 PM format
            
            let dateString = dateFormatter.string(from: date)
            let timeString = timeFormatter.string(from: date)
            
            return "\(dateString) \(timeString)"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TaskCard(
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
            onDelete: { _ in },
            taskManager: TaskManager()
        )
        
        TaskCard(
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
            onDelete: { _ in },
            taskManager: TaskManager()
        )
    }
    .padding()
    .background(Color.black)
} 
