//
//  MainWindowController.m
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 1/9/12.
//  Copyright (c) 2012 Yuji Hirose. All rights reserved.
//

#import "MainWindowController.h"
#import "Utility.h"

@implementation MainWindowController
@synthesize closeButton = _closeButton;
@synthesize playButton = _playButton;

- (void)awakeFromNib
{
    if ([Utility isLionOrLater])
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willClose:)
                                                 name:NSWindowWillCloseNotification
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
    //[_playButton setTransparent:NO];
    //[_playButton setEnabled:YES];
    [_webView setAlphaValue:1.0];
}

- (void)willClose:(NSNotification *)notif
{
    if ([_sound isPlaying]) {
        [_sound stop];
    }
}

- (void)didExitFull:(NSNotification *)notif
{
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:_url]];
    [[self window] setFrame:_originalFrameRect display:YES];
}

- (NSApplicationPresentationOptions)window:(NSWindow *)window
      willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions
{
    return (NSApplicationPresentationFullScreen |
            NSApplicationPresentationHideDock |
            NSApplicationPresentationAutoHideMenuBar);
}

- (void) setupContentWithURL:(NSURL *)url fullScreenURL:(NSURL *)fullScreenURL audioFileURL:(NSURL *)audioFileURL title:(NSString *)title
{
    _url = url;
    _fullScreenURL = fullScreenURL;
    _audioFileURL = audioFileURL;
    _title = title;
    
    [[self window] setTitle:_title];
    [_closeButton setTransparent:YES];
    [_closeButton setEnabled:NO];
    //[_playButton setTransparent:YES];
    //[_playButton setEnabled:NO];
    
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:_url]];
}

- (IBAction)closeAction:(id)sender
{
    [[self window] close];
}

- (IBAction)playAction:(id)sender
{
    if (!_sound)
    {
        _sound = [[NSSound alloc] initWithContentsOfURL:_audioFileURL byReference:FALSE];
        [_sound setDelegate:self];
    }
    
    if ([_sound isPlaying])
    {
        if (!_paused)
        {
            [_sound pause];
            _paused = YES;
        }
        else
        {
            [_sound resume];
            _paused = NO;
        }
    }
    else
    {
        [_sound play];
        _paused = NO;
    }
    
    [_playButton setTitle:[_sound isPlaying] && !_paused ? @"||" : @">"];
}

- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)finishedPlaying
{
    if (finishedPlaying)
    {
        _paused = NO;
        [_playButton setTitle:@">"];
    }
}

@end
