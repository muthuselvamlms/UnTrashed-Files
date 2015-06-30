//
//  unwanted_file_remover.h
//  unwanted_file_remover
//
//  Created by SentientIT on 30/06/15.
//  Copyright (c) 2015 Proton Engineers. All rights reserved.
//

#import <AppKit/AppKit.h>

@class unwanted_file_remover;

static unwanted_file_remover *sharedPlugin;

@interface unwanted_file_remover : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end