//
//  WTStudyModel.h
//  BibleReadingMenulet
//
//  Created by Tomohisa Takaoka on 8/20/12.
//  Copyright (c) 2012 Yuji Hirose. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WTSReadingStart @"WTSReadingStart"
#define WTSReadingEnd @"WTSReadingEnd"

@interface WTStudyModel : NSObject
@property (readonly) BOOL isPlaying;
-(IBAction)actionPlayThisWeek:(id)sender;
-(IBAction)actionOpenPDFThisWeek:(id)sender;
-(IBAction)actionPlayNextWeek:(id)sender;
-(IBAction)actionOpenPDFNextWeek:(id)sender;
-(IBAction)actionPlayPause:(id)sender;
-(IBAction)actionStop:(id)sender;
-(IBAction)actionRestart:(id)sender;
@property NSString* weekName;
@end
