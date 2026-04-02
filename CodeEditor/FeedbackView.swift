//
//  FeedbackView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackType: FeedbackType = .general
    @State private var feedbackText = ""
    @State private var userEmail = ""
    @State private var includeSystemInfo = true
    @State private var showCopiedAlert = false
    
    enum FeedbackType: String, CaseIterable {
        case bug = "Bug Report"
        case feature = "Feature Request"
        case general = "General Feedback"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Send Feedback")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            
            Form {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Feedback Type:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Picker("", selection: $feedbackType) {
                        ForEach(FeedbackType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Email (optional):")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    TextField("email@example.com", text: $userEmail)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("Include your email if you'd like a response")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Feedback:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 150)
                        .font(.body)
                        .border(Color.gray.opacity(0.3), width: 1)
                        .cornerRadius(4)
                }
                
                Toggle("Include system information (helps with debugging)", isOn: $includeSystemInfo)
                    .font(.caption)
            }
            
            if includeSystemInfo {
                VStack(alignment: .leading, spacing: 4) {
                    Text("System Information:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Text(systemInfoString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button(action: copyToClipboard) {
                    Label("Copy to Clipboard", systemImage: "doc.on.clipboard")
                }
                .disabled(feedbackText.isEmpty)
                .help("Copy feedback to clipboard, then paste into email")
                
                Button(action: sendFeedbackViaEmail) {
                    Label("Open Email", systemImage: "envelope")
                }
                .disabled(feedbackText.isEmpty)
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
            
            if showCopiedAlert {
                Text("✓ Feedback copied to clipboard!")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .transition(.opacity)
            }
        }
        .padding(24)
        .frame(width: 550, height: 550)
    }
    
    private var systemInfoString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let hasPremium = StoreManager.shared.hasPremiumFeatures
        return "Code Editor v\(version) (build \(build))\nmacOS \(osVersion)\nPremium: \(hasPremium ? "Yes" : "No")"
    }
    
    private var fullFeedbackText: String {
        var text = "Feedback Type: \(feedbackType.rawValue)\n\n"
        text += feedbackText
        
        if includeSystemInfo {
            text += "\n\n---\nSystem Information:\n\(systemInfoString)"
        }
        
        if !userEmail.isEmpty {
            text += "\n\nReply to: \(userEmail)"
        }
        
        return text
    }
    
    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(fullFeedbackText, forType: .string)
        
        withAnimation {
            showCopiedAlert = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedAlert = false
            }
        }
    }
    
    private func sendFeedbackViaEmail() {
        // Replace with your actual email address
        let email = "feedback@yourapp.com"
        let subject = "[Code Editor] \(feedbackType.rawValue)"
        let body = fullFeedbackText
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            NSWorkspace.shared.open(url)
            
            // Also copy to clipboard as backup
            copyToClipboard()
        }
    }
}

#Preview {
    FeedbackView()
}
