var AppleSignIn = require('ti.applesignin');

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
    AppleSignIn.authorize([ AppleSignIn.AUTHORIZATION_SCOPE_EMAIL, AppleSignIn.AUTHORIZATION_SCOPE_FULLNAME ]);
});

win.add(btn);
win.open();
