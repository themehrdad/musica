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
- [x] Create/edit/delete profile (name + photo picker + beginner toggle)
- [x] Navigation: profile list → practice

### Phase 2: Practice Screen + Music Notation
**Status:** COMPLETE
- [x] MusicNote model (MIDI, frequency, staff position)
- [x] Config constants (daily goal, note ranges, beginner range)
- [x] StaffView (treble clef, 5 lines, note heads, ledger lines)
- [x] CounterView (completed/goal with crown)
- [x] PracticeView layout (counter + staff + mic)

### Phase 3: Audio Pitch Detection + Core Game Loop
**Status:** COMPLETE
- [x] AudioService (AudioKit engine, PitchTap, noise filtering)
- [x] PracticeViewModel (state machine: listening → correct/wrong)
- [x] MicIndicatorView (amplitude-reactive pulse, tap to toggle)
- [x] Wire audio → game logic → UI
- [x] DailyProgress persistence
- [x] PianoHintView (visual keyboard with highlighted key)

### Phase 4: Animations, Hints, Crown & Polish
**Status:** COMPLETE
- [x] ConfettiView (particle animation on correct)
- [x] SadFaceView (animated crying emoji on wrong)
- [x] Crown celebration overlay at daily goal
- [x] Haptic feedback (success/error/heavy)
- [x] Profile switching from practice screen

## Current Phase
**All 4 phases complete**
