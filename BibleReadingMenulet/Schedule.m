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
    for (; i < [_data count] && [[_data objectAtIndex:i] count] > 1; i++)
    {
        ;
    }
    if (i == [_data count])
    {
        i = 0;
        for (; i < curr && [[_data objectAtIndex:i] count] > 1; i++)
        {
            ;
        }
        if (i == curr)
        {
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
    
    NSArray *lines = [rdata componentsSeparatedByString:@"\n"];
    for (int i = 0; i < [lines count]; i++)
    {
        NSString *line = [lines objectAtIndex:i];
        if ([line length] > 0)
        {
            NSArray *fields = [line componentsSeparatedByString:@","];
            NSUInteger count = [fields count];
            
            NSMutableArray *item = [NSMutableArray arrayWithObject:[fields objectAtIndex:0]];
            
            if (count == 2)
            {
                NSString *date = [fields objectAtIndex:1];
                if ([date compare:@"*" options:NSCaseInsensitiveSearch] == NSOrderedSame)
                {
                    *curr = i;
                }
                else
                {
                    [item addObject:date];
                }
            }
            
            [data addObject:item];
        }
    }
    
    return data;
}

- (void)saveData:(NSMutableArray *)data toFile:(NSString *)path
{
    NSMutableArray *lines = [NSMutableArray array];
    for (int i = 0; i < [_data count]; i++)
    {
        NSMutableArray *item = [_data objectAtIndex:i];
        if (i == _curr)
        {
            item = [NSMutableArray arrayWithObjects:[item objectAtIndex:0], @"*", nil];
        }
        [lines addObject:[item componentsJoinedByString:@","]];
    }
    NSString *wdata = [lines componentsJoinedByString:@"\n"];
    [wdata writeToFile:path atomically:TRUE encoding:NSUTF8StringEncoding error:nil];
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
    
    if (self)
    {
        _path = path;
        _curr = -1;
        
        // Load data from file.
        _data = [self loadDataOfFile:path currIndex:&_curr];

        // There is no '*' mark.
        if (_curr == -1)
        {
            // Try to find an available spot.
            _curr = [self advance:0];            
        }
    }
    
    return self;
}

- (BOOL)isComplete
{
    return _curr == -1;
}

- (void)markAsRead
{
    if (![self isComplete])
    {
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd(E) HH:mm:ss"];
        NSString *date = [formatter stringFromDate:now];
        
        [[_data objectAtIndex:_curr] setObject:date atIndex:1];
        
        _curr = [self advance:_curr + 1];
        
        [self saveData:_data toFile:_path];
    }
}

- (NSString *)currRange
{
    NSMutableArray *currItem = [_data objectAtIndex:_curr];
    return [currItem objectAtIndex:0];
}


@end
