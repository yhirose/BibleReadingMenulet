
#import "Utility.h"
#import <regex.h>
#import <string>

@implementation Utility

+ (NSString *)appDirPath {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [rootPath stringByAppendingPathComponent:@"BibleReadingMenulet"];
}

+ (NSString *)progressPath {
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString *fileName = [ud stringForKey:@"PROGRESS"];
    NSString *dirPath = [Utility appDirPath];
    return [dirPath stringByAppendingPathComponent:fileName];
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

@end
