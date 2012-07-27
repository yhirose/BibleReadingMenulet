
#import "Utility.h"
#import <regex.h>
#import <string>

@implementation Utility

+ (NSString *)appDirPath {
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    return [rootPath stringByAppendingPathComponent:@"BibleReadingMenulet"];
}

+ (NSString *)schedulePath {
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString *fileName = [ud stringForKey:@"SCHEDULE"];
    NSString *dirPath = [Utility appDirPath];
    return [dirPath stringByAppendingPathComponent:fileName];
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

+ (NSMutableArray *)findRangesForSchoolSchedule:(NSString *)schoolSchedule
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *now = [NSDate date];
    
    NSArray *lines = [schoolSchedule componentsSeparatedByString:@"\n"];
    
    for (int i = 0; i < [lines count]; i++)
    {
        NSString *line = lines[i];
        NSArray *fields = [line componentsSeparatedByString:@","];
        
        NSDate *beg = [df dateFromString:fields[0]]; 
        NSDate *end = [NSDate dateWithTimeInterval:7*24*60*60 sinceDate:beg];
        
        NSTimeInterval val1 = [now timeIntervalSinceDate:beg];
        NSTimeInterval val2 = [end timeIntervalSinceDate:now];
        
        if (val1 >= 0 && val2 > 0)
        {
            [array addObject:fields[1]];
            
            if (i + 1 < [lines count])
            {
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
    
    if (![ranges count])
    {
        NSString *schoolSchedule = [Utility fetchSchoolSchedule];
        [ud setValue:schoolSchedule forKey:@"SCHOOL_SCHEDULE"];
        
        ranges = [self findRangesForSchoolSchedule:schoolSchedule];
    }    
    
    return ranges;
}

+ (BOOL)isLionOrLater
{
    unsigned int major, minor, bugFix;
    
    [Utility getSystemVersionMajor:&major
                             minor:&minor
                            bugFix:&bugFix];
    
    return (major == 10 && minor >= 7);
}

/* Based on http://www.cocoadev.com/index.pl?DeterminingOSVersion */
+ (void)getSystemVersionMajor:(unsigned int *)major
                        minor:(unsigned int *)minor
                       bugFix:(unsigned int *)bugFix;
{
    OSErr err;
    SInt32 systemVersion, versionMajor, versionMinor, versionBugFix;
    if ((err = Gestalt(gestaltSystemVersion, &systemVersion)) != noErr) goto fail;
    if (systemVersion < 0x1040)
    {
        if (major) *major = ((systemVersion & 0xF000) >> 12) * 10 +
            ((systemVersion & 0x0F00) >> 8);
        if (minor) *minor = (systemVersion & 0x00F0) >> 4;
        if (bugFix) *bugFix = (systemVersion & 0x000F);
    }
    else
    {
        if ((err = Gestalt(gestaltSystemVersionMajor, &versionMajor)) != noErr) goto fail;
        if ((err = Gestalt(gestaltSystemVersionMinor, &versionMinor)) != noErr) goto fail;
        if ((err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix)) != noErr) goto fail;
        if (major) *major = versionMajor;
        if (minor) *minor = versionMinor;
        if (bugFix) *bugFix = versionBugFix;
    }
    
    return;
    
fail:
    NSLog(@"Unable to obtain system version: %ld", (long)err);
    if (major) *major = 10;
    if (minor) *minor = 0;
    if (bugFix) *bugFix = 0;
}

@end
