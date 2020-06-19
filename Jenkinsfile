#!groovy
library 'pipeline-library'

def isMaster = env.BRANCH_NAME.equals('master')

buildModule {
	sdkVersion = '9.0.2.GA'
	iosLabels = 'osx && xcode-11'
	npmPublish = isMaster // By default it'll do github release on master anyways too
}
