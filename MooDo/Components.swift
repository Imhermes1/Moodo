//
//  Components.swift
//  Moodo
//
//  Created by Luke Fornieri on 18/7/2025.
//

import SwiftUI

// MARK: - MoodLens Mood Check-in Component







// MARK: - Wellness Prompt Component

struct WellnessPromptView: View {
    @State private var currentPrompt = "What's one thing you're grateful for today?"
    
    let prompts = [
        "What's one thing you're grateful for today?",
        "How can you be kinder to yourself today?",
        "What's a small win you had recently?",
        "What would make today feel successful?",
        "How are you taking care of yourself today?"
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Text("Wellness Prompt")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: changePrompt) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                }
            }
            
            Text(currentPrompt)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private func changePrompt() {
        // Remove animation for better performance
        currentPrompt = prompts.randomElement() ?? currentPrompt
    }
}

// MARK: - Quick Stats Component

struct QuickStatsView: View {
    let tasks: [Task]
    let moodEntries: [MoodEntry]
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var totalTasksCount: Int {
        tasks.count
    }
    
    var averageMood: Double {
        guard !moodEntries.isEmpty else { return 0 }
        let moodValues = moodEntries.map { moodValue(for: $0.mood) }
        return Double(moodValues.reduce(0, +)) / Double(moodEntries.count)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Quick Stats")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Tasks",
                    value: "\(completedTasksCount)/\(totalTasksCount)",
                    subtitle: "Completed",
                    color: Color(red: 0.22, green: 0.56, blue: 0.94) // mood-blue
                )
                
                StatCard(
                    title: "Mood",
                    value: String(format: "%.1f", averageMood),
                    subtitle: "Average",
                    color: Color(red: 0.22, green: 0.69, blue: 0.42) // mood-green
                )
            }
        }
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private func moodValue(for mood: MoodType) -> Int {
        switch mood {
        case .energized: return 5
        case .calm: return 4
        case .focused: return 3
        case .stressed: return 2
        case .creative: return 4
        case .tired: return 2
        case .anxious: return 2
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(color.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Voice Check-in Components

struct VoiceCheckinView: View {
    let tasks: [Task]
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    @State private var transcript = ""
    @StateObject private var voiceManager = VoiceCheckinManager()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "mic")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text("Voice Check-in")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Recording button
                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? .red : .white.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .foregroundColor(isRecording ? .white : .white)
                            .font(.title)
                    }
                }
                
                // Recording time
                if isRecording {
                    Text(timeString(from: recordingTime))
                        .font(.title2)
                        .foregroundColor(.white)
                        .onReceive(timer) { _ in
                            recordingTime += 1
                        }
                }
                
                // Instructions
                Text(isRecording ? "Tap to stop recording" : "Tap to start recording")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Sample transcript
            if !transcript.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transcript:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(transcript)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private func toggleRecording() {
        isRecording.toggle()
        
        if isRecording {
            recordingTime = 0
            transcript = ""
        } else {
            // Simulate transcript
            transcript = "I'm feeling good today. I completed my morning workout and I'm ready to tackle the day ahead."
            
            // Save voice check-in
            let checkin = VoiceCheckin(
                transcript: transcript,
                duration: recordingTime
            )
            voiceManager.addVoiceCheckin(checkin)
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct VoiceCheckinHistoryView: View {
    @StateObject private var voiceManager = VoiceCheckinManager()
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Check-in History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if voiceManager.voiceCheckins.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "message.circle")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 64, weight: .light))
                    
                    VStack(spacing: 8) {
                        Text("No voice check-ins yet")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Start your first daily check-in to see your conversation history here")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(voiceManager.voiceCheckins.prefix(3)) { checkin in
                        VoiceCheckinRowView(checkin: checkin)
                    }
                }
            }
        }
        .padding(28)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct VoiceCheckinRowView: View {
    let checkin: VoiceCheckin
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(checkin.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("\(Int(checkin.duration))s")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text(checkin.transcript)
                .font(.body)
                .foregroundColor(.white)
                .lineLimit(3)
        }
        .padding(16)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Mood History Component

struct MoodHistoryView: View {
    let moodEntries: [MoodEntry]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.mint)
                    .font(.title2)
                
                Text("Mood History")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if moodEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("No mood entries yet")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(moodEntries.prefix(5)) { entry in
                        MoodEntryRowView(entry: entry)
                    }
                }
            }
        }
        .padding(24)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct MoodEntryRowView: View {
    let entry: MoodEntry
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.mood.icon)
                .foregroundColor(entry.mood.color)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.mood.displayName)
                    .font(.body)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}



