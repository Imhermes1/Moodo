//
//  MoodBasedTasksView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Focus List View (Main Screen)

struct MoodBasedTasksView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    let onAddTask: () -> Void
    let screenSize: CGSize
    @State private var smartRecommendations: [Task] = []
    @State private var isRefreshing = false
    @StateObject private var smartTaskSuggestions = SmartTaskSuggestions()
    
    // AI-powered recommendations (maximum 2 as backup)
    @StateObject private var aiEngine: MLTaskEngine
    @State private var isRefreshingAI = false
    
    // New recommendation states
    @State private var recommendedTask: Task?
    @State private var showRecommendation = false
    
    @State private var editingTask: Task? = nil
    
    init(taskManager: TaskManager, moodManager: MoodManager, onAddTask: @escaping () -> Void, screenSize: CGSize) {
        self.taskManager = taskManager
        self.moodManager = moodManager
        self.onAddTask = onAddTask
        self.screenSize = screenSize
        let engine = MLTaskEngine(taskManager: taskManager, moodManager: moodManager)
        self._aiEngine = StateObject(wrappedValue: engine)
    }
    
    var body: some View {
        // Single comprehensive card container
        VStack(spacing: 20) {
            focusListCard
        }
        .onAppear {
            refreshSmartTasks()
            // Removed automatic AI recommendations on app open
        }
        .onReceive(taskManager.objectWillChange) { _ in
            refreshSmartTasks()
        }
        .sheet(item: $editingTask) { task in
            EditTaskView(
                task: task,
                onSave: { updatedTask in
                    taskManager.updateTask(updatedTask)
                    editingTask = nil
                },
                onDelete: { deletedTask in
                    taskManager.deleteTask(deletedTask)
                    editingTask = nil
                }
            )
            .presentationDetents([.large])
        }
    }
    
    // MARK: - Focus List Card
    private var focusListCard: some View {
        VStack(spacing: 16) {
            // Header Section - Centered
            VStack(spacing: 4) {
                Text("Focus List")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            
            // Controls Row - Centered
            HStack(spacing: 16) {
                // AI Button
                Button(action: refreshAIRecommendations) {
                    HStack(spacing: 6) {
                        if isRefreshingAI {
                            Image(systemName: "brain.head.profile")
                                .font(.callout)
                                .opacity(0.5)
                            Text("AI")
                                .font(.callout)
                                .fontWeight(.medium)
                                .opacity(0.5)
                        } else {
                            Image(systemName: "brain.head.profile")
                                .font(.callout)
                            Text("AI")
                                .font(.callout)
                                .fontWeight(.medium)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.purple.opacity(isRefreshingAI ? 0.2 : 0.3))
                    )
                    .overlay(
                        // Flowing rainbow outline when refreshing
                        Group {
                            if isRefreshingAI {
                                FlowingRainbowBorder(cornerRadius: 10)
                            }
                        }
                    )
                }
                .disabled(isRefreshingAI)
                
                // Refresh Button
                Button(action: refreshSmartTasks) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.callout)
                        Text("Refresh")
                            .font(.callout)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue.opacity(0.3))
                    )
                }
                
                // Add Button
                Button(action: {
                    onAddTask()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        generateRecommendationAfterAdd()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.callout)
                        Text("Add")
                            .font(.callout)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.green.opacity(0.3))
                    )
                }
            }
            
            // Task List Section
            if smartRecommendations.isEmpty && aiEngine.aiRecommendations.isEmpty && !isRefreshingAI {
                emptyStateView
            } else {
                VStack(spacing: 8) {
                    // User Tasks
                    ForEach(smartRecommendations) { task in
                        FocusTaskCard(
                            task: task,
                            isAIGenerated: task.isAIGenerated,
                            onToggleComplete: {
                                taskManager.toggleTaskCompletion(task)
                                refreshSmartTasks()
                            },
                            onTap: { editingTask = task }
                        )
                    }
                    
                    // AI Tasks - only show when not refreshing
                    if !isRefreshingAI {
                        ForEach(aiEngine.aiRecommendations) { aiRec in
                            FocusAITaskCard(
                                recommendation: aiRec,
                                onAdd: {
                                    addAIRecommendationAsTask(aiRec)
                                },
                                onDismiss: {
                                    dismissAIRecommendation(aiRec)
                                }
                            )
                        }
                    }
                    
                    // Placeholder space when AI is refreshing to maintain card size
                    if isRefreshingAI {
                        VStack(spacing: 12) {
                            Text("AI is thinking...")
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Feel. Plan. Do.")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple.opacity(0.9))
                            
                            Text("Analyzing your current mood and energy levels to suggest the perfect tasks that match how you're feeling right now")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                // Base glass layer with 3D depth
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                
                // Inner highlight layer for 3D effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.25),
                                .white.opacity(0.08),
                                .clear,
                                .black.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Outer stroke with glass shimmer
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.5),
                                .white.opacity(0.15),
                                .white.opacity(0.05),
                                .white.opacity(0.25)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                
                // Inner stroke for depth
                RoundedRectangle(cornerRadius: 19)
                    .strokeBorder(
                        .white.opacity(0.1),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
        .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.clipboard")
                .font(.title2)
                .foregroundColor(.white.opacity(0.6))
            
            Text("No tasks yet")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            Text("Feel. Plan. Do.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Computed Properties
    
    private var currentMood: MoodType {
        moodManager.latestMoodEntry?.mood ?? .energized
    }
    
    // MARK: - Methods
    
    private func refreshSmartTasks() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isRefreshing = true
        }
        
        print("🧠 Smart Tasks: Generating recommendations for mood: \(currentMood)")
        print("📋 Total available tasks: \(taskManager.tasks.count)")
        
        // Get all incomplete tasks from the main task list
        let incompleteTasks = taskManager.tasks.filter { !$0.isCompleted }
        
        // Generate smart recommendations (2-5 tasks, minimum 2 if data available)
        let recommendations = generateSmartRecommendations(from: incompleteTasks)
        
        // Also refresh the smart task suggestions
        smartTaskSuggestions.generateSuggestions(
            mood: currentMood,
            timeOfDay: Date(),
            completedTasks: taskManager.tasks.filter { $0.isCompleted }
        )
        
        print("✨ Generated \(recommendations.count) recommendations")
        print("📝 Recommended tasks: \(recommendations.map { $0.title })")
        
        withAnimation(.easeInOut(duration: 0.5)) {
            smartRecommendations = recommendations
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isRefreshing = false
            }
        }
    }
    
    // MARK: - Initial AI Task Generation
    
    private func generateInitialAITasks() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isRefreshingAI = true
        }
        
        // Force AI recommendations even with no existing tasks
        _Concurrency.Task {
            await aiEngine.generateInitialRecommendations()
            
            await MainActor.run {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isRefreshingAI = false
                    }
                }
            }
        }
    }
    
    // MARK: - AI Refresh Method
    
    private func refreshAIRecommendations() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isRefreshingAI = true
        }
        
        _Concurrency.Task {
            // Generate AI recommendations but don't show them yet
            if taskManager.tasks.isEmpty {
                print("🤖 No existing tasks - generating initial AI recommendations")
                await aiEngine.generateInitialRecommendations()
            } else {
                print("🤖 Found \(taskManager.tasks.count) tasks - generating AI recommendations")
                await aiEngine.generateAIRecommendations()
            }
            
            await MainActor.run {
                print("🤖 Generated \(aiEngine.aiRecommendations.count) AI recommendations")
                
                // Keep the loading state for 5 seconds before showing tasks
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isRefreshingAI = false
                    }
                }
            }
        }
    }
    
    // MARK: - AI Recommendation Handling
    
    private func addAIRecommendationAsTask(_ aiRecommendation: AITaskRecommendation) {
        let newTask = Task(
            title: aiRecommendation.title,
            description: aiRecommendation.description,
            priority: aiRecommendation.priority,
            emotion: aiRecommendation.emotion,
            category: aiRecommendation.category,
            estimatedTime: aiRecommendation.estimatedDuration,
            createdAt: Date(),
            isAIGenerated: true // Mark as AI-generated to maintain rainbow outline
        )
        
        taskManager.addTask(newTask)
        HapticManager.shared.taskAdded()
        
        // Remove the AI recommendation from the list
        aiEngine.aiRecommendations.removeAll { $0.id == aiRecommendation.id }
        
        // Only refresh regular tasks, don't trigger AI refresh to avoid loop
        refreshSmartTasks()
        
        print("🤖 Added AI recommendation as task: \(newTask.title)")
    }
    
    private func dismissAIRecommendation(_ aiRecommendation: AITaskRecommendation) {
        withAnimation(.easeOut(duration: 0.3)) {
            aiEngine.aiRecommendations.removeAll { $0.id == aiRecommendation.id }
            print("🤖 Dismissed AI recommendation: \(aiRecommendation.title)")
        }
    }
    
    private func generateSmartRecommendations(from tasks: [Task]) -> [Task] {
        guard !tasks.isEmpty else { return [] }
        
        // Step 1: Calculate mood compatibility scores for all tasks
        let scoredTasks = tasks.map { task in
            (task: task, score: calculateMoodCompatibilityScore(task: task, mood: currentMood))
        }
        
        // Step 2: Sort by mood compatibility, priority, and urgency
        let sortedTasks = scoredTasks.sorted { first, second in
            // High priority tasks get priority boost
            let priorityBoost1 = first.task.priority == .high ? 0.3 : 0.0
            let priorityBoost2 = second.task.priority == .high ? 0.3 : 0.0
            
            // Today's tasks get urgency boost
            let urgencyBoost1 = isTaskDueToday(first.task) ? 0.2 : 0.0
            let urgencyBoost2 = isTaskDueToday(second.task) ? 0.2 : 0.0
            
            let finalScore1 = first.score + priorityBoost1 + urgencyBoost1
            let finalScore2 = second.score + priorityBoost2 + urgencyBoost2
            
            return finalScore1 > finalScore2
        }
        
        // Step 3: Return 2-5 recommendations based on available data
        let recommendationCount = min(max(tasks.count >= 2 ? 2 : tasks.count, 0), 5)
        let recommendations = Array(sortedTasks.prefix(recommendationCount).map { $0.task })
        
        return recommendations
    }
    
    private func calculateMoodCompatibilityScore(task: Task, mood: MoodType) -> Double {
        var score: Double = 0.5 // Base score
        
        // Check if task emotion is compatible with current mood (60% weight)
        let compatibleEmotions = mood.compatibleTaskEmotions
        if compatibleEmotions.contains(task.emotion) {
            score += 0.6
        } else if task.emotion == .stressful && mood == .stressed {
            score -= 0.4 // Avoid stressful tasks when stressed
        }
        
        // Priority consideration (30% weight)
        switch task.priority {
        case .high: score += 0.2
        case .medium: score += 0.1
        case .low: score += 0.0
        }
        
        // Time sensitivity (20% weight)
        if isTaskDueToday(task) {
            score += 0.2
        } else if isTaskDueSoon(task) {
            score += 0.1
        }
        
        return max(0.0, min(1.0, score)) // Clamp between 0 and 1
    }
    
    private func isTaskDueToday(_ task: Task) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        if let reminderAt = task.reminderAt {
            return reminderAt >= today && reminderAt < tomorrow
        }
        if let deadlineAt = task.deadlineAt {
            return deadlineAt >= today && deadlineAt < tomorrow
        }
        return false
    }
    
    private func isTaskDueSoon(_ task: Task) -> Bool {
        let now = Date()
        let threeDaysFromNow = Calendar.current.date(byAdding: .day, value: 3, to: now)!
        
        if let reminderAt = task.reminderAt {
            return reminderAt >= now && reminderAt <= threeDaysFromNow
        }
        if let deadlineAt = task.deadlineAt {
            return deadlineAt >= now && deadlineAt <= threeDaysFromNow
        }
        return false
    }
    
    private func detectEmotionForTask(_ task: Task) -> TaskEmotion {
        let title = task.title.lowercased()
        let description = task.description?.lowercased() ?? ""
        let content = title + " " + description
        
        // Content-based emotion detection
        if content.contains("relax") || content.contains("walk") || content.contains("breathe") || content.contains("meditation") || content.contains("call") || content.contains("text") {
            return .calming
        }
        
        if content.contains("creative") || content.contains("brainstorm") || content.contains("design") || content.contains("art") || content.contains("idea") {
            return .creative
        }
        
        if content.contains("focus") || content.contains("write") || content.contains("analyze") || content.contains("plan") || content.contains("study") {
            return .focused
        }
        
        if content.contains("energy") || content.contains("workout") || content.contains("exercise") || content.contains("project") || content.contains("taxes") {
            return .energizing
        }
        
        if content.contains("deadline") || content.contains("urgent") || content.contains("important") || content.contains("presentation") || content.contains("stress") {
            return .stressful
        }
        
        if content.contains("organize") || content.contains("clean") || content.contains("routine") || content.contains("simple") || content.contains("grass") {
            return .routine
        }
        
        // Priority-based fallback
        switch task.priority {
        case .high:
            return currentMood == .stressed ? .calming : .focused
        case .medium:
            return .routine
        case .low:
            return .calming
        }
    }
    
    // MARK: - New Recommendation Methods
    
    private func generateRecommendationAfterAdd() {
        // Generate recommendation based on mood and existing tasks
        let recommendation = generateMoodBasedRecommendation()
        
        if let rec = recommendation {
            withAnimation(.easeInOut(duration: 0.4)) {
                recommendedTask = rec
                showRecommendation = true
            }
            
            // Auto-dismiss after 10 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                dismissRecommendation()
            }
        }
    }
    
    private func generateMoodBasedRecommendation() -> Task? {
        let currentMood = moodManager.latestMoodEntry?.mood ?? .energized
        let existingTasks = taskManager.tasks
        
        // Don't suggest if user already has many tasks
        guard existingTasks.count < 10 else { return nil }
        
        // AI recommendation logic based on mood and task patterns
        switch currentMood {
        case .energized:
            return Task(
                title: "Tackle a challenging project",
                description: "⚡️ Your energy is high - perfect for complex work that requires focus and determination. Break it into 25-minute focused blocks.",
                priority: .high,
                emotion: .energizing,
                category: .work,
                isAIGenerated: true
            )
        case .calm:
            return Task(
                title: "Organize your workspace",
                description: "🏠 Use this peaceful state for thoughtful tidying. Start with one area - your calm energy makes decision-making easier.",
                priority: .medium,
                emotion: .routine,
                category: .personal,
                isAIGenerated: true
            )
        case .focused:
            return Task(
                title: "Deep work session",
                description: "🎯 Ideal time for concentrated tasks. Turn off notifications and dive into your most important project for 45-90 minutes.",
                priority: .high,
                emotion: .focused,
                category: .work,
                isAIGenerated: true
            )
        case .stressed:
            return Task(
                title: "Take a mindful break",
                description: "🫁 Step back and recharge with 5 minutes of deep breathing. Your stress levels are high - self-care is productive right now.",
                priority: .medium,
                emotion: .calming,
                category: .health,
                isAIGenerated: true
            )
        case .creative:
            return Task(
                title: "Brainstorm new ideas",
                description: "🎨 Channel your creativity into idea generation. Set a 20-minute timer and aim for quantity over quality - let your mind flow freely.",
                priority: .medium,
                emotion: .creative,
                category: .creative,
                isAIGenerated: true
            )
        case .tired:
            return Task(
                title: "Simple administrative task",
                description: "💼 Low-energy but productive work. Try organizing emails, filing documents, or updating your calendar - easy wins that build momentum.",
                priority: .low,
                emotion: .routine,
                category: .personal,
                isAIGenerated: true
            )
        }
    }
    
    private func acceptRecommendation(_ task: Task) {
        // Add the recommended task with achievement animation
        taskManager.addTaskOptimistically(task)
        HapticManager.shared.taskAdded()
        dismissRecommendation()
    }
    
    private func dismissRecommendation() {
        withAnimation(.easeOut(duration: 0.3)) {
            showRecommendation = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            recommendedTask = nil
        }
    }
}

