# AQ Data Pulse

**Know what broke before your users do.**

AQ Data Pulse is a mobile-first monitoring application from Aurea Quantra designed to provide visibility into Microsoft Fabric and Power BI environments.

Version 2.0 delivers live Power BI sync, token refresh, background sync, push registration via `datapulse_api`, and optional Android client.

## Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+

## Getting Started

1. Open `AQDataPulse.xcodeproj` in Xcode
2. Select an iOS Simulator or device
3. Build and run (⌘R)

## Release & integration

- TestFlight checklist: [docs/TESTFLIGHT.md](docs/TESTFLIGHT.md)
- GitHub Actions TestFlight: [docs/GITHUB_ACTIONS_IOS.md](docs/GITHUB_ACTIONS_IOS.md)
- Microsoft OAuth setup: [docs/MICROSOFT_AUTH_SETUP.md](docs/MICROSOFT_AUTH_SETUP.md)
- Screenshot script: `./scripts/capture-screenshots.sh`

## Architecture

- **Platform:** SwiftUI, iOS 17+
- **Pattern:** MVVM
- **Data:** Demo data when signed out; live Power BI sync when connected
- **State:** SwiftUI `@Published` properties; resolved alerts persist for the current session

## Features (v1)

### Dashboard
- Overall health score with trend chart
- Failed refresh count, warnings, workspaces monitored
- Last sync timestamp
- Recent alerts preview
- Beta signup CTA

### Workspaces
Five demo workspaces with semantic models:
- Executive Sales
- Finance Reporting
- Operations Analytics
- Inventory Forecasting
- Customer Insights

### Alerts
- Failed Refresh, Long Running Refresh, No Refresh in 24 Hours
- Filter by All, Active, Resolved, Critical, Warning
- Resolve alerts (session-persistent)

### Model Detail
- Refresh history, error messages, duration
- Copy error to clipboard

### Pricing
- Free, Pro ($19), Business ($99), Consultant ($249)
- No payment processing

### Settings
- Demo mode indicator
- About Aurea Quantra
- Privacy policy
- Support email
- Connect Microsoft (Coming Soon)

## Beta Signup

Tap **Request Beta Access** to send an email to therendle@gmail.com.

## App Store

- **Name:** AQ Data Pulse
- **Subtitle:** BI Platform Health Monitor
- **Category:** Business
- **Price:** Free

## Roadmap

- **v2:** Token refresh, background sync, push + `datapulse_api`, Android app, Fastlane CI
- **v3:** Databricks, Snowflake, Tableau, and additional connectors

Built by [Aurea Quantra](mailto:therendle@gmail.com).
