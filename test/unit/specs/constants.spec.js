let AppleSignin;

describe('ti.applesignin', function () {

	it('can be required', () => {
		AppleSignin = require('ti.applesignin');
		expect(AppleSignin).toBeDefined();
	});

	it('.apiName', () => {
		expect(AppleSignin.apiName).toBe('Ti.applesignin');
	});

	describe('constants', () => {
		describe('RESULT_*', () => {
			it('RESULT_SUCCESS', () => {
				expect(AppleSignin.RESULT_SUCCESS).toEqual(jasmine.any(Number));
			});
			it('RESULT_SERVICE_MISSING', () => {
				expect(AppleSignin.RESULT_SERVICE_MISSING).toEqual(jasmine.any(Number));
			});
			it('RESULT_SERVICE_UPDATING', () => {
				expect(AppleSignin.RESULT_SERVICE_UPDATING).toEqual(jasmine.any(Number));
			});
			it('RESULT_SERVICE_VERSION_UPDATE_REQUIRED', () => {
				expect(AppleSignin.RESULT_SERVICE_VERSION_UPDATE_REQUIRED).toEqual(jasmine.any(Number));
			});
			it('RESULT_SERVICE_INVALID', () => {
				expect(AppleSignin.RESULT_SERVICE_INVALID).toEqual(jasmine.any(Number));
			});
		});

		describe('GOOGLE_PLAY_SERVICES_*', () => {
			it('GOOGLE_PLAY_SERVICES_PACKAGE', () => {
				expect(AppleSignin.GOOGLE_PLAY_SERVICES_PACKAGE).toEqual('com.google.android.gms');
			});
			it('GOOGLE_PLAY_SERVICES_VERSION_CODE', () => {
				expect(AppleSignin.GOOGLE_PLAY_SERVICES_VERSION_CODE).toEqual(jasmine.any(Number));
			});
		});
	});
});
