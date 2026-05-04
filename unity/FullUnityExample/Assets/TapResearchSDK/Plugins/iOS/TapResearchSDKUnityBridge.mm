//
//  TapResearchSDKUnityBridge.cpp
//
//
//  Created by Jeroen Verbeek on 5/16/23.
//

#include "UnityFramework/UnityFramework-Swift.h"
#import <Foundation/Foundation.h>

@interface TapResearchSDKUnityNative : NSObject
@end

@implementation TapResearchSDKUnityNative

/// ---------------------------------------------------------------------------------------------
+ (NSString*)packageVersion {
	// Keep in-sync with version string in TapResearch.cs file!
	return @"3.7.1--rc0";
}

@end

#pragma mark - C interface

extern "C" {

///---------------------------------------------------------------------------------------------
void ConfigureIOS(const char* apiToken, const char* userIdentifier) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);
	[[TapResearchSDKUnityNativeInterface shared] initializeWithApiToken:[NSString stringWithCString:apiToken encoding:NSASCIIStringEncoding]
												userIdentifier:[NSString stringWithCString:userIdentifier encoding:NSASCIIStringEncoding]];
}


///---------------------------------------------------------------------------------------------
void ConfigureIOSWithUserAttributes(const char* apiToken, const char* userIdentifier, const char* attributes, bool clearAttributes) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);

	NSDictionary *dict;
	NSData *jsonData = [[NSString stringWithCString:attributes encoding:NSASCIIStringEncoding] dataUsingEncoding:NSASCIIStringEncoding];
	if (jsonData) {
		NSError *error;
		dict = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
		if (error) {
			NSLog(@"TapResearch: %@ (%ld)", error.localizedDescription, (long)error.code);
		}
	}

	[[TapResearchSDKUnityNativeInterface shared] initializeWithApiToken:[NSString stringWithCString:apiToken encoding:NSASCIIStringEncoding]
												userIdentifier:[NSString stringWithCString:userIdentifier encoding:NSASCIIStringEncoding]
												userAttributes:dict
									   clearPreviousAttributes:clearAttributes
	];
}

///---------------------------------------------------------------------------------------------
void UpdateCurrentUser(const char* userIdentifier) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);
	[[TapResearchSDKUnityNativeInterface shared] setUserIdentifier:[NSString stringWithCString:userIdentifier encoding:NSASCIIStringEncoding]];
}

///---------------------------------------------------------------------------------------------
bool CanShowContent(const char* placementTag) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);
	return [[TapResearchSDKUnityNativeInterface shared] canShowPlacementWithPlacementTag:[NSString stringWithCString:placementTag encoding:NSASCIIStringEncoding]];
}

///---------------------------------------------------------------------------------------------
bool IsReady() {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);
	return [[TapResearchSDKUnityNativeInterface shared] isReady];
}

///---------------------------------------------------------------------------------------------
void ShowContentForPlacement(const char* placementTag) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);
	[[TapResearchSDKUnityNativeInterface shared] showPlacementWithPlacementTag:[NSString stringWithCString:placementTag encoding:NSASCIIStringEncoding]];
}

///---------------------------------------------------------------------------------------------
void GrantBoostWithBoostTag(const char* boostTag) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);
	[[TapResearchSDKUnityNativeInterface shared] grantBoostWithBoostTag:[NSString stringWithCString:boostTag encoding:NSASCIIStringEncoding]];
}

///---------------------------------------------------------------------------------------------
void ShowContentForPlacementWithCustomParameters(const char* placementTag, const char* customParameters) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);

	NSData *jsonData = [[NSString stringWithCString:customParameters encoding:NSASCIIStringEncoding] dataUsingEncoding:NSASCIIStringEncoding];
	if (jsonData) {
		NSError *error;
		NSDictionary *dict = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
		if (!error) {
			[[TapResearchSDKUnityNativeInterface shared] showPlacementWithPlacementTag:[NSString stringWithCString:placementTag encoding:NSASCIIStringEncoding] customParameters:dict];
		}
		else {
			NSLog(@"TapResearch: %@ (%ld)", error.localizedDescription, (long)error.code);
		}
	}
}

