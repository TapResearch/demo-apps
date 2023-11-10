//
//  PlacementCell.m
//  IntegrationDemo_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

#import "PlacementCell.h"

@interface PlacementCell ()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;

@end

@implementation PlacementCell

+ (PlacementCell*)cellForTableView:(UITableView*)tableView andPlacementTag:(NSString*)tag {

	static NSString *cellId = @"PlacementCell";
	PlacementCell *cell = (PlacementCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
	if (!cell) {
		cell = [[PlacementCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
	}
	[cell fillCellWithPlacementTag:tag];
	return cell;
}

- (void)fillCellWithPlacementTag:(NSString*)tag {

	self.title.text = tag;
	self.subLabel.text = nil;
}

@end
