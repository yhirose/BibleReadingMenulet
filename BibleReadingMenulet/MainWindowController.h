//
//  MainWindowController.h
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 1/9/12.
//  Copyright (c) 2012 Yuji Hirose. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MainWindowController : NSWindowController {
    NSURL    *_url;
    NSURL    *_fullScreenURL;
    NSString *_title;
    NSRect   _originalFrameRect;
    
    IBOutlet WebView* _webView;
}

@property (unsafe_unretained) IBOutlet NSButton *closeButton;

- (void) setupContentWithURL:(NSURL *)url fullScreenURL:(NSURL *)fullScreenURL title:(NSString *)title;

- (IBAction)closeAction:(id)sender;

@end
