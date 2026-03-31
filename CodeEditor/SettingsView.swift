//
//  SettingsView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var store = StoreManager.shared
    @State private var showPremiumSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
            
            Form {
                Section("Premium Features") {
                    if store.hasPremiumFeatures {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Premium Unlocked")
                                .fontWeight(.medium)
                        }
                        
                        Text("You have access to all premium features!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Unlock Premium Features")
                                .font(.headline)
                            
                            Text("Get access to all programming languages, find & replace, printing, and more!")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Button("View Premium Features") {
                                showPremiumSheet = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                }
            }
            .formStyle(.grouped)
            
            Spacer()
        }
        .padding()
        .frame(width: 500, height: 400)
        .sheet(isPresented: $showPremiumSheet) {
            PremiumFeatureView(feature: "Unlock all premium features")
        }
    }
}

#Preview {
    SettingsView()
}
