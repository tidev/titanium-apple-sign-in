const Playservices = require('ti.applesignin');

describe('ti.applesignin', () => {
	describe('methods', () => {
		describe('#isGooglePlayServicesAvailable()', () => {
			it('is a function', () => {
				expect(Playservices.isGooglePlayServicesAvailable).toEqual(jasmine.any(Function));
			});
			// TODO: verify return value is one of the RESULT_* constants!
		});

		describe('#isUserResolvableError()', () => {
			it('is a function', () => {
				expect(Playservices.isUserResolvableError).toEqual(jasmine.any(Function));
			});
			// TODO: test return values for known codes
		});

		describe('#getErrorString()', () => {
			it('is a function', () => {
				expect(Playservices.getErrorString).toEqual(jasmine.any(Function));
			});
			// TODO: test return values for known codes?
		});
	});
});
