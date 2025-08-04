//
//  HapticManager.swift
//  Moodo
//
//  Created by Luke Fornieri on 29/7/2025.
//

import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare generators for faster response
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
    }
    
    func taskCompleted() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func taskAdded() {
        impactMedium.impactOccurred()
    }
    
    func moodSelected() {
        impactLight.impactOccurred()
    }
    
    func buttonPressed() {
        impactLight.impactOccurred()
    }
    
    func errorOccurred() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    func achievementUnlocked() {
        impactHeavy.impactOccurred()
    }
    
    func voiceRecordingStarted() {
        impactLight.impactOccurred()
    }
    
    func voiceRecordingStopped() {
        impactMedium.impactOccurred()
    }
    
    // Generic methods for new TasksView
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        @unknown default:
            impactMedium.impactOccurred()
        }
    }
    
    func success() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func selection() {
        impactLight.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
    }
}
