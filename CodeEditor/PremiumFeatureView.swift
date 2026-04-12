//
//  PremiumFeatureView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import SwiftUI
import StoreKit

/// View shown when user tries to access a premium feature
struct PremiumFeatureView: View {
    @StateObject private var store = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let feature: String
    
    init(feature: String) {
        self.feature = feature
        print("💎 PremiumFeatureView initialized with feature: \(feature)")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.yellow)
                
                Text("Premium Feature")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(feature)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Divider()
                    .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 12) {
                    PremiumFeatureRow(icon: "paintpalette", text: "All 21 programming languages")
                    PremiumFeatureRow(icon: "arrow.triangle.2.circlepath", text: "Find and Replace")
                    PremiumFeatureRow(icon: "tablecells", text: "Column-restricted search")
                    PremiumFeatureRow(icon: "printer", text: "Print with headers & footers")
                    PremiumFeatureRow(icon: "lightbulb", text: "Code completion suggestions")
                    PremiumFeatureRow(icon: "doc.on.doc", text: "Multiple file tabs")
                    PremiumFeatureRow(icon: "rectangle.split.3x1", text: "Split view editing")
                    PremiumFeatureRow(icon: "curlybraces", text: "Code snippets & templates")
                    PremiumFeatureRow(icon: "arrow.triangle.branch", text: "Git integration")
                    PremiumFeatureRow(icon: "paintbrush.pointed", text: "Premium color themes")
                    PremiumFeatureRow(icon: "doc.text.magnifyingglass", text: "Multi-file search")
                
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)
                
                // Purchase section
                VStack(spacing: 12) {
                    if store.isLoading {
                        ProgressView("Loading pricing...")
                            .padding()
                            .onAppear { print("💎 Showing loading state") }
                    } else if let product = store.products.first(where: { $0.id == ProductID.premiumFeatures.rawValue }) {
                        // Show product with price
                        Button(action: {
                            print("💎 PURCHASE BUTTON TAPPED!")
                            Task {
                                do {
                                    print("🛒 Purchase button clicked")
                                    let transaction = try await store.purchase(product)
                                    if transaction != nil {
                                        print("✅ Purchase completed successfully")
                                        dismiss()
                                    } else {
                                        print("⚠️ Purchase returned nil (cancelled or pending)")
                                    }
                                } catch {
                                    print("❌ Purchase error: \(error)")
                                    store.errorMessage = "Purchase failed: \(error.localizedDescription)"
                                }
                            }
                        }) {
                            HStack {
                                Text("Unlock Premium")
                                Spacer()
                                Text(product.displayPrice)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                        .onAppear { 
                            print("💎 Showing REAL purchase button with price: \(product.displayPrice)")
                        }
                    } else {
                        // Fallback button if products didn't load
                        Button(action: {
                            print("💎 FALLBACK BUTTON TAPPED!")
                            Task {
                                print("💎 Trying to reload products...")
                                // Try to reload products
                                await store.loadProducts()
                                
                                // If still no products, try to purchase anyway
                                if let product = store.products.first(where: { $0.id == ProductID.premiumFeatures.rawValue }) {
                                    print("💎 Products loaded, attempting purchase...")
                                    _ = try? await store.purchase(product)
                                    dismiss()
                                } else {
                                    print("❌ Still no products after reload!")
                                    store.errorMessage = "Unable to load purchase options. Please check your internet connection."
                                }
                            }
                        }) {
                            HStack {
                                Text("Unlock Premium")
                                Spacer()
                                Text("$14.99")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                        .onAppear { 
                            print("💎 Showing FALLBACK button (products didn't load) - displaying fallback price")
                        }
                    }
                    
                    // Restore purchases button (always show)
                    Button("Restore Purchases") {
                        Task {
                            await store.restorePurchases()
                            if store.hasPremiumFeatures {
                                dismiss()
                            }
                        }
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                
                if let errorMessage = store.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding()
                }
                
                Button("Not Now") {
                    dismiss()
                }
                .padding(.top)
                .padding(.bottom, 20)
            }
            .padding()
        }
        .frame(width: 550, height: 700)
        .task {
            print("💎 PremiumFeatureView appeared")
            print("💎 Store loading: \(store.isLoading)")
            print("💎 Products count: \(store.products.count)")
            print("💎 Has premium: \(store.hasPremiumFeatures)")
            
            // Ensure products are loaded when view appears
            if store.products.isEmpty {
                print("💎 Products empty, loading...")
                await store.loadProducts()
            } else {
                print("💎 Products already loaded: \(store.products.map { $0.id })")
            }
        }
        .onAppear {
            print("💎 PremiumFeatureView onAppear")
        }
        .onDisappear {
            print("💎 PremiumFeatureView dismissed")
        }
    }
}

private struct PremiumFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            Text(text)
            Spacer()
        }
    }
}

#Preview {
    PremiumFeatureView(feature: "Print with Headers & Footers")
}
