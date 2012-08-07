//
//  Utility.mm
//  BibleReadingMenulet
//
//  Created by Yuji Hirose on 12/22/11.
//  Copyright (c) 2011 Yuji Hirose. All rights reserved.
//

#import "Utility.h"
#import <regex.h>
#import <string>

@implementation Utility

+ (NSString *)appDirPath
{
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    return [rootPath stringByAppendingPathComponent:@"BibleReadingMenulet"];
}

+ (NSString *)schedulePath
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString *fileName = [ud stringForKey:@"SCHEDULE"];
    NSString *dirPath = [Utility appDirPath];
    return [dirPath stringByAppendingPathComponent:fileName];
}

+ (NSString *)progressPath
{
    NSString *dirPath = [Utility appDirPath];
    return [dirPath stringByAppendingPathComponent:@"progress.xml"];
}

+ (NSMutableDictionary *)getProgressPropertyList
{
    NSMutableDictionary *plist = [NSMutableDictionary dictionary];
    NSString* pgPath = [Utility progressPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:pgPath]) {
        plist = [[NSMutableDictionary dictionary] initWithContentsOfFile:pgPath];
    }
    
    return plist;
}

+ (NSMutableDictionary *)getProgress:(NSString *)type
{
    NSMutableDictionary *plist = [self getProgressPropertyList];
    NSMutableDictionary *progress = [plist[type] mutableCopy];
    return progress;
}

+ (void)setProgress:(NSMutableDictionary *)progress type:(NSString *)type
{
    NSMutableDictionary *plist = [self getProgressPropertyList];
    NSString* pgPath = [Utility progressPath];
    
    [plist setValue:progress forKey:type];
    [plist writeToFile:pgPath atomically:NO];
}

+ (NSString *)getContentWt:(NSString *)html
{
    const char* str = [html UTF8String];
    const char* pat = "</h3>(.*)<div class=\"footer\"";
    
    std::string content;
    
    regex_t re;
    size_t nmatch = 2;
    regmatch_t matches[nmatch];
    
    regcomp(&re, pat, REG_EXTENDED);
    
    int ret = regexec(&re, str, nmatch, matches, REG_NOTBOL|REG_NOTEOL);
    if (!ret) {
        const auto& m1 = matches[1];
        content.assign(&str[m1.rm_so], &str[m1.rm_eo]);
    }
    
    regfree(&re);
    
    return [NSString stringWithUTF8String:content.c_str()];
}

+ (NSString *)getContentWol:(NSString *)html
{
    const char* str = [html UTF8String];
    const char* pat = "<div class='document'>(.*)</div></div>";
    
    std::string content;
    
    regex_t re;
    size_t nmatch = 2;
    regmatch_t matches[nmatch];
    
    regcomp(&re, pat, REG_EXTENDED);
    
    int ret = regexec(&re, str, nmatch, matches, REG_NOTBOL|REG_NOTEOL);
    if (!ret) {
        const auto& m1 = matches[1];
        content.assign(&str[m1.rm_so], &str[m1.rm_eo]);
    }
    
    regfree(&re);
    
    return [NSString stringWithUTF8String:content.c_str()];
}

+ (NSString *)getTitleWt:(NSString *)html
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

+ (NSString *)getTitleWol:(NSString *)html
{
    const char* str = [html UTF8String];
    const char* pat = "<title>(.*)</title>";
    
    std::string title;
    
    regex_t re;
    size_t nmatch = 2;
    regmatch_t matches[nmatch];
    
    regcomp(&re, pat, REG_EXTENDED);
    
    int ret = regexec(&re, str, nmatch, matches, 0);
    if (!ret) {
        const auto& m1 = matches[1];
        title.assign(&str[m1.rm_so], &str[m1.rm_eo]);
    }
    
    regfree(&re);
    
    return [NSString stringWithUTF8String:title.c_str()];
}

+ (NSString *)fetchFile:(NSString *)urlStr
{
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSURLResponse *resp;
    NSError *err;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req
                                         returningResponse:&resp
                                                     error:&err];
    if (data == nil) {
        return nil;
    }
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)fetchSchoolSchedule
{
    return [self fetchFile:@"http://yhirose.github.com/BibleReadingMenulet/SchoolSchedule.csv"];
}

+ (NSMutableArray *)findRangesForSchoolSchedule:(NSString *)schoolSchedule
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *now = [NSDate date];
    
    NSArray *lines = [schoolSchedule componentsSeparatedByString:@"\n"];
    
    for (int i = 0; i < [lines count]; i++) {
        NSString *line = lines[i];
        NSArray *fields = [line componentsSeparatedByString:@","];
        
        NSDate *beg = [df dateFromString:fields[0]]; 
        NSDate *end = [NSDate dateWithTimeInterval:7*24*60*60 sinceDate:beg];
        
        NSTimeInterval val1 = [now timeIntervalSinceDate:beg];
        NSTimeInterval val2 = [end timeIntervalSinceDate:now];
        
        if (val1 >= 0 && val2 > 0) {
            [array addObject:fields[1]];
            
            if (i + 1 < [lines count]) {
                NSString *line = lines[i + 1];
                NSArray *fields = [line componentsSeparatedByString:@","];
                [array addObject:fields[1]];
            }
            
            break;
        }
    }

    return array;
}

+ (NSMutableArray *)getRangesForSchool
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString *schoolSchedule = [ud stringForKey:@"SCHOOL_SCHEDULE"];
    
    NSMutableArray *ranges = [self findRangesForSchoolSchedule:schoolSchedule];
    
    if (![ranges count]) {
        NSString *schoolSchedule = [Utility fetchSchoolSchedule];
        [ud setValue:schoolSchedule forKey:@"SCHOOL_SCHEDULE"];
        
        ranges = [self findRangesForSchoolSchedule:schoolSchedule];
    }    
    
    return ranges;
}

@end
