import SwiftUI

struct PianoHintView: View {
    let note: MusicNote

    // White key layout: C=0, D=1, E=2, F=3, G=4, A=5, B=6
    // Black keys sit between: C#(0-1), D#(1-2), F#(3-4), G#(4-5), A#(5-6)
    private let whiteKeyNames: [NoteName] = [.C, .D, .E, .F, .G, .A, .B]
    private let blackKeyOffsets: [(NoteName, CGFloat)] = [
        // (adjacent white key's note for labeling, fractional position between white keys)
        (.C, 0.65), (.D, 1.65), (.F, 3.65), (.G, 4.65), (.A, 5.65)
    ]

    private let whiteKeyWidth: CGFloat = 36
    private let whiteKeyHeight: CGFloat = 120
    private let blackKeyWidth: CGFloat = 22
    private let blackKeyHeight: CGFloat = 72

    var body: some View {
        VStack(spacing: 8) {
            Text("Octave \(note.octave)")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            ZStack(alignment: .topLeading) {
                // White keys
                HStack(spacing: 2) {
                    ForEach(Array(whiteKeyNames.enumerated()), id: \.offset) { index, keyName in
                        let isTarget = keyName == note.name
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isTarget ? Color.blue.opacity(0.3) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(isTarget ? Color.blue : Color.gray.opacity(0.4), lineWidth: isTarget ? 2 : 1)
                            )
                            .overlay(alignment: .bottom) {
                                Text(keyName.rawValue)
                                    .font(.caption2.weight(isTarget ? .bold : .regular))
                                    .foregroundStyle(isTarget ? .blue : .secondary)
                                    .padding(.bottom, 6)
                            }
                            .frame(width: whiteKeyWidth, height: whiteKeyHeight)
                    }
                }

                // Black keys
                ForEach(Array(blackKeyOffsets.enumerated()), id: \.offset) { _, pair in
                    let xOffset = pair.1 * (whiteKeyWidth + 2)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.black)
                        .frame(width: blackKeyWidth, height: blackKeyHeight)
                        .offset(x: xOffset, y: 0)
                }
            }
            .frame(
                width: CGFloat(whiteKeyNames.count) * (whiteKeyWidth + 2) - 2,
                height: whiteKeyHeight
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
