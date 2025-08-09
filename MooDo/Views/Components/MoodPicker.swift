import SwiftUI

struct MoodPicker: View {
    var onSelect: (MoodType) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("How did this task make you feel?")
                .font(.headline)
                .foregroundColor(.primary)

            HStack(spacing: 12) {
                ForEach(MoodType.allCases, id: \.self) { mood in
                    Button(action: {
                        onSelect(mood)
                        dismiss()
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: mood.icon)
                                .foregroundColor(mood.color)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(mood.color.opacity(0.2)))
                            Text(mood.displayName)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        .padding(6)
                    }
                }
            }
        }
        .padding(24)
    }
}

#Preview {
    MoodPicker { _ in }
}
