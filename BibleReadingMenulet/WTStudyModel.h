//
//  WTStudyModel.h
//  BibleReadingMenulet
//
//  Created by Tomohisa Takaoka on 8/20/12.
//  Copyright (c) 2012 Yuji Hirose. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTStudyModel : NSObject
@property BOOL isPlaying;
-(IBAction)actionPlayThisWeek:(id)sender;
-(IBAction)actionOpenPDFThisWeek:(id)sender;
-(IBAction)actionPlayNextWeek:(id)sender;
-(IBAction)actionOpenPDFNextWeek:(id)sender;
@end
