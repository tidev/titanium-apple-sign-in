# Apple Sign In in Titanium

![Titanium](https://img.shields.io/badge/Titanium-13.1+-red.svg) ![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg) ![License](https://img.shields.io/badge/license-MIT-blue.svg) ![Maintained](https://img.shields.io/badge/Maintained-Yes-green.svg)

Full support for Apple Sign In with Titanium.

## Requirements

- [x] Xcode 16+
- [x] iOS 15+
- [x] Titanium SDK 13.1.0+

## Example

```js
var AppleSignIn = require('ti.applesignin');

// Fired when the user logs in
AppleSignIn.addEventListener('login', function(event) {
  if (!event.success) {
    alert(event.error);
    return;
  }

  // Save userId locally for credential state checks on next app launch
  Ti.App.Properties.setString('apple_user_id', event.profile.userId);
});

// Fired when the user revokes Apple Sign In externally (e.g. via iPhone Settings)
AppleSignIn.addEventListener('credentialRevoked', function() {
  Ti.App.Properties.removeAllProperties();
  // Navigate to login/onboarding screen
});

var win = Ti.UI.createWindow({ backgroundColor: '#fff' });

win.addEventListener('open', function() {
  // Check if credential was revoked while the app was closed
  var userId = Ti.App.Properties.getString('apple_user_id', null);
  if (userId) {
    AppleSignIn.getCredentialState(userId, function(result) {
      if (result.state === AppleSignIn.CREDENTIAL_STATE_REVOKED ||
          result.state === AppleSignIn.CREDENTIAL_STATE_NOT_FOUND) {
        Ti.App.Properties.removeAllProperties();
        // Navigate to login/onboarding screen
      }
    });
  }

  AppleSignIn.checkExistingAccounts();
});

var btn = AppleSignIn.createLoginButton({ width: 280, height: 38 });

btn.addEventListener('click', function() {
  AppleSignIn.authorize();
});

win.add(btn);
win.open();
```

## API

### Methods

#### `checkExistingAccounts()`

Silently checks for existing Apple ID or password-based accounts. If found, fires the `login` event automatically without user interaction.

---

#### `createLoginButton([options])`

Creates a localized Apple Sign In button.

| Option | Type | Default | Description |
|---|---|---|---|
| `type` | Number | `BUTTON_TYPE_DEFAULT` | Button type constant |
| `style` | Number | `BUTTON_STYLE_BLACK` | Button style constant |
| `width` | Number | — | Button width |
| `height` | Number | — | Button height |

---

#### `authorize([options])`

Starts an Apple Sign In authorization flow.

| Option | Type | Default | Description |
|---|---|---|---|
| `scopes` | String[] | `['fullName', 'email']` | Array of requested scopes |
| `nonce` | String | — | Optional SHA-256 hashed nonce for backend token validation (e.g. Firebase) |

On success, fires the `login` event with the user's profile.

---

#### `getCredentialState(userId, callback)`

Checks the current credential state for a given `userId` (obtained from `event.profile.userId` on login).

Call this on every app launch to detect revocations that happened while the app was closed.

The `callback` receives an object with a `state` property matching one of the `CREDENTIAL_STATE_*` constants.

```js
AppleSignIn.getCredentialState(userId, function(result) {
  if (result.state === AppleSignIn.CREDENTIAL_STATE_AUTHORIZED) {
    // User is still authenticated
  } else if (result.state === AppleSignIn.CREDENTIAL_STATE_REVOKED) {
    // User revoked access — log them out
  }
});
```

---

#### `deleteAccount(options, callback)`

Handles the full account deletion flow as required by App Store Review Guideline 5.1.1(v).

Internally, the module re-authenticates the user with Apple to obtain a fresh `authorizationCode`, then sends it to your backend which exchanges it for a refresh token and revokes it via Apple's REST API.

| Option | Type | Required | Description |
|---|---|---|---|
| `backendURL` | String | ✅ | Your backend endpoint that handles token revocation |

The `callback` receives `{ success: true }` or `{ success: false, error: '...' }`.

```js
AppleSignIn.deleteAccount({ backendURL: 'https://yourbackend.com/apple/revoke' }, function(result) {
  if (result.success) {
    Ti.App.Properties.removeAllProperties();
    // Navigate to onboarding screen
  } else {
    alert(result.error);
  }
});
```

> **Backend requirement:** Your backend must implement the two-step revocation flow:
> 1. `POST https://appleid.apple.com/auth/token` — exchange `authorization_code` for a `refresh_token`
> 2. `POST https://appleid.apple.com/auth/revoke` — revoke the `refresh_token`
>
> This requires a `.p8` key with **Sign In with Apple** enabled, generated at [developer.apple.com](https://developer.apple.com) → Keys.

### Backend Helpers

The module provides the necessary backend implementations in [Python](https://github.com/deckameron/Titanium-Apple-Sign-In/tree/master/example/backends/python), [Node.js](https://github.com/deckameron/Titanium-Apple-Sign-In/tree/master/example/backends/node) and [PHP](https://github.com/deckameron/Titanium-Apple-Sign-In/tree/master/example/backends/php). Also the [documentation](https://github.com/deckameron/Titanium-Apple-Sign-In/blob/master/documentation/APPLE_CREDENTIALS.md) showing how to get the necessary keys and ids.

---

### Events

#### `login`

Fired after a successful or failed authorization attempt.

| Property | Type | Description |
|---|---|---|
| `success` | Boolean | Whether the login succeeded |
| `cancelled` | Boolean | Whether the user cancelled the flow |
| `error` | String | Error message (only on failure) |
| `credentialType` | String | `'apple'` or `'password'` |
| `profile` | Object | User profile (only on success, see below) |

**`profile` object:**

| Property | Type | Description |
|---|---|---|
| `userId` | String | Stable unique user identifier — save this locally |
| `identityToken` | String | JWT for backend validation |
| `authorizationCode` | String | One-time code (expires in ~5 min) for token exchange |
| `email` | String | User's email — only provided on first login |
| `name` | Object | User's name — only provided on first login |
| `realUserStatus` | Number | Matches `USER_DETECTION_STATUS_*` constants |
| `authorizedScopes` | String[] | Scopes actually authorized by the user |
| `state` | String | Optional state value passed in the request |

> **Note:** `email` and `name` are only returned on the **first** authorization. Save them locally immediately — Apple will not return them again on subsequent logins.

---

#### `credentialRevoked`

Fired when the user revokes Apple Sign In access while the app is running (e.g. via iPhone Settings → Apple ID → Password & Security → Apps Using Apple ID).

Use this event together with `getCredentialState()` on app launch to cover all revocation scenarios.

```js
AppleSignIn.addEventListener('credentialRevoked', function() {
  // Clear local data and navigate to login screen
});
```

---

### Constants

#### Button Types
| Constant | Description |
|---|---|
| `BUTTON_TYPE_DEFAULT` | Default "Sign in with Apple" button |
| `BUTTON_TYPE_CONTINUE` | "Continue with Apple" button |
| `BUTTON_TYPE_SIGN_IN` | "Sign in with Apple" button |

#### Button Styles
| Constant | Description |
|---|---|
| `BUTTON_STYLE_BLACK` | Black background, white text |
| `BUTTON_STYLE_WHITE` | White background, black text |
| `BUTTON_STYLE_WHITE_OUTLINE` | White background with black border |

#### Credential States
| Constant | Description |
|---|---|
| `CREDENTIAL_STATE_AUTHORIZED` | User is authenticated and credential is valid |
| `CREDENTIAL_STATE_REVOKED` | User has revoked access |
| `CREDENTIAL_STATE_NOT_FOUND` | No credential found for this user ID |
| `CREDENTIAL_STATE_TRANSFERRED` | Credential was transferred (app transfer scenario) |

#### User Detection Status
| Constant | Description |
|---|---|
| `USER_DETECTION_STATUS_REAL` | Likely a real user |
| `USER_DETECTION_STATUS_UNKNOWN` | Detection status is unknown |
| `USER_DETECTION_STATUS_UNSUPPORTED` | Detection not supported on this device |

---

## Installation

**1. Add the Sign In with Apple entitlement to your `tiapp.xml`:**

```xml
<ios>
  <entitlements>
    <dict>
      <key>com.apple.developer.applesignin</key>
      <array>
        <string>Default</string>
      </array>
    </dict>
  </entitlements>
</ios>
```

**2. Enable the Sign In with Apple capability** in your Provisioning Profile at [developer.apple.com](https://developer.apple.com) → Certificates, Identifiers & Profiles → your App ID → Capabilities.

**3. (Optional) For `deleteAccount` support**, create a `.p8` key with Sign In with Apple enabled at [developer.apple.com](https://developer.apple.com) → Keys, and implement the backend revocation endpoint.

---

## License

MIT

## Author

Hans Knöchel