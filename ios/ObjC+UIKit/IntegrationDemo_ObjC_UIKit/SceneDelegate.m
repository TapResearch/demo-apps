//
//  SceneDelegate.m
//  IntegrationDemo_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

#import "SceneDelegate.h"

NSString *apiToken = @"100e9133abc21471c8cd373587e07515";
NSString *userIdentifier = @"some-user-identifier";

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
	// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
	// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
	// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

	[TapResearch initializeWithAPIToken:apiToken userIdentifier:userIdentifier sdkDelegate:self completion:^(NSError * _Nullable error) {
		if (error) {
			NSLog(@"Error on initialize: %ld, %@", (long)error.code, error.localizedDescription);
		}
	}];
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

- (void)onTapResearchDidError:(NSError * _Nonnull)error {
	NSLog(@"onTapResearchDidError() -> %@, %ld", error.localizedDescription, (long)error.code);
}

- (void)onTapResearchDidReceiveRewards:(NSArray<TRReward *> * _Nonnull)rewards {
	NSLog(@"onTapResearchDidReceiveRewards(%@)", rewards);
}

- (void)onTapResearchSdkReady {
	NSLog(@"onTapResearchSdkReady()");

	NSError *error = [TapResearch sendUserAttributesWithAttributes: @{@"Number" : @12, @"String" : @"Some text", @"Boolean" : @"true"}];
	if (error) {
		NSLog(@"Error sending user attributes: %ld %@", (long)error.code, error.localizedDescription);
	}
}

@end
