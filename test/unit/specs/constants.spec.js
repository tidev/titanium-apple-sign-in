let AppleSignin = require('ti.applesignin');

describe('ti.applesignin', () => {
	it('can be required', () => {
		expect(AppleSignin).toBeDefined();
	});

	it('.moduleId', () => {
		expect(AppleSignin.moduleId).toBe('ti.applesignin');
	});

	describe('constants', () => {
		describe('AUTHORIZATION_SCOPE_*', () => {
			it('AUTHORIZATION_SCOPE_EMAIL', () => {
				expect(AppleSignin.AUTHORIZATION_SCOPE_EMAIL).toEqual('email');
			});

			it('AUTHORIZATION_SCOPE_FULLNAME', () => {
				expect(AppleSignin.AUTHORIZATION_SCOPE_FULLNAME).toEqual('full_name');
			});
		});

		describe('BUTTON_STYLE_*', () => {
			it('BUTTON_STYLE_WHITE', () => {
				expect(AppleSignin.BUTTON_STYLE_WHITE).toEqual(jasmine.any(Number));
			});

			it('BUTTON_STYLE_WHITE_OUTLINE', () => {
				expect(AppleSignin.BUTTON_STYLE_WHITE_OUTLINE).toEqual(
					jasmine.any(Number)
				);
			});

			it('BUTTON_STYLE_BLACK', () => {
				expect(AppleSignin.BUTTON_STYLE_BLACK).toEqual(jasmine.any(Number));
			});
		});

		describe('BUTTON_TYPE_*', () => {
			it('BUTTON_TYPE_DEFAULT', () => {
				expect(AppleSignin.BUTTON_TYPE_DEFAULT).toEqual(jasmine.any(Number));
			});

			it('BUTTON_TYPE_CONTINUE', () => {
				expect(AppleSignin.BUTTON_TYPE_CONTINUE).toEqual(jasmine.any(Number));
			});

			it('BUTTON_TYPE_SIGN_IN', () => {
				expect(AppleSignin.BUTTON_TYPE_SIGN_IN).toEqual(jasmine.any(Number));
			});
		});

		describe('CREDENTIAL_STATE_*', () => {
			it('CREDENTIAL_STATE_AUTHORIZED', () => {
				expect(AppleSignin.CREDENTIAL_STATE_AUTHORIZED).toEqual(
					jasmine.any(Number)
				);
			});

			it('CREDENTIAL_STATE_NOT_FOUNFD', () => {
				expect(AppleSignin.CREDENTIAL_STATE_NOT_FOUNFD).toEqual(undefined);
			});

			it('CREDENTIAL_STATE_REVOKED', () => {
				expect(AppleSignin.CREDENTIAL_STATE_REVOKED).toEqual(
					jasmine.any(Number)
				);
			});
		});

		describe('USER_DETECTION_STATUS_*', () => {
			it('USER_DETECTION_STATUS_REAL', () => {
				expect(AppleSignin.USER_DETECTION_STATUS_REAL).toEqual(
					jasmine.any(Number)
				);
			});

			it('USER_DETECTION_STATUS_UNKNOWN', () => {
				expect(AppleSignin.USER_DETECTION_STATUS_UNKNOWN).toEqual(
					jasmine.any(Number)
				);
			});

			it('USER_DETECTION_STATUS_UNSUPPORTED', () => {
				expect(AppleSignin.USER_DETECTION_STATUS_UNSUPPORTED).toEqual(
					jasmine.any(Number)
				);
			});
		});
	});
});
