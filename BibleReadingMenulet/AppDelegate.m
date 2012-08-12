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

enum MenuTag {
    ReadMenuTag = 0,
    SchoolMenuTag = 1,
    LanguageMenuTag = 2
};

- (void)setupScheduleFiles
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *dstPath = [Schedule scheduleDirPath];
    if (![fileManager fileExistsAtPath:dstPath]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *srcPath = [[bundle resourcePath] stringByAppendingPathComponent:@"schedule"];
        
        NSError *err;
        [fileManager moveItemAtPath:srcPath toPath:dstPath error:&err];
    }
}

- (void)setupStatusMenuTitle
{
    Schedule *schedule = [Schedule currentSchedule];
    
    if ([schedule isComplete]) {
        [_statusItem setTitle:@"Congratulations!!"];
    } else {
        NSString *range = [schedule currentRange];        
        
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        NSString *lang = [ud stringForKey:@"LANGUAGE"];
        
        LanguageInformation *langInfo = [LanguageInformation instance];
        NSString *vernacularRane = [langInfo translateRange:range language:lang];
        
        [_statusItem setTitle:vernacularRane];
    }    
}

- (void)setupReadMenu
{
    Schedule *schedule = [Schedule currentSchedule];
    
    if (schedule == nil) {
        return;
    }
    
    NSMenuItem *menuRead = [_menu itemWithTag:ReadMenuTag];
    
    if ([schedule isComplete]) {
        [menuRead setSubmenu:nil];
    } else {
        NSString *range = [schedule currentRange];        
        
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        NSString *lang = [ud stringForKey:@"LANGUAGE"];

        NSMutableDictionary *prevProgress = [Schedule getProgress:@"SCHEDULE_PROGRESS"];
        NSMutableDictionary *progress = [NSMutableDictionary dictionary];        
        
        LanguageInformation *langInfo = [LanguageInformation instance];
        _chapList = [langInfo makeChapterListFromRange:range language:lang];
        
        NSMenu *menuChapters = [[NSMenu alloc] init];        
        
        int i = 0;
        for (NSDictionary *item in _chapList) {
            NSString *label = item[@"label"];
            NSString *bookChapId = item[@"bookChapId"];

            NSMenuItem *menuItem = [menuChapters addItemWithTitle:label
                                                           action:@selector(readAction:)
                                                    keyEquivalent:@""];
            
            [menuItem setTag:i];
            
            if (prevProgress[bookChapId]) {
                [menuItem setState:NSOnState];
                [progress setValue:@YES forKey:bookChapId];
            }
            
            i++;
        }
        
        [menuRead setSubmenu:menuChapters];
        
        [Schedule setProgress:progress type:@"SCHEDULE_PROGRESS"];
    }
}

- (NSString *)htmlDirPath
{
    NSString *dirPath = [Utility appDirPath];
    return [dirPath stringByAppendingPathComponent:@"html"];
}

- (NSString *)htmlPathWithLanguage:(NSString *)lang book:(NSString *)book chapter:(NSNumber *)chap
{
    NSString *dirPath = [self htmlDirPath];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@.html", book, chap, lang];
    return [dirPath stringByAppendingPathComponent:fileName];
}

- (NSString *)htmlTemplatePath
{
    NSBundle *bundle = [NSBundle mainBundle];
    return [bundle pathForResource:@"Template" ofType:@"html"];
}

// Create html directory in application directory, and copy support files to it.
- (void)setupHTMLDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *dstPath = [self htmlDirPath];
    if (![fileManager fileExistsAtPath:dstPath]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *srcPath = [[bundle resourcePath] stringByAppendingPathComponent:@"html"];
        
        NSError *err;
        [fileManager copyItemAtPath:srcPath toPath:dstPath error:&err];
    }    
}

// Remove html directory in application directory
- (void)removeHTMLDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[self htmlDirPath]]) {
        NSError *err;
        [fileManager removeItemAtPath:[self htmlDirPath] error:&err];
    }
}

