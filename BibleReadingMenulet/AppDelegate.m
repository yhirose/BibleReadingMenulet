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
@synthesize menu = _menu;
@synthesize windowController = _windowController;

enum MenuTag
{
    ReadMenuTag = 0,
    SchoolMenuTag = 1,
    LanguageMenuTag = 2
};

- (void)setupScheduleFiles
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
        
        NSString *urlStr = [_langInfo pageURLWithLanguage:lang
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

        NSString *html = [NSString stringWithFormat:tmpl, 
                          [Utility getTitle:nwtHTML],
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
    if (_schedule == nil)
    {
        return;
    }
    
    if ([_schedule isComplete])
    {
        [_statusItem setTitle:@"Congratulations!!"];
    }
    else
    {
        NSString *range = [_schedule currentRange];        
        
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        NSString *lang = [ud stringForKey:@"LANGUAGE"];
        
        NSString *vernacularRane = [_langInfo translateRange:range language:lang];
        
        [_statusItem setTitle:vernacularRane];
    }    
}

- (void)setupReadMenu
{
    NSMenuItem *menuRead = [_menu itemWithTag:ReadMenuTag];
    
    if (_schedule == nil)
    {
        return;
    }
    
    if ([_schedule isComplete])
    {
        [menuRead setSubmenu:nil];
    }
    else
    {
        NSString *range = [_schedule currentRange];        
        
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        NSString *lang = [ud stringForKey:@"LANGUAGE"];
        
        _chapList = [_langInfo makeChapterListFromRange:range language:lang];
        
        NSMenu *menuChapters = [[NSMenu alloc] init];        
        
        int i = 0;
        for (NSDictionary *item in _chapList)
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
    NSMenu *menuLangs = [[NSMenu alloc] init];

    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString *currLangSymbol = [ud stringForKey:@"LANGUAGE"];
    
    int i = 0;
    for (NSDictionary* val in _langInfo.infoArray)
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
    
    [[_menu itemWithTag:LanguageMenuTag] setSubmenu:menuLangs];    
}

- (void)setupSchoolMenu
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString *lang = [ud stringForKey:@"LANGUAGE"];
    
    _chapListForSchool = [NSMutableArray array];
    NSMenu *menuChapters = [[NSMenu alloc] init];
    
    int i = 0;
    for (NSString *range in [Utility getRangesForSchool])
    {
        if (i != 0)
        {
            [menuChapters addItem:[NSMenuItem separatorItem]];
        }
        
        NSMutableArray *chapList = [_langInfo makeChapterListFromRange:range language:lang];
        
        for (NSDictionary *item in chapList)
        {
            NSMenuItem *menuItem = [menuChapters addItemWithTitle:[item valueForKey:@"label"]
                                                           action:@selector(readActionForSchool:)
                                                    keyEquivalent:@""];
            
            [menuItem setTag:i];
            
            i++;
        }
        
        [_chapListForSchool addObjectsFromArray:chapList];
    }    
    
    [[_menu itemWithTag:SchoolMenuTag] setSubmenu:menuChapters];
}

- (void)setupUserDefaults
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    
    [defaults setObject:@"e" forKey:@"LANGUAGE"];
    [defaults setObject:@"Schedule.csv" forKey:@"SCHEDULE"];
    
    [ud registerDefaults:defaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupUserDefaults];
    [self setupScheduleFiles];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(setupStatusMenuTitle) name:@"currentRangeChanged" object:nil];
    [nc addObserver:self selector:@selector(setupStatusMenuTitle) name:@"languageChanged" object:nil];
        
    _langInfo = [LanguageInformation instance];
    _schedule = [[Schedule alloc] initWithPath:[Utility schedulePath]];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setMenu:_menu];
    [_statusItem setHighlightMode:YES];
    
    [_menu setDelegate:self];
    
    [self setupStatusMenuTitle];
}

- (void)read:(id)sender chapterList:(NSMutableArray *)chapList
{
    NSInteger i = [sender tag];
    NSDictionary *item = [chapList objectAtIndex:i];
    
    NSString *book = [item valueForKey:@"book"];
    NSNumber *chap = [item valueForKey:@"chap"];
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString *lang = [ud stringForKey:@"LANGUAGE"];

    NSString *urlStr = [_langInfo pageURLWithLanguage:lang
                                                 book:book
                                              chapter:chap];
    
    NSURL *url = [NSURL URLWithString:urlStr];

    if (url == nil)
    {
        NSRunAlertPanel(NSLocalizedString(@"OPEN_ERR_TTL", @"Title for Open error"),
                        NSLocalizedString(@"OPEN_ERR_MSG", @"Message for open error"),
                        @"OK", nil, nil);
        
        return;
    }
    
    urlStr = [self setupHTMLFileWithLanguage:lang
                                        book:book
                                     chapter:chap];
    
    NSURL *urlFullScreen = [NSURL fileURLWithPath:urlStr];        

    urlStr = [_langInfo mp3URLWithLanguage:lang
                                      book:book
                                   chapter:chap];

    NSURL *urlAudioFile = [NSURL URLWithString:urlStr];

    [_windowController setupContentWithURL:url
                             fullScreenURL:urlFullScreen
                              audioFileURL:urlAudioFile
                                     title:[item valueForKey:@"label"]];
    
    [NSApp activateIgnoringOtherApps:YES];
    [_windowController showWindow:self];
    [[_windowController window] makeKeyAndOrderFront:self];

}

- (IBAction)readAction:(id)sender
{
    [self read:sender chapterList:_chapList];
}

- (IBAction)readActionForSchool:(id)sender
{
    [self read:sender chapterList:_chapListForSchool];
}

- (IBAction)langAction:(id)sender
{
    NSInteger i = [sender tag];
    NSDictionary *item = [_langInfo.infoArray objectAtIndex:i];
    
    NSString *lang = [item valueForKey:@"symbol"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:lang forKey:@"LANGUAGE"];
    [ud synchronize];
    
    NSNotification *n = [NSNotification notificationWithName:@"languageChanged" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (IBAction)markAsReadAction:(id)sender
{
    [_schedule markAsRead];
}

- (IBAction)quitAction:(id)sender
{
    [NSApp terminate:self];
}

- (IBAction)showSchedulePanel:(id)sender
{
    if (!_schedulePanelController)
    {
        _schedulePanelController = [[SchedulePanelController alloc] initWithSchedule:_schedule];
    }
    
    [NSApp activateIgnoringOtherApps:YES];
    [_schedulePanelController showWindow:self];
    [[_schedulePanelController window] makeKeyAndOrderFront:self];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    [self setupReadMenu];
    [self setupLanguageMenu];
    [self setupSchoolMenu];
}

@end
