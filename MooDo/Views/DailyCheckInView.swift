//
//  DailyCheckInView.swift
//  Moodo
//
//  Created by Luke Fornieri on 29/7/2025.
//

import SwiftUI
import Speech
import AVFoundation

struct DailyCheckInView: View {
    @ObservedObject var moodManager: MoodManager
    @State private var checkInText = ""
    @State private var isRecording = false
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var showInsights = false
    @State private var checkInMode: CheckInMode = .text
    @Environment(\.dismiss) private var dismiss
    
    enum CheckInMode {
        case text, voice
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Daily Check-In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("How was your day? Share your thoughts and feelings")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // Mode Selector
                Picker("Input Mode", selection: $checkInMode) {
                    Text("Type").tag(CheckInMode.text)
                    Text("Voice").tag(CheckInMode.voice)
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Input Section
                if checkInMode == .text {
                    textInputSection
                } else {
                    voiceInputSection
                }
                
                // Mood Insights Preview
                if !checkInText.isEmpty && showInsights {
                    insightsSection
                }
                
                Spacer()
                
                // Submit Button
                Button(action: submitCheckIn) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Complete Check-In")
                    }
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(checkInText.isEmpty)
                .opacity(checkInText.isEmpty ? 0.6 : 1.0)
            }
            .padding(20)
            .background(UniversalBackground())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { 
                        HapticManager.shared.buttonPressed()
                        dismiss() 
                    }
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            requestSpeechPermission()
        }
    }
    
    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Share your thoughts")
                .font(.headline)
                .foregroundColor(.white)
            
            TextEditor(text: $checkInText)
                .frame(minHeight: 120)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .foregroundColor(.white)
                .onChange(of: checkInText) {
                    analyzeTextForInsights()
                }
        }
    }
    
    private var voiceInputSection: some View {
        VStack(spacing: 16) {
            Text("Tap to record your thoughts")
                .font(.headline)
                .foregroundColor(.white)
            
            Button(action: toggleRecording) {
                VStack(spacing: 12) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(isRecording ? .red : .blue)
                        .scaleEffect(isRecording ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isRecording)
                    
                    Text(isRecording ? "Recording..." : "Tap to Record")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 140, height: 140)
            .background(
                Circle()
                    .fill(.ultraThinMaterial.opacity(0.3))
                    .overlay(
                        Circle()
                            .stroke(isRecording ? .red.opacity(0.5) : .blue.opacity(0.5), lineWidth: 2)
                    )
            )
            
            if !checkInText.isEmpty {
                ScrollView {
                    Text(checkInText)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial.opacity(0.2))
                        )
                }
                .frame(maxHeight: 100)
            }
        }
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                Text("Mood Insights")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                InsightRow(
                    icon: "heart.fill",
                    title: "Detected Mood",
                    value: analyzeMoodFromText(),
                    color: .pink
                )
                
                InsightRow(
                    icon: "chart.bar.fill",
                    title: "Sentiment",
                    value: analyzeSentiment(),
                    color: .blue
                )
                
                InsightRow(
                    icon: "lightbulb.fill",
                    title: "Suggestion",
                    value: generateSuggestion(),
                    color: .yellow
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Speech Recognition Methods
    
    private func requestSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                // Handle permission status
            }
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else { return }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.checkInText = result.bestTranscription.formattedString
                }
            }
            
            if error != nil {
                self.stopRecording()
            }
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        
        isRecording = true
        HapticManager.shared.voiceRecordingStarted()
    }
    
    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isRecording = false
        HapticManager.shared.voiceRecordingStopped()
    }
    
    // MARK: - Analysis Methods
    
    private func analyzeTextForInsights() {
        showInsights = !checkInText.isEmpty && checkInText.count > 20
    }
    
    private func analyzeMoodFromText() -> String {
        let text = checkInText.lowercased()
        
        if text.contains("happy") || text.contains("good") || text.contains("great") {
            return "Positive"
        } else if text.contains("tired") || text.contains("exhausted") {
            return "Tired"
        } else if text.contains("stressed") || text.contains("overwhelmed") {
            return "Stressed"
        } else if text.contains("calm") || text.contains("peaceful") {
            return "Calm"
        } else if text.contains("creative") || text.contains("inspired") {
            return "Creative"
        }
        
        return "Neutral"
    }
    
    private func analyzeSentiment() -> String {
        let positiveWords = ["good", "great", "happy", "awesome", "wonderful", "fantastic"]
        let negativeWords = ["bad", "terrible", "awful", "stressed", "sad", "angry"]
        
        let text = checkInText.lowercased()
        let positiveCount = positiveWords.filter { text.contains($0) }.count
        let negativeCount = negativeWords.filter { text.contains($0) }.count
        
        if positiveCount > negativeCount {
            return "Positive"
        } else if negativeCount > positiveCount {
            return "Negative"
        } else {
            return "Neutral"
        }
    }
    
    private func generateSuggestion() -> String {
        let mood = analyzeMoodFromText().lowercased()
        
        switch mood {
        case "positive":
            return "Great energy! Perfect time for challenging tasks"
        case "stressed":
            return "Take some time for self-care and relaxation"
        case "tired":
            return "Consider lighter tasks and early rest"
        case "creative":
            return "Channel this creativity into brainstorming"
        case "calm":
            return "Ideal time for focused, detail-oriented work"
        default:
            return "Balance your tasks based on your energy level"
        }
    }
    
    private func submitCheckIn() {
        // Create mood entry based on analysis
        let detectedMood = getMoodTypeFromAnalysis()
        
        // Add mood entry
        moodManager.addMoodEntry(MoodEntry(
            mood: detectedMood,
            timestamp: Date()
        ))
        
        // Success animation and feedback
        HapticManager.shared.achievementUnlocked()
        
        dismiss()
    }
    
    private func getMoodTypeFromAnalysis() -> MoodType {
        let analysis = analyzeMoodFromText().lowercased()
        
        switch analysis {
        case "positive": return .energized
        case "stressed": return .stressed
        case "tired": return .tired
        case "creative": return .creative
        case "calm": return .calm
        default: return .focused
        }
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

