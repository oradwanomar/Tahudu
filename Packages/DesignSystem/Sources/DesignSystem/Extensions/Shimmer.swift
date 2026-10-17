import SwiftUI

public extension View {
    func shimmer() -> some View {
        modifier(DSShimmerModifier())
    }
}

private struct DSShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if !reduceMotion {
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.7), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 0.6)
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                        .animation(.linear(duration: 1.4).repeatForever(autoreverses: false), value: isAnimating)
                    }
                }
                .mask(content)
                .allowsHitTesting(false)
            )
            .onAppear {
                isAnimating = true
            }
    }
}
