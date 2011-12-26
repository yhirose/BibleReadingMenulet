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
+ (NSString *)progressPath;
+ (NSString *)getContent:(NSString *)html;
+ (NSString *)getTitle:(NSString *)html;
@end

#endif
