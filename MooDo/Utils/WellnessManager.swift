import Foundation
import UserNotifications

class WellnessManager {
    static let shared = WellnessManager()
    private init() {}

    private let actions = [
        "Take 5 deep breaths",
        "Stand up and stretch",
        "Recall something you're grateful for"
    ]

    func triggerMicroBreak() {
        let content = UNMutableNotificationContent()
        content.title = "Wellness Break"
        content.body = actions.randomElement() ?? "Take a short wellness break"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
