import SwiftUI

struct StaffView: View {
    let note: MusicNote?
    let lineSpacing: CGFloat = 14
    let noteHeadWidth: CGFloat = 18
    let noteHeadHeight: CGFloat = 13

    private let staffLinePositions = [2, 4, 6, 8, 10]

    var body: some View {
        Canvas { context, size in
            let staffWidth = size.width - 80
            let staffLeft: CGFloat = 70
            let midY = size.height / 2

            // Draw 5 staff lines
            for (i, _) in staffLinePositions.enumerated() {
                let y = midY + CGFloat(2 - i) * lineSpacing
                let path = Path { p in
                    p.move(to: CGPoint(x: staffLeft, y: y))
                    p.addLine(to: CGPoint(x: staffLeft + staffWidth, y: y))
                }
                context.stroke(path, with: .color(.primary.opacity(0.4)), lineWidth: 1.5)
            }

            // Draw treble clef
            let clefText = Text("𝄞")
                .font(.system(size: lineSpacing * 6.5))
                .foregroundColor(.primary.opacity(0.6))
            context.draw(clefText,
                         at: CGPoint(x: staffLeft + 20, y: midY + lineSpacing * 0.2))

            // Draw note
            if let note {
                let noteX = size.width / 2 + 20
                let noteY = yPosition(for: note.staffPosition, midY: midY)

                // Ledger lines
                for ledgerPos in ledgerLinesNeeded(for: note.staffPosition) {
                    let ly = yPosition(for: ledgerPos, midY: midY)
                    let path = Path { p in
                        p.move(to: CGPoint(x: noteX - noteHeadWidth - 4, y: ly))
                        p.addLine(to: CGPoint(x: noteX + noteHeadWidth + 4, y: ly))
                    }
                    context.stroke(path, with: .color(.primary.opacity(0.4)), lineWidth: 1.5)
                }

                // Note head
                let noteRect = CGRect(
                    x: noteX - noteHeadWidth / 2,
                    y: noteY - noteHeadHeight / 2,
                    width: noteHeadWidth,
                    height: noteHeadHeight
                )
                context.fill(Path(ellipseIn: noteRect), with: .color(.primary))
            }
        }
        .frame(height: lineSpacing * 12)
    }

    private func yPosition(for staffPosition: Int, midY: CGFloat) -> CGFloat {
        midY - CGFloat(staffPosition - 6) * (lineSpacing / 2)
    }

    private func ledgerLinesNeeded(for staffPosition: Int) -> [Int] {
        var lines: [Int] = []
        if staffPosition <= 0 {
            var pos = 0
            while pos >= staffPosition {
                lines.append(pos)
                pos -= 2
            }
        }
        if staffPosition >= 12 {
            var pos = 12
            while pos <= staffPosition {
                lines.append(pos)
                pos += 2
            }
        }
        return lines
    }
}
