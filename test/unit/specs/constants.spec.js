let AppleSignin;

describe('ti.applesignin', () => {

	it('can be required', () => {
		AppleSignin = require('ti.applesignin');

		expect(AppleSignin).toBeDefined();
	});

	// it('.apiName', () => {
	// 	expect(AppleSignin.apiName).toBe('Ti.Applesignin');
	// });

	describe('constants', () => {
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

		describe('BUTTON_STYLE_*', () => {
			it('BUTTON_STYLE_WHITE', () => {
				expect(AppleSignin.BUTTON_STYLE_WHITE).toEqual(jasmine.any(Number));
			});

			it('BUTTON_STYLE_WHITE_OUTLINE', () => {
				expect(AppleSignin.BUTTON_STYLE_WHITE_OUTLINE).toEqual(jasmine.any(Number));
			});

			it('BUTTON_STYLE_BLACK', () => {
				expect(AppleSignin.BUTTON_STYLE_BLACK).toEqual(jasmine.any(Number));
			});
		});
	});
});
