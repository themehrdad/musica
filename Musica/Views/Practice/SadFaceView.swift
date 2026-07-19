import SwiftUI

struct SadFaceView: View {
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        Text("😢")
            .font(.system(size: 80))
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(x: shakeOffset)
            .onAppear {
                // Pop in with spring
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    scale = 1.2
                    opacity = 1
                }
                // Shake
                withAnimation(
                    .easeInOut(duration: 0.08)
                    .repeatCount(5, autoreverses: true)
                    .delay(0.4)
                ) {
                    shakeOffset = 10
                }
                // Settle to normal scale
                withAnimation(.easeOut(duration: 0.2).delay(0.85)) {
                    scale = 1.0
                    shakeOffset = 0
                }
            }
    }
}
