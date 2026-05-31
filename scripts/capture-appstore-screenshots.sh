#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SIM_NAME="${1:-iPhone 17 Pro Max}"
OUT="$ROOT/AppStoreScreenshots/appstore-6.5"
APP="$ROOT/.derivedData/Build/Products/Debug-iphonesimulator/AQDataPulse.app"

mkdir -p "$OUT"

echo "Building app..."
xcodebuild \
  -project "$ROOT/AQDataPulse.xcodeproj" \
  -scheme AQDataPulse \
  -configuration Debug \
  -destination "platform=iOS Simulator,name=$SIM_NAME" \
  -derivedDataPath "$ROOT/.derivedData" \
  build >/dev/null

DEVICE_ID="$(xcrun simctl list devices available | awk -F '[()]' -v name="$SIM_NAME" '$0 ~ name {print $2; exit}')"
if [[ -z "$DEVICE_ID" ]]; then
  echo "Simulator '$SIM_NAME' not found."
  exit 1
fi

xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator --args -CurrentDeviceUDID "$DEVICE_ID"
sleep 2
xcrun simctl install "$DEVICE_ID" "$APP"

capture() {
  local tab="$1"
  local name="$2"
  xcrun simctl terminate "$DEVICE_ID" com.aureaquantra.datapulse 2>/dev/null || true
  xcrun simctl launch "$DEVICE_ID" com.aureaquantra.datapulse -ScreenshotTab "$tab" >/dev/null
  sleep 3
  xcrun simctl io "$DEVICE_ID" screenshot "$OUT/${name}-raw.png"
  sips -z 2778 1284 "$OUT/${name}-raw.png" --out "$OUT/${name}.png" >/dev/null
  echo "Saved $OUT/${name}.png"
}

capture 0 "01-dashboard"
capture 1 "02-workspaces"
capture 2 "03-alerts"
capture 3 "04-settings"

echo ""
echo "Upload these 1284×2778 PNGs to App Store Connect → iPhone 6.5\" Display:"
ls "$OUT"/0*.png | grep -v raw
