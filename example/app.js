var AppleSignIn = require('ti.applesignin');

// A new random nonce for each request. Send the raw value to your server with the
// identity token: Apple puts what authorize() is given (here its SHA-256 hash) in the
// token's "nonce" claim.
var rawNonce;

AppleSignIn.addEventListener('login', function (event) {
    if (!event.success) {
        alert(event.error);
        return;
    }

    Ti.API.warn(event);
    alert('Login successfully');
});

var win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

win.addEventListener('open', () => {
    AppleSignIn.checkExistingAccounts();
});

var btn = Ti.UI.createButton({
    title: 'Sign in with Apple'
});

btn.addEventListener('click', function () {
    rawNonce = Ti.Platform.createUUID();
    AppleSignIn.authorize({ nonce: Ti.Utils.sha256(rawNonce) });
});

win.add(btn);
win.open();
