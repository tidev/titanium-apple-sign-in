const AppleSignin = require('ti.applesignin');
var signInButton = AppleSignin.createLoginButton({
	type: AppleSignin.BUTTON_TYPE_SIGNIN,
	style: AppleSignin.BUTTON_STYLE_BLACK,
	borderRadius: 10,
});

describe('ti.applesignin', () => {
	describe('methods', () => {
		describe('#authorize()', () => {
			it('is a function', () => {
				expect(AppleSignin.authorize).toEqual(jasmine.any(Function));
			});
		});

		describe('#createLoginButton()', () => {
			it('is a function', () => {
				expect(AppleSignin.createLoginButton).toEqual(jasmine.any(Function));
			});
		});

		describe('#getCredentialState()', () => {
			it('is a function', () => {
				expect(AppleSignin.getCredentialState).toEqual(jasmine.any(Function));
			});
		});
	});
});

describe('ti.applesignin.LoginButton', () => {
	describe('properties', () => {
		it('should have valid borderRadius', () => {
			expect(signInButton.borderRadius).toEqual(10);
		});

		it('should have valid type', () => {
			expect(signInButton.type).toEqual(AppleSignin.BUTTON_TYPE_SIGNIN);
		});

		it('should have valid style', () => {
			expect(signInButton.style).toEqual(AppleSignin.BUTTON_STYLE_BLACK);
		});
	});
});