// In SmartInputView, wrap main VStack in ScrollView for better fit
struct SmartInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var naturalLanguageInput: String
    @Binding var processedTask: ProcessedTask?
    @StateObject var voiceRecognition: VoiceRecognitionManager
    @StateObject var nlpProcessor: NaturalLanguageProcessor
    @State private var textInput = ""
    @State private var showingVoiceInput = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    // Header
                    VStack(spacing: 6) {
                        Image(systemName: "brain.head.profile")
                            .font(.title)
                            .foregroundColor(.purple)
                        
                        Text("Smart Task Creation")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Describe your task naturally and let AI help you organize it")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity)
                    
                    // Input methods
                    VStack(spacing: 10) {
                        // Text input
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Type your task:")
                                .font(.subheadline)
                            
                            TextField("e.g., 'Remind me to call mom tomorrow at 3pm'", text: $textInput, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(2...4)
                                .font(.footnote)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Voice input
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Or use voice:")
                                .font(.subheadline)
                            
                            Button(action: {
                                if voiceRecognition.isRecording {
                                    voiceRecognition.stopRecording()
                                } else {
                                    voiceRecognition.startRecording()
                                }
                            }) {
                                HStack {
                                    Image(systemName: voiceRecognition.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                        .font(.title3)
                                    Text(voiceRecognition.isRecording ? "Stop Recording" : "Start Voice Input")
                                        .font(.footnote)
                                }
                                .foregroundColor(voiceRecognition.isRecording ? .red : .blue)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(8)
                            }
                            .disabled(!voiceRecognition.isAuthorized)
                            
                            if !voiceRecognition.transcript.isEmpty {
                                Text("Transcript: \(voiceRecognition.transcript)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(6)
                                    .background(Color.gray.opacity(0.08))
                                    .cornerRadius(6)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity)
                    
                    // Process button
                    Button(action: processInput) {
                        HStack {
                            if nlpProcessor.isProcessing {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text(nlpProcessor.isProcessing ? "Processing..." : "Process with AI")
                                .font(.footnote)
                        }
                        .foregroundColor(.white)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(8)
                    }
                    .disabled(textInput.isEmpty && voiceRecognition.transcript.isEmpty || nlpProcessor.isProcessing)
                    .padding(.horizontal, 4)
                    
                    // Processing results
                    if !nlpProcessor.processedText.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("AI Analysis:")
                                    .font(.subheadline)
                                
                                Text(nlpProcessor.processedText)
                                    .font(.footnote)
                                    .padding(6)
                                    .background(Color.gray.opacity(0.08))
                                    .cornerRadius(6)
                            }
                            .padding(.horizontal, 4)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Spacer(minLength: 10)
                }
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Smart Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Use This") {
                        useProcessedTask()
                    }
                    .disabled(processedTask == nil)
                }
            }
        }
    }
    
    private func processInput() {
        let input = textInput.isEmpty ? voiceRecognition.transcript : textInput
        guard !input.isEmpty else { return }
        
        naturalLanguageInput = input
        let task = nlpProcessor.processNaturalLanguage(input)
        processedTask = task
    }
    
    private func useProcessedTask() {
        dismiss()
    }
}

// MARK: - Smart Insights Views

struct SmartInsightsView: View {
    let insights: [Insight]
    
    var body: some View {
        if !insights.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                // Header with summary
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.purple)
                            .font(.title3)
                        Text("Smart Insights")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(insights.count) insights")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    
                    Text("AI-powered analysis of your patterns and behaviors")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Detailed insights with more content
                LazyVStack(spacing: 16) {
                    ForEach(insights) { insight in
                        EnhancedInsightCardView(insight: insight)
                    }
                }
                
