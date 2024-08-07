//
//  NSObject+Logging.m
//  Core
//
//  Created by Tony He (CTR) on 2024/7/9.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "NSObject+Logging.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@implementation NSObject (Logging)

- (void)log:(NSString *)format, ... {
    if (![Airwallex analyticsEnabled]) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *formattedMessage = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    [self logMessage:formattedMessage];
}

@end
