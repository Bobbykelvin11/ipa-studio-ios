# IPA Studio

An on-device IPA editor for iPhone and iPad (iOS 16+, SwiftUI), by Bobby Media Co.

## Features
- **Import** `.ipa` files from Files, “Open in IPA Studio” share targets, a direct URL (with download progress), or GitHub releases.
- **Inspect**: name, bundle ID, version/build, minimum iOS, icon, sizes, and FairPlay encryption status (`LC_ENCRYPTION_INFO` `cryptid`).
- **Edit**: display name, bundle ID (extensions updated too), version, build, minimum iOS, app icon (Photos/Files, all sizes generated), tint icon, remove `UISupportedDevices`, enable file sharing, raw Info.plist key editor.
- **File browser**: view text/plist/JSON/images, edit text and plists, replace, delete and add files.
- **Repack** to a new unsigned `.ipa` (`_CodeSignature` and `embedded.mobileprovision` stripped). Share it or Save to Files, then sign with Sideloadly or SideStore.
- **Library** of imported projects and exported IPAs.
- **Ask AI** bar: offline command parser (“rename to X”, “change bundle id to …”, “make icon blue”, “enable file sharing”), GitHub search for open-source apps with `.ipa` release assets, DuckDuckGo web search, and optional AI chat via any OpenAI-compatible API (Groq / OpenRouter free tiers). Your key is stored in the Keychain. AI actions run only after you confirm.

## Not included (by design)
No subscription or in-app-purchase unlocking, license bypassing, App Store decryption, or cracking of any kind. Encrypted App Store apps are flagged with a warning.

## Build
GitHub Actions (`.github/workflows/build-ipa.yml`) generates the project with XcodeGen and archives an unsigned build on macOS. Download the `IPAStudio-ipa` artifact.

Dependencies: [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) (MIT).
