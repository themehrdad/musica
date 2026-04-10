import SwiftUI

struct StaffView: View {
    let note: MusicNote?
    let clefMode: ClefMode

    let lineSpacing: CGFloat = 12
    let noteHeadWidth: CGFloat = 16
    let noteHeadHeight: CGFloat = 11

    // Staff line positions (in staffPosition units)
    // Treble: E4=2, G4=4, B4=6, D5=8, F5=10
    // Bass: G2=-10, B2=-8, D3=-6, F3=-4, A3=-2
    private let trebleLines = [2, 4, 6, 8, 10]
    private let bassLines = [-10, -8, -6, -4, -2]

    var body: some View {
        Canvas { context, size in
            let staffWidth = size.width - 80
            let staffLeft: CGFloat = 70

            switch clefMode {
            case .treble:
                let midY = size.height / 2
                drawStaff(context: context, midY: midY, staffLeft: staffLeft, staffWidth: staffWidth, lines: trebleLines)
                drawTrebleClef(context: context, midY: midY, staffLeft: staffLeft)
                if let note {
                    drawNote(context: context, note: note, staffLeft: staffLeft, staffWidth: staffWidth,
                             refMidY: midY, refPosition: 6, lines: trebleLines, size: size)
                }

            case .bass:
                let midY = size.height / 2
                drawStaff(context: context, midY: midY, staffLeft: staffLeft, staffWidth: staffWidth, lines: bassLines)
                drawBassClef(context: context, midY: midY, staffLeft: staffLeft)
                if let note {
                    drawNote(context: context, note: note, staffLeft: staffLeft, staffWidth: staffWidth,
                             refMidY: midY, refPosition: -6, lines: bassLines, size: size)
                }

            case .both:
                let gap: CGFloat = lineSpacing * 4
                let trebleMidY = size.height / 2 - gap / 2 - lineSpacing * 2
                let bassMidY = size.height / 2 + gap / 2 + lineSpacing * 2

                // Draw both staves
                drawStaff(context: context, midY: trebleMidY, staffLeft: staffLeft, staffWidth: staffWidth, lines: trebleLines)
                drawTrebleClef(context: context, midY: trebleMidY, staffLeft: staffLeft)

                drawStaff(context: context, midY: bassMidY, staffLeft: staffLeft, staffWidth: staffWidth, lines: bassLines)
                drawBassClef(context: context, midY: bassMidY, staffLeft: staffLeft)

                // Draw brace (left bracket)
                let braceTop = trebleMidY - lineSpacing * 2
                let braceBottom = bassMidY + lineSpacing * 2
                let bracePath = Path { p in
                    p.move(to: CGPoint(x: staffLeft - 2, y: braceTop))
                    p.addLine(to: CGPoint(x: staffLeft - 2, y: braceBottom))
                }
                context.stroke(bracePath, with: .color(.primary.opacity(0.4)), lineWidth: 2)

                // Draw note on the correct staff
                if let note {
                    if note.isTreble {
                        drawNote(context: context, note: note, staffLeft: staffLeft, staffWidth: staffWidth,
                                 refMidY: trebleMidY, refPosition: 6, lines: trebleLines, size: size)
                    } else {
                        drawNote(context: context, note: note, staffLeft: staffLeft, staffWidth: staffWidth,
                                 refMidY: bassMidY, refPosition: -6, lines: bassLines, size: size)
                    }
                }
            }
        }
        .frame(height: clefMode == .both ? lineSpacing * 22 : lineSpacing * 12)
    }

    // MARK: - Drawing helpers

    private func drawStaff(context: GraphicsContext, midY: CGFloat, staffLeft: CGFloat, staffWidth: CGFloat, lines: [Int]) {
        for (i, _) in lines.enumerated() {
            let y = midY + CGFloat(2 - i) * lineSpacing
            let path = Path { p in
                p.move(to: CGPoint(x: staffLeft, y: y))
                p.addLine(to: CGPoint(x: staffLeft + staffWidth, y: y))
            }
            context.stroke(path, with: .color(.primary.opacity(0.4)), lineWidth: 1.5)
        }
    }

