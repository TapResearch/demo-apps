//
//  PlacementCell.h
//  IntegrationDemo_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

#import <UIKit/UIKit.h>

@interface PlacementCell : UITableViewCell

+ (PlacementCell*)cellForTableView:(UITableView*)tableView placementTag:(NSString*)tag andInfo:(NSString*)info;

@end
