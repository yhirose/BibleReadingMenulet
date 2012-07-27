//
//  LanguageInformation.mm
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/22/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import "LanguageInformation.h"
#import "Utility.h"
#import <regex.h>
#import <stdlib.h>
#import <string>
#import <vector>

struct LanguageInfo
{
    const char* name;
    const char* symbol;
    const char* pageURL;
    const char* wolPageURL;
    const char* bookNames;
};

const struct LanguageInfo langInfo[] =
{
    { "", "*", "http://www.watchtower.org/%@/bible/%@/chapter_%03d.htm", "", "" },
    { "Afrikaans", "af", "http://www.watchtower.org/%@/bybel/%@/chapter_%03d.htm", "", "" },
    { "Shqip", "al", "", "", "" },
    { "Česky", "b", "", "", "" },
    { "Български", "bl", "", "", "" },
    { "Hrvatski", "c", "http://www.watchtower.org/%@/biblija/%@/chapter_%03d.htm", "", "" },
    { "汉语（简化字）", "ch", "", "", "" },
    { "漢語（繁體字）", "chs", "", "", "" },
    { "Dansk", "d", "http://www.watchtower.org/%@/bibelen/%@/chapter_%03d.htm", "", "" },
    { "English", "e", "http://www.watchtower.org/%@/bible/%@/chapter_%03d.htm", "http://wol.jw.org/en/wol/b/r1/lp-e/%d/%d", "" },
    { "Français", "f", "", "", "" },
    { "Suomi", "fi", "http://www.watchtower.org/%@/raamattu/%@/chapter_%03d.htm", "", "" },
    { "Magyar", "h", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "", "" },
    { "Italiano", "i", "http://www.watchtower.org/%@/bibbia/%@/chapter_%03d.htm", "http://wol.jw.org/it/wol/b/r6/lp-i", "" },
    { "日本語", "j", "", "http://wol.jw.org/ja/wol/b/r7/lp-j/%d/%d", "創,出,レビ,民,申,ヨシ,裁,ルツ,サ一,サ二,王一,王二,代一,代二,エズ,ネヘ,エス,ヨブ,詩,箴,伝,歌,イザ,エレ,哀,エゼ,ダニ,ホセ,ヨエ,アモ,オバ,ヨナ,ミカ,ナホ,ハバ,ゼパ,ハガ,ゼカ,マラ,マタ,マル,ルカ,ヨハ,使徒,ロマ,コ一,コ二,ガラ,エフェ,フィリ,コロ,テサ一,テサ二,テモ一,テモ二,テト,フィレ,ヘブ,ヤコ,ペテ一,ペテ二,ヨハ一,ヨハ二,ヨハ三,ユダ,啓" },
    { "한국어", "ko", "", "http://wol.jw.org/ko/wol/b/r8/lp-ko", "" },
    { "Română", "m", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "", "" },
    { "Norsk", "n", "http://www.watchtower.org/%@/bibelen/%@/chapter_%03d.htm", "http://wol.jw.org/no/wol/b/r3/lp-n", "" },
    { "Nederlands", "o", "http://www.watchtower.org/%@/bijbel/%@/chapter_%03d.htm", "", "" },
    { "Polski", "p", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "", "" },
    { "Հայերեն", "rea", "", "", "" },
    { "Español", "s", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "http://wol.jw.org/es/wol/b/r4/lp-s", "" },
    { "Српски", "sb", "", "", "" },
    { "Kiswahili", "sw", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "", "" },
    { "V Slovenščini", "sv", "http://www.watchtower.org/%@/svetopismo/%@/chapter_%03d.htm", "", "" },
    { "Português", "t", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "http://wol.jw.org/pt/wol/b/r5/lp-t", "" },
    { "Türkçe", "tk", "http://www.watchtower.org/%@/kutsalkitap/%@/chapter_%03d.htm", "", "" },
    { "Setswana", "tn", "http://www.watchtower.org/%@/baebele/%@/chapter_%03d.htm", "", "" },
    { "Русский", "u", "", "http://wol.jw.org/ru/wol/b/r2/lp-u", "" },
    { "Slovenský", "v", "http://www.watchtower.org/%@/biblia/%@/chapter_%03d.htm", "", "" },
    { "Deutsch", "x", "http://www.watchtower.org/%@/bibel/%@/chapter_%03d.htm", "", "" },
    { "Svenska", "z", "http://www.watchtower.org/%@/bibeln/%@/chapter_%03d.htm", "", "" },
    { "IsiZulu", "zu", "http://www.watchtower.org/%@/ibhayibheli/%@/chapter_%03d.htm", "", "" },
};

