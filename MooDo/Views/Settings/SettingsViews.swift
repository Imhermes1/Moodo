//
//  SettingsViews.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var moodManager = MoodManager()
    @StateObject private var voiceManager = VoiceCheckinManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Cloud Sync Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cloud Sync")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Button("Sync with iCloud") {
                        taskManager.syncWithCloud()
                        moodManager.syncWithCloud()
                        voiceManager.syncWithCloud()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.thinMaterial)
                            .opacity(0.1)
                    )
                    .foregroundColor(.white)
                }
                
                // Data Management Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Data Management")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Tasks: \(taskManager.tasks.count)")
                                .foregroundColor(.white.opacity(0.7))
                            Text("Moods: \(moodManager.moodEntries.count)")
                                .foregroundColor(.white.opacity(0.7))
                            Text("Voice: \(voiceManager.voiceCheckins.count)")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.thinMaterial)
                            .opacity(0.05)
                    )
                }
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        // Handle done action
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

 