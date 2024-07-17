//
//  NSObject+Logging.m
//  Core
//
//  Created by Tony He (CTR) on 2024/7/9.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "NSObject+Logging.h"

@implementation NSObject (Logging)

- (void)log:(NSString *)format, ... {
    if (![Airwallex analyticsEnabled]) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *formattedMessage = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";

    NSString *className = NSStringFromClass([self class]);

    NSLog(@"----Airwallex SDK----%@----%@----\n %@", [formatter stringFromDate:now], className, formattedMessage);

    if ([Airwallex isLocalLogFileEnabled]) {
        NSString *log = [NSString stringWithFormat:@"----Airwallex SDK----%@----%@----\n %@\n", [formatter stringFromDate:now], className, formattedMessage];
        [self logIntoLocalFile:log];
    }
}

- (void)logIntoLocalFile:(NSString *)log {
    NSString *logDateKey = @"AirwallexSDK_last_log_date";

    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSURL *documentsUrl = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *logFileUrl = [documentsUrl URLByAppendingPathComponent:@"AirwallexSDK.log"];

    NSData *data = [log dataUsingEncoding:NSUTF8StringEncoding];

    NSDate *now = [NSDate date];
    NSTimeInterval todayDate = [now timeIntervalSince1970];
    NSTimeInterval lastDate = [NSUserDefaults.standardUserDefaults doubleForKey:logDateKey];

    if ([fileManager fileExistsAtPath:[logFileUrl path]] && todayDate - lastDate < 60 * 60 * 24 * 7) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:[logFileUrl path]];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
    } else {
        NSError *error;
        [fileManager removeItemAtURL:logFileUrl error:&error];
        [data writeToURL:logFileUrl atomically:YES];
        if (!error) {
            [NSUserDefaults.standardUserDefaults setDouble:todayDate forKey:logDateKey];
        }
    }
}

@end
