//
//  Schedule.h
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/18/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Schedule : NSObject {
  @private
    NSString       *_path;
    int             _curr;
    NSMutableArray *_ranges;
}

- (id)init;
- (BOOL)isComplete;
- (void)markAsRead;
- (void)markAsReadAtIndex:(NSInteger)index;
- (void)markAsUnreadAtIndex:(NSInteger)index;
- (NSString *)currentRange;
- (NSMutableArray *)ranges;
- (int)currentIndex;
- (void)setCurrentIndex:(NSInteger)index;

+ (Schedule *)currentSchedule;
+ (void)reloadSchedule;

+ (NSInteger) scheduleType;
+ (void)setScheduleType:(NSInteger)type;
+ (NSString *) scheduleDirPath;

+ (NSMutableDictionary *)getProgress:(NSString *)type;
+ (void)setProgress:(NSMutableDictionary *)progress type:(NSString *)type;

@end
