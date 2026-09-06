import SwiftUI

/// Overlay for the practice screen when the free daily notes are used up.
struct FreeLimitReachedView: View {
    var onDone: () -> Void
    @State private var showGate = false
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("⭐️")
                    .font(.system(size: 64))
                Text("Great practicing!")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                Text("That's all \(Config.freeDailyNoteLimit) free notes for today.\nCome back tomorrow — or unlock unlimited practice.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Button {
                    showGate = true
                } label: {
                    Text("Ask a grown-up to unlock")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.purple.opacity(0.15))
                        .clipShape(Capsule())
                }
                Button("Done for today", action: onDone)
                    .font(.headline)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(24)
        }
        .sheet(isPresented: $showGate) {
            ParentalGateView { showPaywall = true }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

/// Shown in place of the Progress tab on the free plan.
struct LockedProgressView: View {
    @State private var showGate = false
    @State private var showPaywall = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 52))
                .foregroundStyle(.purple.opacity(0.6))
            Text("Progress is a Premium treat")
                .font(.system(.title2, design: .rounded, weight: .bold))
            Text("See a month of scores, gold stars for reached goals, and every note practiced each day.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            Button {
                showGate = true
            } label: {
                Text("Unlock Premium")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.purple.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showGate) {
            ParentalGateView { showPaywall = true }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}
