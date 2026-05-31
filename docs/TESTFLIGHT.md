# TestFlight & App Store Checklist

## Prerequisites

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) ($99/year).
2. Sign in to Xcode with your Apple ID: **Xcode → Settings → Accounts**.
3. In Xcode, open the project → **AQDataPulse** target → **Signing & Capabilities** → select your **Team** (required for archive/upload).
4. Create the app record in [App Store Connect](https://appstoreconnect.apple.com/) using bundle ID `com.aureaquantra.datapulse`.

## App metadata

| Field | Value |
|-------|-------|
| Name | AQ Data Pulse |
| Subtitle | BI Platform Health Monitor |
| Category | Business |
| Price | Free |
| Privacy Policy URL | Host the in-app policy and paste the public URL in App Store Connect |

## Build & upload

**Fastest path:** open the project in Xcode, then **Product → Archive → Distribute App → App Store Connect**.

Or run the helper script (after selecting a Team in Xcode):

```bash
chmod +x scripts/upload-testflight.sh
./scripts/upload-testflight.sh
```

## Screenshots

```bash
chmod +x scripts/capture-screenshots.sh
./scripts/capture-screenshots.sh "iPhone 17 Pro"
```

Upload PNGs from `AppStoreScreenshots/appstore-6.5/`. Paste-ready metadata: [APP_STORE_COPY.md](APP_STORE_COPY.md). Privacy policy HTML: [privacy-policy.html](privacy-policy.html).

## TestFlight

1. Upload a build (steps above).
2. In App Store Connect → **TestFlight**, wait for processing.
3. Add internal testers (your team) or external testers.
4. Submit export compliance: select **No** for encryption if you only use standard HTTPS.

## Version 1.1 review notes

Tell App Review:

- **Demo mode** when signed out (sample workspaces and alerts).
- **Connect Microsoft** is optional; when used, live Power BI workspace data is shown.
- Microsoft sign-in uses standard OAuth; tokens stored in Keychain only.
- Beta signup opens the user’s Mail app; no in-app account is created.
- Export compliance: **No** custom encryption (HTTPS only).

## Before each release

- [ ] Bump `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in Xcode (current: **1.1** / **2**)
- [ ] Verify app icon appears on home screen
- [ ] Run on a physical device
- [ ] Update privacy policy if data collection changes
