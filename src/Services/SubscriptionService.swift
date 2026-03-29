import Foundation
import StoreKit

// MARK: - Subscription Tier
enum SubscriptionTier: String, CaseIterable, Codable {
    case free = "free"
    case pro = "pro"
    case family = "family"

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .pro: return "Pro"
        case .family: return "Family"
        }
    }

    var swipeLimitPerDay: Int {
        switch self {
        case .free: return 10
        case .pro: return 100
        case .family: return 100
        }
    }

    var hasTasteDNA: Bool {
        return self != .free
    }

    var historyDays: Int? {
        switch self {
        case .free: return 7
        case .pro: return nil  // Permanent
        case .family: return nil
        }
    }

    var hasWeeklyReport: Bool {
        return self != .free
    }

    var familySlots: Int {
        switch self {
        case .free: return 0
        case .pro: return 1
        case .family: return 5
        }
    }
}

// MARK: - Subscription Product IDs
enum SubscriptionProductID: String, CaseIterable {
    case proMonthly = "com.whattoeat.pro.monthly"
    case proYearly = "com.whattoeat.pro.yearly"
    case familyMonthly = "com.whattoeat.family.monthly"
    case familyYearly = "com.whattoeat.family.yearly"

    var tier: SubscriptionTier {
        switch self {
        case .proMonthly, .proYearly: return .pro
        case .familyMonthly, .familyYearly: return .family
        }
    }

    var isYearly: Bool {
        switch self {
        case .proYearly, .familyYearly: return true
        case .proMonthly, .familyMonthly: return false
        }
    }

    var displayPrice: String {
        switch self {
        case .proMonthly: return "¥9.9/月"
        case .proYearly: return "¥79/年"
        case .familyMonthly: return "¥19.9/月"
        case .familyYearly: return "¥159/年"
        }
    }

    var savings: String? {
        switch self {
        case .proYearly: return "省¥40"
        case .familyYearly: return "省¥79"
        default: return nil
        }
    }
}

// MARK: - Subscription State
struct SubscriptionState {
    var tier: SubscriptionTier = .free
    var expiresAt: Date?
    var swipeCountToday: Int = 0
    var swipeResetDate: Date = Date()

    var isActive: Bool {
        if tier == .free { return true }
        guard let expires = expiresAt else { return false }
        return expires > Date()
    }

    var remainingSwipes: Int {
        max(0, tier.swipeLimitPerDay - swipeCountToday)
    }

    var canSwipe: Bool {
        return remainingSwipes > 0
    }
}

// MARK: - Subscription Manager
@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published private(set) var state = SubscriptionState()
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private var updateListenerTask: Task<Void, Error>?

    // UserDefaults Keys
    private let swipeCountKey = "swipe_count_today"
    private let swipeResetDateKey = "swipe_reset_date"
    private let subscriptionTierKey = "subscription_tier"
    private let subscriptionExpiresKey = "subscription_expires"

    private init() {
        loadState()
        updateListenerTask = listenForTransactions()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Public API

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let productIDs = Set(SubscriptionProductID.allCases.map { $0.rawValue })
            products = try await Product.products(for: productIDs)
            products.sort { $0.price < $1.price }
            isLoading = false
        } catch {
            errorMessage = "无法加载订阅产品"
            isLoading = false
        }
    }

    func purchase(_ productID: SubscriptionProductID) async throws -> Bool {
        guard let product = products.first(where: { $0.id == productID.rawValue }) else {
            throw SubscriptionError.productNotFound
        }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateState(from: transaction)
                await transaction.finish()
                isLoading = false
                return true

            case .userCancelled:
                isLoading = false
                return false

            case .pending:
                errorMessage = "购买待处理，请稍后"
                isLoading = false
                return false

            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }

    func restorePurchases() async {
        isLoading = true

        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                do {
                    let transaction = try checkVerified(result)
                    await updateState(from: transaction)
                } catch {
                    // Skip invalid transactions
                }
            }
            isLoading = false
        } catch {
            errorMessage = "恢复购买失败"
            isLoading = false
        }
    }

    func checkSwipe() -> Bool {
        checkSwipeReset()
        if state.canSwipe {
            incrementSwipeCount()
            return true
        }
        return false
    }

    func resetSwipeCount() {
        state.swipeCountToday = 0
        state.swipeResetDate = Date()
        saveState()
    }

    // MARK: - Private Methods

    private func loadState() {
        // Load subscription tier
        if let tierString = UserDefaults.standard.string(forKey: subscriptionTierKey),
           let tier = SubscriptionTier(rawValue: tierString) {
            state.tier = tier
        }

        // Load expiration date
        if let expires = UserDefaults.standard.object(forKey: subscriptionExpiresKey) as? Date {
            state.expiresAt = expires
        }

        // Load swipe count
        state.swipeCountToday = UserDefaults.standard.integer(forKey: swipeCountKey)

        // Load reset date
        if let resetDate = UserDefaults.standard.object(forKey: swipeResetDateKey) as? Date {
            state.swipeResetDate = resetDate
        }

        checkSwipeReset()
    }

    private func saveState() {
        UserDefaults.standard.set(state.tier.rawValue, forKey: subscriptionTierKey)
        if let expires = state.expiresAt {
            UserDefaults.standard.set(expires, forKey: subscriptionExpiresKey)
        }
        UserDefaults.standard.set(state.swipeCountToday, forKey: swipeCountKey)
        UserDefaults.standard.set(state.swipeResetDate, forKey: swipeResetDateKey)
    }

    private func checkSwipeReset() {
        let calendar = Calendar.current
        if !calendar.isDateInToday(state.swipeResetDate) {
            state.swipeCountToday = 0
            state.swipeResetDate = Date()
            saveState()
        }
    }

    private func incrementSwipeCount() {
        state.swipeCountToday += 1
        saveState()
    }

    private func updateState(from transaction: Transaction) async {
        // Check subscription status
        if let subscriptionInfo = transaction.subscriptionGroupID {
            // Determine tier from product ID
            let productID = transaction.productID
            if productID.contains("family") {
                state.tier = .family
            } else if productID.contains("pro") {
                state.tier = .pro
            }
            state.expiresAt = transaction.expirationDate
        }

        saveState()
    }

    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateState(from: transaction)
                    await transaction.finish()
                } catch {
                    // Log error
                }
            }
        }
    }
}

// MARK: - Subscription Error
enum SubscriptionError: Error, LocalizedError {
    case productNotFound
    case verificationFailed
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .productNotFound: return "未找到订阅产品"
        case .verificationFailed: return "购买验证失败"
        case .purchaseFailed: return "购买失败"
        }
    }
}
