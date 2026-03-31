//
//  StoreManager.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import StoreKit
import SwiftUI

/// Product identifiers for in-app purchases
enum ProductID: String, CaseIterable {
    case premiumFeatures = "com.codeeditor.premium"
    
    var displayName: String {
        switch self {
        case .premiumFeatures:
            return "Premium Features"
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
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    /// Load products from the App Store
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let productIds = ProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIds)
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("Failed to load products: \(error)")
        }
    }
    
    /// Purchase a product
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedProducts()
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            return nil
            
        @unknown default:
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
        purchasedProducts.contains(ProductID.premiumFeatures.rawValue)
    }
    
    /// Update the list of purchased products
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
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
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
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
