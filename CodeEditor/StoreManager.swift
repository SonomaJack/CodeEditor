//
//  StoreManager.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import StoreKit
import SwiftUI
import Combine

/// Product identifiers for in-app purchases
enum ProductID: String, CaseIterable {
    case premiumFeatures = "com.yourcompany.claritycode.premium"  // Using existing App Store Connect ID
    
    var displayName: String {
        switch self {
        case .premiumFeatures:
            return "Clarity Code Edit - Premium Features"
        }
    }
    
    var description: String {
        switch self {
        case .premiumFeatures:
            return "Unlock all languages, find & replace, printing, code completion, and more"
        }
    }
}

/// Manages in-app purchases and premium feature access
@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProducts: Set<String> = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    private var updateListenerTask: Task<Void, Never>?
    
    init() {
        print("🏪 StoreManager initializing...")
        updateListenerTask = listenForTransactions()
        
        Task {
            print("🏪 Loading products and purchases...")
            await loadProducts()
            await updatePurchasedProducts()
            print("🏪 Initialization complete. Products: \(products.count), Purchased: \(purchasedProducts.count)")
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    /// Load products from the App Store
    func loadProducts() async {
        print("📦 Loading products from App Store...")
        isLoading = true
        defer { 
            isLoading = false
            print("📦 Loading complete. Found \(products.count) product(s)")
        }
        
        do {
            let productIds = ProductID.allCases.map { $0.rawValue }
            print("📦 Requesting products: \(productIds)")
            products = try await Product.products(for: productIds)
            
            if products.isEmpty {
                print("⚠️ No products returned from App Store")
            } else {
                for product in products {
                    print("✅ Product loaded: \(product.id) - \(product.displayName) - \(product.displayPrice)")
                }
            }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("❌ Failed to load products: \(error)")
        }
    }
    
    /// Purchase a product
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        print("🛒 Attempting to purchase: \(product.id)")
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            print("✅ Purchase successful, verifying...")
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedProducts()
            print("✅ Transaction finished and products updated")
            return transaction
            
        case .userCancelled:
            print("❌ User cancelled purchase")
            errorMessage = "Purchase was cancelled"
            return nil
            
        case .pending:
            print("⏳ Purchase is pending")
            errorMessage = "Purchase is pending approval"
            return nil
            
        @unknown default:
            print("⚠️ Unknown purchase result")
            errorMessage = "An unknown error occurred"
            return nil
        }
    }
    
    /// Restore purchases
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            print("Failed to restore purchases: \(error)")
        }
    }
    
    /// Check if user has premium features
    var hasPremiumFeatures: Bool {
        // Check override first (for TestFlight testing)
        if FeatureAccess.overridePremiumForTesting {
            print("🔐 Premium check: ✅ HAS PREMIUM (OVERRIDE ACTIVE)")
            return true
        }
        
        // Check actual purchase status
        let result = purchasedProducts.contains(ProductID.premiumFeatures.rawValue)
        print("🔐 Premium check: \(result ? "✅ HAS PREMIUM" : "❌ NO PREMIUM")")
        return result
    }
    
    /// Update the list of purchased products
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchased.insert(transaction.productID)
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        purchasedProducts = purchased
    }
    
    /// Listen for transaction updates
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try await MainActor.run {
                        try self.checkVerified(result)
                    }
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    /// Verify a transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
