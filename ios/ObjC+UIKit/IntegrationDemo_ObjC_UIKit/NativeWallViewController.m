//
//  NativeWallViewController.m
//  TestApp_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

#import "NativeWallViewController.h"
#import <TapResearchSDK/TapResearchSDK.h>
#import "PlacementCell.h"
#import "NSObject+LogPrint.h"

@interface NativeWallViewController () <UITableViewDelegate, UITableViewDataSource, TapResearchContentDelegate, TapResearchSurveysDelegate, TapResearchRewardDelegate>

@property (nonatomic, strong) NSMutableArray<TRSurvey *> *surveys;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *networkBanner;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation NativeWallViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.surveys = [[NSMutableArray alloc] initWithArray:[TapResearch getSurveysFor:self.placementTag errorHandler:^(NSError * _Nullable error) {
	}]];

	if (self.surveys.count > 0) {
		self.spinner.hidesWhenStopped = YES;
		[self.spinner stopAnimating];
	}

	[TapResearch setSurveysDelegate:self];

	[self.navigationItem setHidesBackButton:YES];
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Back" image:[UIImage systemImageNamed:@"chevron.left"] target:self action:@selector(back) menu:nil];
	self.navigationItem.leftBarButtonItem = button;

}

- (void)back {

	[TapResearch setSurveysDelegate:nil];
	[self.navigationController popViewControllerAnimated:YES];
}

//MARK: - TableView Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.surveys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	TRSurvey *survey = self.surveys[indexPath.row];
	NSString *title = [NSString stringWithFormat:@"%@ %@", self.placementTag, survey.surveyIdentifier];
	NSString *info = [NSString stringWithFormat:@"%ld %@, %ld %@", (long)survey.lengthInMinutes, (survey.lengthInMinutes == 1 ? @"minute" : @"minutes"), (long)survey.rewardAmount, survey.currencyName];

	return [PlacementCell cellForTableView:tableView placementTag:title andInfo:info]; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

	TRSurvey *survey = self.surveys[indexPath.row];
	NSString *surveyId = survey.surveyIdentifier;

	if ([TapResearch canShowSurveyWithSurveyId:surveyId forPlacementTag:self.placementTag]) {
		//[TapResearch showSurveyWithSurveyId:surveyId placementTag:self.placementTag delegate:self customParameters: @{@"key":@"value"} errorHandler:^(NSError * _Nullable error) {
		[TapResearch showSurveyWithSurveyId:surveyId placementTag:self.placementTag delegate:self errorHandler:^(NSError * _Nullable error) {
			if (error) {
				[self logPrint:[NSString stringWithFormat:@"Error: %@ %@", error.userInfo[TapResearch.TapResearchErrorCodeString], error.localizedDescription] function: __FUNCTION__];
				// handle the error
			}
		}];
	}
}

//MARK: - TapResearch Survey Delegates

- (void)onTapResearchSurveysRefreshedForPlacement:(NSString *)placementTag {
	[self logPrint:[NSString stringWithFormat:@"placement surveys refreshed for %@", placementTag] function:__FUNCTION__];

	self.surveys = [[NSMutableArray alloc] initWithArray:[TapResearch getSurveysFor:self.placementTag errorHandler:^(NSError * _Nullable error) {
	}]];
	[self.tableView reloadData];

	if (self.surveys.count > 0) {
		self.spinner.hidesWhenStopped = YES;
		[self.spinner stopAnimating];
	}
}

//MARK: - TapResearch Content Delegates

- (void)onTapResearchContentShownForPlacement:(NSString *)placement {
	[self logPrint:[NSString stringWithFormat:@"placement = %@", placement] function:__FUNCTION__];
}

- (void)onTapResearchContentDismissedForPlacement:(NSString *)placement {
	[self logPrint:[NSString stringWithFormat:@"placement = %@", placement] function:__FUNCTION__];
	dispatch_async(dispatch_get_main_queue(), ^{
		// Perform any actions if necessary
	});
}

//MARK: - TapResearchRewardDelegate

- (void)onTapResearchDidReceiveRewards:(NSArray<TRReward *> * _Nonnull)rewards {
	[self logPrint:[NSString stringWithFormat:@"number of rewards = %lu", (unsigned long)rewards.count] function:__FUNCTION__];
}

@end
