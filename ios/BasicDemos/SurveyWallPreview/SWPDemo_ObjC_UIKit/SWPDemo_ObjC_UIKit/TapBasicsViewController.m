//
//  TapBasicsViewController.m
//  WallDemo_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

#define TAP_RESEARCH_TOKEN @"YOUR_API_TOKEN" // Replace with your own token

#import "TapBasicsViewController.h"
#import "SurveyWallPreviewController.h"
#import <TapResearchSDK/TapResearchSDK.h>

@interface TapBasicsViewController () <TapResearchContentDelegate, TapResearchSDKDelegate, TapResearchRewardDelegate>

@property NSString *surveysPlacement;
@property NSString *userIdentifier;

@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *showSurveyWallPreviewButton;

@property (nonatomic, assign) BOOL surveyWallHasSurveys;

@end

@implementation TapBasicsViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.surveysPlacement = @"earn-center";
	self.userIdentifier = @"public-demo-test-user-for-2026"; // Replace with your own unique user identifiers
	[self.spinner startAnimating];
	self.buttonContainer.hidden = YES;
	[TapResearch initializeWithAPIToken:TAP_RESEARCH_TOKEN userIdentifier:self.userIdentifier sdkDelegate:self completion:^(NSError * _Nullable error) {
		if (error) {
			NSLog(@"Error on initialize: %ld, %@", (long)error.code, error.localizedDescription);
		}
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.surveyWallHasSurveys = NO;
	[self.showSurveyWallPreviewButton setTitle:@"Has surveys for Survey Wall Preview?" forState:UIControlStateNormal];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

	if ([segue.identifier isEqualToString:@"ShowSurveyWallPreview"]) {
		SurveyWallPreviewController *vc = (SurveyWallPreviewController*)segue.destinationViewController;
		vc.surveysPlacement = self.surveysPlacement;
	}
}

//MARK: -

- (IBAction)surveyWallPreviewButtonTapped:(UIButton *)sender {

	if (self.surveyWallHasSurveys) {
		self.surveyWallHasSurveys = NO;
		[self performSegueWithIdentifier:@"ShowSurveyWallPreview" sender:self];
	}
	else {
		self.surveyWallHasSurveys = [TapResearch hasSurveysFor:self.surveysPlacement errorHandler:^(NSError * _Nullable error) {
			// Optional error handling block.
		}];
		dispatch_async(dispatch_get_main_queue(), ^{
			if (self.surveyWallHasSurveys) {
				[self.showSurveyWallPreviewButton setTitle:@"Show Survey Wall Preview" forState:UIControlStateNormal];
			}
			else {
				[self.showSurveyWallPreviewButton setTitle:@"Has surveys for Survey Wall Preview?" forState:UIControlStateNormal];
			}
		});
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
	self.buttonContainer.hidden = NO;
}

@end
