//
//  Schedule.m
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/18/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import "Schedule.h"

@implementation Schedule

- (int)advance:(int)curr
{
    int i = curr;
    for (; i < [_ranges count] && [_ranges[i] count] > 1; i++) {
        ;
    }
    if (i == [_ranges count]) {
        i = 0;
        for (; i < curr && [_ranges[i] count] > 1; i++) {
            ;
        }
        if (i == curr) {
            return -1;
        }
    }
    return i;
}

- (NSMutableArray *)loadDataOfFile:(NSString *)path currIndex:(int *)curr
{
    NSMutableArray *data = [NSMutableArray array];
    *curr = -1;
    
    NSString *rdata = [NSString stringWithContentsOfFile:path
                                                encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *lines = [[rdata stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                      componentsSeparatedByString:@"\n"];
    
    for (int i = 0; i < [lines count]; i++) {
        NSString *line = lines[i];
        NSArray *fields = [line componentsSeparatedByString:@","];
        NSUInteger count = [fields count];
        
        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObject:fields[0]
                                                                       forKey:@"range"];
        
        if (count == 2) {
            NSString *date = fields[1];
            if ([date compare:@"*" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                *curr = i;
            } else {
                [item setValue:date forKey:@"date"];
            }
        }
        
        [data addObject:item];
    }
    
    return data;
}

- (void)saveData:(NSMutableArray *)data toFile:(NSString *)path
{
    NSMutableArray *lines = [NSMutableArray array];
    for (int i = 0; i < [_ranges count]; i++) {
        NSString *line = [NSString stringWithString:_ranges[i][@"range"]];
        
        NSString *date = (i == self.currentIndex) ? @"*" : _ranges[i][@"date"];
        
        if (date) {
            line = [line stringByAppendingFormat:@",%@", date];
        }
        
        [lines addObject:line];
    }
    NSString *wdata = [lines componentsJoinedByString:@"\n"];
    [wdata writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

- (id)init
{
    @throw [NSException exceptionWithName:@"BadInitCall"
                                   reason:@"Initialize Schedule with initWithPath:"
                                 userInfo:nil];
    return nil;
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    
    if (self) {
        _path = path;
        int curr = -1;
        
        // Load data from file.
        _ranges = [self loadDataOfFile:path currIndex:&curr];

        // There is no '*' mark.
        if (curr == -1) {
            // Try to find an available spot.
            curr = [self advance:0];            
        }
        
        _curr = curr;
    }
    
    return self;
}

- (BOOL)isComplete {
    return self.currentIndex == -1;
}

- (void)markAsRead {
    [self markAsReadAtIndex:self.currentIndex];
}

- (void)markAsReadAtIndex:(NSInteger)index {
    if (![self isComplete]) {
        if (!_ranges[index][@"date"]) {
            NSDate *now = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd(E) HH:mm:ss"];
            NSString *date = [formatter stringFromDate:now];
            
            [_ranges[index] setValue:date forKey:@"date"];
            
            if (index == self.currentIndex) {
                self.currentIndex = [self advance:self.currentIndex + 1];
            }
            
            [self saveData:_ranges toFile:_path];
            
            NSNotification *n = [NSNotification notificationWithName:@"markChanged" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:n];
        }
    }
}

- (void)markAsUnreadAtIndex:(NSInteger)index {
    if (_ranges[index][@"date"]) {
        [_ranges[index] setValue:nil forKey:@"date"];
        
        [self saveData:_ranges toFile:_path];
        
        NSNotification *n = [NSNotification notificationWithName:@"markChanged" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }
}

- (NSString *)currentRange {
    return _ranges[self.currentIndex][@"range"];
}

- (NSMutableArray *)ranges {
    return _ranges;
}

- (int)currentIndex {
    return _curr;
}

- (void)setCurrentIndex:(NSInteger)index {
    _curr = (int)index;
    [self saveData:_ranges toFile:_path];
    
    NSNotification *n = [NSNotification notificationWithName:@"currentRangeChanged" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

@end
