//
//  SchedulePanelController.h
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/26/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SchedulePanelController : NSWindowController {
  @private
    NSColor *_white;
    NSColor *_yellow;
}

@property (unsafe_unretained) IBOutlet NSTableView *tableView;
@property (unsafe_unretained) IBOutlet NSComboBox *scheduleTypeCombo;

- (id)init;
- (IBAction)actionMarkAsRead:(id)sender;
- (IBAction)actionMarkAsUnread:(id)sender;
- (IBAction)actionSetCurrent:(id)sender;
- (void)redraw;
- (void)tableView:(NSTableView *)tableView 
  willDisplayCell:(id)cell 
   forTableColumn:(NSTableColumn *)tableColumn 
              row:(int)row;
@end
