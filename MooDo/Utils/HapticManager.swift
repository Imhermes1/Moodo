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
}
