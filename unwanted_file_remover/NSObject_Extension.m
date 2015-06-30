//
//  NSObject_Extension.m
//  unwanted_file_remover
//
//  Created by SentientIT on 30/06/15.
//  Copyright (c) 2015 Proton Engineers. All rights reserved.
//


#import "NSObject_Extension.h"
#import "unwanted_file_remover.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[unwanted_file_remover alloc] initWithBundle:plugin];
        });
    }
}
@end
