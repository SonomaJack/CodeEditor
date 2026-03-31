//
//  PremiumFeatureView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import SwiftUI

/// View shown when user tries to access a premium feature
struct PremiumFeatureView: View {
    @StateObject private var store = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let feature: String
    
    var body: some View {
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
                FeatureRow(icon: "paintpalette", text: "All programming languages")
                FeatureRow(icon: "arrow.triangle.2.circlepath", text: "Find and Replace")
                FeatureRow(icon: "printer", text: "Print with headers & footers")
                FeatureRow(icon: "lightbulb", text: "Code completion suggestions")
                FeatureRow(icon: "doc.on.doc", text: "Multiple file tabs")
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            
            if store.isLoading {
                ProgressView()
                    .padding()
            } else if let product = store.products.first(where: { $0.id == ProductID.premiumFeatures.rawValue }) {
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            do {
                                _ = try await store.purchase(product)
                                dismiss()
                            } catch {
                                print("Purchase failed: \(error)")
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
            }
            
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
        }
        .padding()
        .frame(width: 500, height: 600)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.accentColor)
                .frame(width: 24)
            Text(text)
            Spacer()
        }
    }
}

#Preview {
    PremiumFeatureView(feature: "Print with Headers & Footers")
}