    private func drawTrebleClef(context: GraphicsContext, midY: CGFloat, staffLeft: CGFloat) {
        let clef = Text("𝄞")
            .font(.system(size: lineSpacing * 6.5))
            .foregroundColor(.primary.opacity(0.6))
        context.draw(clef, at: CGPoint(x: staffLeft + 20, y: midY + lineSpacing * 0.2))
    }

    private func drawBassClef(context: GraphicsContext, midY: CGFloat, staffLeft: CGFloat) {
        let clef = Text("𝄢")
            .font(.system(size: lineSpacing * 3.5))
            .foregroundColor(.primary.opacity(0.6))
        context.draw(clef, at: CGPoint(x: staffLeft + 18, y: midY - lineSpacing * 0.5))
    }

    private func drawNote(context: GraphicsContext, note: MusicNote, staffLeft: CGFloat, staffWidth: CGFloat,
                          refMidY: CGFloat, refPosition: Int, lines: [Int], size: CGSize) {
        let noteX = staffLeft + staffWidth / 2 + 20
        let noteY = yPosition(for: note.staffPosition, refMidY: refMidY, refPosition: refPosition)

        // Ledger lines
        let lowestLine = lines.first!
        let highestLine = lines.last!

        if note.staffPosition < lowestLine {
            var pos = lowestLine - 2
            while pos >= note.staffPosition {
                if pos % 2 == 0 { // ledger lines only on even positions
                    let ly = yPosition(for: pos, refMidY: refMidY, refPosition: refPosition)
                    let path = Path { p in
                        p.move(to: CGPoint(x: noteX - noteHeadWidth - 4, y: ly))
                        p.addLine(to: CGPoint(x: noteX + noteHeadWidth + 4, y: ly))
                    }
                    context.stroke(path, with: .color(.primary.opacity(0.4)), lineWidth: 1.5)
                }
                pos -= 1
            }
            // Also draw ledger line at note position if on a line
            if note.staffPosition % 2 == 0 {
                let ly = yPosition(for: note.staffPosition, refMidY: refMidY, refPosition: refPosition)
                let path = Path { p in
                    p.move(to: CGPoint(x: noteX - noteHeadWidth - 4, y: ly))
                    p.addLine(to: CGPoint(x: noteX + noteHeadWidth + 4, y: ly))
                }
                context.stroke(path, with: .color(.primary.opacity(0.4)), lineWidth: 1.5)
            }
        }

        if note.staffPosition > highestLine {
            var pos = highestLine + 2
            while pos <= note.staffPosition {
                if pos % 2 == 0 {
                    let ly = yPosition(for: pos, refMidY: refMidY, refPosition: refPosition)
                    let path = Path { p in
                        p.move(to: CGPoint(x: noteX - noteHeadWidth - 4, y: ly))
                        p.addLine(to: CGPoint(x: noteX + noteHeadWidth + 4, y: ly))
                    }
                    context.stroke(path, with: .color(.primary.opacity(0.4)), lineWidth: 1.5)
                }
                pos += 1
            }
            if note.staffPosition % 2 == 0 {
                let ly = yPosition(for: note.staffPosition, refMidY: refMidY, refPosition: refPosition)
                let path = Path { p in
                    p.move(to: CGPoint(x: noteX - noteHeadWidth - 4, y: ly))
                    p.addLine(to: CGPoint(x: noteX + noteHeadWidth + 4, y: ly))
                }
                context.stroke(path, with: .color(.primary.opacity(0.4)), lineWidth: 1.5)
            }
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

    private func yPosition(for staffPosition: Int, refMidY: CGFloat, refPosition: Int) -> CGFloat {
        refMidY - CGFloat(staffPosition - refPosition) * (lineSpacing / 2)
    }
}
