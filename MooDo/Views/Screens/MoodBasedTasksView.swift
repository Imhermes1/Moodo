//
//  MoodBasedTasksView.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - Mood-Based Smart Tasks View (Main Screen)

struct MoodBasedTasksView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodManager: MoodManager
    let onAddTask: () -> Void
    let onTaskTap: ((Task) -> Void)?
    let screenSize: CGSize
    @State private var smartRecommendations: [Task] = []
    @State private var isRefreshing = false
    @StateObject private var smartTaskSuggestions = SmartTaskSuggestions()
    
    // New recommendation states
    @State private var recommendedTask: Task?
    @State private var showRecommendation = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Smart Tasks Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Smart Tasks")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.purple)
                                .font(.caption)
                            
                            Text("Top \(smartRecommendations.count) recommendations based on deadlines and your mood")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // Refresh smart tasks button
                        Button(action: refreshSmartTasks) {
                            Image(systemName: isRefreshing ? "arrow.clockwise" : "brain.head.profile")
                                .foregroundColor(.white)
                                .font(.title3)
                                .fontWeight(.medium)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(.purple.opacity(0.3))
                                        .overlay(
                                            Circle()
                                                .stroke(.purple.opacity(0.5), lineWidth: 1)
                                        )
                                )
                                .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                                .animation(.linear(duration: 1).repeatCount(isRefreshing ? .max : 1, autoreverses: false), value: isRefreshing)
                        }
                        
                        // Add task button with recommendation trigger
                        Button(action: {
                            onAddTask()
                            // Generate recommendation after user adds a task
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                generateRecommendationAfterAdd()
                            }
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.title3)
                                .fontWeight(.medium)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(.green.opacity(0.3))
                                        .overlay(
                                            Circle()
                                                .stroke(.green.opacity(0.5), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
                
                // Recommendation banner (new)
                if let recommended = recommendedTask, showRecommendation {
                    RecommendationBanner(
                        task: recommended,
                        onAccept: {
                            acceptRecommendation(recommended)
                        },
                        onDismiss: {
                            dismissRecommendation()
                        }
                    )
                    .transition(.slide)
                }
                
                // Mood insights
                moodInsightsSection
            }
            
            // Smart task recommendations
            if smartRecommendations.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(smartRecommendations) { task in
                        SmartTaskCard(
                            task: task,
                            onToggleComplete: {
                                taskManager.toggleTaskCompletion(task)
                                refreshSmartTasks()
                            },
                            onTap: {
                                onTaskTap?(task)
                            }
                        )
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
                                .white.opacity(0.6),
                                .white.opacity(0.2),
                                .white.opacity(0.05),
                                .white.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                
                // Inner stroke for depth
                RoundedRectangle(cornerRadius: 19)
                    .strokeBorder(
                        .white.opacity(0.1),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
        .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            refreshSmartTasks()
        }
        .onChange(of: moodManager.currentMood) { 
            print("🔄 MoodBasedTasksView: MoodManager currentMood changed to: \(moodManager.currentMood)")
            refreshSmartTasks() 
        }
        .onChange(of: taskManager.tasks) { 
            print("🔄 MoodBasedTasksView: TaskManager tasks changed, count: \(taskManager.tasks.count)")
            refreshSmartTasks() 
        }
    }
    
    // MARK: - Computed Properties
    
    private var currentMood: MoodType {
        moodManager.latestMoodEntry?.mood ?? .energized
    }
    
    // MARK: - Subviews
    
    private var moodInsightsSection: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .foregroundColor(.purple)
                .font(.caption)
            
            Text("Smart recommendations from your \(taskManager.tasks.count) tasks")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            if !smartRecommendations.isEmpty {
                Text("\(smartRecommendations.filter { !$0.isCompleted }.count) remaining")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.orange.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.title3)
                    .foregroundColor(.purple.opacity(0.7))
                
                Text(taskManager.tasks.isEmpty ? "No tasks yet" : "No recommendations right now")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Button(action: onAddTask) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("Add Task")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.green.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(.green.opacity(0.5), lineWidth: 1)
                            )
                    )
                }
            }
            
            if taskManager.tasks.isEmpty {
                Text("Add some tasks and I'll recommend the best ones based on deadlines and your mood!")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                description: "Your energy is high - perfect for complex work",
                priority: .high,
                emotion: .energizing
            )
        case .calm:
            return Task(
                title: "Organize your workspace",
                description: "Use this peaceful state for tidying up",
                priority: .medium,
                emotion: .routine
            )
        case .focused:
            return Task(
                title: "Deep work session",
                description: "Ideal time for concentrated tasks",
                priority: .high,
                emotion: .focused
            )
        case .stressed:
            return Task(
                title: "Take a mindful break",
                description: "Step back and recharge",
                priority: .medium,
                emotion: .calming
            )
        case .creative:
            return Task(
                title: "Brainstorm new ideas",
                description: "Channel your creativity",
                priority: .medium,
                emotion: .creative
            )
        case .tired:
            return Task(
                title: "Simple administrative task",
                description: "Low-energy but productive",
                priority: .low,
                emotion: .routine
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

// MARK: - Smart Task Card Component

struct SmartTaskCard: View {
    let task: Task
    let onToggleComplete: () -> Void
    let onTap: () -> Void
    @State private var glowEffect: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion button
            Button(action: onToggleComplete) {
                ZStack {
                    Circle()
                        .stroke(task.emotion.color, lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .opacity(0.4)
                        )
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(task.emotion.color)
                    }
                }
            }
            
            // Tappable task content
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .strikethrough(task.isCompleted)
                        .opacity(task.isCompleted ? 0.6 : 1.0)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 8) {
                        // Emotion badge
                        HStack(spacing: 4) {
                            Image(systemName: task.emotion.icon)
                                .font(.caption2)
                            Text(task.emotion.displayName)
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(task.emotion.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(task.emotion.color.opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(task.emotion.color.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // Priority badge
                        Text(task.priority.displayName.prefix(1))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(task.priority.color)
                            .frame(width: 16, height: 16)
                            .background(
                                Circle()
                                    .fill(task.priority.color.opacity(0.15))
                                    .overlay(
                                        Circle()
                                            .stroke(task.priority.color.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        
                        Spacer()
                        
                        // AI optimized badge
                        HStack(spacing: 4) {
                            Image(systemName: "brain.head.profile")
                                .font(.caption2)
                                .foregroundColor(.purple)
                            Text("Smart")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.purple)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(.purple.opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(.purple.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(glowEffect ? 0.6 : 0.4),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(task.isCompleted ? 0.98 : 1.0)
        .opacity(task.isCompleted ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowEffect.toggle()
            }
        }
    }
}

// MARK: - Recommendation Banner Component

struct RecommendationBanner: View {
    let task: Task
    let onAccept: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text("Suggested for you")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.yellow)
                }
                
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                if let description = task.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button("Add", action: {
                    HapticManager.shared.buttonPressed()
                    onAccept()
                })
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.green.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(.green.opacity(0.5), lineWidth: 1)
                            )
                    )
                
                Button(action: {
                    HapticManager.shared.buttonPressed()
                    onDismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.yellow.opacity(0.3), lineWidth: 1)
                )
        )
    }
} 