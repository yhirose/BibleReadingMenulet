//
//  SchedulePanelController.m
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/26/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import "SchedulePanelController.h"
#import "LanguageInformation.h"
#import "Schedule.h"
#import "Utility.h"

@interface SchedulePanelController ()
@property NSColor *white;
@property NSColor *yellow;
@end

@implementation SchedulePanelController

- (id)init
{
    self = [super initWithWindowNibName:@"SchedulePanel"];
    _white = [NSColor whiteColor];
    _yellow = [NSColor yellowColor];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window
    // controller's window has been loaded from its nib file.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(redraw) name:@"scheduleChanged" object:nil];
    [nc addObserver:self selector:@selector(redraw) name:@"languageChanged" object:nil];
    
    NSInteger index = [Schedule scheduleType];
    [_scheduleTypeCombo selectItemAtIndex:index];
    
    Schedule *schedule = [Schedule currentSchedule];
    [_tableView scrollRowToVisible:[schedule currentIndex]];
}

- (IBAction)actionMarkAsRead:(id)sender
{
    Schedule *schedule = [Schedule currentSchedule];
    NSIndexSet *indexes = [_tableView selectedRowIndexes];
    NSInteger index = [indexes firstIndex];
    while(index != NSNotFound) {
        [schedule markAsReadAtIndex:index];
        index = [indexes indexGreaterThanIndex:index];        
    }
}

- (IBAction)actionMarkAsUnread:(id)sender
{
    Schedule *schedule = [Schedule currentSchedule];
    NSIndexSet *indexes = [_tableView selectedRowIndexes];
    NSInteger index = [indexes firstIndex];
    while(index != NSNotFound) {
        [schedule markAsUnreadAtIndex:index];
        index = [indexes indexGreaterThanIndex:index];        
    }
}

- (IBAction)actionSetCurrent:(id)sender
{
    Schedule *schedule = [Schedule currentSchedule];
    NSInteger row = [_tableView selectedRow];
    [schedule setCurrentIndex:row];
}

- (void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(int)row
{
    Schedule *schedule = [Schedule currentSchedule];
    [cell setDrawsBackground:YES];
    [cell setBackgroundColor:(row == [schedule currentIndex] ? _yellow : _white)];
}

- (void)redraw
{
    [_tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    Schedule *schedule = [Schedule currentSchedule];
    return [schedule.ranges count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Schedule *schedule = [Schedule currentSchedule];
    if ([[tableColumn identifier] isEqualToString:@"range"]) {
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        NSString *lang = [ud stringForKey:@"LANGUAGE"];
        
        NSString *str = schedule.ranges[row][@"range"];
        
        return [[LanguageInformation instance] translateRange:str language:lang];
    } else { // "date"
        return schedule.ranges[row][@"date"];
    }
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSInteger index = [_scheduleTypeCombo indexOfSelectedItem];
    [Schedule setScheduleType:index];
}

@end
