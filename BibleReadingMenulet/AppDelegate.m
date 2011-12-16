//
//  AppDelegate.m
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/12/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (NSString *)appDirPath {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dirPath  = [rootPath stringByAppendingPathComponent:@"BibleReadingMenulet"];
    return dirPath;
}

- (NSString *)progressPath {
    NSString *dirPath = [self appDirPath];
    NSString *filePath = [dirPath stringByAppendingPathComponent:@"progress.csv"];
    return filePath;
}

- (NSString *)templatePath {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"OneYear" ofType:@"csv"];
    return path;
}

- (NSString *)getCurrentRange
{
    NSString *path = [self progressPath];
    NSString *rdata = [NSString stringWithContentsOfFile:path
                                                encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [rdata componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSLog(@"range -> %@", line);
        NSArray *fields = [line componentsSeparatedByString:@","];
        NSUInteger count = [fields count];
        if (count == 1) {
            return [fields objectAtIndex:0];
        }
    }
    
    return nil;
}

- (void)markCurrentRangeAsRead
{
    // TODO:
    NSString *path = [self progressPath];
    NSString *rdata = [NSString stringWithContentsOfFile:path
                                                encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *newLines = [NSMutableArray array];
    BOOL found = FALSE;
    NSArray *lines = [rdata componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSArray *fields = [line componentsSeparatedByString:@","];
        NSUInteger count = [fields count];
        if (!found && count == 1) {
            NSDate *now = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@", yyyy-MM-dd(E) HH:mm:ss"];
            NSString *result = [formatter stringFromDate:now];
            [newLines addObject:[line stringByAppendingString:result]];
            found = TRUE;
        } else {
            [newLines addObject:line];
        }
    }
    
    NSString* wdata = [newLines componentsJoinedByString:@"\n"];
    [wdata writeToFile:path atomically:TRUE encoding:NSUTF8StringEncoding error:nil];
}

- (void)setupProgressFile
{
    NSString *progPath = [self progressPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:progPath]) {
        [fileManager createDirectoryAtPath:[self appDirPath]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
        NSString *tmplPath = [self templatePath];
        [fileManager copyItemAtPath:tmplPath toPath:progPath error:nil];
    }
}

- (void)setupStatusMenuTitle
{
    NSString *range = [self getCurrentRange];
    if (range) {
        [statusItem setTitle:range];
    } else {
        [statusItem setTitle:@"Congratulations!!"];
    }    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupProgressFile];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:menu];
    [statusItem setHighlightMode:YES];
    [self setupStatusMenuTitle];
}

- (IBAction)readAction:(id)sender {
    NSString *range = [self getCurrentRange];
    if (range) {
        // TODO: open the bible...
    }    
}

- (IBAction)markAsReadAction:(id)sender {
    [self markCurrentRangeAsRead];
    [self setupStatusMenuTitle];
}

- (IBAction)quitAction:(id)sender {
    [NSApp terminate:self];
}
@end
