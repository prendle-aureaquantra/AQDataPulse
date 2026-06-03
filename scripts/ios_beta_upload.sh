#!/usr/bin/env bash
# Archive AQ Data Pulse and upload to TestFlight (requires fastlane + ASC API key in fastlane/.env)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -f fastlane/.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source fastlane/.env
  set +a
fi

if [[ -n "${ASC_KEY_PATH:-}" && -f "${ASC_KEY_PATH}" ]]; then
  mkdir -p ~/.appstoreconnect/private_keys
  cp -f "${ASC_KEY_PATH}" ~/.appstoreconnect/private_keys/
fi

bundle exec fastlane beta
