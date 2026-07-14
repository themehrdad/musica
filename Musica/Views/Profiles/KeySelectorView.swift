import SwiftUI

/// An interactive multi-octave piano keyboard for choosing practice keys.
/// Parents tap white keys to toggle them, or use Range mode (tap a first and
/// last key) to fill a stretch. Black keys are shown for realism but are not
/// selectable — the app practices natural notes only.
struct KeySelectorView: View {
    let title: String
    let subtitle: String
    let selectableRange: ClosedRange<Int>   // MIDI bounds of the keyboard
    let staffOnlyRange: ClosedRange<Int>    // preset: the classic on-staff range
    @Binding var selection: Set<Int>        // selected natural MIDI numbers

    @State private var rangeAnchor: Int?    // first key tapped in Range mode
    @State private var rangeMode = false

    private let whiteKeyWidth: CGFloat = 34
    private let whiteKeyHeight: CGFloat = 110
    private let keySpacing: CGFloat = 2

    private var whiteKeys: [MusicNote] {
        selectableRange.compactMap { MusicNote(midiNumber: $0) }
    }

    // Keys visible on THIS keyboard; the set may hold strays from a
    // previously shown range (a clef-mode switch), which are not saved.
    private var visibleSelection: Set<Int> {
        selection.filter { selectableRange.contains($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                Text(visibleSelection.isEmpty ? subtitle : "\(visibleSelection.count) keys selected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            keyboard

            HStack(spacing: 10) {
                Button(rangeMode ? (rangeAnchor == nil ? "Tap first key…" : "Tap last key…") : "Range") {
                    rangeMode.toggle()
                    rangeAnchor = nil
                }
                .buttonStyle(.bordered)
                .tint(rangeMode ? .orange : .blue)

                Button("Staff only") {
                    exitRangeMode()
                    selection = Set(staffOnlyRange.filter { MusicNote(midiNumber: $0) != nil })
                }
                .buttonStyle(.bordered)

                Button("All") {
                    exitRangeMode()
                    selection = Set(whiteKeys.map(\.midiNumber))
                }
                .buttonStyle(.bordered)

                Button("Clear") {
                    exitRangeMode()
                    selection = []
                }
                .buttonStyle(.bordered)
            }
            .font(.caption)
        }
    }

    private var keyboard: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    HStack(spacing: keySpacing) {
                        ForEach(whiteKeys, id: \.midiNumber) { key in
                            whiteKey(key)
                                .id(key.midiNumber)
                        }
                    }
                    blackKeys
                }
            }
            .frame(height: whiteKeyHeight)
            .onAppear {
                // Land the view roughly on the staff-only preset
                proxy.scrollTo(staffOnlyRange.lowerBound + 12, anchor: .center)
            }
        }
    }

    private func whiteKey(_ key: MusicNote) -> some View {
        let isSelected = selection.contains(key.midiNumber)
        let isAnchor = rangeAnchor == key.midiNumber
        return RoundedRectangle(cornerRadius: 4)
            .fill(isSelected ? Color.blue.opacity(0.35) : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isAnchor ? Color.orange : (isSelected ? Color.blue : Color.gray.opacity(0.4)),
                            lineWidth: isSelected || isAnchor ? 2 : 1)
            )
            .overlay(alignment: .bottom) {
                VStack(spacing: 1) {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.blue)
                    }
                    // Label every C with its octave so parents can orient
                    Text(key.name == .C ? key.displayName : key.name.rawValue)
                        .font(.caption2.weight(key.name == .C ? .bold : .regular))
                        .foregroundStyle(isSelected ? .blue : .secondary)
                }
                .padding(.bottom, 5)
            }
            .frame(width: whiteKeyWidth, height: whiteKeyHeight)
            .contentShape(Rectangle())
            .onTapGesture { tapped(key.midiNumber) }
    }

    private var blackKeys: some View {
        // A black key sits between every pair of adjacent white keys except E–F and B–C
        ForEach(Array(whiteKeys.dropLast().enumerated()), id: \.offset) { index, key in
            if key.name != .E, key.name != .B {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.black.opacity(0.75))
                    .frame(width: 18, height: whiteKeyHeight * 0.55)
                    .offset(x: CGFloat(index) * (whiteKeyWidth + keySpacing) + whiteKeyWidth * 0.68)
                    .allowsHitTesting(false)
            }
        }
    }

    private func tapped(_ midi: Int) {
        if rangeMode {
            if let anchor = rangeAnchor {
                let range = min(anchor, midi)...max(anchor, midi)
                selection.formUnion(range.filter { MusicNote(midiNumber: $0) != nil })
                exitRangeMode()
            } else {
                rangeAnchor = midi
            }
        } else if selection.contains(midi) {
            selection.remove(midi)
        } else {
            selection.insert(midi)
        }
    }

    private func exitRangeMode() {
        rangeMode = false
        rangeAnchor = nil
    }
}
