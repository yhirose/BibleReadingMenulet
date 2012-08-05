//
//  SchedulePanelController.m
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/26/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import "SchedulePanelController.h"
#import "LanguageInformation.h"

@implementation SchedulePanelController

- (id)initWithSchedule:(Schedule *)schedule {
    self = [super initWithWindowNibName:@"SchedulePanel"];
    _schedule = schedule;
    _white = [NSColor whiteColor];
    _yellow = [NSColor yellowColor];
    return self;
}

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window
    // controller's window has been loaded from its nib file.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(redraw) name:@"currentRangeChanged" object:nil];
    [nc addObserver:self selector:@selector(redraw) name:@"languageChanged" object:nil];
    [nc addObserver:self selector:@selector(redraw) name:@"markChanged" object:nil];
    
    [_tableView scrollRowToVisible:[_schedule currentIndex]];
}

- (Schedule *)schedule {
    return _schedule;
}

- (IBAction)actionMarkAsRead:(id)sender {
    NSIndexSet *indexes = [_tableView selectedRowIndexes];
    NSInteger index = [indexes firstIndex];
    while(index != NSNotFound) {
        [_schedule markAsReadAtIndex:index];
        index = [indexes indexGreaterThanIndex:index];        
    }
}

- (IBAction)actionMarkAsUnread:(id)sender {
    NSIndexSet *indexes = [_tableView selectedRowIndexes];
    NSInteger index = [indexes firstIndex];
    while(index != NSNotFound) {
        [_schedule markAsUnreadAtIndex:index];
        index = [indexes indexGreaterThanIndex:index];        
    }
}

- (IBAction)actionSetCurrent:(id)sender {
    NSInteger row = [_tableView selectedRow];
    [_schedule setCurrentIndex:row];
}

- (void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(int)row {
    [cell setDrawsBackground:YES];
    [cell setBackgroundColor:(row == [_schedule currentIndex] ? _yellow : _white)];
}

- (void)redraw {
    [_tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView; {
    return [_schedule.ranges count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn identifier] isEqualToString:@"range"]) {
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        NSString *lang = [ud stringForKey:@"LANGUAGE"];
        
        NSString *str = _schedule.ranges[row][@"range"];
        
        return [[LanguageInformation instance] translateRange:str language:lang];
    } else { // "date"
        return _schedule.ranges[row][@"date"];
    }
}

@end
