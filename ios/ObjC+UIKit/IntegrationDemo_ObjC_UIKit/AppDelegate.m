//
//  AppDelegate.m
//  IntegrationDemo_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

#import "AppDelegate.h"

NSString *apiToken = @"0b5dcbae8151c1b82d69697dce004bf2";
NSString *userIdentifier = @"public-demo-test-user";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	[TapResearchSDK initializeWithAPIToken:apiToken userIdentifier:userIdentifier sdkDelegate:self completion:^(TRError * _Nullable error) {
		if (error) {
			NSLog(@"Error on initialize: %ld, %@", (long)error.code, error.localizedDescription);
		}
	}];
	return YES;
}

//MARK: - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
	// Called when a new scene session is being created.
	// Use this method to select a configuration to create the new scene with.
	return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
	// Called when the user discards a scene session.
	// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
	// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

//MARK: - TapResearchSDKDelegate

///---------------------------------------------------------------------------------------------
- (void)onTapResearchDidError:(TRError * _Nonnull)error {
	NSLog(@"onTapResearchDidError() -> %@, %ld", error.localizedDescription, (long)error.code);
}

///---------------------------------------------------------------------------------------------
- (void)onTapResearchDidReceiveRewards:(NSArray<TRReward *> * _Nonnull)rewards {
	NSLog(@"onTapResearchDidReceiveRewards(%@)", rewards);
}

@end
