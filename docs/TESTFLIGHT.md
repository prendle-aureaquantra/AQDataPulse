# TestFlight & App Store Checklist

## Prerequisites

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) ($99/year).
2. Sign in to Xcode with your Apple ID: **Xcode → Settings → Accounts**.
3. Create the app record in [App Store Connect](https://appstoreconnect.apple.com/) using bundle ID `com.aureaquantra.datapulse`.

## App metadata

| Field | Value |
|-------|-------|
| Name | AQ Data Pulse |
| Subtitle | BI Platform Health Monitor |
| Category | Business |
| Price | Free |
| Privacy Policy URL | Host the in-app policy and paste the public URL in App Store Connect |

## Build & upload

```bash
cd /Users/paulrendleman/Desktop/AQDataPulse

# Archive for release
xcodebuild \
  -scheme AQDataPulse \
  -project AQDataPulse.xcodeproj \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/AQDataPulse.xcarchive \
  archive

# Upload to App Store Connect
xcodebuild \
  -exportArchive \
  -archivePath build/AQDataPulse.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/export
```

Or in Xcode: **Product → Archive**, then **Distribute App → App Store Connect**.

## Screenshots

```bash
chmod +x scripts/capture-screenshots.sh
./scripts/capture-screenshots.sh "iPhone 17 Pro"
```

Upload PNGs from `AppStoreScreenshots/` to App Store Connect. Capture additional sizes if required (6.7", 6.5", iPad).

## TestFlight

1. Upload a build (steps above).
2. In App Store Connect → **TestFlight**, wait for processing.
3. Add internal testers (your team) or external testers.
4. Submit export compliance: select **No** for encryption if you only use standard HTTPS.

## Version 1 review notes

Tell App Review:

- The app uses **demo data only**; no login is required.
- **Connect Microsoft** is optional scaffolding for a future release.
- Beta signup opens the user’s Mail app; no in-app account is created.

## Before each release

- [ ] Bump `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in Xcode (current: **1.1** / **2**)
- [ ] Verify app icon appears on home screen
- [ ] Run on a physical device
- [ ] Update privacy policy if data collection changes
