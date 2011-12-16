//
//  AppDelegate.h
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/12/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSMenu *menu;
    NSStatusItem *statusItem;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction)readAction:(id)sender;
- (IBAction)markAsReadAction:(id)sender;
- (IBAction)quitAction:(id)sender;

@end
