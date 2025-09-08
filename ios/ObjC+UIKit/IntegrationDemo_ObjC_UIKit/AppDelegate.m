//
//  AppDelegate.m
//  IntegrationDemo_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

#import "AppDelegate.h"
#import "TapResearchSDK/TapResearchSDK.h"
#import "UserNotifications/UserNotifications.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	return YES;
}

//MARK: - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
	// Called when a new scene session is being created.
	// Use this method to select a configuration to create the new scene with.
	UNUserNotificationCenter *userNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
	[userNotificationCenter setDelegate: self];
	return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
	// Called when the user discards a scene session.
	// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
	// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
		 withCompletionHandler:(void (^)(void))completionHandler
{
	BOOL handled = [TapResearch handleNotificationWithDidReceive:response contentDelegate:nil];
	if (handled) {
		// ...
	}
	completionHandler();
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
	   willPresentNotification:(UNNotification *)notification
		 withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
	if (![TapResearch handleNotificationPresentation:notification withCompletionHandler:completionHandler]) {

		if (@available(iOS 14.0, *)) {
			completionHandler(UNNotificationPresentationOptionSound |
							  UNNotificationPresentationOptionBanner |
							  UNNotificationPresentationOptionList);
		} else {
			completionHandler(UNNotificationPresentationOptionSound |
							  UNNotificationPresentationOptionAlert);
		}
	}
}

@end
