//
//  SceneDelegate.m
//  IntegrationDemo_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

#import "SceneDelegate.h"
#import "NSObject+LogPrint.h"

NSString *apiToken = @"0b5dcbae8151c1b82d69697dce004bf2"; // Replace with your own token
NSString *userIdentifier = @"some-user-identifier999"; // Replace with your own app's player user id

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
	// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
	// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
	// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

	[TapResearch initializeWithAPIToken:apiToken
						 userIdentifier:userIdentifier
						 userAttributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"a string value", @12, nil]
																	forKeys:[NSArray arrayWithObjects:@"some_string", @"some_number", nil]
										]
				clearPreviousAttributes:YES
							sdkDelegate:self
							 completion:^(NSError * _Nullable error) {
		if (error) {
			[self logPrint:[NSString stringWithFormat:@"Error on initialize: %ld, %@", (long)error.code, error.localizedDescription] function: __FUNCTION__];
		}
	}];

	// Initialize TapResearchSDK without passing user attributes:
	//[TapResearch initializeWithAPIToken:apiToken userIdentifier:userIdentifier sdkDelegate:self completion:^(NSError * _Nullable error) {
	//	if (error) {
	//		[self logPrint:[NSString stringWithFormat:@"Error on initialize: %ld, %@", (long)error.code, error.localizedDescription] function: __FUNCTION__];
	//	}
	//}];
}

- (void)sceneDidDisconnect:(UIScene *)scene {
	// Called as the scene is being released by the system.
	// This occurs shortly after the scene enters the background, or when its session is discarded.
	// Release any resources associated with this scene that can be re-created the next time the scene connects.
	// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
	// Called when the scene has moved from an inactive state to an active state.
	// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}

- (void)sceneWillResignActive:(UIScene *)scene {
	// Called when the scene will move from an active state to an inactive state.
	// This may occur due to temporary interruptions (ex. an incoming phone call).
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
	// Called as the scene transitions from the background to the foreground.
	// Use this method to undo the changes made on entering the background.
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
	// Called as the scene transitions from the foreground to the background.
	// Use this method to save data, release shared resources, and store enough scene-specific state information
	// to restore the scene back to its current state.
}

//MARK: - TapResearchSDKDelegate

// Optional
//- (void)onTapResearchDidReceiveRewards:(NSArray<TRReward *> * _Nonnull)rewards {
//	[self logPrint:[NSString stringWithFormat:@"number of rewards = %lu", (unsigned long)rewards.count] function:__FUNCTION__];
//}

// Optional
//- (void)onTapResearchQuickQuestionResponse:(TRQQDataPayload *)qqPayload {
//	[self logPrint:@" recieved a qq response" function:__FUNCTION__];
//}

- (void)onTapResearchDidError:(NSError * _Nonnull)error {
	[self logPrint:[NSString stringWithFormat:@"error = %ld %@", (long)error.code, error.localizedDescription] function:__FUNCTION__];
}

- (void)onTapResearchSdkReady {
	[self logPrint:@"" function:__FUNCTION__];

	NSError *error = [TapResearch sendUserAttributesWithAttributes:@{@"Number" : @12, @"String" : @"Some text", @"Boolean" : @"true"}
										   clearPreviousAttributes:NO];
	if (error) {
		[self logPrint:[NSString stringWithFormat:@"Error sending user attributes: %ld %@", (long)error.code, error.localizedDescription] function:__FUNCTION__];

	}
}

@end
