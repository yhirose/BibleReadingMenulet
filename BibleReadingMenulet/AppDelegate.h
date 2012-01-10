//
//  AppDelegate.h
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/12/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Schedule.h"
#import "LanguageInformation.h"
#import "MainWindowController.h"

@class SchedulePanelController;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
    @private
    NSStatusItem *_statusItem;
    LanguageInformation *_langInfo;
    Schedule *_schedule;
    NSMutableArray *_chapList;
    NSMutableArray *_chapListForSchool;
    SchedulePanelController *_schedulePanelController;
}

@property (unsafe_unretained) IBOutlet NSMenu *menu;
@property (unsafe_unretained) IBOutlet MainWindowController *windowController;

- (void)read:(id)sender chapterList:(NSMutableArray *)chapList;
- (IBAction)readAction:(id)sender;
- (IBAction)readActionForSchool:(id)sender;
- (IBAction)langAction:(id)sender;
- (IBAction)markAsReadAction:(id)sender;
- (IBAction)quitAction:(id)sender;
- (IBAction)showSchedulePanel:(id)sender;

@end
