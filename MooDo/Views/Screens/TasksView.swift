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
                LazyVStack(spacing: 0) {
                    // All Tasks List - Full Screen
                    AllTasksListView(
                        tasks: taskManager.tasks,
                        onAddTask: {
                            showingAddTaskModal = true
                        },
                        taskManager: taskManager
                    )
                    .frame(minHeight: screenSize.height * 0.8) // Ensure it takes up most of the screen
                }
                .padding(.horizontal, max(screenSize.width * 0.02, 8)) // Reduced horizontal padding
                .padding(.top, max(screenSize.height * 0.08, 60)) // Reduced top padding since navigation is now at top
                .padding(.bottom, 10)
            }
        }
        .ignoresSafeArea(.container, edges: .top) // Ignore safe area for proper positioning
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