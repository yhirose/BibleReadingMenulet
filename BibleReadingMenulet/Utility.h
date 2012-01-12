//
//  Utility.h
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/16/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#ifndef BibleReadingMenulet_Utility_h
#define BibleReadingMenulet_Utility_h

@interface Utility : NSObject
+ (NSString *)appDirPath;
+ (NSString *)schedulePath;
+ (NSString *)getContent:(NSString *)html;
+ (NSString *)getTitle:(NSString *)html;
+ (NSMutableArray *)getRangesForSchool;
+ (BOOL)isLionOrLater;

/* Based on http://www.cocoadev.com/index.pl?DeterminingOSVersion */
+ (void)getSystemVersionMajor:(unsigned int *)major
                        minor:(unsigned int *)minor
                       bugFix:(unsigned int *)bugFix;
@end

#endif
