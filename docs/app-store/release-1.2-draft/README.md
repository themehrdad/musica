# Musica 1.2 listing draft — not submitted

Prepared October 12, 2026, following the [final campaign audit](../campaigns/2026-10-12-final-audit.md). Nothing here has been uploaded to App Store Connect.

## Why

US App Store Search impressions jumped to 30–60 a day from October 8, but only about 2% led to a product-page view (233 impressions → 5 views → 1 download, Sep 12 – Oct 11). The search result tile is the step losing people. The icon, name, subtitle, rating and the first three screenshots are what a searcher sees there.

A rough rank check with the public iTunes Search API found Musica in the top ~190 only for its full name in the US. In Canada it also appeared at #72 for "piano note practice" and #155 for "treble clef practice". It has no ratings yet. That API approximates native search; it is not an exact rank.

## Screenshots

[`tile-compare.png`](tile-compare.png) shows today's search tile next to the draft at real iPhone size.

- The real app screens are cropped and zoomed into cards, so the staff, note and keyboard are about 1.6× larger at thumbnail size.
- The first three slots now show three different things: note → key, daily goal, progress. Today, slots 1 and 2 look almost the same.
- Headlines are bigger: 146 px, up from 116.
- Premium screens stay labeled.

Order: 01 note-to-key (hints) · 02 goal · 03 progress (Premium) · 04 listens (practice) · 05 grand staff (Premium) · 06 profiles (Premium).

To reproduce, run this from the repository root:

```bash
swift docs/app-store/release-1.2-draft/render_screens.swift "$PWD/docs/app-store"
```

The output is six opaque 1320 × 2868 JPEGs in `screenshots/`. They reuse the 1.1 simulator captures in `../release-1.1/raw/`.

## Subtitle and keywords (proposal)

| Field | Today | Draft |
|---|---|---|
| Subtitle | Sight reading for kids (22) | **Read music on a real piano** (26) |
| Keywords | `learn,treble,bass,clef,staff,beginner,trainer,flashcards,keyboard,sheet,recognition` | `sight,reading,kids,learn,treble,bass,clef,staff,trainer,flashcards,beginner,lessons,keyboard,sheet` (98) |

- The draft adds **music**, **read** and **real** to the indexed words. Today "music" appears in none of the indexed fields; "Musica" is a different word.
- "sight", "reading" and "kids" move from the subtitle into keywords.
- "recognition" is dropped, and "lessons" is added.
- No indexed word appears twice.

These are candidate terms only. Real query data from the US Search Match test (if approved) should be used to finalize them.

## Name (decided by Mehrdad, Oct 17, 2026)

**Note School: Piano Reading** (26 characters). The home-screen name would be **Note School** (11).

- Why: the Oct 13–17 US Search Match test matched "Musica" to music-player searches, including "music" in Russian and Arabic ([check-in](../campaigns/2026-10-17-us-check-in.md)). The new name is piano-first.
- Rejected options: "Simple Piano School" is too close to Simply Piano, which has about 858k ratings. "Piano School" is already used by another app and overpromises full lessons.
- Avoid "Kids" in the name; it was removed on purpose in PR #10.
- Apple confirms the name is free only when it's entered in App Store Connect.
- The subtitle must not repeat name words (note, school, piano, reading). "Sight reading for kids" repeats "reading". Candidates to finalize after the Oct 19 data: "Treble & bass for kids", "Sight-read treble & bass".
- In-app "Musica" branding to rename in the 1.2 build: the profiles screen title, "Musica Premium" on the paywall and in the description, the screenshot header in `render_screens.swift`, and the bundle display name. The bundle ID `com.higgssoftware.musica` and the subscription product IDs stay the same.

## Icon (candidate)

- [`icon/AppIcon-note-school.png`](icon/AppIcon-note-school.png): 1024 × 1024 PNG with no alpha. Made with Gemini on Oct 17, 2026; the 2048 px source is kept as `icon/gemini-source-2048.jpeg`.
- [`icon/icon-compare.png`](icon/icon-compare.png) compares it with the current icon at 180/120/60/40 px.
- The current icon is busy, has a baked-in rounded border, and shows a cartoon piano rather than note reading. At 60 px it blurs.
- Gemini prompt (first pass): "Create an image: a 1024x1024 iOS app icon for a children's piano note-reading app called "Note School". One bold, simple central symbol: a large, friendly quarter note (music note) wearing a small graduation cap, resting on five clean staff lines, with a short row of piano keys along the bottom edge. Flat vector style with soft gradients and thick, rounded shapes that stay readable at 60x60 pixels. Palette: deep blue background gradient (#2B59C3 to #4A7BE0), white staff lines and white piano keys with black keys, a sunny yellow note with a coral-orange cap. Centered composition with generous padding. Full-bleed square background edge to edge: no rounded corners, no border, no frame, no outer shadow, no text, no letters, no watermark."
- Follow-up prompt: "keep everything the same but fix the staff: exactly five single, evenly spaced white staff lines, with no duplicate or shadow lines…" The first pass had doubled staff lines.
- To adopt it, replace `Musica/Assets.xcassets/AppIcon.appiconset/AppIcon.png` in the 1.2 build.

## Constraints

- The subtitle, keywords and screenshots can only change with a **new app version**. That means a new build plus App Review. Promotional text can change any time, but it does not show in search results.
- Submitting is a public change, so it needs Mehrdad's explicit go-ahead.
