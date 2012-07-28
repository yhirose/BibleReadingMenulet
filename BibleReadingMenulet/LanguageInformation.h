//
//  LanguageInformation.h
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/22/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LanguageInformation : NSObject

@property (nonatomic, strong, readonly) NSArray *infoArray;

+ (LanguageInformation *)instance;

- (int)getBookNo:(NSString *)name;
- (NSString *)pageURLWithLanguage:(NSString *)lang book:(NSString*)book chapter:(NSNumber *)chap;
- (NSString *)wtPageURLWithLanguage:(NSString *)lang book:(NSString*)book chapter:(NSNumber *)chap;
- (NSString *)wolPageURLWithLanguage:(NSString *)lang book:(NSString*)book chapter:(NSNumber *)chap;
- (NSMutableArray *)makeChapterListFromRange:(NSString *)range language:(NSString *)lang;
- (NSString *)translateRange:(NSString *)range language:(NSString *)lang;

@end