                // Summary section
                VStack(alignment: .leading, spacing: 8) {
                    Text("📊 Summary")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 16) {
                        InsightSummaryItem(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Trend",
                            value: "Positive",
                            color: .green
                        )
                        
                        InsightSummaryItem(
                            icon: "clock",
                            title: "Frequency",
                            value: "Daily",
                            color: .blue
                        )
                        
                        InsightSummaryItem(
                            icon: "target",
                            title: "Accuracy",
                            value: "92%",
                            color: .orange
                        )
                    }
                }
                .padding(16)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .opacity(0.3)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.4),
                                        .white.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
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
        }
    }
}

struct InsightCardView: View {
    let insight: Insight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: insight.icon)
                    .foregroundColor(insight.color)
                    .font(.title3)
                
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(insight.type.displayName)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(insight.color.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            Text(insight.description)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("💡 Recommendation:")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(insight.recommendation)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(12)
        .background(
            GlassPanelBackground()
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EnhancedInsightCardView: View {
    let insight: Insight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon and type
            HStack {
                Image(systemName: insight.icon)
                    .foregroundColor(insight.color)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(insight.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(insight.type.displayName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Confidence indicator
                VStack(spacing: 2) {
                    Text("92%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Confidence")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Description
            Text(insight.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(nil)
            
            // Key metrics
            HStack(spacing: 16) {
                InsightMetricItem(
                    icon: "chart.bar.fill",
                    title: "Impact",
                    value: "High",
                    color: .orange
                )
                
                InsightMetricItem(
                    icon: "clock.fill",
                    title: "Duration",
                    value: "2 weeks",
                    color: .blue
                )
                
                InsightMetricItem(
                    icon: "arrow.up.right",
                    title: "Trend",
                    value: "Improving",
                    color: .green
                )
            }
            
            // Recommendation section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("Recommendation")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                Text(insight.recommendation)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                                .opacity(0.3)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.4),
                                            .white.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "bookmark")
                            .font(.caption)
                        Text("Save")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.3))
                    .clipShape(Capsule())
                }
                
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                        Text("Share")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.3))
                    .clipShape(Capsule())
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            ZStack {
                // Base glass layer with 3D depth
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                
                // Inner highlight layer for 3D effect
                RoundedRectangle(cornerRadius: 16)
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
                RoundedRectangle(cornerRadius: 16)
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
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(
                        .white.opacity(0.1),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -0.5)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct InsightMetricItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct InsightSummaryItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}







struct SuggestionDetailItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SuggestionStatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

extension InsightType {
    var displayName: String {
        switch self {
        case .mood:
            return "Mood"
        case .productivity:
            return "Productivity"
        case .wellness:
            return "Wellness"
        }
    }
}

// MARK: - Simple Mood Insights

struct SimpleMoodInsightsView: View {
    let moodEntries: [MoodEntry]
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Mood Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            if moodEntries.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text("No mood data yet")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Start logging your mood to see insights")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                // Enhanced mood overview
                EnhancedMoodOverviewView(moodEntries: moodEntries)
                
                // Quick Stats
                QuickMoodStatsView(moodEntries: moodEntries)
                
                // Key Insight
                if let keyInsight = generateKeyInsight() {
                    KeyInsightView(insight: keyInsight)
                }

                // Task-Mood Insight
                if let taskInsight = generateTaskMoodInsight() {
                    TaskMoodInsightView(insight: taskInsight)
                }

                // Mood patterns
                MoodPatternsView(moodEntries: moodEntries)
                
                // Web App Button
                WebAppButtonView()
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
    }
    
    // MARK: - Helper Methods
    
    private func generateKeyInsight() -> String? {
        guard !moodEntries.isEmpty else { return nil }
        
        let recentEntries = Array(moodEntries.suffix(7)) // Last 7 entries
        let averageMood = recentEntries.map { $0.mood.numericValue }.reduce(0, +) / Double(recentEntries.count)
        
        if averageMood >= 7.0 {
            return "You've been feeling great lately! Keep up the positive energy."
        } else if averageMood >= 5.0 {
            return "Your mood has been steady. Try adding some variety to your routine."
        } else {
            return "You might be going through a rough patch. Remember, it's okay to take breaks."
        }
    }

    private func generateTaskMoodInsight() -> String? {
        let completedTasks = taskManager.getCompletedTasks().filter { $0.completedMood != nil }
        guard !completedTasks.isEmpty else { return nil }

        var counts: [TaskEmotion: [MoodType: Int]] = [:]
        for task in completedTasks {
            guard let mood = task.completedMood else { continue }
            counts[task.emotion, default: [:]][mood, default: 0] += 1
        }

        guard let (emotion, moodCounts) = counts.max(by: { lhs, rhs in
            lhs.value.values.reduce(0, +) < rhs.value.values.reduce(0, +)
        }), let (mood, _) = moodCounts.max(by: { $0.value < $1.value }) else { return nil }

        return "You feel \(mood.displayName.lowercased()) after \(emotion.displayName.lowercased()) tasks."
    }
}

struct EnhancedMoodOverviewView: View {
    let moodEntries: [MoodEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 Mood Overview")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                MoodOverviewItem(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Current",
                    value: String(format: "%.1f/10", currentMood),
                    color: .blue
                )
                
                MoodOverviewItem(
                    icon: "calendar",
                    title: "This Week",
                    value: String(format: "%.1f/10", weeklyAverage),
                    color: .green
                )
                
                MoodOverviewItem(
                    icon: "clock.arrow.circlepath",
                    title: "Trend",
                    value: trendText,
                    color: trendColor
                )
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
                
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.4),
                                .white.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var currentMood: Double {
        guard let latest = moodEntries.last else { return 0 }
        return latest.mood.numericValue
    }
    
    private var weeklyAverage: Double {
        let recentEntries = Array(moodEntries.suffix(7))
        guard !recentEntries.isEmpty else { return 0 }
        return recentEntries.map { $0.mood.numericValue }.reduce(0, +) / Double(recentEntries.count)
    }
    
    private var trendText: String {
        let recentEntries = Array(moodEntries.suffix(7))
        guard recentEntries.count >= 2 else { return "Stable" }
        
        let firstHalf = Array(recentEntries.prefix(recentEntries.count / 2))
        let secondHalf = Array(recentEntries.suffix(recentEntries.count / 2))
        
        let firstAvg = firstHalf.map { $0.mood.numericValue }.reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.map { $0.mood.numericValue }.reduce(0, +) / Double(secondHalf.count)
        
        if secondAvg > firstAvg + 0.5 {
            return "↗️ Up"
        } else if secondAvg < firstAvg - 0.5 {
            return "↘️ Down"
        } else {
            return "→ Stable"
        }
    }
    
    private var trendColor: Color {
        let recentEntries = Array(moodEntries.suffix(7))
        guard recentEntries.count >= 2 else { return .gray }
        
        let firstHalf = Array(recentEntries.prefix(recentEntries.count / 2))
        let secondHalf = Array(recentEntries.suffix(recentEntries.count / 2))
        
        let firstAvg = firstHalf.map { $0.mood.numericValue }.reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.map { $0.mood.numericValue }.reduce(0, +) / Double(secondHalf.count)
        
        if secondAvg > firstAvg + 0.5 {
            return .green
        } else if secondAvg < firstAvg - 0.5 {
            return .red
        } else {
            return .orange
        }
    }
}

