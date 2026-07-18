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

- [ ] Sign the **Paid Applications Agreement** in App Store Connect; enter banking + tax info
- [ ] Enroll in the **App Store Small Business Program** (15% instead of 30%)
- [ ] Create the App Store Connect app record for `com.musica.app`
- [ ] Host a simple **privacy policy** page ("no data collected, everything on-device") + support page — GitHub Pages is fine
- [ ] Design a proper **app icon** (we currently ship without a real one)
- [ ] Screenshots for 6.9" and 6.5" iPhones (practice screen, progress calendar, key selector)
- [ ] Write the App Store description; complete the **age rating** questionnaire and **privacy nutrition label** (nothing collected)
- [ ] Upload a build to **TestFlight** and confirm it installs/runs for an external tester

## Phase B: Create the subscription product (no code)

- [ ] Subscription group: `Musica Premium`
- [ ] Auto-renewable product `com.musica.app.premium.monthly` — $4.99/month
- [ ] Auto-renewable product `com.musica.app.premium.yearly` — $39.99/year (same group, so switching plans is handled by Apple automatically)
- [ ] **Intro offer: 7 days free on both products** (this is how "try before you buy" works; no code needed)
- [ ] Localized display names + descriptions
- [ ] **Family Sharing: ON** (one subscription covers the whole family — parents expect this for a kids' app)

## Phase C: StoreKit 2 integration (the code)

Target: iOS 17+, so we use modern StoreKit 2 (async/await, on-device receipt verification — **no server needed**).

- [ ] **Task C1 — `StoreService`** (`Musica/Services/StoreService.swift`): loads both `Product`s, exposes `purchase()`, `restore()`, and an `isPremium` flag driven by `Transaction.currentEntitlements`; listens to `Transaction.updates` for renewals/cancellations; caches the last known entitlement so the app works offline
- [ ] **Task C2 — Free/premium split (decided — freemium):**
  - **Free forever:** 1 profile, treble clef, 5 notes/day — the app stays genuinely useful unpaid
  - **Premium:** unlimited notes, unlimited profiles, bass + grand staff, per-hand key selection, progress calendar with note history
- [ ] **Task C3 — `PaywallView`**: both plans shown with yearly highlighted as the better value, price + renewal terms shown plainly (required by App Review), Subscribe button, **Restore Purchases** button (required), links to privacy policy + terms (required), parent-facing copy
- [ ] **Task C4 — Parental gate**: simple adult-check (e.g., "type three × four") shown before the paywall
- [ ] **Task C5 — Gating hooks**: daily-cap check in `PracticeViewModel`, profile-count check in `ProfileListView`, lock badge + blurred preview on the Progress tab when not premium
- [ ] **Task C6 — Testing**: local `.storekit` configuration file, `StoreKitTest` unit tests for purchase/restore/expiry, sandbox-account test on a real phone
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
