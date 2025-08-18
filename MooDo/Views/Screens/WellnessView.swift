//
//  WellnessView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct WellnessView: View {
    @Binding var showingAddTaskModal: Bool
    @Binding var showingNotifications: Bool
    @Binding var showingAccountSettings: Bool
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    let screenSize: CGSize
    
    @State private var showingDailyCheckIn = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: screenSize.height * 0.025) {
                // Enhanced Daily Check-in Button
                Button(action: {
                    HapticManager.shared.buttonPressed()
                    showingDailyCheckIn = true
                }) {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Check-In")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("How are you feeling today?")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "heart.text.square.fill")
                                .font(.title)
                                .foregroundColor(.pink)
                        }
                        
                        HStack(spacing: 16) {
                            VStack(spacing: 4) {
                                Image(systemName: "keyboard")
                                    .foregroundColor(.green)
                                Text("Type")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Text("or")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            VStack(spacing: 4) {
                                Image(systemName: "mic.fill")
                                    .foregroundColor(.blue)
                                Text("Voice")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.purple)
                                Text("Quick Support")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        ZStack {
                            GlassPanelBackground()
                            
                            // Blue tint for wellness check-in
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blue.opacity(0.06))
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(PlainButtonStyle())
                
                // Wellness Actions
                WellnessActionsView(moodManager: moodManager)
            }
            .padding(.horizontal, max(screenSize.width * 0.04, 12))
            .padding(.top, max(screenSize.height * 0.08, 60))
            .padding(.bottom, max(screenSize.height * 0.12, 100))
        }
        .ignoresSafeArea(edges: [.top, .bottom])
        .sheet(isPresented: $showingDailyCheckIn) {
            DailyCheckInView(moodManager: moodManager)
        }
    }
    
    //#Preview {
     //   WellnessView(
     //       showingAddTaskModal: .constant(false),
      //      showingNotifications: .constant(false),
      //      showingAccountSettings: .constant(false),
      //      taskManager: TaskManager(),
      //      moodManager: MoodManager(),
      //      screenSize: CGSize(width: 390, height: 844)
      //  )
      //  .background(UniversalBackground())
    //}
}
