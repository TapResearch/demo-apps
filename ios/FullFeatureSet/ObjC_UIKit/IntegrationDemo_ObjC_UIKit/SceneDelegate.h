//
//  SceneDelegate.h
//  IntegrationDemo_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

#import <UIKit/UIKit.h>
#import <TapResearchSDK/TapResearchSDK.h>

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate, TapResearchSDKDelegate>

@property (strong, nonatomic) UIWindow * window;

@end

