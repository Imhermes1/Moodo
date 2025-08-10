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
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
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
                        screenSize: screenSize
                    )
                    
                    // Today's Progress (animated counters like web app)
                    TodaysProgressView(tasks: taskManager.tasks, moodEntries: moodManager.moodEntries)
                    // Quick wellness actions
                    WellnessActionsView()
                    // Notes section
                    NotesSectionView(taskManager: taskManager)
                }
                .padding(.horizontal, 20)
                .padding(.top, max(screenSize.height * 0.08, 60))
            }
            .ignoresSafeArea(edges: [.top, .bottom])
            
            Color.clear
                .frame(height: 1)
                .ignoresSafeArea(edges: .top)
                .allowsHitTesting(false)
            Color.clear
                .frame(height: 1)
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)
        }
    }
}

