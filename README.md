# AQ Data Pulse

**Know what broke before your users do.**

AQ Data Pulse is a mobile-first monitoring application from Aurea Quantra designed to provide visibility into Microsoft Fabric and Power BI environments.

Version 1 delivers a polished App Store presence using realistic demo data and lead generation for beta customers.

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
- Microsoft OAuth setup: [docs/MICROSOFT_AUTH_SETUP.md](docs/MICROSOFT_AUTH_SETUP.md)
- Screenshot script: `./scripts/capture-screenshots.sh`

## Architecture

- **Platform:** SwiftUI, iOS 17+
- **Pattern:** MVVM
- **Data:** Local mock data (no backend, database, or login)
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

- **v2:** Microsoft Fabric OAuth, live monitoring, push notifications
- **v3:** Databricks, Snowflake, Tableau, and additional connectors

Built by [Aurea Quantra](mailto:therendle@gmail.com).
