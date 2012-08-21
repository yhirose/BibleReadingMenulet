//
//  WTStudyModel.m
//  BibleReadingMenulet
//
//  Created by Tomohisa Takaoka on 8/20/12.
//  Copyright (c) 2012 Yuji Hirose. All rights reserved.
//

#import "WTStudyModel.h"
#import <AVFoundation/AVFoundation.h>
#import "Utility.h"
@interface WTStudyModel ()
@property AVAudioPlayer* player;
-(NSString*)getMondayString;
@end

@implementation WTStudyModel
-(NSString*)getMondayString{
    NSDate *dateNow = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:dateNow];
    
    NSDate* dateFirst = [dateNow dateByAddingTimeInterval:-1*60*60*24*(components.weekday-2)];
    NSDateFormatter* formatter =[[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:dateFirst];

}
-(IBAction)actionPlayThisWeek:(id)sender{
    if (_isPlaying) {
        _isPlaying = !_isPlaying;
        [_player stop];
        _player = nil;
        return;
    }
    _isPlaying = !_isPlaying;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        id schedule = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://dl.dropbox.com/u/1157820/wt_schedule.json"]] options:0 error:nil];
        NSLog(@"%@",[schedule description]);
        
        id thisWeek = [schedule valueForKey:[self getMondayString]];
        NSLog(@"%@",[thisWeek description]);
        
        
        
        
        NSURL* url =[NSURL URLWithString:[NSString stringWithFormat:[thisWeek valueForKey:@"mp3"],[[[NSUserDefaults standardUserDefaults] stringForKey:@"LANGUAGE"]uppercaseString]]];
        NSURLRequest* req = [NSURLRequest requestWithURL:url];
        NSURLResponse *resp;
        NSError *err;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:req
                                             returningResponse:&resp
                                                         error:&err];
        if (data == nil) {
                NSRunAlertPanel(NSLocalizedString(@"OPEN_ERR_TTL", @"Title for Open error"),
                                NSLocalizedString(@"OPEN_ERR_MSG", @"Message for open error"),
                                @"OK", nil, nil);
                
            return;
        }
        if (!_isPlaying) {
            return;
        }
        _player = [[AVAudioPlayer alloc] initWithData:data error:&err];
        NSLog(@"%@",err);
        [_player play];
    });
}
-(IBAction)actionOpenPDFThisWeek:(id)sender{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        id schedule = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://dl.dropbox.com/u/1157820/wt_schedule.json"]] options:0 error:nil];
        NSLog(@"%@",[schedule description]);
        
        id thisWeek = [schedule valueForKey:[self getMondayString]];
        NSLog(@"%@",[thisWeek description]);
        
        NSURL* url =[NSURL URLWithString:[NSString stringWithFormat:[thisWeek valueForKey:@"pdf"],[[[NSUserDefaults standardUserDefaults] stringForKey:@"LANGUAGE"]uppercaseString]]];
        NSURLRequest* req = [NSURLRequest requestWithURL:url];
        NSURLResponse *resp;
        NSError *err;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:req
                                             returningResponse:&resp
                                                         error:&err];
        if (data == nil) {
            NSRunAlertPanel(NSLocalizedString(@"OPEN_ERR_TTL", @"Title for Open error"),
                            NSLocalizedString(@"OPEN_ERR_MSG", @"Message for open error"),
                            @"OK", nil, nil);
            
            return;
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:[[Utility appDirPath] stringByAppendingPathComponent:@"watchtower"]]) {
            [fileManager createDirectoryAtPath:[[Utility appDirPath] stringByAppendingPathComponent:@"watchtower"]
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        }
        
        NSString* wtPath = [[Utility appDirPath] stringByAppendingPathComponent:@"watchtower/thisweek.pdf"];
        [data writeToFile:wtPath atomically:YES];
        BOOL success = [[NSWorkspace sharedWorkspace] openFile:wtPath];
        NSLog(@"%d",success);
    });
}
@end
