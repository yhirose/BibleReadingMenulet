//
//  MainWindowController.h
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 1/9/12.
//  Copyright (c) 2012 Yuji Hirose. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MainWindowController : NSWindowController<NSSoundDelegate> {
    NSURL    *_url;
    NSURL    *_fullScreenURL;
    NSURL    *_audioFileURL;
    NSString *_title;
    NSRect   _originalFrameRect;
    NSSound  *_sound;
    BOOL     _paused;
    
    IBOutlet WebView* _webView;
}

@property (unsafe_unretained) IBOutlet NSButton *closeButton;
@property (unsafe_unretained) IBOutlet NSButton *playButton;

- (void) setupContentWithURL:(NSURL *)url fullScreenURL:(NSURL *)fullScreenURL audioFileURL:(NSURL *)audioFileURL title:(NSString *)title;

- (IBAction)closeAction:(id)sender;
- (IBAction)playAction:(id)sender;

@end
