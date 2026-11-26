import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let ipa: UTType = UTType(importedAs: "com.apple.itunes.ipa", conformingTo: .zip)
}

@main
struct IPAStudioApp: App {
    @StateObject private var store = LibraryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onOpenURL { url in
                    guard url.isFileURL else { return }
                    Task {
                        do {
                            try await store.importIPA(from: url)
                        } catch {
                            store.lastError = error.localizedDescription
                        }
                    }
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var store: LibraryStore
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            HomeView(selectedTab: $tab)
                .tabItem { Label("Studio", systemImage: "sparkles") }
                .tag(0)
            LibraryView()
                .tabItem { Label("Library", systemImage: "shippingbox") }
                .tag(1)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(2)
        }
        .overlay {
            if let msg = store.busyMessage {
                BusyOverlay(message: msg)
            }
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { store.lastError != nil },
            set: { if !$0 { store.lastError = nil } }
        )) {
            Button("OK", role: .cancel) { store.lastError = nil }
        } message: {
            Text(store.lastError ?? "")
        }
    }
}
