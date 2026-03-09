#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <TapResearchSDK/TapResearchSDK.h>
#import <TapResearchSDK/TapResearchSDK-Swift.h>

#if __has_include("UnityAppController.h")
#import "UnityAppController.h"
#elif __has_include("Classes/UnityAppController.h")
#import "Classes/UnityAppController.h"
#else
#error "UnityAppController.h not found. This override approach requires a classic Unity iOS export (not Unity-as-a-Library)."
#endif

@interface TapResearchSDKAppController : UnityAppController <UNUserNotificationCenterDelegate>
@end

// Tell Unity to use our subclass instead of the default controller.
IMPL_APP_CONTROLLER_SUBCLASS(TapResearchSDKAppController)

@implementation TapResearchSDKAppController

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	BOOL ok = [super application:application didFinishLaunchingWithOptions:launchOptions];

	//NSLog(@"☑️ TapResearchSDKAppController.mm: %@: Entered didFinishLaunchingWithOptions", [NSString stringWithCString:__FUNCTION__]);

	// Tell iOS about our notification handling object:
	UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
	center.delegate = self;

	return ok;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
		 withCompletionHandler:(void (^)(void))completionHandler
{
	//NSLog(@"☑️ TapResearchSDKAppController.mm: %@", [NSString stringWithCString:__FUNCTION__]);
	BOOL handled = [TapResearch handleNotificationWithDidReceive:response contentDelegate:nil];
	if (handled) {
		NSLog(@"✅ TapResearchSDKAppController.mm: %@: Notification handled.", [NSString stringWithCString:__FUNCTION__]);
	}
	else {
		NSLog(@"❌ TapResearchSDKAppController.mm: %@: Notification not handled, not a valid TapResearch notification.", [NSString stringWithCString:__FUNCTION__]);
	}
	completionHandler();
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
	   willPresentNotification:(UNNotification *)notification
		 withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
	//NSLog(@"☑️ TapResearchSDKAppController.mm: %@", [NSString stringWithCString:__FUNCTION__]);
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
