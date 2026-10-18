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

## Constraints

- The subtitle, keywords and screenshots can only change with a **new app version**. That means a new build plus App Review. Promotional text can change any time, but it does not show in search results.
- Submitting is a public change, so it needs Mehrdad's explicit go-ahead.
