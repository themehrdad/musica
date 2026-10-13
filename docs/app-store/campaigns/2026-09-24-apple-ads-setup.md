# Musica Apple Ads initial setup — September 24, 2026

Status: RUNNING, verified after the user completed business details and added a payment method. All previous holds cleared. At verification (September 25, 2026, approximately 05:26 UTC / September 24, 10:26 PM Vancouver), dashboard reports CAD 0 spend, 0 impressions, and 0 installs. Reporting may lag up to three hours. Previously held for App pending review, No payment method, and Tax Information Issues. The user authorized the previously proposed CAD 100 initial test and explicitly authorized acceptance of Apple's agreement at the acceptance step.

Campaign ID: 2144753115. Ad group ID: 2151353472. Account/campaign group URL identifier: 24380240.

Campaign: https://app-ads.apple.com/cm/app/24380240/report/campaign/2144753115

## Account preparation

Only Higgs Software Services Inc. was selected for linking. The unrelated Relentless Ventures LLC account was deselected. Account name: Musica Higgs Software Services. Legal entity: Higgs Software Services Inc. Primary contact name and the existing signed-in email were populated. The user supplied the phone number in the browser; visual inspection confirmed it was present despite the text snapshot omitting its value. No contact phone number is stored here.

Country: Canada. Currency: Canadian Dollar. Time zone: America/Vancouver. Marketing email opt-in left unchecked, preserving the user's choice. Apple Advertising Services Terms of Service (effective July 28, 2026) accepted after the user's explicit “yes please.”

The user completed business details and added a payment method. Billing confirms a payment method is present and the dashboard no longer shows business/tax or payment holds. Private tax, address, and card information are not stored here.

## Promotional credit verified after billing setup

Billing shows Promo Credit / Date Applied / September 25, 2026. Apple's help explicitly identifies that date as confirmation that a credit was applied. The standard new App Store advertising account offer is USD 100, converted into the account currency (CAD) using Apple's daily exchange rate. Billing currently shows neither the initial converted amount nor a remaining credit balance; no invoices/card transactions are available yet. Do not invent the precise CAD amount or account-specific expiry. Apple directs users to invoices to track applied credit and calculate the balance. Taxes and other fees cannot be paid with the promotional credit, and excess costs can be charged to the payment method. The existing campaign budget and end date were not increased because of the credit.

Sources checked September 25 UTC: https://ads.apple.com/app-store/help/billing/0032-apple-ads-promo-credit and https://ads.apple.com/promo-terms.

## Saved campaign configuration

- Name: Musica CA Piano Note Reading Test.
- Placement: App Store Search Results.
- Country: Canada.
- App: 6794258266, Musica: Piano Note Practice.
- Devices: compatible iPhones; avoid paying for unsupported platform traffic.
- Bidding: manual maximum cost per tap so individual keywords can be controlled.
- Ad group: Note Reading Exact All Eligible (renamed September 27 after removing the New users restriction); exact match; Search Match off. Saved ad-group report confirms Search Match Off and CAD 1.50 default max CPT.
- Ten keywords saved, each at CAD 1.50 maximum CPT and Exact match: piano note reading; piano note practice; learn piano notes; sight reading piano; piano sight reading; sight reading; read music piano; treble clef practice; bass clef practice; music note trainer.
- Apple's keyword popularity indicators returned 1 for all ten terms. These are relative indicators, not search-volume estimates. General recommendations were unrelated popular apps and were not added. Delivery may be limited by low keyword volume or the opening bid.
- Do not bid initially on the ambiguous brand term musica, music streaming, music players, piano tiles, or general entertainment games. Add clearly irrelevant search terms as negatives if they appear in reporting.
- Initially New users selected, iPhone only, all genders and ages, all locations within Canada, no daypart restrictions. On September 27, after roughly three days with zero recorded delivery, switched to Reach All Eligible Users. See 2026-09-27-delivery-review.md for evidence and rationale.
- Use the current default product page and screenshots. Its first image clearly states that a real piano is required; later images label Premium benefits. Custom product pages can be a later experiment after sufficient traffic.

## Spending controls

Saved daily budget: CAD 8. Campaign start: September 24, 2026, 12:00 AM America/Vancouver. Campaign end: October 3, 2026, 11:59 PM America/Vancouver. These persisted settings were reopened and verified after creation. This spans ten calendar dates, conservatively allocating no more than CAD 80 in media under Apple's documented date-based budget rule, with CAD 20 reserved within the authorized CAD 100 for taxes/charges. Apple's interface reports 9 total/days-left for this schedule; do not claim that its displayed count was 10. Holds may shorten actual delivery; no automatic extension is authorized. Billing and applicable tax treatment remain unverified.

Apple's current help states that with a campaign end date, spend will not exceed the number of campaign days multiplied by the daily budget. A daily budget alone is an average and does not cap an individual day's spend. Set both start and end dates, count inclusive campaign days in the account time zone, and verify the resulting media limit. Do not extend the campaign or raise its overall allocation automatically.

Apple suggested CAD 2.06 for the ad-group default max CPT. Selected CAD 1.50 initially to limit the cost of learning. This can underdeliver; no install or subscription forecast is validated. Review actual delivery before raising bids or widening terms, and preserve the overall spending limit.

## Optimization and measurement

Use impressions, taps, tap-through installs, new downloads, spend, and cost per new download from Apple Ads. Distinguish new downloads from redownloads and tap-through from view-through attribution. Keep paid performance separate from aggregate App Store Search growth.

Subscription acquisition is the business objective, but the current app has no identified AdServices attribution integration. Do not claim direct per-keyword trial or paid-subscription measurement. App Store Connect subscription results can provide aggregate context subject to reporting thresholds and attribution limits. No telemetry or privacy changes are included in this campaign task.

After launch, investigate absence of delivery before widening terms: account/billing status, app eligibility, keyword volume, and bid competitiveness. If there are taps but no downloads, examine query relevance and the real-piano requirement. A provisional review trigger of 15–20 taps without a new download can help avoid spending the entire test on one weak term, but it is a practical budget rule rather than statistical proof. Observe actual practice sessions to diagnose activation and subscription interest.

No recurring campaign monitor has been scheduled. A fixed end date is the primary spending safeguard; do not imply continuous oversight until an authorized monitor is configured and functioning.

Source: https://ads.apple.com/app-store/help/bids-and-budget/0016-manage-budgets (checked September 24, 2026).
