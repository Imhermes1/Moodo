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
    @State private var taskDescription = ""
    @State private var taskTags = ""
    @State private var showingVoiceInput = false
    @State private var isProcessing = false
    @State private var showingAdvancedOptions = false
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedEmotion: TaskEmotion = .focused
    @State private var reminderDate = Date().addingTimeInterval(3600) // Default to 1 hour from now
    @State private var deadlineDate = Date().addingTimeInterval(86400) // Default to tomorrow
    @State private var hasReminder = false
    @State private var hasDeadline = false
    @ObservedObject var taskManager: TaskManager
    @StateObject private var nlpProcessor = NaturalLanguageProcessor()
    @StateObject private var voiceRecognition = VoiceRecognitionManager()
    
    // Animation states for achievement effect
    @State private var showSuccessAnimation = false
    @State private var bounceScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Universal background
            UniversalBackground()
            
            VStack(spacing: 0) {
                // Fixed Header - Always visible
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
                            .scaleEffect(bounceScale)
                            .overlay(
                                // Success animation overlay
                                Group {
                                    if showSuccessAnimation {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.green)
                                            .scaleEffect(showSuccessAnimation ? 1.5 : 0.1)
                                            .opacity(showSuccessAnimation ? 1.0 : 0.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: showSuccessAnimation)
                                    }
                                }
                            )
                    }
                    .disabled(taskInput.isEmpty || isProcessing)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Scrollable content area
                ScrollView {
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
                            
                            TextField("e.g., 'Call mum tomorrow at 3pm' or 'Brainstorm new project ideas by Friday'", text: $taskInput, axis: .vertical)
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
                                    // Description field
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "doc.text")
                                                .foregroundColor(.white.opacity(0.8))
                                                .font(.caption)
                                            Text("Description (optional)")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                        TextField("Add more details about your task...", text: $taskDescription, axis: .vertical)
                                            .font(.body)
                                            .foregroundColor(.white)
                                            .padding(12)
                                            .background(
                                                GlassPanelBackground()
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .lineLimit(2...4)
                                    }
                                    
                                    // Tags field
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "tag")
                                                .foregroundColor(.white.opacity(0.8))
                                                .font(.caption)
                                            Text("Tags (optional)")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                    TextField("Add tags separated by commas or use #hashtags", text: $taskTags)
                                            .font(.body)
                                            .foregroundColor(.white)
                                            .padding(12)
                                            .background(
                                                GlassPanelBackground()
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }

                                    // Priority and Mood
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
                                            .padding(10)
                                            .background(
                                                GlassPanelBackground()
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        
                                        // Task Characteristic selector
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "brain.head.profile")
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .font(.caption)
                                                Text("Task Type")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            
                                            Picker("Task Type", selection: $selectedEmotion) {
                                                ForEach(TaskEmotion.allCases, id: \.self) { emotion in
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
                                            .padding(10)
                                            .background(
                                                GlassPanelBackground()
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }

                                    }
                                    
                                    // Reminder and Deadline
                                    VStack(spacing: 12) {
                                        // Reminder toggle
                                        HStack(spacing: 10) {
                                            Toggle("", isOn: $hasReminder)
                                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                                .scaleEffect(0.8)
                                                .frame(width: 45, height: 28)
                                            
                                            if !hasReminder {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "clock")
                                                        .foregroundColor(.white.opacity(0.8))
                                                        .font(.caption2)
                                                    Text("Reminder")
                                                        .font(.caption2)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.white.opacity(0.8))
                                                }
                                                .frame(maxWidth: .infinity)
                                                .multilineTextAlignment(.center)
                                            } else {
                                                Spacer()
                                                    .frame(maxWidth: .infinity)
                                            }
                                            
                                            if hasReminder {
                                                DatePicker("", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                                                    .datePickerStyle(CompactDatePickerStyle())
                                                    .labelsHidden()
                                                    .colorScheme(.dark)
                                                    .scaleEffect(0.9)
                                            }
                                        }
                                        .frame(height: 36)
                                        .padding(10)
                                        .background(
                                            GlassPanelBackground()
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        // Deadline toggle
                                        HStack(spacing: 10) {
                                            Toggle("", isOn: $hasDeadline)
                                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                                                .scaleEffect(0.8)
                                                .frame(width: 45, height: 28)
                                            
                                            if !hasDeadline {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "exclamationmark.triangle")
                                                        .foregroundColor(.white.opacity(0.8))
                                                        .font(.caption2)
                                                    Text("Deadline")
                                                        .font(.caption2)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.white.opacity(0.8))
                                                }
                                                .frame(maxWidth: .infinity)
                                                .multilineTextAlignment(.center)
                                            } else {
                                                Spacer()
                                                    .frame(maxWidth: .infinity)
                                            }
                                            
                                            if hasDeadline {
                                                DatePicker("", selection: $deadlineDate, displayedComponents: [.date, .hourAndMinute])
                                                    .datePickerStyle(CompactDatePickerStyle())
                                                    .labelsHidden()
                                                    .colorScheme(.dark)
                                                    .scaleEffect(0.9)
                                            }
                                        }
                                        .frame(height: 36)
                                        .padding(10)
                                        .background(
                                            GlassPanelBackground()
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                                .padding(16)
                                .background(
                                    GlassPanelBackground()
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
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
                .padding(.bottom, 20)
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
        
        // Show processing state
        isProcessing = true
        
        let processedTask = nlpProcessor.processNaturalLanguage(input)
        
        // Use description field if provided, otherwise use processed description
        let finalDescription = taskDescription.isEmpty ? processedTask.description : taskDescription
        
        // Combine manual tags with NLP extracted tags
        var finalTags = processedTask.tags
        if !taskTags.isEmpty {
            // Parse both comma-separated tags and hashtags
            var manualTags: [String] = []
            
            // First, extract hashtags
            let hashtagPattern = #"#\w+"#
            let hashtagRegex = try! NSRegularExpression(pattern: hashtagPattern)
            let hashtagMatches = hashtagRegex.matches(in: taskTags, range: NSRange(taskTags.startIndex..., in: taskTags))
            
            for match in hashtagMatches {
                if let range = Range(match.range, in: taskTags) {
                    let hashtag = String(taskTags[range]).dropFirst() // Remove the # symbol
                    if !hashtag.isEmpty {
                        manualTags.append(String(hashtag))
                    }
                }
            }
            
            // Then, parse comma-separated tags (after removing hashtags)
            let withoutHashtags = hashtagRegex.stringByReplacingMatches(in: taskTags, options: [], range: NSRange(taskTags.startIndex..., in: taskTags), withTemplate: "")
            let commaTags = withoutHashtags.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            manualTags.append(contentsOf: commaTags)
            
            // Add manual tags to final tags (avoiding duplicates)
            for tag in manualTags {
                if !finalTags.contains(tag) {
                    finalTags.append(tag)
                }
            }
        }
        
        // Use advanced options if they're set, otherwise use processed values
        let finalPriority = showingAdvancedOptions ? selectedPriority : processedTask.priority
        let finalEmotion = showingAdvancedOptions ? selectedEmotion : (processedTask.emotion != .routine ? processedTask.emotion : detectEmotionForTask(title: processedTask.title, description: finalDescription, priority: finalPriority))
        
        // Handle future dates properly - use provided dates or processed dates
        var finalReminderAt: Date? = nil
        var finalDeadlineAt: Date? = nil
        
        if hasReminder {
            // Ensure reminder date is in the future
            if reminderDate > Date() {
                finalReminderAt = reminderDate
            } else {
                // If selected date is in the past, add one day
                finalReminderAt = Calendar.current.date(byAdding: .day, value: 1, to: reminderDate)
            }
        } else if let processedReminder = processedTask.reminderAt, processedReminder > Date() {
            finalReminderAt = processedReminder
        }
        
        if hasDeadline {
            // Ensure deadline is in the future
            if deadlineDate > Date() {
                finalDeadlineAt = deadlineDate
            } else {
                // If selected date is in the past, add one day
                finalDeadlineAt = Calendar.current.date(byAdding: .day, value: 1, to: deadlineDate)
            }
        }
        
        let task = Task(
            title: processedTask.title,
            description: finalDescription,
            priority: finalPriority,
            emotion: finalEmotion,
            reminderAt: finalReminderAt,
            deadlineAt: finalDeadlineAt,
            naturalLanguageInput: input,
            tags: finalTags
        )
        
        print("📝 Creating task: \(task.title)")
        print("🏷️ Tags: \(finalTags)")
        print("⏰ Reminder: \(finalReminderAt?.description ?? "None")")
        print("📅 Deadline: \(finalDeadlineAt?.description ?? "None")")
        
        // Use optimistic UI update for instant response
        taskManager.addTaskOptimistically(task)
        
        // Achievement animation sequence
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showSuccessAnimation = true
            bounceScale = 1.2
        }
        
        // Enhanced haptic feedback
        HapticManager.shared.achievementUnlocked()
        
        // Complete animation and dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.2)) {
                bounceScale = 1.0
                showSuccessAnimation = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isProcessing = false
                dismiss()
            }
        }
    }
    
    private func detectEmotionForTask(title: String, description: String?, priority: TaskPriority) -> TaskEmotion {
        let titleLower = title.lowercased()
        let descriptionLower = description?.lowercased() ?? ""
        let content = titleLower + " " + descriptionLower
        
        // Step 1: Analyze task complexity
        let complexityScore = analyzeTaskComplexity(title: titleLower, description: descriptionLower)
        
        // Step 2: Keyword-based emotion detection (highest priority)
        if content.contains("urgent") || content.contains("deadline") || content.contains("emergency") {
            return .stressful
        }

        if content.contains("anxious") || content.contains("anxiety") || content.contains("nervous") || content.contains("worry") {
            return .anxious
        }
        
        if content.contains("creative") || content.contains("design") || content.contains("brainstorm") || content.contains("idea") {
            return .creative
        }
        
        if content.contains("exercise") || content.contains("workout") || content.contains("run") || content.contains("gym") || content.contains("energy") {
            return .energizing
        }
        
        if content.contains("meeting") || content.contains("presentation") || content.contains("work") || content.contains("project") {
            return complexityScore > 0.7 ? .focused : .routine
        }
        
        if content.contains("relax") || content.contains("meditate") || content.contains("read") || content.contains("rest") || content.contains("walk") || content.contains("call") {
            return .calming
        }
        
        if content.contains("family") || content.contains("friend") || content.contains("social") || content.contains("celebrate") {
            return .calming
        }
        
        if content.contains("organize") || content.contains("clean") || content.contains("routine") || content.contains("simple") {
            return .routine
        }
        
        // Step 3: Complexity-based emotion assignment
        if complexityScore >= 0.8 {
            return .focused  // Very complex tasks need focus
        } else if complexityScore >= 0.6 {
            return priority == .high ? .focused : .routine  // Moderately complex
        } else if complexityScore >= 0.3 {
            return .routine  // Simple to moderate tasks
        } else {
            return .calming     // Very simple tasks
        }
    }
    
    private func analyzeTaskComplexity(title: String, description: String) -> Double {
        var complexityScore: Double = 0.0
        let content = title + " " + description
        
        // Complexity indicators
        let complexKeywords = [
            // High complexity words (0.3 each)
                            "analyse", "develop", "implement", "design", "research", "plan", "strategy", "review", "optimise", "configure",
            "troubleshoot", "debug", "architecture", "database", "algorithm", "integration", "deployment", "migration",
            
            // Medium complexity words (0.2 each)
                                "organise", "prepare", "coordinate", "schedule", "document", "report", "presentation", "meeting", "discussion",
            "training", "learning", "study", "practice", "setup", "install", "update", "backup",
            
            // Process complexity words (0.1 each)
            "multiple", "several", "various", "different", "complex", "detailed", "comprehensive", "thorough", "extensive"
        ]
        
        let simpleKeywords = [
            // Simple task indicators (-0.2 each, reduces complexity)
            "call", "email", "text", "send", "buy", "pick up", "drop off", "water", "feed", "clean", "wash",
            "take out", "put away", "turn on", "turn off", "check", "quick", "simple", "easy", "basic"
        ]
        
        // Count complex keywords
        for keyword in complexKeywords {
            if content.contains(keyword) {
                if ["analyse", "develop", "implement", "design", "research"].contains(keyword) {
                    complexityScore += 0.3
                } else if ["organise", "prepare", "coordinate"].contains(keyword) {
                    complexityScore += 0.2
                } else {
                    complexityScore += 0.1
                }
            }
        }
        
        // Subtract for simple keywords
        for keyword in simpleKeywords {
            if content.contains(keyword) {
                complexityScore -= 0.2
            }
        }
        
        // Length-based complexity (longer descriptions = more complex)
        let wordCount = content.split(separator: " ").count
        if wordCount > 10 {
            complexityScore += 0.2
        } else if wordCount > 5 {
            complexityScore += 0.1
        }
        
        // Multi-step indicator (words like "and", "then", "after")
        let multiStepWords = ["and", "then", "after", "before", "first", "second", "next", "finally"]
        let stepCount = multiStepWords.filter { content.contains($0) }.count
        complexityScore += Double(stepCount) * 0.1
        
        // Time duration indicators
        if content.contains("hour") || content.contains("hours") {
            complexityScore += 0.2
        }
        if content.contains("day") || content.contains("days") || content.contains("week") {
            complexityScore += 0.3
        }
        
        // Clamp between 0 and 1
        return max(0.0, min(1.0, complexityScore))
    }
} 