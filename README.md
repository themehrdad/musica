# Musica

A native iOS app for piano learners. Musica displays random notes on a treble staff and listens through the microphone as you play them on a real piano, giving instant feedback on correctness.

## Features

- **Profile management** — Create multiple learner profiles with custom avatars
- **Music staff notation** — Treble clef with correctly positioned notes, ledger lines, and a treble clef symbol
- **Real-time pitch detection** — Powered by AudioKit, detects piano notes through the microphone
- **Voice/noise filtering** — Amplitude threshold + pitch stability filtering ignores background chatter
- **Beginner mode** — Restricts notes to the 5 staff lines only (no ledger lines) for new learners
- **Daily goal tracking** — Practice counter with configurable daily target (default: 20 notes)
- **Confetti animation** — Celebratory particle burst on correct notes
- **Sad face animation** — Animated emoji feedback on wrong notes
- **Piano keyboard hint** — After 3 wrong attempts, shows a visual piano octave with the correct key highlighted
- **Crown celebration** — Overlay animation when the daily goal is reached
- **Haptic feedback** — Tactile responses for correct, wrong, and goal events
- **Mic toggle** — Tap the mic indicator to pause/resume listening

## Tech Stack

- **Swift 6** / **SwiftUI** / **SwiftData**
- **AudioKit** + **SoundpipeAudioKit** for real-time pitch detection
- **XcodeGen** for project generation
- iOS 17.0+

## Getting Started

### Prerequisites

- Xcode 16+ with iOS 17+ SDK
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- A physical iOS device (microphone input is required — simulators don't have mic access)

### Setup

```bash
# Clone the repo
git clone https://github.com/themehrdad/musica.git
cd musica

# Generate the Xcode project
xcodegen generate

# Open in Xcode
open Musica.xcodeproj
```

In Xcode:
1. Select your **Development Team** in Signing & Capabilities
2. Select your physical device as the build target
3. Build and run (Cmd+R)

The app will request microphone permission on first launch.

## Configuration

Tunable constants are in `Musica/Config.swift`:

| Constant | Default | Description |
|----------|---------|-------------|
| `dailyGoal` | 20 | Notes to practice per day |
| `wrongAttemptsBeforeHint` | 3 | Wrong tries before showing piano hint |
| `pitchAmplitudeThreshold` | 0.05 | Minimum volume to register a note |
| `pitchStabilityFrames` | 3 | Consecutive matching frames to confirm a note |
| `noteRange` | C3–G5 | Full MIDI note range |
| `beginnerNoteRange` | E4–F5 | Beginner mode range (on-staff notes only) |

## Project Structure

```
Musica/
├── MusicaApp.swift              # App entry point + SwiftData container
├── Config.swift                 # Tunable constants
├── Models/
│   ├── Profile.swift            # Learner profile (SwiftData)
│   ├── DailyProgress.swift      # Daily practice tracking
│   └── MusicNote.swift          # Note model with MIDI/frequency math
├── Services/
│   ├── AudioService.swift       # AudioKit microphone + pitch detection
│   └── PracticeViewModel.swift  # Game state machine
└── Views/
    ├── Components/
    │   └── AvatarView.swift     # Circular avatar with initials fallback
    ├── Profiles/
    │   ├── ProfileListView.swift    # Profile grid + create/edit/delete
    │   └── CreateProfileView.swift  # Profile form (create & edit)
    └── Practice/
        ├── PracticeView.swift       # Main practice screen
        ├── StaffView.swift          # Canvas-drawn treble staff
        ├── CounterView.swift        # Animated daily counter
        ├── MicIndicatorView.swift   # Pulsing microphone indicator
        ├── PianoHintView.swift      # Visual piano keyboard hint
        ├── ConfettiView.swift       # Confetti particle animation
        └── SadFaceView.swift        # Sad face feedback animation
```

## License

MIT
