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
    return [rootPath stringByAppendingPathComponent:@"BibleReadingMenulet"];
}

- (NSString *)progressPath {
    NSString *dirPath = [self appDirPath];
    return [dirPath stringByAppendingPathComponent:@"progress.csv"];
}

- (NSString *)progressTemplatePath {
    NSBundle *bundle = [NSBundle mainBundle];
    return [bundle pathForResource:@"OneYear" ofType:@"csv"];
}

- (void)setupProgressFile
{
    NSString *path = [self progressPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        
        [fileManager createDirectoryAtPath:[self appDirPath]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
        
        NSString *tmplPath = [self progressTemplatePath];
        
        [fileManager copyItemAtPath:tmplPath toPath:path error:nil];
    }
}

- (NSString *)htmlPathForBook:(NSString *)book forChap:(NSNumber *)chap {
    NSString *dirPath = [self appDirPath];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.html", book, chap];
    return [dirPath stringByAppendingPathComponent:fileName];
}

- (NSString *)htmlTemplatePath {
    NSBundle *bundle = [NSBundle mainBundle];
    return [bundle pathForResource:@"Template" ofType:@"html"];
}

- (NSString *)setupHTMLFileForBook:(NSString *)book forChap:(NSNumber *)chap
{
    NSString *path = [self htmlPathForBook:book forChap:chap];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        
        [fileManager createDirectoryAtPath:[self appDirPath]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"http://www.watchtower.org/j/bible/%@/chapter_%03d.htm",
                            [book lowercaseString],
                            [chap intValue]];
        
        NSURL *url = [NSURL URLWithString:urlStr];
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        NSURLResponse *resp;
        NSError *err;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:req
                                             returningResponse:&resp
                                                         error:&err];
        
        NSString *nwtHTML = [[NSString alloc] initWithData:data 
                                                  encoding:NSUTF8StringEncoding];

        NSString *tmplPath = [self htmlTemplatePath];
        
        NSString *tmpl = [NSString stringWithContentsOfFile:tmplPath 
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];

        NSString *mp3UrlStr = [NSString stringWithFormat:@"http://download.jw.org/files/media_bible/%02d_%@_J_%02d.mp3",
                            [Utility getBookNo:book],
                            book,
                            [chap intValue]];
        
        NSString *html = [NSString stringWithFormat:tmpl, 
                          [Utility getTitle:nwtHTML],
                          mp3UrlStr,
                          [Utility getContent:nwtHTML]];
        
        [html writeToFile:path
               atomically:TRUE 
                 encoding:NSUTF8StringEncoding 
                    error:nil];
    }
    
    return path;
}

- (void)setupStatusMenuTitle
{
    NSMenuItem *menuRead = [menu itemWithTitle:@"Read"];
    NSMenuItem *menuListen = [menu itemWithTitle:@"Listen"];
    
    if ([schedule isComplete])
    {
        [statusItem setTitle:@"Congratulations!!"];
        
        [menuRead setSubmenu:nil];
        [menuListen setSubmenu:nil];
    }
    else
    {
        NSString *range = [schedule currRange];
        [statusItem setTitle:range];
        
        chapList = [Utility makeChapterList:range];
        
        NSMenu *menuChapters = [[NSMenu alloc] initWithTitle:@"Read Chapters"];        
        
        int i = 0;
        for (NSDictionary *item in chapList)
        {
            NSMenuItem *menuItem = [menuChapters addItemWithTitle:[item valueForKey:@"label"]
                                                           action:@selector(readAction:)
                                                    keyEquivalent:@""];
            
            [menuItem setTag:i];
            
            i++;
        }
        
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
    
    NSString *path = [self setupHTMLFileForBook:[item valueForKey:@"book"]
                                        forChap:[item valueForKey:@"chap"]];
    
    NSURL *url = [NSURL fileURLWithPath:path];

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
