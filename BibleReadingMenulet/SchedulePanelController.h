//
//  SchedulePanelController.h
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/26/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Schedule.h"

@interface SchedulePanelController : NSWindowController {
    Schedule *_schedule;
    NSColor *_white;
    NSColor *_yellow;
}

@property (unsafe_unretained) IBOutlet NSTableView *tableView;

- (id)initWithSchedule:(Schedule *)schedule;
- (Schedule *)schedule;
- (IBAction)actionMarkAsRead:(id)sender;
- (IBAction)actionMarkAsUnread:(id)sender;
- (IBAction)actionSetCurrent:(id)sender;
- (void)redraw;
- (void)tableView:(NSTableView *)tableView 
  willDisplayCell:(id)cell 
   forTableColumn:(NSTableColumn *)tableColumn 
              row:(int)row;
@end
