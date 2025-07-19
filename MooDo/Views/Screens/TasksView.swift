//
//  TasksView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct TasksView: View {
    @Binding var showingAddTaskModal: Bool
    @Binding var showingNotifications: Bool
    @Binding var showingAccountSettings: Bool
    @ObservedObject var taskManager: TaskManager
    let screenSize: CGSize
    
    var body: some View {
        ZStack {
            // Lensflare animation behind all cards
            LensflareView()
                .offset(x: screenSize.width * 0.3, y: screenSize.height * 0.2)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: screenSize.height * 0.025) {
                    // All Tasks List
                    AllTasksListView(
                        tasks: taskManager.tasks,
                        onAddTask: {
                            showingAddTaskModal = true
                        }
                    )
                }
                .padding(.horizontal, max(screenSize.width * 0.04, 12))
                .padding(.top, max(screenSize.height * 0.12, 80))
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    TasksView(
        showingAddTaskModal: .constant(false),
        showingNotifications: .constant(false),
        showingAccountSettings: .constant(false),
        taskManager: TaskManager(),
        screenSize: CGSize(width: 390, height: 844)
    )
    .background(UniversalBackground())
} 