- (NSString *)setupHTMLFileWithLanguage:(NSString *)lang book:(NSString *)book chapter:(NSNumber *)chap
{
    [self setupHTMLDirectory];
    
    // Create a reading HTML file.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self htmlPathWithLanguage:lang
                                           book:book
                                        chapter:chap];
    
    LanguageInformation *langInfo = [LanguageInformation instance];
    
    if (![fileManager fileExistsAtPath:path]) {
        NSString *urlStr = [langInfo wolPageURLWithLanguage:lang
                                                       book:book
                                                    chapter:chap];
        if (urlStr == nil) {
            return nil;
        }
        
        NSURL *url = [NSURL URLWithString:urlStr];
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        NSURLResponse *resp;
        NSError *err;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:req
                                             returningResponse:&resp
                                                         error:&err];
        if (data == nil) {
            return nil;
        }
        
        NSString *nwtHTML = [[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding];
        
        NSString *tmplPath = [self htmlTemplatePath];
        
        NSString *tmpl = [NSString stringWithContentsOfFile:tmplPath
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
        
        NSString *html = [NSString stringWithFormat:tmpl,
                          [Utility getTitleWol:nwtHTML],
                          urlStr,
                          [Utility getContentWol:nwtHTML],
                          lang,
                          @([langInfo getBookNo:book]),
                          chap];
        
        [html writeToFile:path
               atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:nil];
    }
    
    return path;
}

- (void)setupLanguageMenu
{    
    NSMenu *menuLangs = [[NSMenu alloc] init];

    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];

    NSString *currLangSymbol = [ud stringForKey:@"LANGUAGE"];
    LanguageInformation *langInfo = [LanguageInformation instance];
    
    int i = 0;
    for (NSDictionary* val in langInfo.infoArray) {
        NSString *name = val[@"name"];
        NSString *symbol = val[@"symbol"];

        if ([symbol isEqualToString:@"*"])
            continue;
        
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
    
    NSMutableDictionary *prevProgress = [Schedule getProgress:@"SCHOOL_SCHEDULE_PROGRESS"];
    NSMutableDictionary *progress = [NSMutableDictionary dictionary];
    
    _chapListForSchool = [NSMutableArray array];
    NSMenu *menuChapters = [[NSMenu alloc] init];

    LanguageInformation *langInfo = [LanguageInformation instance];
    
    int i = 0;
    for (NSString *range in [Utility getRangesForSchool]) {
        if (i != 0) {
            [menuChapters addItem:[NSMenuItem separatorItem]];
        }
        
        NSMutableArray *chapList = [langInfo makeChapterListFromRange:range language:lang];
        
        for (NSDictionary *item in chapList) {
            NSString *label = item[@"label"];
            NSString *bookChapId = item[@"bookChapId"];
                        
            NSMenuItem *menuItem = [menuChapters addItemWithTitle:label
                                                           action:@selector(readActionForSchool:)
                                                    keyEquivalent:@""];
            
            [menuItem setTag:i];
            
            if (prevProgress[bookChapId]) {
                [menuItem setState:NSOnState];
                [progress setValue:@YES forKey:bookChapId];
            }
            
            i++;
        }
        
        [_chapListForSchool addObjectsFromArray:chapList];
    }    
    
    [[_menu itemWithTag:SchoolMenuTag] setSubmenu:menuChapters];
    
    [Schedule setProgress:progress type:@"SCHOOL_SCHEDULE_PROGRESS"];
}

- (void)setupUserDefaults
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    
    defaults[@"LANGUAGE"] = @"e";
    defaults[@"SCHEDULE_TYPE"] = @(0);
    defaults[@"SCHEDULE_DIR"] = [[Utility appDirPath] stringByAppendingPathComponent:@"schedule"];
    
    [ud registerDefaults:defaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self removeHTMLDirectory];
    [self setupUserDefaults];
    [self setupScheduleFiles];
    [self setupFSEventListener];

    // Create the application directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[Utility appDirPath]]) {
        [fileManager createDirectoryAtPath:[Utility appDirPath]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    // Register event observers
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(setupStatusMenuTitle) name:@"scheduleChanged" object:nil];
    [nc addObserver:self selector:@selector(setupStatusMenuTitle) name:@"languageChanged" object:nil];
    
    // Make menulet
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setMenu:_menu];
    [_statusItem setHighlightMode:YES];    
    [_menu setDelegate:self];
    
    [self setupStatusMenuTitle];
}

