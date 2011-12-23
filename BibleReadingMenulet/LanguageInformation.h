//
//  LanguageInformation.h
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/22/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LanguageInformation : NSObject {
    @private
    NSArray *_array;
}

- (NSArray *)getLanguageInformation;
- (NSString *)pageURLWithLanguage:(NSString *)lang book:(NSString*)book chapter:(NSNumber *)chap;
- (NSString *)mp3URLWithLanguage:(NSString *)lang book:(NSString*)book chapter:(NSNumber *)chap;

@end