struct MoodOverviewItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct MoodPatternsView: View {
    let moodEntries: [MoodEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔄 Mood Patterns")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                MoodPatternItem(
                    icon: "sun.max.fill",
                    title: "Best Time",
                    value: "Morning (8-10 AM)",
                    color: .yellow
                )
                
                MoodPatternItem(
                    icon: "moon.fill",
                    title: "Lowest Time",
                    value: "Evening (6-8 PM)",
                    color: .purple
                )
                
                MoodPatternItem(
                    icon: "calendar.badge.clock",
                    title: "Most Consistent",
                    value: "Weekends",
                    color: .green
                )
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
                
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.4),
                                .white.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct MoodPatternItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct QuickMoodStatsView: View {
    let moodEntries: [MoodEntry]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(weeklyAverage, specifier: "%.1f")/10")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Good Days")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(goodDaysCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            // Simple trend indicator
            HStack {
                Image(systemName: trendIcon)
                    .foregroundColor(trendColor)
                    .font(.caption)
                Text(trendText)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.1))
        )
    }
    
    private var weeklyAverage: Double {
        let recentEntries = Array(moodEntries.suffix(7))
        guard !recentEntries.isEmpty else { return 0 }
        return recentEntries.map { $0.mood.numericValue }.reduce(0, +) / Double(recentEntries.count)
    }
    
    private var goodDaysCount: Int {
        let recentEntries = Array(moodEntries.suffix(7))
        return recentEntries.filter { $0.mood.numericValue >= 7.0 }.count
    }
    
    private var trendIcon: String {
        let recentEntries = Array(moodEntries.suffix(7))
        guard recentEntries.count >= 2 else { return "minus" }
        
        let firstHalf = Array(recentEntries.prefix(recentEntries.count / 2))
        let secondHalf = Array(recentEntries.suffix(recentEntries.count / 2))
        
        let firstAvg = firstHalf.map { $0.mood.numericValue }.reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.map { $0.mood.numericValue }.reduce(0, +) / Double(secondHalf.count)
        
        if secondAvg > firstAvg + 0.5 {
            return "arrow.up"
        } else if secondAvg < firstAvg - 0.5 {
            return "arrow.down"
        } else {
            return "minus"
        }
    }
    
    private var trendColor: Color {
        switch trendIcon {
        case "arrow.up": return .green
        case "arrow.down": return .orange
        default: return .gray
        }
    }
    
    private var trendText: String {
        switch trendIcon {
        case "arrow.up": return "Mood improving"
        case "arrow.down": return "Mood declining"
        default: return "Mood stable"
        }
    }
}

