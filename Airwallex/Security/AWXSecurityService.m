//
//  AWXSecurityService.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXSecurityService.h"
#import "AWXConstants.h"
#import "NSObject+logging.h"
#import <RLTMXProfiling/TMXProfiling.h>
#import <RLTMXProfilingConnections/TMXProfilingConnections.h>

@interface AWXSecurityService ()

@property (nonatomic, strong) RLTMXProfiling *profiling;

@end

@implementation AWXSecurityService

+ (instancetype)sharedService {
    static AWXSecurityService *sharedService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [self new];
    });
    return sharedService;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.profiling = [RLTMXProfiling sharedInstance];
        RLTMXProfilingConnections *profilingConnections = [RLTMXProfilingConnections new];
        profilingConnections.connectionTimeout = 20;
        profilingConnections.connectionRetryCount = 2;
        [self.profiling configure:@{
            RLTMXOrgID: AWXThreatMatrixOrganizationID,
            RLTMXFingerprintServer: AWXThreatMatrixFingerprintServer,
            RLTMXProfileTimeout: @20,
            RLTMXProfilingConnectionsInstance: profilingConnections,
        }];
    }
    return self;
}

- (void)doProfile:(NSString *)sessionId
       completion:(void (^)(NSString *_Nullable))completion {
#if TARGET_OS_SIMULATOR
    completion(sessionId);
#else
    [self.profiling profileDeviceUsing:@{RLTMXSessionID: sessionId}
                         callbackBlock:^(NSDictionary *result) {
                             RLTMXStatusCode statusCode = [[result valueForKey:RLTMXProfileStatus] integerValue];
                             NSString *signifydSessionID = result[RLTMXSessionID];
                             [self log:@"Session id: %@, Session status: %lu", signifydSessionID, statusCode];
                         }];
    completion(sessionId);
#endif
}

@end
