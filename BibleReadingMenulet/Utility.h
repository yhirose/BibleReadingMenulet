//
//  Utility.h
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/16/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

@interface Utility : NSObject
+ (NSString *)appDirPath;
+ (NSString *)getContentWt:(NSString *)html;
+ (NSString *)getContentWol:(NSString *)html;
+ (NSString *)getTitleWt:(NSString *)html;
+ (NSString *)getTitleWol:(NSString *)html;
+ (NSString *)fetchFile:(NSString *)url;
+ (NSMutableArray *)getRangesForSchool;
@end
