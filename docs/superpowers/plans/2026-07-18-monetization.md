# Musica Monetization Plan — Premium Subscription

**Status:** PLANNED (nothing implemented yet; pricing + free/premium split decided 2026-07-18)
**Written:** 2026-07-18

**Goal:** Charge for Musica with an auto-renewable subscription sold through Apple In-App Purchase: **$4.99/month or $39.99/year** (yearly presented as the better deal), both with a **7-day free trial**.

---

## Reality checks before any code

1. **Musica is not on the App Store yet.** It has only ever been installed on our own devices with developer builds. You cannot charge anyone until the app ships through the App Store — so most of this plan is App Store work, not subscription work.
2. **Apple IAP is mandatory.** Digital subscriptions inside an iOS app must use Apple's In-App Purchase. No Stripe, no web checkout inside the app. Apple keeps 30% — or **15% if we enroll in the Small Business Program** (free, for developers under $1M/year). Enroll on day one.
3. **Pricing (decided).** We considered $4.99/week (≈ $260/year) and rejected it — competitors charge far less (Simply Piano ≈ $150/yr, Yousician ≈ $140/yr), and weekly pricing drives churn and refund complaints. Decision: **$4.99/month + $39.99/year, 7-day free trial on both.** Prices live in App Store Connect and can be changed anytime without a code change.
4. **This is a kids' app.** That means: a **parental gate** (small challenge only an adult should pass) before any purchase screen, a privacy policy, and an honest age rating. Our story here is strong — the app collects zero data and everything stays on the device. We should choose **Education** as the primary category (not the restrictive Kids Category), like other piano-learning apps.

---

## Phase A: Get the app onto the App Store (no code)

- [x] Sign the **Paid Applications Agreement** in App Store Connect; enter banking + tax info (done 2026-08-05)
- [ ] Enroll in the **App Store Small Business Program** (15% instead of 30%)
- [x] Create the App Store Connect app record for `com.higgssoftware.musica` (adopted 2026-07-24 in commit 028ad0f; `com.musica.app` was already taken globally) — app ID `6794258266`, "Musica: Kids Learn Piano Notes"
- [x] Host a simple **privacy policy** page ("no data collected, everything on-device") + support page — live at https://themehrdad.github.io/musica/privacy.html and https://themehrdad.github.io/musica/support.html (gh-pages branch)
- [x] Design a proper **app icon** — kawaii piano artwork in the asset catalog (PR #5)
- [x] Screenshots for 6.9" iPhones — four shots in `docs/app-store/screenshots/` (practice, progress calendar, grand staff, profiles) via the DEBUG `-demo-screen` mode (PR #5)
- [x] Write the App Store description; **age rating** + **privacy nutrition label** answers drafted in `docs/app-store/listing.md` (PR #5)
- [x] Upload a build to **TestFlight** and confirm it installs/runs on a device (internal tester, 2026-08-05; external tester optional before submission)

## Phase B: Create the subscription product (no code)

- [x] Subscription group: `Musica Premium` (created 2026-08-05)
- [x] Auto-renewable product `com.musica.app.premium.monthly` — $4.99/month (product IDs keep the `com.musica.app` namespace; only the app bundle ID changed)
- [x] Auto-renewable product `com.musica.app.premium.yearly` — $39.99/year (same group, so switching plans is handled by Apple automatically)
- [x] **Intro offer: 7 days free on both products** (this is how "try before you buy" works; no code needed) — set up 2026-08-05 as an *Introductory Offer* → Free → **1 Week**, starting 2026-08-05 with no end date, all 175 storefronts
- [x] Localized display names + descriptions — `Premium Monthly` / `Premium Yearly` plus group name `Musica Premium`, in English (U.S.) and English (Canada) (2026-08-05)
- [x] **Family Sharing: ON** (one subscription covers the whole family — parents expect this for a kids' app)

Both products sit in Draft Submission (1) at **Ready for Review**. Apple requires the first subscription group to be submitted alongside an app version, so they go live with the 1.0 submission — nothing further to do here.

Two gotchas worth remembering: a free trial is not a field, it is an **Introductory Offer** hidden behind the dropdown at the top of the Subscription Pricing page (and the duration menu offers "1 Week", never "7 days"); and once a product is added to a review submission its names and descriptions silently go read-only — remove it from the submission to edit, then add it back.

## Phase C: StoreKit 2 integration (the code)

> Built 2026-07-18, shipped **dark** behind `Config.premiumGatingEnabled = false` — flip to `true` when the products are live in App Store Connect.

Target: iOS 17+, so we use modern StoreKit 2 (async/await, on-device receipt verification — **no server needed**).

- [x] **Task C1 — `StoreService`** (`Musica/Services/StoreService.swift`): loads both `Product`s, exposes `purchase()`, `restore()`, and an `isPremium` flag driven by `Transaction.currentEntitlements`; listens to `Transaction.updates` for renewals/cancellations; caches the last known entitlement so the app works offline
- [x] **Task C2 — Free/premium split (decided — freemium):**
  - **Free forever:** 1 profile, treble clef, 5 notes/day — the app stays genuinely useful unpaid
  - **Premium:** unlimited notes, unlimited profiles, bass + grand staff, per-hand key selection, progress calendar with note history
- [x] **Task C3 — `PaywallView`**: both plans shown with yearly highlighted as the better value, price + renewal terms shown plainly (required by App Review), Subscribe button, **Restore Purchases** button (required), links to privacy policy + terms (required), parent-facing copy
- [x] **Task C4 — Parental gate**: simple adult-check (e.g., "type three × four") shown before the paywall
- [x] **Task C5 — Gating hooks**: daily-cap check in `PracticeViewModel`, profile-count check in `ProfileListView`, lock badge + blurred preview on the Progress tab when not premium
- [x] **Task C6a — Local testing**: `.storekit` config wired into the run scheme, FreeTier unit tests
- [ ] **Task C6b — Sandbox test on a real phone** (blocked until the App Store Connect products exist)
- [ ] Unit tests green; manual sandbox purchase + cancel + restore verified on device

## Phase D: Submit and launch

- [ ] App Review notes: explain the parental gate and where the subscription lives
- [ ] Submit; expect 1–2 review rejections on paywall wording (normal for subscriptions — fix and resubmit)
- [ ] After approval: monitor App Store Connect for sales/refunds (Apple handles all billing, refunds, and cancellations)
- [ ] Later, optional: App Store **Server Notifications V2** + a tiny backend if we ever want renewal analytics or promo codes

---

## What we deliberately do NOT need

- No payment processing of our own, no user accounts, no backend — StoreKit 2's on-device verification is sufficient at this scale
- No price logic in code — prices and trial length live in App Store Connect

## Rough effort

| Phase | Effort |
|---|---|
| A — App Store presence | 1–2 days (mostly admin + icon/screenshots) |
| B — Product setup | half a day |
| C — StoreKit code | 2–3 working sessions |
| D — Review + launch | ~1 week calendar time (Apple's review pace) |
