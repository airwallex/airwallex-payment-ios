//
//  AWXLogger.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXLogger.h"

@implementation AWXLogger

+ (instancetype)sharedLogger {
    static AWXLogger *sharedLogger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogger = [self new];
    });
    return sharedLogger;
}

- (void)logException:(NSString *)message {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:message
                                 userInfo:nil];
}

- (void)logEvent:(NSString *)name {
    [self logEvent:name parameters:@{}];
}

- (void)logEvent:(NSString *)name parameters:(NSDictionary *)parameters {
    if (self.enableLogPrinted) {
        NSLog(@"[%@]:\n%@", name, parameters.description);
    }
}

@end
