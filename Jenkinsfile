#!groovy
library 'pipeline-library'

def isMaster = env.BRANCH_NAME.equals('master')

buildModule {
	sdkVersion = '8.2.0.v20190806082810'
	iosLabels = 'osx && xcode-11'
	npmPublish = isMaster // By default it'll do github release on master anyways too
	npmPublishArgs = '--access public'
}
