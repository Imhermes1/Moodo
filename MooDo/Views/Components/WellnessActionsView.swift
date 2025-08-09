//
//  WellnessActionsView.swift
//  Moodo
//
//  Created by OpenAI ChatGPT on 15/8/2025.
//

import SwiftUI

struct WellnessAction: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

struct WellnessActionsView: View {
    private let actions: [WellnessAction] = [
        WellnessAction(
            title: "Breathing Exercise",
            description: "Breathe in for 4 seconds, hold for 4, and exhale for 4. Repeat a few times."
        ),
        WellnessAction(
            title: "Quick Stretch",
            description: "Stand up and stretch your arms overhead for 30 seconds."
        ),
        WellnessAction(
            title: "Gratitude",
            description: "Think of one thing you're grateful for right now."
        )
    ]

    @State private var selectedAction: WellnessAction?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wellness Actions")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(actions) { action in
                        Button {
                            selectedAction = action
                        } label: {
                            Text(action.title)
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .alert(item: $selectedAction) { action in
            Alert(
                title: Text(action.title),
                message: Text(action.description),
                dismissButton: .default(Text("Done"))
            )
        }
    }
}

struct WellnessActionsView_Previews: PreviewProvider {
    static var previews: some View {
        WellnessActionsView()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

