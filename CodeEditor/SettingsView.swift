//
//  SettingsView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = StoreManager.shared
    @State private var showPremiumSheet = false
    @State private var selectedTab: SettingsTab = .general
    
    // Settings
    @State private var fontSize: CGFloat = UserDefaults.standard.object(forKey: "fontSize") as? CGFloat ?? 13
    @State private var showStatusBar = UserDefaults.standard.object(forKey: "showStatusBar") as? Bool ?? true
    @State private var autoSave = UserDefaults.standard.object(forKey: "autoSave") as? Bool ?? false
    
    enum SettingsTab: String, CaseIterable {
        case general = "General"
        case premium = "Premium"
        case about = "About"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 8) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        HStack {
                            Image(systemName: iconForTab(tab))
                                .frame(width: 20)
                            Text(tab.rawValue)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedTab == tab ? Color.accentColor.opacity(0.2) : Color.clear)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            .padding()
            .frame(width: 150)
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch selectedTab {
                    case .general:
                        generalSettings
                    case .premium:
                        premiumSettings
                    case .about:
                        aboutSettings
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: 700, height: 550)
        .sheet(isPresented: $showPremiumSheet) {
            PremiumFeatureView(feature: "Unlock all premium features")
        }
        .task {
            // Load products when settings opens
            if store.products.isEmpty {
                await store.loadProducts()
            }
        }
    }
    
    private var generalSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("General")
                .font(.title2)
                .fontWeight(.bold)
            
            Form {
                Toggle("Show status bar", isOn: $showStatusBar)
                    .help("Display file information at the bottom")
                    .onChange(of: showStatusBar) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "showStatusBar")
                    }
                
                Toggle("Auto-save files", isOn: $autoSave)
                    .help("Automatically save files after editing")
                    .onChange(of: autoSave) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "autoSave")
                    }
                
                HStack {
                    Text("Font size:")
                    Slider(value: $fontSize, in: 8...24, step: 1)
                        .frame(width: 200)
                    Text("\(Int(fontSize)) pt")
                        .monospacedDigit()
                        .frame(width: 50)
                }
                .onChange(of: fontSize) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "fontSize")
                }
            }
            
            Text("Note: Some settings apply to new files or require reopening files to take effect.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var premiumSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Premium Features")
                .font(.title2)
                .fontWeight(.bold)
            
            if store.hasPremiumFeatures {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text("Premium Unlocked")
                                .font(.headline)
                            Text("Thank you for your purchase!")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Thank you for your purchase of Code Editor. Your support makes it possible to continue to enhance this product.")
                            .font(.callout)
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                            Text("If you want to send us feedback, you can access the \"Send Feedback\" option under the Help menu.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                }
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Upgrade to Premium")
                        .font(.headline)
                    
                    Text("Get access to all premium features and unlock the full potential of Code Editor")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                }
            }
            
            // Feature list (2-column grid)
            Text("Premium Features:")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.top, 8)
            
            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                FeatureCheckmark(text: "21 languages")
                FeatureCheckmark(text: "Code completion")
                FeatureCheckmark(text: "Column search")
                FeatureCheckmark(text: "Split view")
                FeatureCheckmark(text: "Code snippets")
                FeatureCheckmark(text: "Git integration")
                FeatureCheckmark(text: "Premium themes")
                FeatureCheckmark(text: "Multi-file search")
                FeatureCheckmark(text: "Code folding")
                FeatureCheckmark(text: "Folder support")
            }
            .padding()
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(8)
            
            // Purchase buttons (only if not premium)
            if !store.hasPremiumFeatures {
                Divider()
                
                VStack(spacing: 12) {
                    if store.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Loading pricing...")
                            Spacer()
                        }
                        .padding()
                    } else if let product = store.products.first(where: { $0.id == ProductID.premiumFeatures.rawValue }) {
                        // Show button with real price from StoreKit
                        Button(action: {
                            Task {
                                do {
                                    _ = try await store.purchase(product)
                                } catch {
                                    print("Purchase failed: \(error)")
                                }
                            }
                        }) {
                            HStack {
                                Text("Unlock Premium")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(product.displayPrice)
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Fallback button if products didn't load
                        Button(action: {
                            Task {
                                // Try to reload products
                                await store.loadProducts()
                                
                                // If still no products, try to purchase anyway
                                if let product = store.products.first(where: { $0.id == ProductID.premiumFeatures.rawValue }) {
                                    _ = try? await store.purchase(product)
                                }
                            }
                        }) {
                            HStack {
                                Text("Unlock Premium")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("$14.99")
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Always show restore button
                    Button("Restore Purchases") {
                        Task {
                            await store.restorePurchases()
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
            }
        }
    }
    
    private var aboutSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("Code Editor")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Professional code editing for macOS")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                Form {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                    LabeledContent("Copyright", value: "© 2026 Code Editor")
                }
                
                Divider()
                
                Button(action: {
                    // Dismiss settings first, then show feedback after a short delay
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        NotificationCenter.default.post(name: .showFeedback, object: nil)
                    }
                }) {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Send Feedback")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
        }
    }
    
    private func iconForTab(_ tab: SettingsTab) -> String {
        switch tab {
        case .general: return "gearshape"
        case .premium: return "star.circle.fill"
        case .about: return "info.circle"
        }
    }
}

struct FeatureCheckmark: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
    }
}

#Preview {
    SettingsView()
}
