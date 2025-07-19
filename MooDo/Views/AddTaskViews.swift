//
//  AddTaskViews.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Add Task Modal View

struct AddTaskModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var taskInput = ""
    @State private var showingVoiceInput = false
    @State private var isProcessing = false
    @State private var showingAdvancedOptions = false
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedEmotion: EmotionType = .focused
    @State private var reminderDate = Date().addingTimeInterval(3600) // Default to 1 hour from now
    @State private var deadlineDate = Date().addingTimeInterval(86400) // Default to tomorrow
    @State private var hasReminder = false
    @State private var hasDeadline = false
    @ObservedObject var taskManager: TaskManager
    @StateObject private var nlpProcessor = NaturalLanguageProcessor()
    @StateObject private var voiceRecognition = VoiceRecognitionManager()
    
    var body: some View {
        ZStack {
            // Universal background
            UniversalBackground()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    GlassPanelBackground()
                                )
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("Add Task")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: createTask) {
                            Image(systemName: "checkmark")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    taskInput.isEmpty ? Color.gray.opacity(0.3) : Color.green.opacity(0.3)
                                )
                                .background(
                                    GlassPanelBackground()
                                )
                                .clipShape(Circle())
                        }
                        .disabled(taskInput.isEmpty || isProcessing)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Main input area
                    VStack(spacing: 20) {
                        // Natural language input
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.bubble")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text("Describe your task")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            
                            TextField("e.g., 'Call mom tomorrow at 3pm' or 'Brainstorm new project ideas by Friday'", text: $taskInput, axis: .vertical)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(16)
                                .background(
                                    GlassPanelBackground()
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .lineLimit(3...6)
                        }
                        
                        // Advanced Options
                        VStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showingAdvancedOptions.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "slider.horizontal.3")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                    Text("Advanced Options")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: showingAdvancedOptions ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.caption)
                                        .animation(.easeInOut(duration: 0.3), value: showingAdvancedOptions)
                                }
                                .padding(16)
                                .background(
                                    GlassPanelBackground()
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            
                            if showingAdvancedOptions {
                                VStack(spacing: 16) {
                                    // Priority and Emotion
                                    HStack(spacing: 12) {
                                        // Priority selector
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "exclamationmark.triangle")
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .font(.caption)
                                                Text("Priority")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            
                                            Picker("Priority", selection: $selectedPriority) {
                                                ForEach(TaskPriority.allCases, id: \.self) { priority in
                                                    HStack {
                                                        Circle()
                                                            .fill(priority.color)
                                                            .frame(width: 8, height: 8)
                                                        Text(priority.displayName)
                                                            .foregroundColor(.white)
                                                    }
                                                    .tag(priority)
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            .foregroundColor(.white)
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(.ultraThinMaterial)
                                                    .opacity(0.6)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                                    )
                                            )
                                        }
                                        
                                        // Emotion selector
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "heart")
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .font(.caption)
                                                Text("Emotion")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            
                                            Picker("Emotion", selection: $selectedEmotion) {
                                                ForEach(EmotionType.allCases, id: \.self) { emotion in
                                                    HStack {
                                                        Image(systemName: emotion.icon)
                                                            .foregroundColor(emotion.color)
                                                        Text(emotion.displayName)
                                                            .foregroundColor(.white)
                                                    }
                                                    .tag(emotion)
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            .foregroundColor(.white)
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(.ultraThinMaterial)
                                                    .opacity(0.6)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                                    )
                                            )
                                        }
                                    }
                                    
                                    // Reminder and Deadline
                                    VStack(spacing: 12) {
                                        // Reminder toggle
                                        HStack {
                                            Toggle("", isOn: $hasReminder)
                                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                                .scaleEffect(0.8)
                                            
                                            HStack(spacing: 6) {
                                                Image(systemName: "clock")
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .font(.caption)
                                                Text("Set Reminder")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            
                                            Spacer()
                                            
                                            if hasReminder {
                                                DatePicker("", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                                                    .datePickerStyle(CompactDatePickerStyle())
                                                    .labelsHidden()
                                                    .colorScheme(.dark)
                                            }
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(.ultraThinMaterial)
                                                .opacity(0.6)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                        
                                        // Deadline toggle
                                        HStack {
                                            Toggle("", isOn: $hasDeadline)
                                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                                                .scaleEffect(0.8)
                                            
                                            HStack(spacing: 6) {
                                                Image(systemName: "exclamationmark.triangle")
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .font(.caption)
                                                Text("Set Deadline")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            
                                            Spacer()
                                            
                                            if hasDeadline {
                                                DatePicker("", selection: $deadlineDate, displayedComponents: [.date, .hourAndMinute])
                                                    .datePickerStyle(CompactDatePickerStyle())
                                                    .labelsHidden()
                                                    .colorScheme(.dark)
                                            }
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(.ultraThinMaterial)
                                                .opacity(0.6)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                                    removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                                ))
                            }
                        }
                        
                        // Voice input option
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "mic.circle")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text("Or use voice")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                if voiceRecognition.isRecording {
                                    voiceRecognition.stopRecording()
                                } else {
                                    voiceRecognition.startRecording()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: voiceRecognition.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(voiceRecognition.isRecording ? .red : .white)
                                    
                                    Text(voiceRecognition.isRecording ? "Stop Recording" : "Tap to speak")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    if voiceRecognition.isRecording {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(16)
                                .background(
                                    GlassPanelBackground()
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .disabled(!voiceRecognition.isAuthorized)
                            
                            if !voiceRecognition.transcript.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Transcript:")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text(voiceRecognition.transcript)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(
                                            GlassPanelBackground()
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        
                        // Processing indicator
                        if isProcessing {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .foregroundColor(.white)
                                
                                Text("Analyzing your task...")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(20)
                            .background(
                                GlassPanelBackground()
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // Task preview (when processed)
                        if !nlpProcessor.processedText.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.yellow)
                                        .font(.title3)
                                    Text("Task Analysis")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                
                                Text(nlpProcessor.processedText)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(16)
                                    .background(
                                        GlassPanelBackground()
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onChange(of: voiceRecognition.transcript) { _, newValue in
            if !newValue.isEmpty {
                taskInput = newValue
                processTask()
            }
        }
    }
    
    private func processTask() {
        let input = taskInput.isEmpty ? voiceRecognition.transcript : taskInput
        guard !input.isEmpty else { return }
        
        isProcessing = true
        _ = nlpProcessor.processNaturalLanguage(input)
        
        // Reduced processing delay for better performance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isProcessing = false
        }
    }
    
    private func createTask() {
        let input = taskInput.isEmpty ? voiceRecognition.transcript : taskInput
        guard !input.isEmpty else { return }
        
        let processedTask = nlpProcessor.processNaturalLanguage(input)
        
        // Use advanced options if they're set, otherwise use processed values
        let finalPriority = showingAdvancedOptions ? selectedPriority : processedTask.priority
        let finalEmotion = showingAdvancedOptions ? selectedEmotion : (processedTask.emotion != .neutral ? processedTask.emotion : detectEmotionForTask(title: processedTask.title, description: processedTask.description, priority: finalPriority))
        let finalReminderAt = hasReminder ? reminderDate : processedTask.reminderAt
        let finalDeadlineAt = hasDeadline ? deadlineDate : nil
        
        let task = Task(
            title: processedTask.title,
            description: processedTask.description,
            priority: finalPriority,
            emotion: finalEmotion,
            reminderAt: finalReminderAt,
            deadlineAt: finalDeadlineAt,
            naturalLanguageInput: input
        )
        
        taskManager.addTask(task)
        dismiss()
    }
    
    private func detectEmotionForTask(title: String, description: String?, priority: TaskPriority) -> EmotionType {
        let titleLower = title.lowercased()
        let descriptionLower = description?.lowercased() ?? ""
        let content = titleLower + " " + descriptionLower
        
        // Keyword-based emotion detection
        if content.contains("urgent") || content.contains("deadline") || content.contains("emergency") {
            return .stressed
        }
        
        if content.contains("creative") || content.contains("design") || content.contains("brainstorm") || content.contains("idea") {
            return .creative
        }
        
        if content.contains("exercise") || content.contains("workout") || content.contains("run") || content.contains("gym") {
            return .energetic
        }
        
        if content.contains("meeting") || content.contains("presentation") || content.contains("work") || content.contains("project") {
            return .focused
        }
        
        if content.contains("relax") || content.contains("meditate") || content.contains("read") || content.contains("rest") {
            return .calm
        }
        
        if content.contains("family") || content.contains("friend") || content.contains("social") || content.contains("celebrate") {
            return .content
        }
        
        // Priority-based fallback
        switch priority {
        case .high:
            return .focused
        case .medium:
            return .content
        case .low:
            return .calm
        }
    }
} 