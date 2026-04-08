import SwiftUI

struct PianoHintView: View {
    let note: MusicNote

    var body: some View {
        Text("Hint: Play \(note.displayName)")
            .font(.headline)
            .padding()
            .background(.yellow.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