struct KeyInsightView: View {
    let insight: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.title3)
            
            Text(insight)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.yellow.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.yellow.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct TaskMoodInsightView: View {
    let insight: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "face.smiling")
                .foregroundColor(.green)
                .font(.title3)

            Text(insight)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.green.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.green.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct WebAppButtonView: View {
    var body: some View {
        Button(action: {
            // TODO: Open web app URL
            print("Opening web app for detailed analytics...")
        }) {
            HStack(spacing: 8) {
                Image(systemName: "globe")
                    .font(.caption)
                    .fontWeight(.medium)
                Text("View Detailed Analytics")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.blue.opacity(0.5), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Body Scan Component (matches web app)

struct BodyScanView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.pink)
                    .font(.title2)
                    .scaleEffect(1.0)
                    // .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Body Scan")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Connect with yourself")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text("Starting from your toes, notice how each part of your body feels right now.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                    Text("Start Body Scan")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.3)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
        .background(
            ZStack {
                // Base glass layer with 3D depth
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                
                // Inner highlight layer for 3D effect
                RoundedRectangle(cornerRadius: 24)
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
                RoundedRectangle(cornerRadius: 24)
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
                RoundedRectangle(cornerRadius: 23)
                    .strokeBorder(
                        .white.opacity(0.1),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
        .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear {
            // Disable animation for better performance
            // isAnimating = true
        }
    }
}

// MARK: - Today's Progress Component (matches web app with animated counters)

struct TodaysProgressView: View {
    let tasks: [Task]
    let moodEntries: [MoodEntry]
    let thoughts: [Thought]? // Optional - for backward compatibility
    
    // Remove animated counters for better performance
    // @State private var animatedTasksCount: Int = 0
    // @State private var animatedMindfulCount: Int = 0
    // @State private var animatedMoodCount: Int = 0
    // @State private var animatedWellnessScore: Int = 0
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var thoughtsCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return thoughts?.filter { 
            $0.dateCreated >= today && $0.dateCreated < tomorrow 
        }.count ?? 0
    }
    
    var moodCheckinsCount: Int {
        moodEntries.count
    }
    
    var wellnessScore: Int {
        0 // Mock data matching web app
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Today's Progress")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ProgressCard(
                    title: "Tasks Done",
                    value: completedTasksCount,
                    color: Color.green,
                    isPercentage: false
                )
                
                ProgressCard(
                    title: "Thoughts Captured", 
                    value: thoughtsCount,
                    color: Color.purple,
                    isPercentage: false
                )
                
                ProgressCard(
                    title: "Mood Check-ins",
                    value: moodCheckinsCount,
                    color: Color.blue,
                    isPercentage: false
                )
                
                ProgressCard(
                    title: "Wellness Score",
                    value: wellnessScore,
                    color: Color.orange,
                    isPercentage: true
                )
            }
        }
        .padding(24)
        .background(
            ZStack {
                // Base glass layer with 3D depth
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                
                // Inner highlight layer for 3D effect
                RoundedRectangle(cornerRadius: 24)
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
                RoundedRectangle(cornerRadius: 24)
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
                RoundedRectangle(cornerRadius: 23)
                    .strokeBorder(
                        .white.opacity(0.1),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
        .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear {
            // Removed animation for better performance
        }
    }
    
    // Removed animateCounters function for better performance
}

struct ProgressCard: View {
    let title: String
    let value: Int
    let color: Color
    let isPercentage: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text("\(value)\(isPercentage ? "%" : "")")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            ZStack {
                // Base glass layer for progress cards
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.7)
                
                // Color overlay with glass effect
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.15))
                
                // Inner highlight for 3D effect
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.2),
                                .white.opacity(0.06),
                                .clear,
                                .black.opacity(0.03)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Glass border
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.4),
                                .white.opacity(0.15),
                                .white.opacity(0.05),
                                .white.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        .shadow(color: .white.opacity(0.08), radius: 1, x: 0, y: -0.5)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Mindful Moment Component (matches web app)

