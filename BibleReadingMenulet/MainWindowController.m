//
//  MainWindowController.m
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 1/9/12.
//  Copyright (c) 2012 Yuji Hirose. All rights reserved.
//

#import "MainWindowController.h"

@implementation MainWindowController
@synthesize closeButton = _closeButton;

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterFull:)
                                                 name:NSWindowWillEnterFullScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterFull:)
                                                 name:NSWindowDidEnterFullScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didExitFull:)
                                                 name:NSWindowDidExitFullScreenNotification
                                               object:nil];
}

- (void)willEnterFull:(NSNotification *)notif
{
    _originalFrameRect = [[self window] frame];
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:_fullScreenURL]];
    [_webView setAlphaValue:0];
}

- (void)didEnterFull:(NSNotification *)notif
{
    [_closeButton setTransparent:NO];
    [_closeButton setEnabled:YES];
    [_webView setAlphaValue:1.0];
}

- (void)didExitFull:(NSNotification *)notif
{
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:_url]];
    [[self window] setFrame:_originalFrameRect display:YES];
}

- (NSApplicationPresentationOptions)window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions
{
    return (NSApplicationPresentationFullScreen |       // support full screen for this window (required)
            NSApplicationPresentationHideDock |         // completely hide the dock
            NSApplicationPresentationAutoHideMenuBar);  // yes we want the menu bar to show/hide
}

- (void) setupContentWithURL:(NSURL *)url fullScreenURL:(NSURL *)fullScreenURL title:(NSString *)title
{
    _url = url;
    _fullScreenURL = fullScreenURL;
    _title = title;
    
    [[self window] setTitle:_title];
    [_closeButton setTransparent:YES];
    [_closeButton setEnabled:NO];
    
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:_url]];
}

- (IBAction)closeAction:(id)sender {
    [[self window] close];
}

@end
