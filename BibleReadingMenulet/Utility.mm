
#import "Utility.h"
#import <regex.h>
#import <string>

@implementation Utility

+ (NSString *)appDirPath {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [rootPath stringByAppendingPathComponent:@"BibleReadingMenulet"];
}

+ (NSString *)schedulePath {
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString *fileName = [ud stringForKey:@"SCHEDULE"];
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

+ (NSString *)fetchSchoolSchedule
{
    NSURL *url = [NSURL URLWithString:@"http://yhirose.github.com/private/school.csv"];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSURLResponse *resp;
    NSError *err;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req
                                         returningResponse:&resp
                                                     error:&err];
    if (data == nil)
    {
        return nil;
    }
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSMutableArray *)getRangesForSchool
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *schoolSchedule = [Utility fetchSchoolSchedule];
    if (schoolSchedule)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *now = [NSDate date];
        
        NSArray *lines = [schoolSchedule componentsSeparatedByString:@"\n"];
        
        for (int i = 0; i < [lines count]; i++)
        {
            NSString *line = [lines objectAtIndex:i];
            NSArray *fields = [line componentsSeparatedByString:@","];
            
            NSDate *beg = [df dateFromString:[fields objectAtIndex:0]]; 
            NSDate *end = [NSDate dateWithTimeInterval:7*24*60*60 sinceDate:beg];
            
            NSTimeInterval val1 = [now timeIntervalSinceDate:beg];
            NSTimeInterval val2 = [end timeIntervalSinceDate:now];
            
            if (val1 >= 0 && val2 > 0)
            {
                [array addObject:[fields objectAtIndex:1]];
                
                if (i + 1 < [lines count])
                {
                    NSString *line = [lines objectAtIndex:i + 1];
                    NSArray *fields = [line componentsSeparatedByString:@","];
                    [array addObject:[fields objectAtIndex:1]];
                }
                
                break;
            }
        }
    }    

    return array;
}

@end
