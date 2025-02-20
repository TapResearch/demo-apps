//
//  NativeWallViewController.m
//  TestApp_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

#import "NativeWallViewController.h"
#import <TapResearchSDK/TapResearchSDK.h>
#import "PlacementCell.h"

@interface NativeWallViewController () <UITableViewDelegate, UITableViewDataSource, TapResearchContentDelegate, TapResearchSurveysDelegate>

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
}

#pragma mark - TableView Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.surveys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	TRSurvey *survey = self.surveys[indexPath.row];
	NSString *title = [NSString stringWithFormat:@"%@ %@", self.placementTag, survey.surveyIdentifier];
	NSMutableString *info = [NSMutableString stringWithFormat:@"%ld %@, %ld %@", (long)survey.lengthInMinutes, (survey.lengthInMinutes == 1 ? @"minute" : @"minutes"), (long)survey.rewardAmount, survey.currencyName];
	if (survey.isSale) {
		[info appendString:[NSString stringWithFormat:@" 🛍️ X %.0f", survey.saleMultiplier]];
	}
	if (survey.isHotTile) {
		[info appendString:@" 🔥"];
	}
	PlacementCell *cell =  [PlacementCell cellForTableView:tableView placementTag:title andInfo:info];
	cell.contentView.layer.borderWidth = 4;
	cell.contentView.layer.borderColor = [UIColor systemBackgroundColor].CGColor;
	if (survey.isSale) {
		if (survey.isHotTile) {
			cell.contentView.backgroundColor = [UIColor systemRedColor];
		} else {
			cell.contentView.backgroundColor = [UIColor systemOrangeColor];
		}
	}
	else {
		cell.contentView.backgroundColor = [UIColor systemBackgroundColor];
		if (survey.isHotTile) {
			cell.contentView.layer.borderColor = [UIColor systemRedColor].CGColor;
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

	TRSurvey *survey = self.surveys[indexPath.row];
	NSString *surveyId = survey.surveyIdentifier;

	if ([TapResearch canShowSurveyWithSurveyId:surveyId forPlacementTag:self.placementTag]) {
		//[TapResearch showSurveyWithSurveyId:surveyId placementTag:self.placementTag delegate:self customParameters: @{@"key":@"value"} errorHandler:^(NSError * _Nullable error) {
		[TapResearch showSurveyWithSurveyId:surveyId placementTag:self.placementTag delegate:self errorHandler:^(NSError * _Nullable error) {
			if (error) {
				NSLog(@"Error: %@ %@", error.userInfo[TapResearch.TapResearchErrorCodeString], error.localizedDescription);
				// handle the error
			}
		}];
	}
}

#pragma mark - TapResearch Survey Delegates

- (void)onTapResearchSurveysRefreshedForPlacement:(NSString *)placementTag {
	NSLog(@"placement surveys refreshed for %@", placementTag);

	self.surveys = [[NSMutableArray alloc] initWithArray:[TapResearch getSurveysFor:self.placementTag errorHandler:^(NSError * _Nullable error) {
	}]];
	[self.tableView reloadData];

	if (self.surveys.count > 0) {
		self.spinner.hidesWhenStopped = YES;
		[self.spinner stopAnimating];
	}
}

#pragma mark - TapResearch Content Delegates

- (void)onTapResearchContentShownForPlacement:(NSString *)placement {
	NSLog(@"[%@] onTapResearchContentShown(%@)", [NSDate date], placement);
}

- (void)onTapResearchContentDismissedForPlacement:(NSString *)placement {
	NSLog(@"[%@] onTapResearchContentDismissed(%@)", [NSDate date], placement);
	dispatch_async(dispatch_get_main_queue(), ^{
		// Perform any actions if necessary
	});
}

@end
