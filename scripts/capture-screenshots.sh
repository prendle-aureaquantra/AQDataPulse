#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/AppStoreScreenshots"
DEVICE_NAME="${1:-iPhone 17 Pro}"
BUNDLE_ID="com.aureaquantra.datapulse"
APP="$ROOT/.derivedData/Build/Products/Debug-iphonesimulator/AQDataPulse.app"

mkdir -p "$OUT"

echo "Building app..."
xcodebuild \
  -project "$ROOT/AQDataPulse.xcodeproj" \
  -scheme AQDataPulse \
  -configuration Debug \
  -destination "platform=iOS Simulator,name=$DEVICE_NAME" \
  -derivedDataPath "$ROOT/.derivedData" \
  build >/dev/null

DEVICE_ID="$(xcrun simctl list devices available | awk -F '[()]' -v name="$DEVICE_NAME" '$0 ~ name {print $2; exit}')"
if [[ -z "$DEVICE_ID" ]]; then
  echo "Simulator '$DEVICE_NAME' not found."
  exit 1
fi

xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator --args -CurrentDeviceUDID "$DEVICE_ID"
sleep 2

xcrun simctl install booted "$APP"
xcrun simctl launch booted "$BUNDLE_ID" >/dev/null
sleep 2

capture() {
  local name="$1"
  echo "Capturing $name..."
  xcrun simctl io booted screenshot "$OUT/$name.png"
  sleep 1
}

capture "01-dashboard"
capture "02-workspaces"
capture "03-alerts"
capture "04-settings"

echo "Screenshots saved to $OUT"
