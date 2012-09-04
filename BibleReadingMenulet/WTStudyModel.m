//
//  WTStudyModel.m
//  BibleReadingMenulet
//
//  Created by Tomohisa Takaoka on 8/20/12.
//  Copyright (c) 2012 Yuji Hirose. All rights reserved.
//

#import "WTStudyModel.h"
#import <AppKit/AppKit.h>
#import "JSONKit.h"
#import "Utility.h"

@interface WTStudyModel ()
@property NSSound* player;
@end

@implementation WTStudyModel
-(NSString*)getMondayFromDate:(NSDate*)date{
    NSDate *dateNow = date;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:dateNow];
    
    NSDate* dateFirst = [dateNow dateByAddingTimeInterval:-1*60*60*24*(components.weekday-2)];
    NSDateFormatter* formatter =[[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:dateFirst];
    
}
-(id)loadSchedule {
    NSURL *url = [NSURL URLWithString:@"https://dl.dropbox.com/u/1157820/wt_schedule.json"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data) {
        return [data objectFromJSONData];
    }
    return nil;
}
-(IBAction)actionPlayThisWeek:(id)sender{
    [self actionPlayFromDate:[NSDate date]];
}
-(IBAction)actionOpenPDFThisWeek:(id)sender{
    [self actionOpenPDFFromDate:[NSDate date]];
}
-(IBAction)actionPlayNextWeek:(id)sender{
    NSDate* dateNextWeek = [[NSDate date] dateByAddingTimeInterval:1*60*60*24*(7.0)];
    [self actionPlayFromDate:dateNextWeek];
}
-(IBAction)actionOpenPDFNextWeek:(id)sender{
    NSDate* dateNextWeek = [[NSDate date] dateByAddingTimeInterval:1*60*60*24*(7.0)];
    [self actionOpenPDFFromDate:dateNextWeek];
}

-(IBAction)actionPlayFromDate:(NSDate*)date{
    if (_isPlaying) {
        _isPlaying = !_isPlaying;
        [_player stop];
        _player = nil;
        return;
    }
    _isPlaying = !_isPlaying;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        id schedule = [self loadSchedule];
        if (schedule == nil) {
            [Utility showConnectionError];
            return;
        }
        NSLog(@"%@",[schedule description]);
        
        id thisWeek = [schedule valueForKey:[self getMondayFromDate:date]];
        NSLog(@"%@",[thisWeek description]);
        
        NSURL* url =[NSURL URLWithString:[NSString stringWithFormat:[thisWeek valueForKey:@"mp3"],[[[NSUserDefaults standardUserDefaults] stringForKey:@"LANGUAGE"]uppercaseString]]];
        NSURLRequest* req = [NSURLRequest requestWithURL:url];
        NSURLResponse *resp;
        NSError *err;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:req
                                             returningResponse:&resp
                                                         error:&err];
        if (data == nil) {
            [Utility showConnectionError];
            return;
        }
        if (!_isPlaying) {
            return;
        }
        _player = [[NSSound alloc] initWithData:data];
        NSLog(@"%@",err);
        [_player play];
    });
}
-(IBAction)actionOpenPDFFromDate:(NSDate*)date{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        id schedule = [self loadSchedule];
        if (schedule == nil) {
            [Utility showConnectionError];
            return;
        }        
        NSLog(@"%@",[schedule description]);
        
        id thisWeek = [schedule valueForKey:[self getMondayFromDate:date]];
        NSLog(@"%@",[thisWeek description]);
        
        NSURL* url =[NSURL URLWithString:[NSString stringWithFormat:[thisWeek valueForKey:@"pdf"],[[[NSUserDefaults standardUserDefaults] stringForKey:@"LANGUAGE"]uppercaseString]]];
        
        [[NSWorkspace sharedWorkspace] openURL:url];
    });
}
@end
