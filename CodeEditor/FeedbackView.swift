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
    @State private var isSending = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
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
                .disabled(isSending)
                
                Spacer()
                
                Button(action: copyToClipboard) {
                    Label("Copy to Clipboard", systemImage: "doc.on.clipboard")
                }
                .disabled(feedbackText.isEmpty || isSending)
                .help("Copy feedback to clipboard")
                
                Button(action: sendFeedback) {
                    if isSending {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("Sending...")
                        }
                    } else {
                        Label("Send Feedback", systemImage: "paperplane")
                    }
                }
                .disabled(feedbackText.isEmpty || isSending)
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
            
            if showCopiedAlert {
                Text("✓ Feedback copied to clipboard!")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .transition(.opacity)
            }
            
            if showSuccessAlert {
                Text("✓ Feedback sent successfully! Thank you!")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .transition(.opacity)
            }
            
            if showErrorAlert {
                Text("⚠ Error sending feedback: \(errorMessage)")
                    .font(.caption)
                    .foregroundStyle(.red)
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
        return "Clarity Code Edit v\(version) (build \(build))\nmacOS \(osVersion)\nPremium: \(hasPremium ? "Yes" : "No")"
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
    
    private func sendFeedback() {
        guard let url = URL(string: "https://codeedit.sonomaenterprises.com/api/feedback-handler-v3.aspx") else {
            showError("Invalid URL")
            return
        }
        
        isSending = true
        showSuccessAlert = false
        showErrorAlert = false
        
        // Create a custom URL session configuration with timeout
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        let session = URLSession(configuration: configuration)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("CodeEditor-macOS", forHTTPHeaderField: "User-Agent")
        
        // Prepare the feedback data
        let feedbackData: [String: Any] = [
            "feedbackType": feedbackType.rawValue,
            "feedback": feedbackText,
            "fromEmail": "noreply@sonomaenterprises.com",
            "replyTo": userEmail.isEmpty ? nil : userEmail,
            "systemInfo": includeSystemInfo ? systemInfoString : nil,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: feedbackData)
        } catch {
            showError("Failed to encode feedback data: \(error.localizedDescription)")
            isSending = false
            return
        }
        
        // Debug: Print request details
        print("🔵 Sending feedback to: \(url.absoluteString)")
        print("🔵 Request body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")")
        
        // Send the request
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSending = false
                
                if let error = error {
                    let nsError = error as NSError
                    print("🔴 Network error: \(error.localizedDescription)")
                    print("🔴 Error domain: \(nsError.domain)")
                    print("🔴 Error code: \(nsError.code)")
                    
                    // Provide more specific error messages
                    if nsError.domain == NSURLErrorDomain {
                        switch nsError.code {
                        case NSURLErrorCannotFindHost:
                            showError("Cannot find server. Please check the URL and your internet connection.")
                        case NSURLErrorNotConnectedToInternet:
                            showError("No internet connection. Please check your network settings.")
                        case NSURLErrorTimedOut:
                            showError("Request timed out. Please try again.")
                        case NSURLErrorCannotConnectToHost:
                            showError("Cannot connect to server. The server may be down.")
                        default:
                            showError("Network error: \(error.localizedDescription)")
                        }
                    } else {
                        showError(error.localizedDescription)
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    showError("Invalid response from server")
                    return
                }
                
                print("🟢 Response status code: \(httpResponse.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("🟢 Response body: \(responseString)")
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    // Success
                    withAnimation {
                        showSuccessAlert = true
                    }
                    
                    // Close the dialog after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                } else {
                    // Show response body in error if available
                    var errorMsg = "Server returned status code \(httpResponse.statusCode)"
                    if let data = data, let responseString = String(data: data, encoding: .utf8), !responseString.isEmpty {
                        errorMsg += ": \(responseString)"
                    }
                    showError(errorMsg)
                }
            }
        }
        
        task.resume()
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        withAnimation {
            showErrorAlert = true
        }
        
        // Hide error after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                showErrorAlert = false
            }
        }
    }
}

#Preview {
    FeedbackView()
}
