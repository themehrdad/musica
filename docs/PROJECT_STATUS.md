# Musica — Project Status

## Overview
iOS piano note recognition trainer. Learners see random notes on a music staff, play them on a real piano, and get instant audio feedback.

## Tech Stack
- Swift 6.3 / SwiftUI / SwiftData / iOS 17+
- AudioKit + SoundpipeAudioKit (pitch detection)
- XcodeGen (project generation)

## Phases

### Phase 1: Project Setup + Profile Management
**Status:** COMPLETE
- [x] XcodeGen project scaffold
- [x] SwiftData models (Profile, DailyProgress)
- [x] Profile list view (grid with avatars)
- [x] Create profile view (name + photo picker)
- [x] Navigation: profile list → practice (placeholder)

### Phase 2: Practice Screen + Music Notation
**Status:** NOT STARTED
- [ ] MusicNote model (MIDI, frequency, staff position)
- [ ] Config constants
- [ ] StaffView (treble clef, 5 lines, note heads, ledger lines)
- [ ] CounterView (completed/goal with crown)
- [ ] PracticeView layout (counter + staff + mic placeholder)

### Phase 3: Audio Pitch Detection + Core Game Loop
**Status:** NOT STARTED
- [ ] AudioService (AudioKit engine, PitchTap, noise filtering)
- [ ] PracticeViewModel (state machine: listening → correct/wrong)
- [ ] MicIndicatorView (amplitude-reactive pulse)
- [ ] Wire audio → game logic → UI
- [ ] DailyProgress persistence

### Phase 4: Animations, Hints, Crown & Polish
**Status:** NOT STARTED
- [ ] ConfettiView (particle animation on correct)
- [ ] SadFaceView (animated crying emoji on wrong)
- [ ] PianoHintView (drawn keyboard with highlighted key)
- [ ] Crown celebration overlay at daily goal
- [ ] Profile switching from practice screen
- [ ] Haptic feedback
- [ ] Dark mode verification
- [ ] Final UI polish

## Current Phase
**Phase 1 complete — awaiting build verification (iOS 26.4 simulator downloading)**
