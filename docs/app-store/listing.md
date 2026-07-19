# Musica — App Store Listing

Everything to paste into App Store Connect when the app record exists.
Screenshots (6.9", 1320×2868) live in `screenshots/` beside this file.

## Name (30 chars max)

**Musica: Kids Learn Piano Notes** (30 — if taken, fallbacks below)

- Musica — Piano Notes for Kids
- Musica: Piano Note Practice

## Subtitle (30 chars max)

**Play real piano, learn notes** (28)

## Category

- Primary: **Education**
- Secondary: **Music**

## Age rating

**4+** — answer "None" to every content question (no violence, no user
content, no web access, no contests). Made for families; the app has a
parental gate in front of all purchase screens.

## Privacy nutrition label

**Data Not Collected** — answer No to every collection question. The app
has no accounts, no analytics, no ads; microphone audio is processed live
on-device and never recorded or transmitted.

- Privacy Policy URL: https://themehrdad.github.io/musica/privacy.html
- Support URL: https://themehrdad.github.io/musica/support.html

## Promotional text (170 chars max)

Watch your child light up when the piano answers back. Real-piano note
practice with instant feedback, gold stars, and a progress calendar
parents actually love.

## Description

Musica teaches kids to read music the way it should feel: like a game
played on a real piano.

A note appears on the staff. Your child finds it on your piano and plays
it — for real, no touchscreen keys. Musica listens through the microphone,
recognizes the note instantly, and celebrates every right answer with
confetti. Wrong guesses get gentle hints: first the note's name, then a
glowing key on a piano diagram.

BUILT FOR REAL PIANOS
• On-device AI reacts only to piano sounds — voices, claps, and squeaky
  chairs are ignored
• Works with any acoustic or digital piano. No cables, no MIDI, no setup

MADE FOR KIDS, TUNED BY PARENTS
• A profile for each child, with their own pace and progress
• Daily goals you choose per kid (5 to 100 notes a day)
• Beginner mode with staff-line notes only
• Treble, bass, or the full grand staff
• Pick the exact keys to practice — a range, or just the tricky ones,
  for each hand

PROGRESS YOU CAN SEE
• A month calendar with each day's score
• Gold stars on the days the goal was reached
• Tap any day to see exactly which notes were practiced

PRIVATE BY DESIGN
• No ads. No accounts. No data collection — everything stays on the device
• Microphone audio is analyzed live and never recorded or sent anywhere

Musica Premium (optional, family-shareable) unlocks unlimited daily
practice, profiles for every kid, the grand staff, and per-key practice
selection — with a 7-day free trial. The free plan stays genuinely
useful: one profile, treble clef, five notes a day, forever.

Questions or ideas? themehrdad@gmail.com — we read everything.

## Keywords (100 chars max, comma-separated, no spaces)

`piano,notes,kids,music,sight reading,note reading,staff,treble,bass,practice,learn,ear training` (97)

## Screenshot order + captions (captions optional, for later polish)

1. `1-practice-6.9.png` — "Play the note on YOUR piano"
2. `2-progress-6.9.png` — "Stars for every day the goal is reached"
3. `3-grand-staff-6.9.png` — "Treble, bass, or the grand staff"
4. `4-profiles-6.9.png` — "A profile for every kid"

## App Review notes (paste when submitting)

- The app requires a piano (acoustic or digital) to use. For review
  without a piano: any piano app on another device playing notes near the
  microphone will register, or see the demo video link we attach.
- Microphone is used solely for live note detection; audio is never
  recorded or transmitted (see privacy policy).
- All purchase flows sit behind a parental gate (multiplication question).
- Subscriptions: Musica Premium monthly $4.99 / yearly $39.99, 7-day free
  trial, managed entirely through StoreKit.

## Regenerating screenshots

DEBUG builds accept `-demo-screen profiles|practice|grand|progress` and
show seeded demo data in an in-memory store (see `Musica/DemoScreens.swift`):

```
xcrun simctl privacy <sim> grant microphone com.musica.app
xcrun simctl launch <sim> com.musica.app -demo-screen progress
xcrun simctl io <sim> screenshot progress.png
```
