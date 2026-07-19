import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var startTime: Date = .now

    struct ConfettiParticle: Identifiable {
        let id = UUID()
        let startX: CGFloat
        let startY: CGFloat
        let vx: CGFloat
        let vy: CGFloat
        let rotation: Double
        let rotationSpeed: Double
        let color: Color
        let size: CGFloat
    }

    private let colors: [Color] = [.yellow, .purple, .blue, .pink, .green, .orange]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSince(startTime)
                let gravity: CGFloat = 800

                for p in particles {
                    let t = CGFloat(elapsed)
                    let x = size.width / 2 + p.startX + p.vx * t
                    let y = size.height / 2 + p.startY + p.vy * t + 0.5 * gravity * t * t
                    let rot = p.rotation + p.rotationSpeed * Double(elapsed)
                    let opacity = max(0, 1 - elapsed / 2.0)

                    let rect = CGRect(
                        x: -p.size / 2,
                        y: -p.size * 0.3,
                        width: p.size,
                        height: p.size * 0.6
                    )

                    context.drawLayer { ctx in
                        ctx.translateBy(x: x, y: y)
                        ctx.rotate(by: .degrees(rot))
                        ctx.opacity = opacity
                        ctx.fill(Path(rect), with: .color(p.color))
                    }
                }
            }
        }
        .onAppear { spawnParticles() }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private func spawnParticles() {
        startTime = .now
        particles = (0..<50).map { _ in
            ConfettiParticle(
                startX: CGFloat.random(in: -30...30),
                startY: 0,
                vx: CGFloat.random(in: -200...200),
                vy: CGFloat.random(in: -600...(-200)),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -360...360),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 6...12)
            )
        }
    }
}
