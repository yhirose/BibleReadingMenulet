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

- (NSString *)pageURLWithLanguage:(NSString *)lang book:(NSString*)book chapter:(NSNumber *)chap;
- (NSString *)mp3URLWithLanguage:(NSString *)lang book:(NSString*)book chapter:(NSNumber *)chap;
- (NSMutableArray *)makeChapterListFromRange:(NSString *)range language:(NSString *)lang;
- (NSString *)translateCitation:(NSString *)str language:(NSString *)lang;
- (NSString *)translateRange:(NSString *)range language:(NSString *)lang;

@end
