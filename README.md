# iOS 13+ Apple Sign In in Titanium [![Build Status](https://jenkins.appcelerator.org/buildStatus/icon?job=modules%2Ftitanium-apple-sign-in%2Fmaster)](https://jenkins.appcelerator.org/job/modules/job/titanium-apple-sign-in/job/master/) [![@titanium-sdk/ti.applesignin](https://img.shields.io/npm/v/@titanium-sdk/ti.applesignin.png)](https://www.npmjs.com/package/@titanium-sdk/ti.applesignin)

Full support for iOS 13+ Apple Sign In with Titanium.

## Requirements

The following project- and OS-requirements are necessary:

- [x] Xcode 11+
- [x] iOS 13+
- [x] Titanium SDK 8.0.0+

## Example

This module was designed to follow a similar scheme like Ti.Facebook and Ti.GoogleSignIn.

```js
var AppleSignIn = require('ti.applesignin');

AppleSignIn.addEventListener('login', function (event) {
  if (!event.success) {
    alert(event.error);
    return;
  }

  Ti.API.warn(event);
});

var win = Ti.UI.createWindow({
  backgroundColor: '#fff'
});

var btn = AppleSignIn.createLoginButton({ width: 280, height: 38 });

btn.addEventListener('click', function () {
  AppleSignIn.authorize();
});

win.add(btn);
win.open();
```

## API's

### Methods

#### `createLoginButton()`

Creates a new localized login button.

#### `authorize({ scopes })`

Starts an authorization flow with an optional array of scoped. Defaults to all scopes (`fullName` and `email`).

#### `getCredentialState(userId, callback)`

Fetches the current credential state with a given user-id (received from the `event.profile.userId`  key of the `login` event).
The result is returned to the `state` parameter of the `callback` and can be authorized, revoked, transferred or unknown.

### Events

#### `login`

The login event with the user's `profile`.

## Installation

- [x] Add the following entitlements to your project:
```xml
<key>com.apple.developer.applesignin</key>
<array>
  <string>Default</string>
</array>
```
- [x] Make sure your server is eligible to send mails to the Apple Sign In provider service.


## License

MIT

## Author

Hans Knöchel
