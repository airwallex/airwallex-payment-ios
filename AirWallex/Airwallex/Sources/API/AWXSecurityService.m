//
//  AWXSecurityService.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXSecurityService.h"
#import "AWXConstants.h"
#import <RLTMXProfiling/TMXProfiling.h>
#import <RLTMXProfilingConnections/TMXProfilingConnections.h>

@interface AWXSecurityService ()

@property (nonatomic, strong) RLTMXProfiling *profiling;

@end

@implementation AWXSecurityService

+ (instancetype)sharedService
{
    static AWXSecurityService *sharedService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [self new];
    });
    return sharedService;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.profiling = [RLTMXProfiling sharedInstance];
        RLTMXProfilingConnections *profilingConnections = [RLTMXProfilingConnections new];
        profilingConnections.connectionTimeout = 20;
        profilingConnections.connectionRetryCount = 2;
        [self.profiling configure:@{
            RLTMXOrgID: AWXCyberSourceOrganizationID,
            RLTMXProfileTimeout: @20,
            RLTMXProfilingConnectionsInstance: profilingConnections,
        }];
    }
    return self;
}

- (void)doProfile:(NSString *)intentId
       completion:(void(^)(NSString * _Nullable))completion
{
#if TARGET_OS_SIMULATOR
    completion([UIDevice currentDevice].identifierForVendor.UUIDString);
#else
    NSString *fraudSessionId = [NSString stringWithFormat:@"%@%f", intentId, [[NSDate date] timeIntervalSince1970]];
    NSString *sessionId = [NSString stringWithFormat:@"%@%@", AWXCyberSourceMerchantID, fraudSessionId];
    [self.profiling profileDeviceUsing:@{@"session_id": sessionId} callbackBlock:^(NSDictionary *result) {
        NSString *sessionId = result[RLTMXSessionID];
        completion(sessionId ?: @"");
    }];
#endif
}

@end
