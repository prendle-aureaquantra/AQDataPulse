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

The app requests `https://analysis.windows.net/powerbi/api/.default` at sign-in, which includes **every delegated Power BI permission you enable below**. Add only what you need.

### Microsoft Graph (delegated)

| Permission | Why |
|------------|-----|
| `openid` | Sign-in |
| `profile` | Display name in Settings |
| `offline_access` | Refresh tokens for background sync (v2) |
| `User.Read` | Load profile from Microsoft Graph |

### Power BI Service / Fabric (delegated) — **add these**

| Permission | Why |
|------------|-----|
| **Workspace.Read.All** | List workspaces (matches Workspaces tab) |
| **SemanticModel.Read.All** | Read semantic models in Fabric |
| **Dataset.Read.All** | Refresh history via Power BI REST (`/datasets/.../refreshes`) |
| **Item.Read.All** | Read Fabric items across workspaces |
| **ItemMetadata.Read.All** | Item metadata without write access |

### Optional (add later if needed)

| Permission | When | Admin consent |
|------------|------|---------------|
| **Tenant.Read.All** | Monitor entire tenant, not just workspaces the user already sees | **Yes** |
| **Report.Read.All** | Surface report-level health | No |
| **Dashboard.Read.All** | Surface dashboard health | No |

### Do **not** add for AQ Data Pulse

Skip every **ReadWrite.All** permission (Dataset, Workspace, SemanticModel, Item, etc.). This app is read-only monitoring — write scopes are unnecessary and make admin review harder.

After adding permissions, click **Grant admin consent for [your org]** if `Tenant.Read.All` or your tenant policy requires it.

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