#define LANGUAGE_INFO_COUNT (sizeof(langInfo) / sizeof(langInfo[0]))

static int getBookId(const std::string& name)
{
    const char* names[] =
    {
        "Ge", "Ex", "Le", "Nu", "De",
        "Jos", "Jg", "Ru", "1Sa", "2Sa",
        "1Ki", "2Ki", "1Ch", "2Ch", "Ezr",
        "Ne", "Es", "Job", "Ps", "Pr",
        "Ec", "Ca", "Isa", "Jer", "La",
        "Eze", "Da", "Ho", "Joe", "Am",
        "Ob", "Jon", "Mic", "Na", "Hab",
        "Zep", "Hag", "Zec", "Mal", "Mt",
        "Mr", "Lu", "Joh", "Ac", "Ro",
        "1Co", "2Co", "Ga", "Eph", "Php",
        "Col", "1Th", "2Th", "1Ti", "2Ti",
        "Tit", "Phm", "Heb", "Jas", "1Pe",
        "2Pe", "1Jo", "2Jo", "3Jo", "Jude",
        "Re",
    };
    
    for (int i = 0; i < 66; i++)
    {
        if (name == names[i])
        {
            return i;
        }
    }
    
    return -1;
}

struct Cita
{
    std::string book;
    int chap;
    int verse;
    std::string label;
    
    Cita() : chap(-1), verse(-1) {}
};

static bool parseChapterRange(const char* str, std::vector<Cita>& list)
{
    const char* pat = "([1-3]?[a-z]+) ([0-9]+)-([0-9]+)";
    
    regex_t re;
    size_t nmatch = 4;
    regmatch_t matches[nmatch];
    
    regcomp(&re, pat, REG_EXTENDED|REG_ICASE);
    
    int ret = regexec(&re, str, nmatch, matches, 0);
    if (!ret)
    {
        const auto& mbook = matches[1];
        const auto& mchap1 = matches[2];
        const auto& mchap2 = matches[3];
        
        std::string book(&str[mbook.rm_so], &str[mbook.rm_eo]);
        int chap1 = atoi(std::string(&str[mchap1.rm_so], &str[mchap1.rm_eo]).c_str());
        int chap2 = atoi(std::string(&str[mchap2.rm_so], &str[mchap2.rm_eo]).c_str());
        
        for (int i = chap1; i <= chap2; i++)
        {            
            Cita cita;
            
            cita.book = book;            
            cita.chap = i;
            
            char buff[BUFSIZ];
            sprintf(buff, "%s %d", book.c_str(), i);
            cita.label = buff;
            
            list.push_back(cita);
        }        
    }
    
    regfree(&re);
    
    return !ret;
}

static bool parseBookNameOnly(const char* str, std::vector<Cita>& list)
{
    const char* pat = "^([1-3]?[a-z]+)$";
    
    regex_t re;
    size_t nmatch = 2;
    regmatch_t matches[nmatch];
    
    regcomp(&re, pat, REG_EXTENDED|REG_ICASE);
    
    int ret = regexec(&re, str, nmatch, matches, 0);
    if (!ret)
    {
        const auto& mbook = matches[1];
        
        std::string book(&str[mbook.rm_so], &str[mbook.rm_eo]);
        
        Cita cita;
        
        cita.book = book;            
        cita.chap = 1;
        
        cita.label = book;
        
        list.push_back(cita);
    }
    
    regfree(&re);
    
    return !ret;
}

