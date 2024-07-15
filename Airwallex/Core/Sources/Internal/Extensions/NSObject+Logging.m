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
}
@end
