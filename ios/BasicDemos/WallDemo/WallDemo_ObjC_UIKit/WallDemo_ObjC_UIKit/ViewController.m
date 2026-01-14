//
//  ViewController.m
//  WallDemo_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

#define TAP_RESEARCH_TOKEN @"YOUR_API_TOKEN" // Replace with your own token

#import "ViewController.h"
#import <TapResearchSDK/TapResearchSDK.h>

@interface ViewController () <TapResearchContentDelegate, TapResearchSDKDelegate, TapResearchRewardDelegate>

@property (weak, nonatomic) IBOutlet UIView *buttonBox;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property NSString *wallPlacement;
@property NSString *userIdentifier;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.wallPlacement = @"earn-center";
	self.userIdentifier = @"public-demo-test-user-for-2026b"; // Replace with your own unique user identifiers
	[self.spinner startAnimating];
	self.buttonBox.hidden = YES;
	[TapResearch initializeWithAPIToken:TAP_RESEARCH_TOKEN userIdentifier:self.userIdentifier sdkDelegate:self completion:^(NSError * _Nullable error) {
		if (error) {
			NSLog(@"Error on initialize: %ld, %@", (long)error.code, error.localizedDescription);
		}
	}];
}

//MARK: -

- (IBAction)showPlacement {

	if (self.wallPlacement.length > 0) {
		if ([TapResearch canShowContentForPlacement:self.wallPlacement error:^(NSError * _Nullable error) {
			// Handle error, this is an optional error block
		}]) {
			[TapResearch showContentForPlacement:self.wallPlacement delegate:self completion:^(NSError * _Nullable error) {
				if (error) {
					NSLog(@"onTapResearchDidError() -> %@, %ld", error.localizedDescription, (long)error.code);
				}
			}];
		}
	}
}

//MARK: - TapResearchContentDelegate

- (void)onTapResearchContentDismissedForPlacement:(NSString * _Nonnull)placement {
	NSLog(@"onTapResearchContentDismissedForPlacement(%@)", placement);
}

- (void)onTapResearchContentShownForPlacement:(NSString * _Nonnull)placement {
	NSLog(@"onTapResearchContentShownForPlacement(%@)", placement);
}

//MARK: - TapResearchRewardDelegate

- (void)onTapResearchDidReceiveRewards:(NSArray<TRReward *> * _Nonnull)rewards {
	NSLog(@"onTapResearchDidReceiveRewards(%@)", rewards);
}

//MARK: - TapResearchSDKDelegate

- (void)onTapResearchDidError:(NSError * _Nonnull)error {
	NSLog(@"onTapResearchDidError() -> %@, %ld", error.localizedDescription, (long)error.code);
}

- (void)onTapResearchSdkReady {
	NSLog(@"onTapResearchSdkReady()");

	[TapResearch setRewardDelegate:self];
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.buttonBox.hidden = NO;
}

@end
