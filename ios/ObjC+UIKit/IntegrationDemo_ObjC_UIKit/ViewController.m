//
//  ViewController.m
//  IntegrationDemo_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

#import "ViewController.h"
#import "PlacementCell.h"
#import <TapResearchSDK/TapResearchSDK.h>

@interface ViewController () <UITextFieldDelegate,
                              UITableViewDelegate,
                              UITableViewDataSource,
                              TapResearchContentDelegate
                              >

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *placementStatus;

@property (strong, nonatomic) NSMutableArray *knownPlacements;

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

	self.textField.placeholder = @"Placement Tag";
	self.textField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.tableView reloadData];
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

- (IBAction)showPlacement {

	NSString *placementTag = self.textField.text;

	if (placementTag && placementTag.length > 0) {
		if ([TapResearchSDK canShowContentForPlacement:placementTag]) {
			[TapResearchSDK showContentForPlacement:placementTag delegate:self completion:^(NSError * _Nullable error) {
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
	return [PlacementCell cellForTableView:tableView andPlacementTag:self.knownPlacements[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	NSString *placementTag = self.knownPlacements[indexPath.row];
	if ([TapResearchSDK canShowContentForPlacement: placementTag]) {
		[TapResearchSDK showContentForPlacement:placementTag delegate:self customParameters:@{@"custom_param_1" : @"test text", @"custom_param_3" : @12} completion:^(NSError * _Nullable error) {
			if (error) {
				NSLog(@"Error on showContent: %ld, %@", (long)error.code, error.localizedDescription);
			}
		}];
	}
	 else {
		NSLog(@"Placement not ready");
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Known Placements";
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.knownPlacements.count;
}

//MARK: - TapResearchContentDelegate

- (void)onTapResearchContentDismissedForPlacement:(NSString * _Nonnull)placement {
	NSLog(@"onTapResearchContentDismissedForPlacement(%@)", placement);
}

- (void)onTapResearchContentShownForPlacement:(NSString * _Nonnull)placement {
	NSLog(@"onTapResearchContentShownForPlacement(%@)", placement);
}

@end
