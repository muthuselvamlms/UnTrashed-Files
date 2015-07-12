//
//  unwanted_file_remover.m
//  unwanted_file_remover
//
//  Created by SentientIT on 30/06/15.
//  Copyright (c) 2015 Proton Engineers. All rights reserved.
//

#import "unwanted_file_remover.h"
#import "KFConsoleController.h"

@interface unwanted_file_remover()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation unwanted_file_remover

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Identify Unused Files" action:@selector(doMenuAction) keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self printmsgOnXcodeConsole:@"Starting"];
        [self IdentifyUnusedFiles:[self getCurrentWorkspaceDirectory]];
        [self printmsgOnXcodeConsole:@"end"];
    });

}

-(void)IdentifyUnusedFiles:(NSString *)workspacePath {
    NSFileManager *workspaceManager = [NSFileManager defaultManager];
    NSArray *Project_Folder = [workspaceManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:workspacePath] includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey, NSURLContentModificationDateKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    if ([Project_Folder count] > 0) {
        NSString *path;
        BOOL isDir;
        NSString *Pbx_Content = [self getContentofPbxFile];
        for (NSURL *file in Project_Folder) {
//            NSLog(@"%@",[file path]);
            isDir = NO;
            path = [file path];
            if ([workspaceManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
                if ([path hasSuffix:@".framework"] || [path hasSuffix:@".bundle"] || [path hasSuffix:@".xcassets"] || [path hasSuffix:@".xcodeproj"] || [path hasSuffix:@".xcworkspace"]) {
                    if (![Pbx_Content containsString:[self getFileName:path]]) {
                        [self printmsgOnXcodeConsole:[NSString stringWithFormat:@"Not Found : %@",path]];
                    }
                }
                else {
                    [self IdentifyUnusedFiles:path];
                }
            }
            else {
                //files
                if (![Pbx_Content containsString:[self getFileName:path]]) {
                    [self printmsgOnXcodeConsole:[NSString stringWithFormat:@"Not Found : %@",path]];
                }
            }
        }
    }
}

-(NSString *)getFileName:(NSString *)path {
    return [[path componentsSeparatedByString:@"/"] lastObject];
}

-(void)printmsgOnXcodeConsole:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
    [[KFConsoleController sharedInstance] logMessage:msg printBold:NO];
    });
}

-(NSString *)getContentofPbxFile {
    NSFileManager *workspaceManager = [NSFileManager defaultManager];
    NSArray *Project_Folder = [workspaceManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:[self getCurrentWorkspaceDirectory]] includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey, NSURLContentModificationDateKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    NSString *filePath;
    for (NSURL *file in Project_Folder) {
        if ([[file path] hasSuffix:@".xcodeproj"]) {
            filePath = [[file path] stringByAppendingFormat:@"/project.pbxproj"];
            break;
        }
    }
    return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *) getCurrentWorkspaceDirectory
{
    NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") valueForKey:@"workspaceWindowControllers"];

    id workSpace;

    for (id controller in workspaceWindowControllers) {
        if ([[controller valueForKey:@"window"] isEqual:[NSApp keyWindow]]) {
            workSpace = [controller valueForKey:@"_workspace"];
        }
    }

    NSString *workspacePath = [[workSpace valueForKey:@"representingFilePath"] valueForKey:@"_pathString"];
    workspacePath = [workspacePath stringByReplacingOccurrencesOfString:[workspacePath lastPathComponent] withString:@""];
    return workspacePath;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
