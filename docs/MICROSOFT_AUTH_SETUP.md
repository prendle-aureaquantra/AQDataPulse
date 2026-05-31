# Microsoft OAuth Setup

AQ Data Pulse uses the Microsoft identity platform with PKCE (`ASWebAuthenticationSession`) for sign-in. Live Fabric data sync arrives in v2; v1 stores tokens securely for future API calls.

## 1. Register an Azure app

1. Open [Azure Portal → App registrations](https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade).
2. **New registration**
   - Name: `AQ Data Pulse`
   - Supported account types: **Accounts in any organizational directory and personal Microsoft accounts**
   - Redirect URI: **Public client/native**, `aqdatapulse://auth`
3. Copy the **Application (client) ID**.

## 2. Configure API permissions

Add delegated permissions:

- `openid`
- `profile`
- `offline_access`
- `Dataset.Read.All` or Power BI Service permissions as needed for v2

Grant admin consent if your tenant requires it.

## 3. Update the iOS app

Edit `AQDataPulse/Info.plist`:

```xml
<key>MicrosoftClientID</key>
<string>YOUR_CLIENT_ID_HERE</string>
```

Replace `YOUR_AZURE_CLIENT_ID` with the value from Azure.

## 4. Test sign-in

1. Build and run on simulator or device.
2. Open **Settings → Connect Microsoft → Sign in with Microsoft**.
3. After success, Settings shows **Connected** and demo mode is disabled in the banner.

## Redirect URI reference

| Setting | Value |
|---------|-------|
| URL scheme | `aqdatapulse` |
| Redirect URI | `aqdatapulse://auth` |
| Bundle ID | `com.aureaquantra.datapulse` |

## Token storage

Access and refresh tokens are stored in the iOS Keychain via `KeychainStore`. **Disconnect** clears all auth material.

## v2 next steps

- Call Power BI REST / Fabric APIs using stored tokens
- Refresh tokens before expiry
- Replace `MockDataService` data with live workspace sync
