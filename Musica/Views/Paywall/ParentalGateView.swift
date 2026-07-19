import SwiftUI

/// A small adult-check shown before any purchase UI, as App Review expects
/// in kids' apps: a multiplication question a young child can't answer.
struct ParentalGateView: View {
    let onPassed: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var a = Int.random(in: 6...9)
    @State private var b = Int.random(in: 3...9)
    @State private var answer = ""
    @State private var wrong = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.and.child.holdinghands")
                .font(.system(size: 44))
                .foregroundStyle(.purple)
            Text("Ask a grown-up")
                .font(.system(.title2, design: .rounded, weight: .bold))
            Text("To continue, solve:")
                .foregroundStyle(.secondary)
            Text("\(a) × \(b) = ?")
                .font(.system(.title, design: .rounded, weight: .bold))

            TextField("Answer", text: $answer)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title2)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(width: 140)

            if wrong {
                Text("Not quite — try again")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                if Int(answer.trimmingCharacters(in: .whitespaces)) == a * b {
                    dismiss()
                    onPassed()
                } else {
                    wrong = true
                    answer = ""
                    a = Int.random(in: 6...9)
                    b = Int.random(in: 3...9)
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.purple.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)

            Button("Cancel") { dismiss() }
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .presentationDetents([.medium])
    }
}
