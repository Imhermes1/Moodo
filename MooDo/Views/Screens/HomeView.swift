//
//  HomeView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct HomeView: View {
    @Binding var showingAddTaskModal: Bool
    @Binding var showingNotifications: Bool
    @Binding var showingAccountSettings: Bool
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    let screenSize: CGSize
    
    var body: some View {
        ZStack {
            // Lensflare animation behind all cards
            LensflareView()
                .offset(x: screenSize.width * 0.3, y: screenSize.height * 0.2)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: screenSize.height * 0.025) {
                    // Mood Check-in (matches web app exactly)
                    MoodLensMoodCheckinView(taskManager: taskManager)
                    
                    // Smart Tasks (mood-based, second position)
                    MoodBasedTasksView(
                        taskManager: taskManager,
                        moodManager: moodManager,
                        onAddTask: {
                            showingAddTaskModal = true
                        },
                        onTaskTap: { task in
                            // Handle task tap - could open task details or mark as complete
                            print("Task tapped: \(task.title)")
                        },
                        screenSize: screenSize
                    )
                    
                    // Today's Progress (animated counters like web app)
                    TodaysProgressView(tasks: taskManager.tasks, moodEntries: moodManager.moodEntries)
                }
                .padding(.horizontal, max(screenSize.width * 0.04, 12))
                .padding(.top, max(screenSize.height * 0.08, 60))
                .padding(.bottom, max(screenSize.height * 0.12, 100))
            }
        }
    }
}

#Preview {
    HomeView(
        showingAddTaskModal: .constant(false),
        showingNotifications: .constant(false),
        showingAccountSettings: .constant(false),
        taskManager: TaskManager(),
        moodManager: MoodManager(),
        screenSize: CGSize(width: 390, height: 844)
    )
    .background(UniversalBackground())
} 
