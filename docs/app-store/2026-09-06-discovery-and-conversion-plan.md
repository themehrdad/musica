# Musica discovery and conversion plan — September 6, 2026

Musica is available and receiving some search exposure. The strongest opportunities are to make its real-piano note-reading purpose immediately clear, improve keyword coverage, and build an initial audience. The small search tile in the supplied screenshot is likely related to the app already being installed; it is not evidence of missing screenshot assets.

This is an investigation and proposed plan. No App Store metadata, availability, pricing, submissions, or app code were changed. Existing working-tree changes, including rating-prompt work, were inspected as context and left intact. Instructions embedded in the repository listing guide were treated as reference material, not permission to submit or change account settings.

**Verified account baseline**

App: `6794258266`, bundle `com.higgssoftware.musica`. Sources: signed-in App Store Connect, the Canadian public product page, the user's iPhone screenshot, and local source code.

| Item | Observed value | Meaning |
| --- | --- | --- |
| Release | Version 1.0, build 4; Ready for Distribution August 26, 2026 | About 11 days since release |
| Availability | Canada and United States available; 173 territories unavailable | Global discovery is restricted; this does not explain weak ranking within Canada |
| Categories | Education primary, Music secondary | Both match the product |
| Localization | English (U.S.) metadata; English app | Other language audiences have not been specifically addressed |
| Screenshots | Four iPhone portrait screenshots; 6.9-inch assets reused for the displayed 6.5-inch slot | Assets exist in Connect and on the public page |
| Published image order | Profiles → grand staff → progress calendar → single-staff practice | The main practice experience appears last |
| Preview video | None shown in the inspected screenshot slot | Optional future improvement |
| Ratings | No ratings; zero reviews in all-country Connect view | No rating-based social proof yet |
| Platform | Public page says Only for iPhone; iOS 17+ | Dedicated iPad support is a potential later product expansion |
| Marketing URL | Empty | An opportunity for a simple explanation and demo page |

