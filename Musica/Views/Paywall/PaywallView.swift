import StoreKit
import SwiftUI

/// The Premium paywall. SubscriptionStoreView does the heavy lifting —
/// localized prices, the 7-day trial badge, purchase flow, and legally
/// required renewal wording all come from StoreKit itself.
struct PaywallView: View {
    /// When set (DEBUG demo screenshots only), show just this one product —
    /// used to capture a clean IAP review screenshot for a specific plan.
    var singleProductID: String?

    var body: some View {
        if let singleProductID {
            singleProductView(productID: singleProductID)
        } else {
            fullPaywall
        }
    }

    private var fullPaywall: some View {
        SubscriptionStoreView(productIDs: Config.premiumProductIDs) {
            marketingContent
        }
        .subscriptionStoreControlStyle(.prominentPicker)
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStorePolicyDestination(url: Config.privacyPolicyURL, for: .privacyPolicy)
        .subscriptionStorePolicyDestination(url: Config.termsOfUseURL, for: .termsOfService)
        .tint(.purple)
    }

    private func singleProductView(productID: String) -> some View {
        SubscriptionStoreView(productIDs: [productID]) {
            marketingContent
        }
        .subscriptionStoreControlStyle(.prominentPicker)
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStorePolicyDestination(url: Config.privacyPolicyURL, for: .privacyPolicy)
        .subscriptionStorePolicyDestination(url: Config.termsOfUseURL, for: .termsOfService)
        .tint(.purple)
    }

    private var marketingContent: some View {
        VStack(spacing: 12) {
            Text("🎹⭐️")
                .font(.system(size: 52))
            Text("Musica Premium")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(
                    LinearGradient(colors: [.purple, .blue],
                                   startPoint: .leading, endPoint: .trailing)
                )
            VStack(alignment: .leading, spacing: 8) {
                benefit("infinity", "Unlimited notes every day")
                benefit("person.2.fill", "Profiles for every kid")
                benefit("music.note.list", "Bass clef and the grand staff")
                benefit("pianokeys", "Pick the exact keys to practice")
                benefit("calendar", "Progress calendar with stars")
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 16)
    }

    private func benefit(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.purple)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}
