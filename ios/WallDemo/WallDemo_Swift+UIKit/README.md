# TapResearch Basics Example

This project contains an example to show implementation details for the following TapResearch SDK features:

1. SDK Initialization
2. Presenting Placement content
3. Showing Survey Wall Preview and presenting its content

## Steps in this example

1. Get a user identifier, this must be supplied by the app before SDK initialization
2. Initialize the SDK
	2.1 Show waiting spinner
3. Wait for the SDK to notify that is ready (unsing the **onTapResearchSdkReady** callback)
	3.1. Hide waiting spinner and show actions
4. Handle button actions
	4.1. Show simple placement full-screen content
	4.2. Show Survey Wall Preview and its survey content

## Example Structure

The example is split over 2 files:

**TapResearchBasicsController.swift** 
This contains initialization and placement content presentation and Survey Wall Preview buttons.

**SurveyWallPreviewController.swift** 
This contains the Survey Wall Preview example including presenting survey content. This view controller is presented by the **TapResearchBasicsController**.

## Notes

~~In this example we set the reward delegate once in **TapResearchBasicsController**, however, best practice for this delegate is to set it in one view controller, unset it when moving to~~  
