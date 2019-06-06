# iOS 13+ Apple Sign In in Titanium

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

var btn = Ti.UI.createButton({
  title: 'Sign in with Apple'
});

btn.addEventListener('click', function () {
  AppleSignIn.authorize();
});

win.add(btn);
win.open();
```

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