static bool parseOneChapter(const char* str, std::vector<Cita>& list)
{
    const char* pat = "^([1-3]?[a-z]+) ([0-9]+)$";
    
    regex_t re;
    size_t nmatch = 3;
    regmatch_t matches[nmatch];
    
    regcomp(&re, pat, REG_EXTENDED|REG_ICASE);
    
    int ret = regexec(&re, str, nmatch, matches, 0);
    if (!ret)
    {
        const auto& mbook = matches[1];
        const auto& mchap1 = matches[2];
        
        std::string book(&str[mbook.rm_so], &str[mbook.rm_eo]);
        int chap1 = atoi(std::string(&str[mchap1.rm_so], &str[mchap1.rm_eo]).c_str());
        
        Cita cita;
        
        cita.book = book;            
        cita.chap = chap1;
        
        char buff[BUFSIZ];
        sprintf(buff, "%s %d", book.c_str(), chap1);
        cita.label = buff;
        
        list.push_back(cita);
    }
    
    regfree(&re);
    
    return !ret;
}

static bool parseFromVerseToChapter(const char* str, std::vector<Cita>& list)
{
    const char* pat = "([1-3]?[a-z]+) ([0-9]+):([0-9]+)-([0-9]+)";
    
    regex_t re;
    size_t nmatch = 5;
    regmatch_t matches[nmatch];
    
    regcomp(&re, pat, REG_EXTENDED|REG_ICASE);
    
    int ret = regexec(&re, str, nmatch, matches, 0);
    if (!ret)
    {
        const auto& mbook = matches[1];
        const auto& mchap1 = matches[2];
        const auto& mverse1 = matches[3];
        const auto& mchap2 = matches[4];
        
        std::string book(&str[mbook.rm_so], &str[mbook.rm_eo]);
        int chap1 = atoi(std::string(&str[mchap1.rm_so], &str[mchap1.rm_eo]).c_str());
        int verse1 = atoi(std::string(&str[mverse1.rm_so], &str[mverse1.rm_eo]).c_str());
        int chap2 = atoi(std::string(&str[mchap2.rm_so], &str[mchap2.rm_eo]).c_str());
        
        for (int i = chap1; i <= chap2; i++)
        {            
            Cita cita;
            
            cita.book = book;            
            cita.chap = i;
            
            char buff[BUFSIZ];
            if (i == chap1)
            {
                cita.verse = verse1;
                sprintf(buff, "%s %d:%d", book.c_str(), i, verse1);
            }
            else
            {
                sprintf(buff, "%s %d", book.c_str(), i);
            }            
            cita.label = buff;
            
            list.push_back(cita);
        }        
    }
    
    regfree(&re);
    
    return !ret;
}

@implementation LanguageInformation

@synthesize infoArray = _infoArray;

+ (LanguageInformation *)instance {
    
    static LanguageInformation *_instance = nil;
    
    if (_instance == nil) {
        _instance = [[LanguageInformation alloc] init];
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        NSMutableArray *marray = [NSMutableArray array];
        
        for (int i = 0; i < LANGUAGE_INFO_COUNT; i++)
        {
            const auto& info = langInfo[i];
            
            NSDictionary *dic = @{@"name": @(info.name),
                                 @"symbol": @(info.symbol),
                                 @"pageURL": @(info.pageURL),
                                 @"wolPageURL": @(info.wolPageURL)};
            
            [marray addObject:dic];
        }
        
        _infoArray = [NSArray arrayWithArray:marray];
    }
    
    return self;
}

- (int)getBookNo:(NSString *)name
{
    std::string s = [name UTF8String];
    return getBookId(s) + 1;
}

- (int)getLanguageId:(NSString *)lang
{
    int i = 0;
    for (NSDictionary *item in _infoArray)
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
    int i = [self getLanguageId:lang];    
    NSString *format = [_infoArray[i] valueForKey:@"pageURL"];
    
    if (![format length])
    {
        // Use default data
        int i = [self getLanguageId:@"*"];    
        format = [_infoArray[i] valueForKey:@"pageURL"];
    }
    
    return [NSString stringWithFormat:format,
            [lang lowercaseString],
            [book lowercaseString],
            [chap intValue]];
}