- (void)read:(id)sender chapterList:(NSMutableArray *)chapList type:(NSString *)type
{
    // Get the selected menu item
    NSInteger i = [sender tag];
    NSDictionary *item = chapList[i];

    // Make a reading page
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];

    NSString *book = item[@"book"];
    NSNumber *chap = item[@"chap"];
    NSString *lang = [ud stringForKey:@"LANGUAGE"];

    NSString *urlStr = [self setupHTMLFileWithLanguage:lang
                                                  book:book
                                               chapter:chap];

    NSURL *url = nil;
    
    if (urlStr) {
        url = [NSURL fileURLWithPath:urlStr];
    } else {
        LanguageInformation *langInfo = [LanguageInformation instance];
        urlStr = [langInfo pageURLWithLanguage:lang
                                           book:book
                                        chapter:chap];
        
        url = [NSURL URLWithString:urlStr];
    }

    if (url == nil) {
        NSRunAlertPanel(NSLocalizedString(@"OPEN_ERR_TTL", @"Title for Open error"),
                        NSLocalizedString(@"OPEN_ERR_MSG", @"Message for open error"),
                        @"OK", nil, nil);
        
        return;
    }
    
    // Show the reading page with the default browser
    [[NSWorkspace sharedWorkspace] openURL:url];

    // Check the selected item
    NSMutableDictionary *progress = [Schedule getProgress:type];
    [progress setValue:@YES forKey:item[@"bookChapId"]];
    [Schedule setProgress:progress type:type];
}

- (IBAction)readAction:(id)sender
{
    [self read:sender chapterList:_chapList type:@"SCHEDULE_PROGRESS"];
}

- (IBAction)readActionForSchool:(id)sender
{
    [self read:sender chapterList:_chapListForSchool type:@"SCHOOL_SCHEDULE_PROGRESS"];
}

- (IBAction)langAction:(id)sender
{
    LanguageInformation *langInfo = [LanguageInformation instance];
    
    NSInteger i = [sender tag];
    NSDictionary *item = (langInfo.infoArray)[i];
    
    NSString *lang = item[@"symbol"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:lang forKey:@"LANGUAGE"];
    [ud synchronize];
    
    NSNotification *n = [NSNotification notificationWithName:@"languageChanged" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (IBAction)markAsReadAction:(id)sender
{
    Schedule *schedule = [Schedule currentSchedule];
    [schedule markAsRead];
}

- (IBAction)quitAction:(id)sender
{
    [NSApp terminate:self];
}

- (IBAction)showSchedulePanel:(id)sender
{
    if (!_schedulePanelController) {
        _schedulePanelController = [[SchedulePanelController alloc] init];
    }    
    [NSApp activateIgnoringOtherApps:YES];
    [_schedulePanelController showWindow:self];
    [[_schedulePanelController window] makeKeyAndOrderFront:self];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    [self setupStatusMenuTitle];
    [self setupReadMenu];
    [self setupLanguageMenu];
    [self setupSchoolMenu];
}

static void fsEventsCallBack(ConstFSEventStreamRef streamRef,
                             void *userData,
                             size_t numEvents,
                             void *eventPaths,
                             const FSEventStreamEventFlags eventFlags[],
                             const FSEventStreamEventId eventIds[])
{
    [Schedule reloadSchedule];
}

- (void)setupFSEventListener
{
	NSArray* pathsToWatch = @[[Schedule scheduleDirPath]];
    
	FSEventStreamContext context = {0, NULL, NULL, NULL, NULL};
    FSEventStreamRef stream;
    NSTimeInterval latency = 3.0; /* Latency in seconds */
    
    stream = FSEventStreamCreate(NULL,
                                 &fsEventsCallBack,
                                 &context,
                                 (__bridge CFArrayRef)pathsToWatch,
                                 kFSEventStreamEventIdSinceNow,
                                 latency,
                                 kFSEventStreamCreateFlagNone);
    
    FSEventStreamScheduleWithRunLoop(stream,
                                     CFRunLoopGetCurrent(), kCFRunLoopDefaultMode
                                     );
    
	FSEventStreamStart(stream);
}

@end
