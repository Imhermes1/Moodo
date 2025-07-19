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
                    MoodLensMoodCheckinView()
                    
                    // Task List (second position)
                    MoodLensTaskListView(
                        tasks: taskManager.tasks,
                        onAddTask: {
                            showingAddTaskModal = true
                        }
                    )
                    
                    // Body Scan feature
                    BodyScanView()
                    
                    // Today's Progress (animated counters like web app)
                    TodaysProgressView(tasks: taskManager.tasks, moodEntries: moodManager.moodEntries)
                    
                    // Mindful Moment
                    MindfulMomentView()
                }
                .padding(.horizontal, max(screenSize.width * 0.04, 12))
                .padding(.top, max(screenSize.height * 0.08, 60))
                .padding(.bottom, 20)
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