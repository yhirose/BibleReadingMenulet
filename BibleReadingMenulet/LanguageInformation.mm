//
//  LanguageInformation.mm
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/22/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import "LanguageInformation.h"
#import "Utility.h"

struct LanguageInfo
{
    const char* name;
    const char* symbol;
    const char* pageURL;
    const char* mp3URL;
};

const struct LanguageInfo langInfo[] =
{
    { "Afrikaans", "af", "http://www.watchtower.org/%@/bybel/%@/chapter_%03d.htm", "" },
    { "Shqip", "al", "", "" },
    { "Česky", "b", "", "" },
    { "Български", "bl", "", "" },
    { "Hrvatski", "c", "http://www.watchtower.org/%@/biblija/%@/chapter_%03d.htm", "" },
    { "汉语（简化字）", "ch", "", "" },
    { "漢語（繁體字）", "chs", "", "" },
    { "Dansk", "d", "http://www.watchtower.org/%@/bibelen/%@/chapter_%03d.htm", "" },
    { "English", "e", "", "" },
    { "Français", "f", "", "" },
    { "Suomi", "fi", "http://www.watchtower.org/%@/raamattu/%@/chapter_%03d.htm", "" },
    { "Magyar", "h", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "" },
    { "Italiano", "i", "http://www.watchtower.org/%@/bibbia/%@/chapter_%03d.htm", "" },
    { "日本語", "j", "", "" },
    { "한국어", "ko", "", "" },
    { "Română", "m", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "" },
    { "Norsk", "n", "http://www.watchtower.org/%@/bibelen/%@/chapter_%03d.htm", "" },
    { "Nederlands", "o", "http://www.watchtower.org/%@/bijbel/%@/chapter_%03d.htm", "" },
    { "Polski", "p", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "" },
    { "Հայերեն", "rea", "", "" },
    { "Español", "s", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "" },
    { "Српски", "sb", "", "" },
    { "Kiswahili", "sw", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "" },
    { "V Slovenščini", "sv", "http://www.watchtower.org/%@/svetopismo/%@/chapter_%03d.htm", "" },
    { "Português", "t", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "" },
    { "Türkçe", "tk", "http://www.watchtower.org/%@/kutsalkitap/%@/chapter_%03d.htm", "" },
    { "Setswana", "tn", "http://www.watchtower.org/%@/baebele/%@/chapter_%03d.htm", "" },
    { "Русский", "u", "", "" },
    { "Slovenský", "v", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "" },
    { "Deutsch", "x", "http://www.watchtower.org/%@/bibel/%@/chapter_%03d.htm", "" },
    { "Svenska", "z", "http://www.watchtower.org/%@/bibeln/%@/chapter_%03d.htm", "" },
    { "IsiZulu", "zu", "http://www.watchtower.org/%@/ibhayibheli/%@/chapter_%03d.htm", "" },
};

#define LANGUAGE_INFO_COUNT (sizeof(langInfo) / sizeof(langInfo[0]))

@implementation LanguageInformation

- (id)init
{
    self = [super init];
    
    if (self)
    {
        NSMutableArray *marray = [NSMutableArray array];
        
        for (int i = 0; i < LANGUAGE_INFO_COUNT; i++)
        {
            const auto& info = langInfo[i];
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithUTF8String:info.name], @"name",
                                 [NSString stringWithUTF8String:info.symbol], @"symbol",
                                 [NSString stringWithUTF8String:info.pageURL], @"pageURL",
                                 [NSString stringWithUTF8String:info.mp3URL], @"mp3URL",
                                 nil];
            
            [marray addObject:dic];
        }
        
        _array = [NSArray arrayWithArray:marray];
    }
    
    return self;
}

- (NSArray *)getLanguageInformation
{
    return _array;
}

- (int)findIndexWithLanguage:(NSString *)lang
{
    int i = 0;
    for (NSDictionary *item in _array)
    {
        if ([[item valueForKey:@"symbol"] isEqualToString:lang])
        {
            return i;
        }
        i++;
    }
    return -1;
}

- (NSString *)pageURLWithLanguage:(NSString *)lang book:(NSString*)book chapter:(NSNumber *)chap
{
    int i = [self findIndexWithLanguage:lang];
    
    NSString *format = [[_array objectAtIndex:i] valueForKey:@"pageURL"];
    if (![format length])
    {
        format = @"http://www.watchtower.org/%@/bible/%@/chapter_%03d.htm";
    }
    
    return [NSString stringWithFormat:format,
            [lang lowercaseString],
            [book lowercaseString],
            [chap intValue]];
}

- (NSString *)mp3URLWithLanguage:(NSString *)lang book:(NSString*)book chapter:(NSNumber *)chap
{
    int i = [self findIndexWithLanguage:lang];
    
    NSString *format = [[_array objectAtIndex:i] valueForKey:@"mp3URL"];
    if (![format length])
    {
        format = @"http://download.jw.org/files/media_bible/%02d_%@_%@_%02d.mp3";
    }
    
    return [NSString stringWithFormat:format,
            [Utility getBookNo:book],
            book,
            [lang uppercaseString],
            [chap intValue]];
}

@end
