import Foundation
import StoreKit

/// StoreKit 2 wrapper: knows whether the family has Musica Premium and
/// keeps that answer fresh across purchases, renewals, and refunds.
/// Purchases themselves run through SubscriptionStoreView in PaywallView.
@MainActor
@Observable
final class StoreService {
    static let shared = StoreService()

    private(set) var isPremium = false

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
                await self?.refreshEntitlement()
            }
        }
        Task { await refreshEntitlement() }
    }

    /// True when any verified, unrevoked premium subscription is active.
    /// StoreKit 2 answers from its local cache, so this works offline.
    func refreshEntitlement() async {
        var premium = false
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement,
               Config.premiumProductIDs.contains(transaction.productID),
               transaction.revocationDate == nil {
                premium = true
            }
        }
        isPremium = premium
    }

    /// "Restore Purchases": re-sync with the App Store (asks for sign-in
    /// if needed), then re-evaluate.
    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlement()
    }
}
