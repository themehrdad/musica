# Musica 1.1 release record

Submitted September 6, 2026 at 1:55 PM Pacific under the user's authorization to execute the discovery and conversion improvement plan.

- App: Musica: Piano Note Practice, Apple ID 6794258266.
- Version/build: 1.1 (5).
- App Store Connect status verified: **Waiting for Review**.
- Submission ID: `583dbd86-4534-43fb-94c0-2075fcf96870`.
- Release setting: automatically release after approval, to all users immediately.
- Review page: https://appstoreconnect.apple.com/apps/6794258266/distribution/reviewsubmissions/details/583dbd86-4534-43fb-94c0-2075fcf96870

## Included changes

The subtitle is now “Sight reading for kids,” with relevant note-reading keywords, clearer promotional copy and description, and six new screenshots. Verified screenshot order in App Store Connect: practice, hints, daily goal, progress, grand staff, profiles. All six uploads are opaque 1320 × 2868 JPEGs; Premium-only screens are labeled.

The free allowance increases from five to 20 correct notes per day. Free goals stay within the allowance, including after a subscription expires; Premium profile goals are preserved. The daily-goal celebration remains visible at the free limit and offers a clear Done for today action. Practice explains the real-piano requirement, microphone placement, and digital-piano speakers. Existing rating-prompt work was completed with distinct practice-day qualification and 120-day spacing across profiles.

Existing prices, subscription products, Canada/US availability, and privacy declarations were retained. This release does not establish a change in search ranking or conversion yet.

## Validation

- 75 tests passed, zero failures, using the Release configuration with ENABLE_TESTABILITY=YES, running the iOS app on the local Apple silicon Mac.
- Release simulator build-for-testing succeeded.
- Signed device archive and App Store Connect upload succeeded; Apple processed build 5 and accepted the submission.
- Six actual app screens captured on an isolated iPhone 17 Pro Max simulator, composed with the supplied Swift renderer, and visually inspected.
- Dimensions and absence of alpha verified on each uploaded JPEG. Upload count and order verified after navigation back to the version form.
- `git diff --check` passed.

Local evidence (ignored build artifacts): `build/growth-mac-tests-final.xcresult`, `build/Musica-1.1-final.xcarchive`, and `build/growth-upload/`. Final test log: `/tmp/musica-mac-tests-final.log`; upload log: `/tmp/musica-growth-upload.log`.

## Measurement after release

Use the audit's baseline and four-week plan. Record the actual live date, then compare equal seven-day windows for App Store Search impressions, first-time downloads, source-specific conversion, and proceeds. Avoid conclusions from the initial 29 impressions and three downloads alone. Confirm the new listing and search presentation with a fresh-customer native App Store session in the intended storefront. Physical-piano onboarding and acoustic detection were not validated by simulator captures or unit tests; those remain user-session checks. No paid campaign or recurring monitor was started.
