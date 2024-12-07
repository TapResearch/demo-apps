//
//  NSObject+LogPrint.h
//  IntegrationDemo_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 12/6/24.
//

#import <Foundation/Foundation.h>

@interface NSObject (LogPrint)

- (void)logPrint:(NSString*)text function:(const char *)funcName;

@end

