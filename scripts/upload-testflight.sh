#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVE="$ROOT/build/AQDataPulse.xcarchive"
EXPORT="$ROOT/build/export"

cd "$ROOT"
mkdir -p build

echo "Checking code signing identities..."
if ! security find-identity -v -p codesigning | grep -q "Apple Development\|Apple Distribution"; then
  echo ""
  echo "No signing certificate found."
  echo "1. Open Xcode → Settings → Accounts → add your Apple ID"
  echo "2. Enroll in Apple Developer Program (\$99/yr) if needed"
  echo "3. Open AQDataPulse.xcodeproj → target → Signing & Capabilities → select Team"
  echo "4. Re-run this script"
  exit 1
fi

echo "Archiving AQ Data Pulse (Release)..."
xcodebuild \
  -scheme AQDataPulse \
  -project AQDataPulse.xcodeproj \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE" \
  archive

echo "Uploading to App Store Connect..."
xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath "$EXPORT"

echo ""
echo "Upload complete. Open App Store Connect → TestFlight to manage testers."
echo "https://appstoreconnect.apple.com/"
