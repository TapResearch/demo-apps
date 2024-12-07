//
//  NSObject+LogPrint.m
//  IntegrationDemo_ObjC_UIKit
//
//  Created by Jeroen Verbeek on 12/6/24.
//

#import "NSObject+LogPrint.h"

@implementation NSObject (LogPrint)

- (void)logPrint:(NSString*)text function:(const char *)funcName {
	NSLog(@"[%@]%@ %@", [NSDate date].description, [NSString stringWithCString:funcName encoding:NSUTF8StringEncoding], text);
}

@end
