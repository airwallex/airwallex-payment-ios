//
//  AWXSecurityService.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXSecurityService.h"
#import "AWXConstants.h"
#import <TrustDefender/TrustDefender.h>

@interface AWXSecurityService ()

@property (nonatomic, strong) THMTrustDefender *defender;

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
        self.defender = [THMTrustDefender sharedInstance];
        [self.defender configure:@{
            THMOrgID: AWXCyberSourceOrganizationID
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
    [self.defender doProfileRequestWithOptions:@{@"session_id": sessionId}
                              andCallbackBlock:^(NSDictionary *result) {
        NSString *sessionId = result[THMSessionID];
        completion(sessionId ?: @"");
    }];
#endif
}

@end
