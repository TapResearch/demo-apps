//
//  ViewController.m
//  IntegrationDemo_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

#import "ViewController.h"
#import "PlacementCell.h"
#import <TapResearchSDK/TapResearchSDK.h>
#import "NativeWallViewController.h"

@interface ViewController () <UITextFieldDelegate,
                              UITableViewDelegate,
                              UITableViewDataSource,
                              TapResearchContentDelegate
                              >

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *placementStatus;

@property (strong, nonatomic) NSMutableArray *knownPlacements;
@property NSString *surveysPlacement;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.knownPlacements = @[
		@"default-placement",
		@"interstitial-placement",
		@"banner-placemenet",
		@"floating-interstitial-placement"
	].mutableCopy;
	self.surveysPlacement = @"earn-center";
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleRefresh:) name:@"refresh" object:nil];
	self.textField.placeholder = @"Placement Tag";
	self.textField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Surveys?" style:UIBarButtonItemStylePlain target:self action:@selector(refresh)];
	[self.navigationItem setRightBarButtonItem:button];
	[self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

	if ([segue.identifier isEqualToString:@"ShowSurveys"]) {
		NativeWallViewController *vc = ((NativeWallViewController*)segue.destinationViewController);
		vc.placementTag = self.surveysPlacement;
	}
}

//MARK: - UITextFieldDelegate

- (void)textFieldDidChangeSelection:(UITextField *)textField {

	if (self.placementStatus.text && self.placementStatus.text.length > 0) {
		self.placementStatus.text = nil;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

	[self showPlacement];
	return YES;
}

//MARK: - Actions and button handlers

-(void)refresh {
	[self.tableView reloadData];
}

- (IBAction)showPlacement {

	NSString *placementTag = self.textField.text;

	if (placementTag && placementTag.length > 0) {
		if ([TapResearch canShowContentForPlacement:placementTag error:^(NSError * _Nullable error) {
			// Handle error, this is an optional error block
		}]) {
			[TapResearch showContentForPlacement:placementTag delegate:self completion:^(NSError * _Nullable error) {
				if (error) {
					self.placementStatus.text = [NSString stringWithFormat:@"%ld, %@", (long)error.code, error.localizedDescription];
				}
				else {
					if (![self.knownPlacements containsObject:placementTag]) {
						[self.knownPlacements addObject:placementTag];
						dispatch_async( dispatch_get_main_queue(), ^{
							[self.tableView reloadData];
						});
					}
					self.placementStatus.text = nil;
				}
			}];
		}
		else {
			self.placementStatus.text = @"No content for placement";
		}
	}
}

//MARK: - Tableview delegate and datasource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

	if (indexPath.section == 0) {
		return [PlacementCell cellForTableView:tableView placementTag:self.knownPlacements[indexPath.row] andInfo:nil];
	}
	else {
		return [PlacementCell cellForTableView:tableView placementTag:self.surveysPlacement andInfo:nil];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 0) {
		NSString *placementTag = self.knownPlacements[indexPath.row];
		if ([TapResearch canShowContentForPlacement: placementTag error:^(NSError * _Nullable error) {
			// Handle error, this is an optional error block
		}]) {
			[TapResearch showContentForPlacement:placementTag delegate:self customParameters:@{@"custom_param_1" : @"test text", @"custom_param_3" : @12} completion:^(NSError * _Nullable error) {
				if (error) {
					NSLog(@"Error on showContent: %ld, %@", (long)error.code, error.localizedDescription);
				}
			}];
		}
		else {
			NSLog(@"Placement not ready");
		}
	}
	else if (indexPath.section == 1) {
		[self performSegueWithIdentifier:@"ShowSurveys" sender:self.surveysPlacement];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	if (section == 0) {
		return @"Known Placements";
	}
	return @"Surveys";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

	BOOL hasSurveys = [TapResearch hasSurveysFor:self.surveysPlacement errorHandler:^(NSError * _Nullable error) { }];
	if (hasSurveys) {
		return 2;
	}
	return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	if (section == 0) {
		return self.knownPlacements.count;
	}
	return 1;
}

//MARK: - TapResearchContentDelegate

- (void)onTapResearchContentDismissedForPlacement:(NSString * _Nonnull)placement {
	NSLog(@"onTapResearchContentDismissedForPlacement(%@)", placement);
}

- (void)onTapResearchContentShownForPlacement:(NSString * _Nonnull)placement {
	NSLog(@"onTapResearchContentShownForPlacement(%@)", placement);
}

- (void)handleRefresh:(NSNotification*)n {
	[self.tableView reloadData];
}

@end
