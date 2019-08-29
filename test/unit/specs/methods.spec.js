const AppleSignin = require('ti.applesignin');

describe('ti.applesignin', () => {
	describe('methods', () => {
		describe('#authorize()', () => {
			it('is a function', () => {
				expect(AppleSignin.authorize).toEqual(jasmine.any(Function));
			});
			// TODO: verify return value is one of the RESULT_* constants!
		});

		// TODO: verify 'login' event
	});
});
