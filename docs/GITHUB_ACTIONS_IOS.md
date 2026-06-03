# GitHub Actions — iOS TestFlight

Build and upload **AQ Data Pulse** from GitHub’s `macos-latest` runner (no cloud Mac required).

## One-time: repository secrets

[AQDataPulse → Settings → Secrets and variables → Actions](https://github.com/prendle-aureaquantra/AQDataPulse/settings/secrets/actions)

| Secret | Required | Notes |
|--------|----------|--------|
| `ASC_KEY_ID` | Yes | App Store Connect API Key ID |
| `ASC_ISSUER_ID` | Yes | Issuer ID from Connect → Integrations |
| `ASC_KEY_P8` | Yes* | Full `.p8` file text (multiline OK) |
| `ASC_KEY_CONTENT` | Yes* | Alternative: `base64 -i AuthKey_XXX.p8` (macOS/Linux) |
| `AUREAQUANTRA_GITHUB_TOKEN` | No | GitHub PAT — only if checkout fails; same-repo uses built-in token |

\* Provide **one** of `ASC_KEY_P8` or `ASC_KEY_CONTENT`. Reuse Cyrano’s key if it has access to the Data Pulse app in Connect.

### Create `ASC_KEY_CONTENT` (PowerShell, from your `.p8`)

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\to\AuthKey_GQ2Z8VT8NK.p8"))
```

Paste the output into the `ASC_KEY_CONTENT` secret.

## Run the workflow

1. Push this repo to `origin/main`.
2. **Actions** → **iOS TestFlight** → **Run workflow**.
3. Optional: enable **Build only** to test archive/signing without uploading.

Jobs:

1. **verify-api** — confirms the Connect API key (`fastlane verify_api`).
2. **beta** — archive + TestFlight upload (`fastlane beta`).

## Troubleshooting

| Failure | Fix |
|---------|-----|
| Missing ASC secrets | Add secrets above |
| `verify_api` fails | Key not Admin/App Manager, or wrong Issuer ID |
| Signing / provisioning | Ensure `com.aureaquantra.datapulse` exists in Connect; open Xcode once on a Mac to refresh profiles |
| SDK too old | Runner Xcode is usually current; compare with App Store minimum |

Local dry run (on a Mac):

```bash
cd AQDataPulse
cp fastlane/.env.example fastlane/.env   # edit paths
bundle install
bundle exec fastlane verify_api
```
