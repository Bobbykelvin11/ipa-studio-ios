import SwiftUI

struct SettingsView: View {
    @AppStorage("ai_base_url") private var baseURL = "https://api.groq.com/openai/v1"
    @AppStorage("ai_model") private var model = "llama-3.3-70b-versatile"
    @State private var apiKey = Keychain.get("ai_api_key")
    @State private var githubToken = Keychain.get("github_token")
    @State private var testResult: String?
    @State private var testing = false
    @EnvironmentObject var store: LibraryStore

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Base URL", text: $baseURL)
                        .keyboardType(.URL).textInputAutocapitalization(.never).autocorrectionDisabled()
                    TextField("Model", text: $model)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                    SecureField("API key (stored in Keychain)", text: $apiKey)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .onChange(of: apiKey) { Keychain.set($0, for: "ai_api_key") }
                    HStack {
                        Button("Groq preset") {
                            baseURL = "https://api.groq.com/openai/v1"
                            model = "llama-3.3-70b-versatile"
                        }
                        .buttonStyle(.bordered)
                        Button("OpenRouter preset") {
                            baseURL = "https://openrouter.ai/api/v1"
                            model = "meta-llama/llama-3.3-70b-instruct:free"
                        }
                        .buttonStyle(.bordered)
                    }
                    Button {
                        testing = true
                        testResult = nil
                        Task {
                            do {
                                let r = try await AIClient.chat(history: [ChatMessage(role: "user", text: "Say hi in five words.")], context: "settings test")
                                testResult = "✅ " + String(r.prefix(120))
                            } catch {
                                testResult = "❌ " + error.localizedDescription
                            }
                            testing = false
                        }
                    } label: {
                        HStack { Text("Test connection"); if testing { Spacer(); ProgressView() } }
                    }
                    .disabled(apiKey.isEmpty || testing)
                    if let testResult { Text(testResult).font(.caption) }
                } header: {
                    Text("AI chat (optional)")
                } footer: {
                    Text("Any OpenAI-compatible API works. Free keys: console.groq.com or openrouter.ai. Without a key, the Ask bar still works offline for edits and GitHub search.")
                }

                Section {
                    SecureField("GitHub token (optional)", text: $githubToken)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .onChange(of: githubToken) { Keychain.set($0, for: "github_token") }
                } header: {
                    Text("GitHub search")
                } footer: {
                    Text("GitHub allows about 60 searches an hour without a token. A free token with no scopes raises the limit.")
                }

                Section("Editor") {
                    Toggle("Update extension bundle IDs too", isOn: $store.updateExtensionBundleIDs)
                }

                Section {
                    NavigationLink { AboutView() } label: { Label("About IPA Studio", systemImage: "info.circle") }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 10) {
                    if let icon = UIImage(named: "AppIcon") {
                        AppIconView(image: icon, size: 90)
                    } else {
                        AppIconView(image: nil, size: 90)
                    }
                    Text("IPA Studio").font(.title2.bold())
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                        .font(.caption).foregroundStyle(.secondary)
                    Text("by Bobby Media Co").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            Section("What it does") {
                Label("Open .ipa files from Files, links, or GitHub releases", systemImage: "square.and.arrow.down")
                Label("Edit name, bundle ID, version, minimum iOS and icon", systemImage: "slider.horizontal.3")
                Label("Browse, replace and add files inside the app", systemImage: "folder")
                Label("Edit any Info.plist key", systemImage: "list.bullet.rectangle")
                Label("Repack to a new unsigned .ipa", systemImage: "shippingbox")
                Label("Ask AI: plain-language commands and app search", systemImage: "sparkles")
            }
            Section("Signing") {
                Text("Exported IPAs are unsigned (old signatures are removed). Sign and install them with Sideloadly, SideStore or AltStore. With a free Apple ID, re-sign every 7 days.")
                    .font(.footnote)
            }
            Section("Limits") {
                Text("App Store apps are encrypted (FairPlay). IPA Studio shows a warning for these: they can't be meaningfully modified or run after re-signing. IPA Studio does not unlock subscriptions or in-app purchases, bypass licenses, or decrypt apps. Use it with apps you own or open-source apps.")
                    .font(.footnote)
            }
            Section("Open source") {
                Link("Source code on GitHub", destination: URL(string: "https://github.com/Bobbykelvin11/ipa-studio-ios")!)
                Link("ZIPFoundation (MIT)", destination: URL(string: "https://github.com/weichsel/ZIPFoundation")!)
            }
        }
        .navigationTitle("About")
    }
}