// MARK: - Focus Task Card Component (User & AI Tasks with Dynamic Outlines)

struct FocusTaskCard: View {
    let task: Task
    let isAIGenerated: Bool
    let onToggleComplete: () -> Void
    let onTap: () -> Void
    
    // Computed properties for cleaner conditional logic
    private var strokeGradient: LinearGradient {
        if task.isAIGenerated {
            return LinearGradient(
                colors: [.red, .orange, .yellow, .green, .blue, .purple, .pink],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [.black, .black],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private var strokeOpacity: Double {
        task.isAIGenerated ? 0.8 : 1.0
    }

    var body: some View {
        HStack(spacing: 12) {
            // Completion button
            Button(action: onToggleComplete) {
                Circle()
                    .stroke(task.isAIGenerated ? Color.purple : Color.black, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .background(
                        Circle()
                            .fill(task.isCompleted ? (task.isAIGenerated ? Color.purple : Color.black) : Color.clear)
                    )
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(task.isCompleted ? 1 : 0)
                    )
            }
            .buttonStyle(PlainButtonStyle())

            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .strikethrough(task.isCompleted)
                    .opacity(task.isCompleted ? 0.6 : 1.0)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 6) {
                    // Left side: Mood/Emotion
                    HStack(spacing: 4) {
                        Circle()
                            .fill(task.priority.color)
                            .frame(width: 6, height: 6)
                        Text(task.emotion.displayName)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    // Center: Auto-applied tags
                    HStack(spacing: 3) {
                        if task.isAIGenerated {
                            Text("AI")
                                .font(.caption2)
                                .foregroundColor(.purple.opacity(0.9))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.purple.opacity(0.2))
                                )
                        }
                        if task.category != .personal {
                            Text(task.category.rawValue.capitalized)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.white.opacity(0.1))
                                )
                        }
                    }
                    Spacer()
                    // Right side: Reminder info
                    if let reminder = task.reminderAt {
                        HStack(spacing: 2) {
                            Image(systemName: "bell.fill")
                                .font(.caption2)
                                .foregroundColor(.orange.opacity(0.8))
                            Text(formatReminderTime(reminder))
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(strokeGradient.opacity(strokeOpacity), lineWidth: 1.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    private func formatReminderTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "d/M" // Australian format
        }
        return formatter.string(from: date)
    }
}

// MARK: - Focus AI Task Card Component (AI Task Suggestions - Rainbow Outline)

struct FocusAITaskCard: View {
    let recommendation: AITaskRecommendation
    let onAdd: () -> Void
    let onDismiss: () -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                // AI Icon - smaller
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                    .font(.caption)
                    .frame(width: 16, height: 16)
                
                // Content - more compact
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Description with expandable view
                    Text(recommendation.description)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(isExpanded ? nil : 2)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpanded.toggle()
                            }
                        }
                    
                    // Show "tap to expand" hint if text is truncated
                    if !isExpanded && recommendation.description.count > 80 {
                        Text("tap to read more...")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                            .italic()
                    }
                    
                    // Bottom row - more compact
                    HStack(spacing: 6) {
                        // Priority dot
                        Circle()
                            .fill(recommendation.priority.color)
                            .frame(width: 4, height: 4)
                        
                        Text(recommendation.emotion.displayName)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                        
                        // Estimated time
                        Text("\(recommendation.estimatedDuration)min")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                // Action buttons - smaller and closer
                HStack(spacing: 4) {
                    Button(action: {
                        HapticManager.shared.buttonPressed()
                        onAdd()
                    }) {
                        Image(systemName: "plus")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(
                                Circle()
                                    .fill(.green.opacity(0.3))
                            )
                    }
                    
                    Button(action: {
                        HapticManager.shared.buttonPressed()
                        onDismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 22, height: 22)
                            .background(
                                Circle()
                                    .fill(.gray.opacity(0.3))
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        colors: [.red, .orange, .yellow, .green, .blue, .purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}

// MARK: - Flowing Rainbow Border Component

struct FlowingRainbowBorder: View {
    let cornerRadius: CGFloat
    @State private var rotation: Double = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        .red, .orange, .yellow, .green, .blue, .purple, .pink, .red
                    ]),
                    center: .center,
                    angle: .degrees(rotation)
                ),
                lineWidth: 2
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 2.0)
                        .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}