///---------------------------------------------------------------------------------------------
void SendUserAttributes(const char* attributes) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);

	NSData *jsonData = [[NSString stringWithCString:attributes encoding:NSASCIIStringEncoding] dataUsingEncoding:NSASCIIStringEncoding];
	if (jsonData) {
		NSError *error;
		NSDictionary *dict = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
		if (!error) {
			[[TapResearchSDKUnityNativeInterface shared] sendUserAttributes:dict];
		}
		else {
			NSLog(@"TapResearch: %@ (%ld)", error.localizedDescription, (long)error.code);
		}
	}
}

///---------------------------------------------------------------------------------------------
void SendUserAttributesWithClearAttributes(const char* attributes, bool clearAttributes) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);

	NSData *jsonData = [[NSString stringWithCString:attributes encoding:NSASCIIStringEncoding] dataUsingEncoding:NSASCIIStringEncoding];
	if (jsonData) {
		NSError *error;
		NSDictionary *dict = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
		if (!error) {
			[[TapResearchSDKUnityNativeInterface shared] sendUserAttributes:dict clearPreviousAttributes: clearAttributes];
		}
		else {
			NSLog(@"TapResearch: %@ (%ld)", error.localizedDescription, (long)error.code);
		}
	}
}

//MARK: - Surveys

/// ---------------------------------------------------------------------------------------------
char* cStringCopy(const char* string) {
	char* result = (char*)malloc(strlen(string) + 1);
	strcpy(result, string);
	return result;
}

/// ---------------------------------------------------------------------------------------------
char* GetPlacementDetail(const char* placementTag) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);
	NSString* string = [[TapResearchSDKUnityNativeInterface shared] getPlacementDetailsWithPlacement:[NSString stringWithCString:placementTag encoding:NSASCIIStringEncoding]];
	char* result = cStringCopy([string UTF8String]);
	return result;
}

/// ---------------------------------------------------------------------------------------------
char* GetSurveys(const char* placementTag) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);
	NSString* string = [[TapResearchSDKUnityNativeInterface shared] getSurveysWithPlacement:[NSString stringWithCString:placementTag encoding:NSASCIIStringEncoding]];
	char* result = cStringCopy([string UTF8String]);
	return result;
}

///---------------------------------------------------------------------------------------------
bool HasSurveys(const char* placementTag) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);
	return [[TapResearchSDKUnityNativeInterface shared] hasSurveysWithPlacementTag:[NSString stringWithCString:placementTag encoding:NSASCIIStringEncoding]];
}

///---------------------------------------------------------------------------------------------
void ShowSurveyForPlacement(const char* surveyId, const char* placementTag) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);
	[[TapResearchSDKUnityNativeInterface shared] showSurveyWithSurveyId:[NSString stringWithCString:surveyId encoding:NSASCIIStringEncoding]
													 placement:[NSString stringWithCString:placementTag encoding:NSASCIIStringEncoding]
	];
}

///---------------------------------------------------------------------------------------------
void ShowSurveyForPlacementWithCustomParameters(const char* surveyId, const char* placementTag, const char* customParameters) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);

	NSData *jsonData = [[NSString stringWithCString:customParameters encoding:NSASCIIStringEncoding] dataUsingEncoding:NSASCIIStringEncoding];
	if (jsonData) {
		NSError *error;
		NSDictionary *dict = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
		if (!error) {
			[[TapResearchSDKUnityNativeInterface shared] showSurveyWithSurveyId:[NSString stringWithCString:surveyId encoding:NSASCIIStringEncoding]
															 placement:[NSString stringWithCString:placementTag encoding:NSASCIIStringEncoding]
													  customParameters:dict
			];
		}
		else {
			NSLog(@"TapResearch: %@ (%ld)", error.localizedDescription, (long)error.code);
		}
	}
}

//MARK: - Callback setter

///---------------------------------------------------------------------------------------------
void SetCallbackEnabled(const char* callbackName, bool enabled) {
	//NSLog(@"BRIDGE.m: %@", [NSString stringWithCString:__FUNCTION__]);
	[[TapResearchSDKUnityNativeInterface shared] setCallbackEnabled:[NSString stringWithCString:callbackName encoding:NSASCIIStringEncoding] enabled:enabled];
}

} //End extern "C" 
