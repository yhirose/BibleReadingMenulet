
#import "Utility.h"
#import <stdlib.h>
#import <regex.h>
#import <string>
#import <vector>

@implementation Utility

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

+ (NSArray *)makeChapterList:(NSString *)range;
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
                NSNumber *chap = [NSNumber numberWithInt:item.chap];
                NSNumber *verse = [NSNumber numberWithInt:item.verse];
                
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSString stringWithCString:item.label.c_str() encoding:NSUTF8StringEncoding], @"label",
                    [NSString stringWithCString:item.book.c_str() encoding:NSUTF8StringEncoding], @"book",
                    chap, @"chap",
                    verse, @"verse",
                    nil];
                
                [list addObject:dic];
            }
        }
    }
    
    return list;
}

+ (int)getBookNo:(NSString *)name
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
    
    std::string s = [name UTF8String];

    for (int i = 0; i < 66; i++)
    {
        if (s == names[i])
        {
            return i + 1;
        }
    }
    
    return -1;
}

+ (NSString *)getContent:(NSString *)html
{
    const char* str = [html UTF8String];
    const char* pat = "</h3>(.*)<div class=\"footer\"";
    
    std::string content;
    
    regex_t re;
    size_t nmatch = 2;
    regmatch_t matches[nmatch];
    
    regcomp(&re, pat, REG_EXTENDED);
    
    int ret = regexec(&re, str, nmatch, matches, REG_NOTBOL|REG_NOTEOL);
    if (!ret)
    {
        const auto& m1 = matches[1];        
        content.assign(&str[m1.rm_so], &str[m1.rm_eo]);
    }
    
    regfree(&re);
    
    return [NSString stringWithUTF8String:content.c_str()];
}

+ (NSString *)getTitle:(NSString *)html
{
    const char* str = [html UTF8String];
    const char* pat = "<h3>(.*)</h3>";
    
    std::string title;
    
    regex_t re;
    size_t nmatch = 2;
    regmatch_t matches[nmatch];
    
    regcomp(&re, pat, REG_EXTENDED);
    
    int ret = regexec(&re, str, nmatch, matches, 0);
    if (!ret)
    {
        const auto& m1 = matches[1];        
        title.assign(&str[m1.rm_so], &str[m1.rm_eo]);
    }
    
    regfree(&re);
    
    return [NSString stringWithUTF8String:title.c_str()];
}

+ (NSArray *)getAvailableLanguages
{
    return [NSArray arrayWithObjects:
            @"ch",
            @"chs",
            @"e",
            @"f",
            @"j",
            //@"s",
            @"u",
            nil];    
}

@end
