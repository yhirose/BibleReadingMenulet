//
//  AppDelegate.m
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/12/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import "AppDelegate.h"
#import "Utility.h"

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
    if ([schedule isComplete])
    {
        [statusItem setTitle:@"Congratulations!!"];
    }
    else
    {
        NSString *range = [schedule currRange];
        [statusItem setTitle:range];
        
        NSMenu *menuChapters = [[NSMenu alloc] initWithTitle:@"Chapters"];
        
        chapList = [Utility makeChapterList:range];
        int i = 0;
        for (NSDictionary *item in chapList)
        {
            NSMenuItem *menuItem = [menuChapters addItemWithTitle:[item valueForKey:@"label"]
                                    action:@selector(readAction:)
                             keyEquivalent:@""];
            [menuItem setTag:i];
            i++;
        }
        
        NSMenuItem *menuRead = [menu itemWithTitle:@"Read"];
        [menuRead setSubmenu:menuChapters];
    }    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupProgressFile];
    
    schedule = [[Schedule alloc] initWithPath:[self progressPath]];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:menu];
    [statusItem setHighlightMode:YES];
    
    [self setupStatusMenuTitle];
}

- (IBAction)readAction:(id)sender
{
    NSInteger i = [sender tag];
    NSDictionary *item = [chapList objectAtIndex:i];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://www.watchtower.org/j/bible/%@/chapter_%03d.htm",
     [[item valueForKey:@"book"] lowercaseString],
     [[item valueForKey:@"chap"] intValue]];

    NSURL *url = [NSURL URLWithString:urlStr];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)markAsReadAction:(id)sender
{
    [schedule markAsRead];
    [self setupStatusMenuTitle];
}

- (IBAction)quitAction:(id)sender
{
    [NSApp terminate:self];
}
@end