struct MindfulMomentView: View {
    @State private var breathingScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mindful Moment")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Take a gentle break")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            
            Text("Take three deep breaths and notice the sounds around you. This moment is yours to enjoy.")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                        .scaleEffect(1.0)
                        // .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: breathingScale)
                    Text("Start 2-min session")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.purple.opacity(0.3),
                            Color.pink.opacity(0.3)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
        .background(
            ZStack {
                // Base glass layer with 3D depth
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                
                // Inner highlight layer for 3D effect
                RoundedRectangle(cornerRadius: 24)
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
                RoundedRectangle(cornerRadius: 24)
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
                RoundedRectangle(cornerRadius: 23)
                    .strokeBorder(
                        .white.opacity(0.1),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
        .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear {
            breathingScale = 1.2
        }
    }
}

// MARK: - Daily Voice Check-in Component (matches web app)

struct DailyVoiceCheckinView: View {
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon and title
            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 64, weight: .medium))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .scaleEffect(pulseScale)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseScale)
                    )
                
                VStack(spacing: 8) {
                    Text("Daily Voice Check-in")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Start a 3-5 minute conversation with your AI therapist friend. Share how you're feeling and get personalized task recommendations.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }
            
            // Start button
            Button(action: {}) {
                HStack(spacing: 12) {
                    Image(systemName: "message.circle.fill")
                        .font(.title2)
                    Text("Start Daily Check-in")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.4),
                            Color.cyan.opacity(0.4)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .padding(32)
        .background(
            ZStack {
                // Base glass layer with 3D depth
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                
                // Inner highlight layer for 3D effect
                RoundedRectangle(cornerRadius: 24)
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
                RoundedRectangle(cornerRadius: 24)
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
                RoundedRectangle(cornerRadius: 23)
                    .strokeBorder(
                        .white.opacity(0.1),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
        .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear {
            pulseScale = 1.1
        }
    }
}

// MARK: - Mood History Detailed Component (matches web app)

struct MoodHistoryDetailedView: View {
    let moodEntries: [MoodEntry]
    @State private var selectedTimeframe: TimeFrame = .week
    
    enum TimeFrame: String, CaseIterable {
        case day = "Today"
        case week = "This Week"
        case month = "This Month"
    }
    
    var filteredEntries: [MoodEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeframe {
        case .day:
            let startOfDay = calendar.startOfDay(for: now)
            return moodEntries.filter { $0.timestamp >= startOfDay }
        case .week:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            return moodEntries.filter { $0.timestamp >= startOfWeek }
        case .month:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return moodEntries.filter { $0.timestamp >= startOfMonth }
        }
    }
    
    var dailyMoodSummary: [Date: [MoodEntry]] {
        let calendar = Calendar.current
        return Dictionary(grouping: filteredEntries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with timeframe selector
            HStack {
                Text("Mood History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Timeframe picker
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .scaleEffect(0.8)
                .frame(width: 200)
            }
            
            if filteredEntries.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("No mood entries yet")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Log your first mood to start tracking your emotional patterns")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(32)
            } else {
                // Mood timeline
                LazyVStack(spacing: 16) {
                    ForEach(Array(dailyMoodSummary.keys.sorted(by: >)), id: \.self) { date in
                        DailyMoodTimelineView(
                            date: date,
                            entries: dailyMoodSummary[date] ?? []
                        )
                    }
                }
                
                // Mood pattern summary
                if filteredEntries.count > 1 {
                    MoodPatternSummaryView(entries: filteredEntries)
                }
            }
        }
        .padding(24)
        .background(
            ZStack {
                // Base glass layer with 3D depth
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                
                // Inner highlight layer for 3D effect
                RoundedRectangle(cornerRadius: 24)
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
                RoundedRectangle(cornerRadius: 24)
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
                RoundedRectangle(cornerRadius: 23)
                    .strokeBorder(
                        .white.opacity(0.1),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
        .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: -1)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Daily Mood Timeline Component

struct DailyMoodTimelineView: View {
    let date: Date
    let entries: [MoodEntry]
    
    var body: some View {
        VStack(spacing: 12) {
            // Date header
            HStack {
                Text(formatDate(date))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(entries.count) entries")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Mood timeline
            VStack(spacing: 8) {
                ForEach(entries.sorted(by: { $0.timestamp < $1.timestamp })) { entry in
                    MoodTimelineEntryView(entry: entry)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Mood Timeline Entry Component

struct MoodTimelineEntryView: View {
    let entry: MoodEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Time
            Text(formatTime(entry.timestamp))
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 50, alignment: .leading)
            
            // Mood indicator
            Circle()
                .fill(entry.mood.color)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
            
            // Mood info
            HStack(spacing: 8) {
                Image(systemName: entry.mood.icon)
                    .font(.caption)
                    .foregroundColor(entry.mood.color)
                
                Text(entry.mood.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Mood Pattern Summary Component

struct MoodPatternSummaryView: View {
    let entries: [MoodEntry]
    
    var moodCounts: [MoodType: Int] {
        Dictionary(grouping: entries, by: { $0.mood })
            .mapValues { $0.count }
    }
    
    var dominantMood: MoodType? {
        moodCounts.max(by: { $0.value < $1.value })?.key
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Mood Pattern")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if let dominant = dominantMood {
                HStack(spacing: 16) {
                    // Dominant mood indicator
                    VStack(spacing: 8) {
                        Image(systemName: dominant.icon)
                            .font(.title2)
                            .foregroundColor(dominant.color)
                        
                        Text(dominant.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(dominant.color.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(dominant.color.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Stats
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Most frequent")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(moodCounts[dominant] ?? 0) times")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        let percentage = Int(Double(moodCounts[dominant] ?? 0) / Double(entries.count) * 100)
                        Text("\(percentage)%")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            // Mood distribution
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(MoodType.allCases, id: \.self) { mood in
                    if let count = moodCounts[mood], count > 0 {
                        VStack(spacing: 4) {
                            Text("\(count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text(mood.displayName)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(mood.color.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
// MARK: - Smart Suggestions View


struct TaskSuggestionCardView: View {
    let suggestion: TaskSuggestion
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Emotion icon
            Image(systemName: suggestion.emotion.icon)
                .foregroundColor(suggestion.emotion.color)
                .font(.title2)
                .frame(width: 32, height: 32)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(suggestion.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                
                // Tags
                HStack(spacing: 8) {
                    // Emotion tag
                    HStack(spacing: 4) {
                        Text(suggestion.emotion.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(suggestion.emotion.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(suggestion.emotion.color.opacity(0.2))
                    .clipShape(Capsule())
                    
                    // Priority tag
                    Text(suggestion.priority.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(suggestion.priority.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(suggestion.priority.color.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            // Add task button
            Button(action: {
                let task = Task(
                    title: suggestion.title,
                    description: suggestion.description,
                    priority: suggestion.priority,
                    emotion: suggestion.emotion
                )
                taskManager.addTask(task)
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}