[Live Canadian listing](https://apps.apple.com/ca/app/id6794258266) · [App information](https://appstoreconnect.apple.com/apps/6794258266/distribution/info) · [Availability](https://appstoreconnect.apple.com/apps/6794258266/distribution/pricing) · [Release history](https://appstoreconnect.apple.com/apps/6794258266/distribution/activity/ios/versions)

**Analytics and what they can establish**

The detailed Metrics and Sources pages were set to June 7–September 4, 2026. Apple displayed a delay notice for September 5. Only the period after release can contain customer acquisition for this version.

| Metric | Observed value |
| --- | ---: |
| Impressions, total | 29 |
| Search impressions | 22 |
| App-referrer impressions | 4 |
| Browse impressions | 3 |
| First-time downloads | 3, all shown on August 27 |
| First-time downloads by source | Browse 2; App Referrer 1; Search displayed “–” |
| Redownloads, overview | 1 |
| Product page views, overview | 12 |
| Conversion rate, overview | 13.3%, labeled Daily Average |
| In-app purchases, overview | 1 |
| Proceeds, paying users, retention | Not Enough Data |

The Overview displayed a September 4 date label despite retaining `dateSpec=d90`. The detailed tables resolved the download timing and confirmed the 90-day download and impression totals. Do not interpret the Overview as three downloads on September 4. Its remaining figures above are recorded as displayed, with that interface caveat.

Twenty-two search impressions demonstrate some search exposure; they do not identify the keywords or guarantee an organic rank. Apple includes paid search exposure in search analytics. No ads-account audit was performed. A dash is not a reliable numerical zero, and one in-app purchase is not proof of one paying subscriber. These samples cannot establish that conversion is good or bad.

Apple's standard conversion rate uses total downloads divided by unique impressions, and includes redownloads. Do not substitute total impressions or product-page views as the denominator, or interpret downloads divided by page views as an attributed page funnel: people can download directly from search. See [Apple's analytics definitions](https://developer.apple.com/app-store-connect/analytics/).

[Download metrics](https://appstoreconnect.apple.com/apps/6794258266/analytics/metrics?dateSpec=d90&frequency=day&measureKey=units) · [Impression metrics](https://appstoreconnect.apple.com/apps/6794258266/analytics/metrics?dateSpec=d90&frequency=day&measureKey=impressionsTotal) · [Acquisition sources](https://appstoreconnect.apple.com/apps/6794258266/analytics/acquisition/sources?dateSpec=d90)

**Why searching “musica” is difficult**

The Canadian web App Store search for `musica` displayed music players and streaming services, including Musica XM, Spotify, Apple Music, and YouTube Music. Musica's piano app was absent from the returned visible set. This supports an ambiguous search-intent problem: the word can refer to music generally, and the competing products have established audiences.

The same web surface also omitted this app from the displayed full-title results, whereas the user's native iPhone screenshot clearly finds it. Web search is therefore only corroborating evidence, not a measurement of native iPhone rank. No exact rank, keyword search volume, or ranking penalty was verified. Run future rank checks on a compatible iPhone with the same Apple Account storefront, language, query, and recorded date.

Apple says metadata relevance and user behavior influence search ranking. Being in the title does not guarantee a leading position. The app's young age, tiny download count, and lack of ratings are plausible contributors, not a proven explanation of Apple's exact ordering. Prioritize relevant searches such as `piano note practice`, `piano note reading`, `sight reading piano`, `learn piano notes`, and `treble clef practice`. These are feature-based candidates; their demand and competitiveness have not been quantified. [Apple search guidance](https://developer.apple.com/app-store/search/)

**Why the result is short**

The supplied screenshot shows Open for Musica and Get for the larger comparison results. The Ultimate Guitar result is also explicitly an ad. Musica has four published screenshots, so missing uploads are ruled out on the inspected listing. Installed/download-history presentation is the leading explanation for its compact result, but a fresh-customer native search has not been observed.

Verify on another compatible iPhone and Apple Account that has never downloaded Musica, in Canada or the United States. Compare the exact-name query and inspect the product page. Prefer this over deleting the existing app, which stores practice data locally and would still leave download history. Apple controls result layouts; do not spend on ads or create artificial events just to obtain a taller tile. Apple documents that screenshots/previews may appear in search and that previous-download status affects event presentation, without promising one universal tile size. [Search presentation](https://developer.apple.com/app-store/search/)

**Proposed next-release metadata**

Keep the existing name for this iteration; first clarify the proposition and gather useful search data. Avoid a broad rebrand based on three downloads.

| Field | Proposed text | Characters |
| --- | --- | ---: |
| Name | Musica: Piano Note Practice | 27 / 30 |
| Subtitle | Sight reading for kids | 22 / 30 |
| Keywords | `learn,treble,bass,clef,staff,beginner,trainer,flashcards,keyboard,sheet,recognition` | 83 / 100 |

The current keyword field repeats piano, notes, practice, and learn from the name/subtitle and includes ear training, a weaker match for the main staff-to-key activity. The proposed set replaces those overlaps with relevant concepts. Not every character must be used. These are candidate terms to validate, not guaranteed ranking improvements. App Store Connect says name/category changes require a new version; package the title/subtitle/keywords work with the next release.

Proposed promotional text, 150 characters:

> Play the note on your piano. Musica listens and gives instant feedback. Build your child’s daily practice habit with hints, goals, and progress stars.

Proposed opening description:

> Help your child connect notes on the staff with keys on a real piano. Musica shows a note, listens as they play, and gives feedback with helpful hints and celebrations.
>
> Use an acoustic piano or a digital piano with its speakers on. Musica listens through your iPhone microphone; no MIDI cable is needed. Practice individual notes in short sessions between lessons.

Follow with brief sections describing the free allowance, Premium features, progress, and privacy. Preserve accurate subscription disclosures. Explain that a sounding piano is required and that this is individual-note practice rather than a full song curriculum. Avoid absolute recognition claims such as “voices are ignored” until demonstrated under realistic conditions. Promotional copy helps communicate value but is not an extra keyword field.

**Screenshot production brief — highest-priority listing improvement**

The current images contain large white areas, small interface elements, and no explanatory headlines. A visitor sees profile initials before understanding the real-piano interaction. This is a visual diagnosis, not a measured conversion effect. Apple's guidance emphasizes the first one to three screenshots and actual app UI. [Product-page guidance](https://developer.apple.com/app-store/product-page/)

| Order | Headline | Visual evidence |
| --- | --- | --- |
| 1 | Play the note on your piano | Large actual practice UI with a legible staff/note and a clear indication of the physical piano interaction |
| 2 | Musica listens as you play | Actual recognition/correct-answer state plus the hint experience; explain microphone use |
| 3 | Build a daily practice habit | Progress calendar with stars and a reachable daily goal |
| 4 | Grow from treble to grand staff | Actual clef options, labeled Premium where applicable |
| 5 | A profile for each child | Profiles and individual progress, with Premium qualification for multiple profiles |

Use short, high-contrast headlines readable at search-thumbnail size and enlarge the useful UI. Inspect on an actual iPhone before submission. Keep the child-friendly identity for the first iteration; icon simplification can be a separate later test. A short preview demonstrating note → physical key → feedback is useful once the still images and onboarding are clear.

**First-session and paid-conversion work**

Local code currently sets a five-note free daily cap and a twenty-note default daily goal. The practice screen renders the profile goal directly, and the limit overlay appears after five correct notes. This means a default free learner cannot reach the advertised daily celebration without changing the goal or upgrading. This is a concrete source-code finding; release build 4 was not exercised on a device during this investigation.

First make the free goal attainable and show its celebration before any upgrade screen. Then evaluate a larger free allowance—such as a complete twenty-note daily session—with a small user pilot. The allowance is a monetization experiment, not an established optimum; keep unlimited practice, additional profiles, and advanced clefs/key selection as clear Premium benefits.

Guide a parent through placing the phone, enabling the microphone, and successfully detecting a few notes before presenting a purchase decision. Test with both acoustic and speaker-equipped digital pianos. The optional trial must be described using actual StoreKit eligibility and localized terms; no live price or subscription configuration change is proposed here.

Existing uncommitted RatingPrompter work waits for three goal days. Complete/review that existing work rather than duplicating it. Ensure ordinary free users can reach the engagement condition, use Apple's system prompt after an appropriate pause, and add sensible request spacing. Do not infer that requesting the prompt guarantees it appears. [Apple review-request guidance](https://developer.apple.com/design/human-interface-guidelines/ratings-and-reviews)

**Four-week sequence and decision rules**

| When | Work | Completion evidence |
| --- | --- | --- |
| Days 1–3 | Record native search baseline on a fresh-customer device; review the metadata and screenshot brief; test first-session flow with five parent/child pairs or teachers | Document queries/storefront/device; identify where people misunderstand the app; capture first-note success and goal/limit behavior |
| Week 1 | Prepare the next release with clarified metadata, reordered/redesigned screenshots, and attainable free goals | Character limits checked; screenshots readable on iPhone; release-mode free session reaches its goal; accurate Premium and microphone messaging |
| Week 2 | Release after review, then observe complete reporting days; demonstrate to a small group of relevant piano teachers/families using direct product links | Track first-time downloads, search unique impressions, Apple conversion, source, territory, and version; record qualitative activation feedback |
| Weeks 3–4 | If traffic supports it, run one screenshot treatment against control; otherwise continue acquisition and user interviews | Use Apple's confidence result rather than declaring victory from a handful of installs |
| After the initial learning cycle | Consider UK, Australia, and New Zealand availability, a simple demo/marketing page, and dedicated iPad support | Confirm intended markets and app/IAP availability before publishing; validate each platform's experience |

Treat Canada and the US as the initial measurement cohorts. Additional countries add reach but do not repair Canadian ranking. A customer's Apple Account region determines their storefront. [Availability guidance](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/manage-availability-for-your-app-on-the-app-store)

For the first month, use 50–100 relevant first-time users as an acquisition planning target, not a statistical threshold or forecast. Use five observed sessions to find obvious comprehension problems. Do not split today's 29 impressions among multiple experiments. Once there is enough traffic, hold metadata and pricing steady during a screenshot test and use one substantial treatment. Apple tests run for up to 90 days, with results appearing after five attributed first-time downloads; that minimum is not statistical confidence. Require Apple's Performing Better result at at least 90% confidence before claiming a test win. [Test duration](https://developer.apple.com/help/app-store-connect/create-product-page-optimization-tests/run-a-test) · [Result interpretation](https://developer.apple.com/help/app-store-connect-analytics/acquisition/product-page-optimization)

Maintain separate measures for acquisition (impression → download), activation (first successful real-piano session), retention (return to practice), and monetization (trial → paid). For now, observe activation with consented user sessions and use Apple's available aggregate reports; adding telemetry would require a separate product/privacy decision because the published app promises Data Not Collected.

Paid acquisition is optional after the first-session fixes. A separately approved, capped test of specific note-reading intent could help learn which searches convert; broad `musica` or `piano` spend is a poor initial bet given the observed competing intent. Keep paid exposure separate when interpreting search growth. No ads or outreach were launched.

Use [Note Rush's public listing](https://apps.apple.com/us/app/note-rush-music-reading-game/id1083801827) as a closer comparison for real-instrument note reading and teacher positioning than the guitar ad in the screenshot. Compare clarity of interaction and value, not its review count as an immediate target.

If full-title discovery fails on a fresh compatible iPhone in an available storefront, record the app ID, exact query, timestamp, OS, storefront, and product-page availability for an Apple Developer Support investigation. Current evidence supports search exposure with weak discovery; it does not establish a global indexing fault or a guaranteed route to first place for `musica`.
