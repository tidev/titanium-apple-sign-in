# Apple Sign In — Obtaining Your Credentials

To run the token revocation backend, you need four values from your Apple Developer account.
This guide walks you through finding each one.

---

## Prerequisites

- An active [Apple Developer Program](https://developer.apple.com/programs/) membership
- An app with **Sign In with Apple** already configured

---

## 1. APPLE_TEAM_ID

Your Team ID identifies your Apple Developer account. It is shared across all your apps.

**Steps:**
1. Go to [developer.apple.com](https://developer.apple.com) and sign in
2. Click your name in the top-right corner
3. Select **Membership Details**
4. Copy the value under **Team ID**

**Format:** `ABC123DEF4` (10 alphanumeric characters)

---

## 2. APPLE_BUNDLE_ID

The Bundle ID is the unique identifier of your app — the same one configured in Xcode and App Store Connect.

**Steps:**
1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com) and sign in
2. Select your app
3. Go to **App Information**
4. Copy the value under **Bundle ID**

Alternatively, you can find it in Xcode under your target's **Signing & Capabilities** tab.

**Format:** `com.yourcompany.yourapp`

---

## 3. APPLE_KEY_ID and APPLE_PRIVATE_KEY

These two values come from the same place: a `.p8` key you create in the Apple Developer portal
with the **Sign In with Apple** service enabled.

> **Important:** The `.p8` file can only be downloaded once at the time of creation.
> If you lose it, you will need to delete the key and create a new one.

**Steps:**
1. Go to [developer.apple.com](https://developer.apple.com) → **Certificates, Identifiers & Profiles**
2. Select **Keys** from the left sidebar
3. Click the **+** button to create a new key
4. Give it a name (e.g. `MyApp Sign In with Apple`)
5. Check ✅ **Sign In with Apple**
6. Click **Configure** → select your App ID → click **Save**
7. Click **Continue** → **Register**
8. On the confirmation screen, copy the **Key ID** — this is your `APPLE_KEY_ID`
9. Click **Download** to save the `.p8` file

**APPLE_KEY_ID format:** `XYZ987654A` (10 alphanumeric characters)

### Extracting APPLE_PRIVATE_KEY from the .p8 file

Open the downloaded `.p8` file in any text editor. The contents will look like this:

```
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgrMjSiABcMHmEJFkM
cMVkFiABcMHmEJFkMcMVkFiABcMHmEJFkMcMVkFiABcMHmEJFkMcMVkFiABcMHm
-----END PRIVATE KEY-----
```

This entire content — including the `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` lines — is your `APPLE_PRIVATE_KEY`.

---

## Setting Up Your .env File

Once you have all four values, add them to your `.env` file.

For the private key, replace each line break with `\n` and wrap the entire value in double quotes:

```bash
# Apple Developer Account
APPLE_TEAM_ID="ABC123DEF4"
APPLE_KEY_ID="XYZ987654A"
APPLE_BUNDLE_ID="com.yourcompany.yourapp"

# Contents of the .p8 file — use \n for each line break
APPLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg...\n-----END PRIVATE KEY-----"
```

> **Security reminder:** Never commit your `.env` file to version control.
> Add it to your `.gitignore` and store these values securely
> (e.g. environment variables on your server, a secrets manager, or a vault service).

---

## Verifying Your Setup

After configuring your `.env`, you can verify that everything is working by sending a test request
to your revocation endpoint using curl:

```bash
curl -X POST https://yourbackend.com/apple/revoke \
  -H "Content-Type: application/json" \
  -d '{"authorization_code": "YOUR_CODE_HERE"}'
```

A successful response looks like:

```json
{ "success": true }
```

> **Note:** A real `authorization_code` is required for this test — it is obtained from the
> Apple Sign In flow on a physical iOS device. The iOS Simulator does not return valid codes.

---

## Troubleshooting

| Error | Likely Cause |
|---|---|
| `invalid_client` | Wrong `APPLE_TEAM_ID`, `APPLE_KEY_ID`, or `APPLE_BUNDLE_ID` |
| `invalid_grant` | `authorization_code` has expired (valid for ~5 minutes) or already used |
| `Failed to exchange authorization code` | Private key is malformed — check the `\n` line breaks |
| `HTTP 400` from Apple | Bundle ID does not match the app that generated the code |

---

## Summary

| Variable | Where to Find |
|---|---|
| `APPLE_TEAM_ID` | developer.apple.com → Your name → Membership Details |
| `APPLE_BUNDLE_ID` | App Store Connect → Your app → App Information |
| `APPLE_KEY_ID` | developer.apple.com → Keys → Your key |
| `APPLE_PRIVATE_KEY` | Contents of the `.p8` file downloaded when creating the key |
