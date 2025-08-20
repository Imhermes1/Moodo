import SwiftUI

// Thin glass-like border overlay for cards
struct GlassThinBorder: View {
    var cornerRadius: CGFloat = 12
    var lineWidth: CGFloat = 0.8

    var body: some View {
        ZStack {
            // Primary soft white gradient stroke
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.28),
                            Color.white.opacity(0.10),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: lineWidth
                )

            // Subtle outer glow for definition
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.06), lineWidth: 0.3)
                .blur(radius: 0.8)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    VStack(spacing: 20) {
        ZStack { Color.clear }
            .frame(height: 100)
            .background(ThoughtGlassBackground(cornerRadius: 12))
            .overlay(GlassThinBorder(cornerRadius: 12))

        ZStack { Color.clear }
            .frame(height: 140)
            .background(ThoughtGlassBackground(cornerRadius: 20))
            .overlay(GlassThinBorder(cornerRadius: 20))
    }
    .padding()
    .background(UniversalBackground())
}

