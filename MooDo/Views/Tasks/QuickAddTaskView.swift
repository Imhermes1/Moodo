//
//  QuickAddTaskView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

struct QuickAddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    
    @State private var taskTitle = ""
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedEmotion: TaskEmotion = .focused
    @State private var aiSuggestedEmotion: TaskEmotion?
    @State private var aiConfidenceLevel: ConfidenceLevel?
    @State private var aiReasonText: String?
    @State private var userHasOverriddenAI = false
    @State private var reminderDate: Date?
    @State private var showingDatePicker = false
    @State private var showingFullEditor = false
    @StateObject private var nlpProcessor = NaturalLanguageProcessor()
    @State private var detectedRanges: [DetectedRange] = []
    @State private var keyboardHeight: CGFloat = 0
    
    struct DetectedRange {
        let range: NSRange
        let type: DetectionType
        let text: String
        
        enum DetectionType: Hashable {
            case time
            case date
            case priority
            case emotion
            
            var color: Color {
                switch self {
                case .time: return .calmingBlue
                case .date: return .peacefulGreen
                case .priority: return .gentleYellow
                case .emotion: return .softViolet
                }
            }
            
            var displayName: String {
                switch self {
                case .time: return "Time"
                case .date: return "Date"
                case .priority: return "Priority"
                case .emotion: return "Mood"
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header with cancel button
            HStack {
                Button("Cancel") {
                    dismiss()
                    HapticManager.shared.impact(.light)
                }
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("Add Task")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Invisible spacer for balance
                Text("Cancel")
                    .font(.body)
                    .opacity(0)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Gentle header
                    VStack(spacing: 8) {
                        Text("What would feel good to accomplish?")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Take your time, no pressure 💙")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 8)
                
                // Task title input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("Task")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        // NLP processing indicator
                        if nlpProcessor.isProcessing {
                            HStack(spacing: 4) {
                                Image(systemName: "brain.head.profile")
                                    .font(.caption2)
                                    .foregroundColor(.calmingBlue)
                                Text("Analyzing...")
                                    .font(.caption2)
                                    .foregroundColor(.calmingBlue)
                            }
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        // Background with highlighting
                        if !taskTitle.isEmpty {
                            highlightedTextView
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                        
                        TextField("Finish report by Friday, Call mum at 5pm", text: $taskTitle)
                            .font(.body)
                            .foregroundColor(taskTitle.isEmpty ? .white : .clear) // Hide text when we have highlighting
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .onChange(of: taskTitle) {
                                processNaturalLanguage(taskTitle)
                            }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.calmingBlue.opacity(0.5), lineWidth: 1)
                            )
                    )
                    
                    // Natural language hint
                    if !taskTitle.isEmpty && (reminderDate != nil || selectedPriority != .medium || selectedEmotion != .focused) {
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.caption2)
                                    .foregroundColor(.gentleYellow)
                                Text("Smart detection active")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            // Detection legend
                            if !detectedRanges.isEmpty {
                                HStack(spacing: 12) {
                                    ForEach(Array(Set(detectedRanges.map { $0.type })), id: \.self) { type in
                                        HStack(spacing: 2) {
                                            Circle()
                                                .fill(type.color)
                                                .frame(width: 6, height: 6)
                                            Text(type.displayName)
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                    }
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                
                // Emotion picker
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "heart")
                            .foregroundColor(.softViolet)
                            .font(.caption)
                        Text("How does this task feel?")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        // AI Suggestion Indicator
                        if let aiSuggested = aiSuggestedEmotion, let confidence = aiConfidenceLevel {
                            HStack(spacing: 4) {
                                Image(systemName: "brain.head.profile")
                                    .font(.caption2)
                                    .foregroundColor(Color.aiSuggestion)
                                Text(confidence.description)
                                    .font(.caption2)
                                    .foregroundColor(Color.aiSuggestion)
                            }
                        }
                    }
                    
                    // AI Suggestion Banner
                    if let aiSuggested = aiSuggestedEmotion, 
                       let confidence = aiConfidenceLevel,
                       let reason = aiReasonText,
                       !taskTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption2)
                                .foregroundColor(Color.aiSuggestion)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text("AI suggests:")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text(aiSuggested.displayName)
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(aiSuggested.color)
                                }
                                Text(reason)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            Spacer()
                            
                            // Show different buttons based on whether user has overridden or if AI suggestion matches current selection
                            if userHasOverriddenAI {
                                Text("Overridden")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                            } else if selectedEmotion == aiSuggested {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark")
                                        .font(.caption2)
                                    Text("Applied")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(Color.aiSuggestion)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.aiSuggestion.opacity(0.2))
                                )
                            } else {
                                Button("Use") {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedEmotion = aiSuggested
                                        HapticManager.shared.selection()
                                    }
                                }
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(Color.aiSuggestion)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .stroke(Color.aiSuggestion, lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.aiSuggestion.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .transition(.opacity.combined(with: .scale))
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TaskEmotion.allCases, id: \.self) { emotion in
                                EmotionPillView(
                                    emotion: emotion,
                                    isSelected: selectedEmotion == emotion
                                ) {
                                    // Check if user is manually overriding AI suggestion
                                    if let aiSuggested = aiSuggestedEmotion, 
                                       emotion != aiSuggested && !userHasOverriddenAI {
                                        userHasOverriddenAI = true
                                    }
                                    selectedEmotion = emotion
                                    HapticManager.shared.selection()
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                // Priority and reminder
                HStack(spacing: 16) {
                    // Priority
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "flag")
                                .foregroundColor(.gentleYellow)
                                .font(.caption)
                            Text("Priority")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                PriorityButton(
                                    priority: priority,
                                    isSelected: selectedPriority == priority
                                ) {
                                    selectedPriority = priority
                                    HapticManager.shared.selection()
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Reminder
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(Color.calmingBlue)
                                .font(.caption)
                            Text("Remind me")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Button(action: {
                            showingDatePicker.toggle()
                            HapticManager.shared.impact(.light)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: reminderDate != nil ? "bell.fill" : "bell")
                                    .font(.caption2)
                                Text(smartReminderText)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(reminderDate != nil ? Color.calmingBlue : .white.opacity(0.7))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(reminderDate != nil ? Color.calmingBlue : .clear, lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                
                // Date picker
                if showingDatePicker {
                    DatePicker(
                        "Reminder time",
                        selection: Binding(
                            get: { reminderDate ?? Date().addingTimeInterval(3600) },
                            set: { reminderDate = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .accentColor(.calmingBlue)
                    .transition(.opacity.combined(with: .scale))
                    .padding(.bottom, 16)
                }
                
                // Action buttons - side by side as pills
                HStack(spacing: 12) {
                    // Add task button
                    Button(action: {
                        addTask()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.body)
                            Text("Add Task")
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color.peacefulGreen.opacity(0.8))
                        )
                    }
                    .disabled(taskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(taskTitle.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                    
                    // More options button
                    Button(action: {
                        showingFullEditor = true
                        HapticManager.shared.impact(.light)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "ellipsis.circle")
                                .font(.body)
                            Text("More Options")
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color.calmingBlue.opacity(0.6))
                        )
                    }
                }
                .padding(.top, 8)
                
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .padding(.bottom, keyboardHeight > 0 ? 10 : 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            UniversalBackground()
                .ignoresSafeArea(.all)
        )
        .sheet(isPresented: $showingFullEditor) {
            let tempTask = Task(
                title: taskTitle.isEmpty ? "New Task" : taskTitle,
                priority: selectedPriority,
                emotion: selectedEmotion,
                reminderAt: reminderDate
            )
            EditTaskView(task: tempTask, onSave: { savedTask in
                var finalTask = savedTask
                // If the title was empty, clear the placeholder
                if taskTitle.isEmpty && finalTask.title == "New Task" {
                    finalTask.title = ""
                }
                taskManager.addTask(finalTask)
                dismiss()
                HapticManager.shared.success()
            }, onDelete: { taskToDelete in
                // Since this is a new task being created, we don't need delete functionality
                // But we need to provide the parameter for the EditTaskView
                dismiss()
            })
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeInOut(duration: 0.3)) {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                keyboardHeight = 0
            }
        }
    }
    
    // MARK: - Highlighted Text View
    
    private var highlightedTextView: some View {
        let attributedString = createAttributedString()
        return Text(AttributedString(attributedString))
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func createAttributedString() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: taskTitle)
        let range = NSRange(location: 0, length: taskTitle.count)
        
        // Set default color
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: range)
        
        // Apply highlighting for detected ranges
        for detectedRange in detectedRanges {
            if detectedRange.range.location + detectedRange.range.length <= taskTitle.count {
                let color = UIColor(detectedRange.type.color)
                attributedString.addAttribute(.foregroundColor, value: color, range: detectedRange.range)
                attributedString.addAttribute(.backgroundColor, value: color.withAlphaComponent(0.2), range: detectedRange.range)
            }
        }
        
        return attributedString
    }
    
    // MARK: - Smart Reminder Display
    
    private var smartReminderText: String {
        guard let date = reminderDate else { return "Later" }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Get start of this week (Sunday)
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? now
        
        // Check if the date is within this week
        if date >= startOfWeek && date <= endOfWeek {
            // This week - show day name and time
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE" // Full day name
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a" // 5:00 PM format
            
            let dayName = dayFormatter.string(from: date)
            let timeString = timeFormatter.string(from: date)
            
            // Remove minutes if it's exactly on the hour (5:00 PM -> 5pm)
            let cleanTimeString = timeString.replacingOccurrences(of: ":00", with: "").lowercased()
            
            // Check if it's today or tomorrow
            if calendar.isDateInToday(date) {
                return "Today \(cleanTimeString)"
            } else if calendar.isDateInTomorrow(date) {
                return "Tomorrow \(cleanTimeString)"
            } else {
                return "\(dayName) \(cleanTimeString)"
            }
        } else {
            // Beyond this week - show date and time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM" // 15 Aug format
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a" // 5:00 PM format
            
            let dateString = dateFormatter.string(from: date)
            let timeString = timeFormatter.string(from: date)
            
            return "\(dateString) \(timeString)"
        }
    }
    
    private func processNaturalLanguage(_ input: String) {
        guard !input.trimmingCharacters(in: .whitespaces).isEmpty else { 
            detectedRanges = []
            // Clear AI suggestions when text is empty
            aiSuggestedEmotion = nil
            aiConfidenceLevel = nil
            aiReasonText = nil
            userHasOverriddenAI = false
            return 
        }
        
        let processedTask = nlpProcessor.processNaturalLanguage(input)
        
        // Detect and store ranges for highlighting
        var newDetectedRanges: [DetectedRange] = []
        
        // Find time patterns
        let timePatterns = [
            "\\d{1,2}:\\d{2}\\s*(am|pm|AM|PM)",
            "\\d{1,2}\\s*(am|pm|AM|PM)",
            "at\\s+\\d{1,2}:\\d{2}", // Added: "at 2:30" pattern
            "\\d{1,2}:\\d{2}(?!\\d)" // Fixed: Added negative lookahead to prevent matching partial numbers
        ]
        
        for pattern in timePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.count))
                for match in matches {
                    let matchedText = (input as NSString).substring(with: match.range)
                    newDetectedRanges.append(DetectedRange(range: match.range, type: .time, text: matchedText))
                }
            }
        }
        
        // Find date patterns
        let datePatterns = [
            "\\b(today|tomorrow|yesterday)\\b",
            "\\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\\b",
            "\\b(january|february|march|april|may|june|july|august|september|october|november|december)\\s+\\d{1,2}\\b",
            "\\b\\d{1,2}\\s+(january|february|march|april|may|june|july|august|september|october|november|december)\\b",
            "\\b(next|this)\\s+(week|month|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\\b"
        ]
        
        for pattern in datePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.count))
                for match in matches {
                    let matchedText = (input as NSString).substring(with: match.range)
                    newDetectedRanges.append(DetectedRange(range: match.range, type: .date, text: matchedText))
                }
            }
        }
        
        // Find priority patterns
        let priorityPatterns = [
            "\\b(urgent|high|important|critical|asap)\\b",
            "\\b(low|later|sometime|eventual)\\b"
        ]
        
        for pattern in priorityPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.count))
                for match in matches {
                    let matchedText = (input as NSString).substring(with: match.range)
                    newDetectedRanges.append(DetectedRange(range: match.range, type: .priority, text: matchedText))
                }
            }
        }
        
        // Find emotion patterns
        let emotionPatterns = [
            "\\b(excited|motivated|energetic)\\b",
            "\\b(calm|peaceful|relaxed)\\b",
            "\\b(focused|concentrated|determined)\\b",
            "\\b(creative|inspired|innovative)\\b"
        ]
        
        for pattern in emotionPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.count))
                for match in matches {
                    let matchedText = (input as NSString).substring(with: match.range)
                    newDetectedRanges.append(DetectedRange(range: match.range, type: .emotion, text: matchedText))
                }
            }
        }
        
        // Update the form fields based on natural language processing
        DispatchQueue.main.async {
            // Update detected ranges for highlighting
            detectedRanges = newDetectedRanges
            
            // Update priority if detected
            selectedPriority = processedTask.priority
            
            // AI Emotion Analysis - Always run and update live
            let emotionAnalysis = EmotionAnalyzer.shared.getEmotionAnalysis(from: input)
            if emotionAnalysis.confidence > 0.2 { // Lower threshold for more suggestions
                // Always update AI suggestions as user types
                aiSuggestedEmotion = emotionAnalysis.suggestedEmotion
                aiConfidenceLevel = emotionAnalysis.confidenceLevel
                aiReasonText = emotionAnalysis.reasonText
                
                // Only auto-apply if user hasn't manually overridden and confidence is high enough
                if !userHasOverriddenAI && emotionAnalysis.confidence > 0.4 {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedEmotion = emotionAnalysis.suggestedEmotion
                    }
                }
            } else {
                // Clear AI suggestions if confidence is too low
                aiSuggestedEmotion = nil
                aiConfidenceLevel = nil
                aiReasonText = nil
            }
            
            // Update reminder date if detected
            if let extractedDate = processedTask.reminderAt {
                reminderDate = extractedDate
            }
        }
    }
    
    private func addTask() {
        guard !taskTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // Process the input one final time to get the cleaned title
        let processedTask = nlpProcessor.processNaturalLanguage(taskTitle)
        
        // If user hasn't overridden AI and there's a valid AI suggestion, use it
        if !userHasOverriddenAI, let aiSuggested = aiSuggestedEmotion {
            selectedEmotion = aiSuggested
        }
        
        // Clean the title by removing detected natural language patterns
        var cleanedTitle = taskTitle.trimmingCharacters(in: .whitespaces)
        
        // Sort detected ranges by location in reverse order to avoid index shifting
        let sortedRanges = detectedRanges.sorted { $0.range.location > $1.range.location }
        
        // Remove detected patterns from the title
        for detectedRange in sortedRanges {
            if detectedRange.range.location + detectedRange.range.length <= cleanedTitle.count {
                let nsString = cleanedTitle as NSString
                let beforeRange = NSRange(location: 0, length: detectedRange.range.location)
                let afterRange = NSRange(
                    location: detectedRange.range.location + detectedRange.range.length,
                    length: cleanedTitle.count - (detectedRange.range.location + detectedRange.range.length)
                )
                
                let beforeText = nsString.substring(with: beforeRange)
                let afterText = nsString.substring(with: afterRange)
                
                cleanedTitle = (beforeText + " " + afterText)
                    .trimmingCharacters(in: .whitespaces)
                    .replacingOccurrences(of: "  ", with: " ") // Remove double spaces
            }
        }
        
        // Use the processed title if available, otherwise use cleaned title
        let finalTitle = processedTask.title.isEmpty ? cleanedTitle : processedTask.title
        
        let newTask = Task(
            title: finalTitle,
            priority: selectedPriority,
            emotion: selectedEmotion,
            reminderAt: reminderDate
        )
        
        taskManager.addTask(newTask)
        
        // Success haptic and animation
        HapticManager.shared.success()
        
        // Gentle dismiss
        dismiss()
    }
}

// MARK: - Emotion Pill View

struct EmotionPillView: View {
    let emotion: TaskEmotion
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: emotion.icon)
                    .font(.caption2)
                Text(emotion.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? emotion.color : .clear, lineWidth: 1.5)
                    )
            )
        }
    }
}

// MARK: - Priority Button

struct PriorityButton: View {
    let priority: TaskPriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "flag.fill")
                .font(.caption2)
                .foregroundColor(isSelected ? priority.color : .white.opacity(0.5))
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? priority.color : .clear, lineWidth: 1.5)
                        )
                )
        }
    }
}

#Preview {
    QuickAddTaskView(
        taskManager: TaskManager(),
        moodManager: MoodManager()
    )
}

