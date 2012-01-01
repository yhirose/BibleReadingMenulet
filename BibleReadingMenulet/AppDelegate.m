//
//  AppDelegate.m
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/12/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import "AppDelegate.h"
#import "SchedulePanelController.h"
#import "Utility.h"

@implementation AppDelegate

- (void)setupProgressFiles
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *resourcePath = [bundle resourcePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:resourcePath error:nil])
    {
        if ([fileName hasSuffix:@".csv"])
        {
            NSString *path = [[Utility appDirPath] stringByAppendingPathComponent:fileName];
            
            if (![fileManager fileExistsAtPath:path]) {
                
                [fileManager createDirectoryAtPath:[Utility appDirPath]
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:nil];
                
                NSString *tmplPath = [resourcePath stringByAppendingPathComponent:fileName];
                
                [fileManager copyItemAtPath:tmplPath toPath:path error:nil];
            }   
        }
    }    
}

- (NSString *)htmlPathWithLanguage:(NSString *)lang book:(NSString *)book chapter:(NSNumber *)chap {
    NSString *dirPath = [Utility appDirPath];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@.html", book, chap, lang];
    return [dirPath stringByAppendingPathComponent:fileName];
}

- (NSString *)htmlTemplatePath {
    NSBundle *bundle = [NSBundle mainBundle];
    return [bundle pathForResource:@"Template" ofType:@"html"];
}

- (NSString *)setupHTMLFileWithLanguage:(NSString *)lang book:(NSString *)book chapter:(NSNumber *)chap
{
    NSString *path = [self htmlPathWithLanguage:lang
                                           book:book
                                        chapter:chap];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        
        [fileManager createDirectoryAtPath:[Utility appDirPath]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
        
        NSString *urlStr = [langInfo pageURLWithLanguage:lang
                                                    book:book
                                                 chapter:chap];
        
        NSURL *url = [NSURL URLWithString:urlStr];
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        NSURLResponse *resp;
        NSError *err;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:req
                                             returningResponse:&resp
                                                         error:&err];
        if (data == nil)
        {
            return nil;
        }
        
        NSString *nwtHTML = [[NSString alloc] initWithData:data 
                                                  encoding:NSUTF8StringEncoding];

        NSString *tmplPath = [self htmlTemplatePath];
        
        NSString *tmpl = [NSString stringWithContentsOfFile:tmplPath 
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];

        NSString *mp3UrlStr = [langInfo mp3URLWithLanguage:lang book:book chapter:chap];
        
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
    NSMenuItem *menuRead = [menu itemAtIndex:0];
    
    if ([schedule isComplete])
    {
        [statusItem setTitle:@"Congratulations!!"];
        
        [menuRead setSubmenu:nil];
    }
    else if ([schedule currentRange])
    {
        NSString *range = [schedule currentRange];        
        
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        NSString *lang = [ud stringForKey:@"LANGUAGE"];
        
        NSString *vernacularRane = [langInfo translateRange:range language:lang];
        
        [statusItem setTitle:vernacularRane];
        
        chapList = [langInfo makeChapterListFromRange:range language:lang];
        
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

- (void)setupLanguageMenu
{
    NSMenuItem *menuLang = [menu itemAtIndex:4];
    
    NSMenu *menuLangs = [[NSMenu alloc] initWithTitle:@"Languages"];

    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString *currLangSymbol = [ud stringForKey:@"LANGUAGE"];
    
    int i = 0;
    for (NSDictionary* val in langInfo.infoArray)
    {
        NSString *name = [val valueForKey:@"name"];
        NSString *symbol = [val valueForKey:@"symbol"];
        
        NSMenuItem *menuItem = [menuLangs addItemWithTitle:name
                                                    action:@selector(langAction:)
                                             keyEquivalent:@""];
        
        [menuItem setState:[currLangSymbol isEqualToString:symbol] ? NSOnState : NSOffState];

        [menuItem setTag:i];
        
        i++;
    }    
    
    [menuLang setSubmenu:menuLangs];    
}

- (void)setupUserDefaults
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    
    [defaults setObject:@"e" forKey:@"LANGUAGE"];
    [defaults setObject:@"OneYear.csv" forKey:@"PROGRESS"];
    
    [ud registerDefaults:defaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupUserDefaults];
    [self setupProgressFiles];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(setupStatusMenuTitle) name:@"currentRangeChanged" object:nil];
    [nc addObserver:self selector:@selector(setupStatusMenuTitle) name:@"languageChanged" object:nil];
    [nc addObserver:self selector:@selector(setupLanguageMenu) name:@"languageChanged" object:nil];
        
    langInfo = [LanguageInformation instance];
    schedule = [[Schedule alloc] initWithPath:[Utility progressPath]];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:menu];
    [statusItem setHighlightMode:YES];

    [self setupLanguageMenu];
    [self setupStatusMenuTitle];
}

- (IBAction)readAction:(id)sender
{
    NSInteger i = [sender tag];
    NSDictionary *item = [chapList objectAtIndex:i];
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString *lang = [ud stringForKey:@"LANGUAGE"];
    
    NSString *path = [self setupHTMLFileWithLanguage:lang
                                                book:[item valueForKey:@"book"]
                                             chapter:[item valueForKey:@"chap"]];
    
    if (path == nil)
    {
        NSRunAlertPanel(NSLocalizedString(@"OPEN_ERR_TTL", @"Title for Open error"),
                        NSLocalizedString(@"OPEN_ERR_MSG", @"Message for open error"),
                        @"OK", nil, nil);
    }
    else
    {
        NSURL *url = [NSURL fileURLWithPath:path];        
        [[NSWorkspace sharedWorkspace] openURL:url];
    }    
}

- (IBAction)langAction:(id)sender
{
    NSInteger i = [sender tag];
    NSDictionary *item = [langInfo.infoArray objectAtIndex:i];
    
    NSString *lang = [item valueForKey:@"symbol"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:lang forKey:@"LANGUAGE"];
    [ud synchronize];
    
    NSNotification *n = [NSNotification notificationWithName:@"languageChanged" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (IBAction)markAsReadAction:(id)sender
{
    [schedule markAsRead];
}

- (IBAction)quitAction:(id)sender
{
    [NSApp terminate:self];
}

- (IBAction)showSchedulePanel:(id)sender
{
    if (!schedulePanelController)
    {
        schedulePanelController = [[SchedulePanelController alloc] initWithSchedule:schedule];
    }
    
    [NSApp activateIgnoringOtherApps:YES];
    [schedulePanelController showWindow:self];
    [[schedulePanelController window] makeKeyAndOrderFront:self];
}

@end
