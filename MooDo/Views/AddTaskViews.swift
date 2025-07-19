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
    @StateObject private var taskManager = TaskManager()
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
        
        let task = Task(
            title: processedTask.title,
            description: processedTask.description,
            priority: processedTask.priority,
            emotion: processedTask.emotion,
            reminderAt: processedTask.reminderAt,
            naturalLanguageInput: input
        )
        
        taskManager.addTask(task)
        dismiss()
    }
} 