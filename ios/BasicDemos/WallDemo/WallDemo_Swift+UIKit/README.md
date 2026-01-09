# TapResearch Basics Example

This project contains an example to show implementation details for the following TapResearch SDK features:

1. SDK Initialization
2. Presenting Placement content
3. SDK callbacks

## First Steps

You will need:

* The current release Xcode from the AppStore including its command line tools
* A TapResearch API token
* Cocoapods

Before opening the project for the first time navigate to the folder in Terminal and run `pod install` to download the TapResearchSDK and add it to the project. 
When Cocoapods has completed you can open the xcworkspace package. 
In the `TapResearchBasicsController.swift` file make sure to set the `apiToken` string to your API token and set `userIdentifier` to a unique user identifier.

You should now be able to build and run the example.

## Elements in this example

1. Get a user identifier, this must be supplied by the app before SDK initialization
2. Initialize the SDK
	2.1 Show waiting spinner
3. Wait for the SDK to notify that is ready (unsing the **onTapResearchSdkReady** callback)
	3.1. Hide waiting spinner and show actions
4. Handle button actions
	4.1. Show simple placement full-screen content
	
## Example Structure

**TapResearchBasicsController.swift** 
This contains initialization and placement content presentation and SDK callbacks, reward callback and content callbacks.