- (NSString *)wolPageURLWithLanguage:(NSString *)lang book:(NSString*)book chapter:(NSNumber *)chap
{
    int i = [self getLanguageId:lang];    
    NSString *format = [_infoArray[i] valueForKey:@"wolPageURL"];
    
    if (![format length])
    {
        // Use www.watchtower.org data
        return [self pageURLWithLanguage:lang
                                    book:book
                                 chapter:chap];
    }
    
    return [NSString stringWithFormat:format,
            [self getBookNo:book],
            [chap intValue]];
}

- (NSMutableArray *)makeChapterListFromRange:(NSString *)range language:(NSString *)lang;
{
    NSMutableArray *list = [NSMutableArray array];
    
    NSArray *citas = [range componentsSeparatedByString:@"/"];
    for (NSString *cita in citas)
    {
        const char* str = [cita UTF8String];
        std::vector<Cita> items;
        bool ret = parseChapterRange(str, items) ||
        parseBookNameOnly(str, items) ||
        parseOneChapter(str, items) ||
        parseFromVerseToChapter(str, items);
        
        if (ret)
        {
            for (const auto& item: items)
            {
                NSString *book = @(item.book.c_str());
                NSNumber *chap = @(item.chap);
                NSNumber *verse = @(item.verse);
                
                NSString *label = @(item.label.c_str());
                label = [self translateCitation:label language:lang];

                NSString *bookChapId = [NSString stringWithFormat:@"%d_%d",
                                        [self getBookNo:book],
                                        [chap intValue]];
                
                NSDictionary *dic = @{@"label": label,
                                     @"bookChapId": bookChapId,
                                     @"book": book,
                                     @"chap": chap,
                                     @"verse": verse};
                
                [list addObject:dic];
            }
        }
    }
    
    return list;
}

- (NSString *)translateCitation:(NSString *)str language:(NSString *)lang
{
    int langId = [self getLanguageId:lang];
    NSString *bookNamesStr = @(langInfo[langId].bookNames);
    
    if (![bookNamesStr length])
    {
        return str;
    }
    
    NSArray *bookNames = [bookNamesStr componentsSeparatedByString:@","];
    
    NSMutableArray *citasVernacular = [NSMutableArray array];
    
    NSArray *citas = [str componentsSeparatedByString:@"/"];
    for (NSString *cita in citas)
    {
        const char* str = [cita UTF8String];

        const char* pat = "^([1-3]?[a-z]+)( .+)?$";
        
        regex_t re;
        size_t nmatch = 3;
        regmatch_t matches[nmatch];
        
        regcomp(&re, pat, REG_EXTENDED|REG_ICASE);
        
        int ret = regexec(&re, str, nmatch, matches, 0);
        if (!ret)
        {
            const auto& mbook = matches[1];
            std::string book(&str[mbook.rm_so], &str[mbook.rm_eo]);
            
            int bookId = getBookId(book);            
            book = [bookNames[bookId] UTF8String];
            
            char buff[BUFSIZ];
            
            if (matches[2].rm_so != -1)
            {
                const auto& mrest = matches[2];            
                std::string rest(&str[mrest.rm_so], &str[mrest.rm_eo]);
                
                sprintf(buff, "%s%s", book.c_str(), rest.c_str());
            }
            else
            {
                sprintf(buff, "%s", book.c_str());
            }
            
            [citasVernacular addObject:@(buff)];
        }
        
        regfree(&re);
    }
    
    NSString *rangeVernacular = [citasVernacular componentsJoinedByString:@"/"];

    return [NSString stringWithString:rangeVernacular];
}

- (NSString *)translateRange:(NSString *)range language:(NSString *)lang
{
    NSMutableArray *citasVernacular = [NSMutableArray array];
    
    NSArray *citas = [range componentsSeparatedByString:@"/"];
    for (NSString *cita in citas)
    {
        [citasVernacular addObject:[self translateCitation:cita language:lang]];
    }
    
    return [citasVernacular componentsJoinedByString:@"/"];
}

@end
