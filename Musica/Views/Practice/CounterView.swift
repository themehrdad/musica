import SwiftUI

struct CounterView: View {
    let completed: Int
    let goal: Int

    private var goalReached: Bool { completed >= goal }

    var body: some View {
        VStack(spacing: 2) {
            if goalReached {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                    .transition(.scale.combined(with: .opacity))
            }
            Text("\(completed)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(goalReached ? .yellow : .primary)
                .contentTransition(.numericText())

            Text("of \(goal)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .animation(.spring(duration: 0.4), value: completed)
        .animation(.spring(duration: 0.4), value: goalReached)
    }
}
