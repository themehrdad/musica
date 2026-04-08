import SwiftUI

struct MicIndicatorView: View {
    let amplitude: Float
    let isListening: Bool

    private var normalizedAmp: CGFloat {
        CGFloat(min(amplitude * 5, 1.0))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 3)
                .scaleEffect(1 + normalizedAmp * 0.5)
                .opacity(Double(1 - normalizedAmp) * 0.6)
                .foregroundStyle(.blue)
                .animation(.easeOut(duration: 0.1), value: normalizedAmp)

            Circle()
                .fill(.blue.opacity(0.15))
                .frame(width: 64, height: 64)

            Image(systemName: isListening ? "mic.fill" : "mic.slash.fill")
                .font(.system(size: 28))
                .foregroundStyle(isListening ? .blue : .gray)
        }
        .frame(width: 80, height: 80)
    }
}
